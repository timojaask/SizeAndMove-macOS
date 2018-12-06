import Cocoa

class AccessibilityInstructionsPage2ViewController: NSViewController {
    
    var nextButtonClicked: (() -> ())? = nil
    
    @IBAction func nextButtonClicked(_ sender: Any) {
        nextButtonClicked?()
    }
}
