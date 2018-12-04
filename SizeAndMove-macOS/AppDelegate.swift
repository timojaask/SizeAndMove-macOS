import Cocoa

let allModifierFlags = NSEvent.ModifierFlags([.shift, .control, .option, .command])

func modifiersAreExactly(modifiers: NSEvent.ModifierFlags, event: NSEvent) -> Bool {
    let otherFlags = allModifierFlags.subtracting(modifiers)
    return event.modifierFlags.isSuperset(of: modifiers) && event.modifierFlags.isDisjoint(with: otherFlags)
}

func isMoveEvent(event: NSEvent) -> Bool {
    return modifiersAreExactly(modifiers: [.command, .shift], event: event)
}

func isResizeEvent(event: NSEvent) -> Bool {
    return modifiersAreExactly(modifiers: [.option, .shift], event: event)
}

func calculateNewWindowPosition(mousePosition: NSPoint, trackingState: TrackingState) -> NSPoint {
    let mouseOffset = NSPoint(
        x: mousePosition.x - trackingState.startMousePosition.x,
        y: mousePosition.y - trackingState.startMousePosition.y
    )
    return NSPoint(
        x: trackingState.startWindowFrame.minX + mouseOffset.x,
        y: trackingState.startWindowFrame.minY + mouseOffset.y
    )
}

func calculateNewWindowSize(mousePosition: NSPoint, trackingState: TrackingState) -> NSSize {
    let mouseOffset = NSPoint(
        x: mousePosition.x - trackingState.startMousePosition.x,
        y: mousePosition.y - trackingState.startMousePosition.y
    )
    return NSSize(
        width: trackingState.startWindowFrame.width + mouseOffset.x,
        height: trackingState.startWindowFrame.height + mouseOffset.y
    )
}

struct TrackingState {
    var startWindowFrame: CGRect
    var startMousePosition: NSPoint
    var window: AXUIElement
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    let popover = NSPopover()
    var clickEventMonitor: EventMonitor?
    var mouseMoveEventMonitor: EventMonitor?
    var trackingState: TrackingState?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        AccessibilityHelper.askForAccessibilityIfNeeded()
        
        // Configure status bar icon and popover
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("status-bar-icon"))
            button.action = #selector(togglePopover(_:))
        }
        popover.contentViewController = PopoverViewController.freshController()
        
        // Configure click event monitor for closing the popover
        clickEventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
        
        // Configure mouse move event monitor for moving and resizing the windows
        mouseMoveEventMonitor = EventMonitor(mask: [.mouseMoved]) { [weak self] event in
            guard let strongSelf = self else { return }
            guard let event = event else { return }
            strongSelf.handleMouseMove(event: event)
        }
        mouseMoveEventMonitor?.start()
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func createTrackingState(mousePosition: NSPoint) -> TrackingState? {
        guard let window = CocoaHelper.getWindowAt(point: mousePosition) else { return nil }
        guard let windowFrame = CocoaHelper.getWindowFrame(window: window) else { return nil }
        
        return TrackingState(
            startWindowFrame: windowFrame,
            startMousePosition: mousePosition,
            window: window
        )
    }
    
    func stopTracking() {
        self.trackingState = nil
    }
    
    func handleMouseMove(event: NSEvent) {
        guard isMoveEvent(event: event) || isResizeEvent(event: event) else {
            stopTracking()
            return
        }
        
        let mousePosition = CocoaHelper.getMousePosition()
        
        guard let trackingState = self.trackingState else {
            self.trackingState = createTrackingState(mousePosition: mousePosition)
            return
        }
        
        if isMoveEvent(event: event) {
            
            let newPosition = calculateNewWindowPosition(mousePosition: mousePosition, trackingState: trackingState)
            CocoaHelper.setWindowPosition(element: trackingState.window, value: newPosition)
            
        } else if isResizeEvent(event: event) {
            
            let newSize = calculateNewWindowSize(mousePosition: mousePosition, trackingState: trackingState)
            CocoaHelper.setWindowSize(element: trackingState.window, value: newSize)
            
        }
        
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            clickEventMonitor?.start()
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        clickEventMonitor?.stop()
    }
}

