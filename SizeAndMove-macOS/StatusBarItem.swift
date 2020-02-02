import Cocoa

class StatusBarItem {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let popover = NSPopover()
    private var mouseClickedEventMonitor: EventMonitor?
    
    init() {
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("status-bar-icon"))
            button.action = #selector(togglePopover)
            button.target = self
        }
        popover.contentViewController = PopoverViewController.instantiate()
        
        mouseClickedEventMonitor = EventMonitor.mouseClickedMonitor { [weak self] event in
            if let strongSelf = self, strongSelf.popover.isShown {
                strongSelf.closePopover(sender: event)
            }
        }
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if popover.isShown {
            closePopover(sender: sender)
        } else {
            showPopover(sender: sender)
        }
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
            mouseClickedEventMonitor?.start()
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        mouseClickedEventMonitor?.stop()
    }
}
