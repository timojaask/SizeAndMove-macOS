import Cocoa

class AccessibilityInstructionsPage5ViewController: NSViewController {
    
    var doneButtonClicked: (() -> ())? = nil
    
    @IBAction func doneButtonClicked(_ sender: Any) {
        doneButtonClicked?()
    }
}
