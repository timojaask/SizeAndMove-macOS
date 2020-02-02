import Cocoa

class SizeAndMoveController {
    
    private var targetWindow: TargetWindow?
    private var mouseMovedEventMonitor: EventMonitor?
    
    init() {
        mouseMovedEventMonitor = EventMonitor.mouseMovedMonitor { [weak self] event in
            guard let strongSelf = self else { return }
            guard let nsEvent = event else { return }
            strongSelf.handleEvent(event: SizeAndMoveEvent.of(nsEvent))
        }
        mouseMovedEventMonitor?.start()
    }
    
    private func handleEvent(event: SizeAndMoveEvent) {
        let mousePosition = CocoaHelper.getMousePosition()
        if self.targetWindow == nil {
            self.targetWindow = createTargetWindowState(mousePosition: mousePosition)
        }
        guard let targetWindow = self.targetWindow else { return }
        switch event {
        case .Other:
            clearTargetWindowState()
            return
        case .MoveEvent:
            handleMoveEvent(mousePosition: mousePosition, targetWindow: targetWindow)
        case .SizeEvent:
            handleSizeEvent(mousePosition: mousePosition, targetWindow: targetWindow)
        }
    }
    
    private func clearTargetWindowState() {
        self.targetWindow = nil
    }
    
    private func createTargetWindowState(mousePosition: NSPoint) -> TargetWindow? {
        guard let window = CocoaHelper.getWindowAt(point: mousePosition) else { return nil }
        guard let windowFrame = CocoaHelper.getWindowFrame(window: window) else { return nil }
        
        return TargetWindow(
            initialFrame: windowFrame,
            initialMousePosition: mousePosition,
            element: window
        )
    }
    
    private func handleMoveEvent(mousePosition: NSPoint, targetWindow: TargetWindow) {
        let newPosition = calculateNewWindowPosition(mousePosition: mousePosition, targetWindow: targetWindow)
        CocoaHelper.setWindowPosition(element: targetWindow.element, value: newPosition)
    }
    
    private func handleSizeEvent(mousePosition: NSPoint, targetWindow: TargetWindow) {
        let newSize = calculateNewWindowSize(mousePosition: mousePosition, targetWindow: targetWindow)
        CocoaHelper.setWindowSize(element: targetWindow.element, value: newSize)
    }
}

private struct TargetWindow {
    var initialFrame: CGRect
    var initialMousePosition: NSPoint
    var element: AXUIElement
}

private enum SizeAndMoveEvent {
    case SizeEvent
    case MoveEvent
    case Other
    
    static func of(_ event: NSEvent) -> SizeAndMoveEvent {
        if isMoveEvent(event: event) {
            return SizeAndMoveEvent.MoveEvent
        } else if isResizeEvent(event: event) {
            return SizeAndMoveEvent.SizeEvent
        } else {
            return SizeAndMoveEvent.Other
        }
    }
    
    private static let allModifierFlags = NSEvent.ModifierFlags([.shift, .control, .option, .command])

    private static func isMoveEvent(event: NSEvent) -> Bool {
        let moveKeys = Settings.load().moveKeys
        return modifiersAreExactly(modifiers: moveKeys, event: event)
    }

    private static func isResizeEvent(event: NSEvent) -> Bool {
        let resizeKeys = Settings.load().resizeKeys
        return modifiersAreExactly(modifiers: resizeKeys, event: event)
    }
    
    private static func modifiersAreExactly(modifiers: NSEvent.ModifierFlags, event: NSEvent) -> Bool {
        let otherFlags = allModifierFlags.subtracting(modifiers)
        return event.modifierFlags.isSuperset(of: modifiers) && event.modifierFlags.isDisjoint(with: otherFlags)
    }
}

private func calculateNewWindowPosition(mousePosition: NSPoint, targetWindow: TargetWindow) -> NSPoint {
    let mouseOffset = NSPoint(
        x: mousePosition.x - targetWindow.initialMousePosition.x,
        y: mousePosition.y - targetWindow.initialMousePosition.y
    )
    return NSPoint(
        x: targetWindow.initialFrame.minX + mouseOffset.x,
        y: targetWindow.initialFrame.minY + mouseOffset.y
    )
}

private func calculateNewWindowSize(mousePosition: NSPoint, targetWindow: TargetWindow) -> NSSize {
    let mouseOffset = NSPoint(
        x: mousePosition.x - targetWindow.initialMousePosition.x,
        y: mousePosition.y - targetWindow.initialMousePosition.y
    )
    return NSSize(
        width: targetWindow.initialFrame.width + mouseOffset.x,
        height: targetWindow.initialFrame.height + mouseOffset.y
    )
}
