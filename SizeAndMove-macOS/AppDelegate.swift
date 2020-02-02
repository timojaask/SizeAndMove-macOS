import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let popover = NSPopover()
    private var clickEventMonitor: EventMonitor?
    private var sizeAndMove = SizeAndMove()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let hasAccess = AccessibilityHelper.checkAccess()
        if !hasAccess {
            self.showAccessibilityInstructions()
        }
        
        // Configure status bar icon and popover
        if let button = statusItem.button {
            button.image = NSImage(named: NSImage.Name("status-bar-icon"))
            button.action = #selector(togglePopover(_:))
        }
        popover.contentViewController = PopoverViewController.instantiate()
        // Configure click event monitor for closing the popover
        clickEventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
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
    
    var instructionsWindow: AccessibilityInstructionsWindow!
    
    func showAccessibilityInstructions() {
        self.instructionsWindow = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "AccessibilityInstructionsWindow") as? AccessibilityInstructionsWindow
        self.instructionsWindow?.showWindow(self)
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

