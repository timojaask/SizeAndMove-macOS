import Cocoa

class AccessibilityInstructionsPage3ViewController: NSViewController {
    
    var nextButtonClicked: (() -> ())? = nil
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        nextButtonClicked?()
    }
}
