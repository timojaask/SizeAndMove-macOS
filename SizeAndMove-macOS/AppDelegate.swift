import Cocoa

let allModifierFlags = NSEvent.ModifierFlags([.shift, .control, .option, .command])

func isMoveEvent(event: NSEvent) -> Bool {
    let moveFlags = NSEvent.ModifierFlags([.command, .shift])
    let otherFlags = allModifierFlags.subtracting(moveFlags)
    return event.modifierFlags.isSuperset(of: moveFlags) && event.modifierFlags.isDisjoint(with: otherFlags)
}

func calculateNewWindowPosition(mousePosition: NSPoint, trackingState: TrackingState) -> NSPoint {
    let mouseOffset = NSPoint(
        x: mousePosition.x - trackingState.startMousePosition.x,
        y: mousePosition.y - trackingState.startMousePosition.y
    )
    return NSPoint(
        x: trackingState.startWindowPosition.x + mouseOffset.x,
        y: trackingState.startWindowPosition.y + mouseOffset.y
    )
}

struct TrackingState {
    var startWindowPosition: NSPoint
    var startMousePosition: NSPoint
    var trackedWindow: AXUIElement
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
        guard let windowPosition = CocoaHelper.getWindowPosition(window: window) else { return nil }
        return TrackingState(
            startWindowPosition: windowPosition,
            startMousePosition: mousePosition,
            trackedWindow: window
        )
    }
    
    func stopTracking() {
        self.trackingState = nil
    }
    
    func handleMouseMove(event: NSEvent) {
        guard isMoveEvent(event: event) else {
            stopTracking()
            return
        }
        
        let mousePosition = CocoaHelper.getMousePosition()
        
        guard let trackingState = self.trackingState else {
            self.trackingState = createTrackingState(mousePosition: mousePosition)
            return
        }
        
        let newWindowPosition = calculateNewWindowPosition(mousePosition: mousePosition, trackingState: trackingState)
        
        CocoaHelper.setWindowPosition(element: trackingState.trackedWindow, attribute: NSAccessibility.Attribute.position, value: newWindowPosition)
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

