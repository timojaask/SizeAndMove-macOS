import Cocoa

class AccessibilityInstructionsPage1ViewController: NSViewController {
    
    var openAccessibilityPreferncesButtonClicked: (() -> ())? = nil
    
    @IBAction func openAccessibilityPreferencesButtonClicked(_ sender: Any) {
        openAccessibilityPreferncesButtonClicked?()
    }
}
