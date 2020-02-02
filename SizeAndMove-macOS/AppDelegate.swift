import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    private let sizeAndMoveController = SizeAndMoveController()
    private let statusBarItem = StatusBarItem()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let hasAccess = AccessibilityHelper.checkAccess()
        if !hasAccess {
            self.showAccessibilityInstructions()
        }
    }
    
    func showAccessibilityInstructions() {
        let instructionsWindow = NSStoryboard(name: "Main", bundle: nil).instantiateController(withIdentifier: "AccessibilityInstructionsWindow") as? AccessibilityInstructionsWindow
        instructionsWindow?.showWindow(self)
    }
}

