import Cocoa

class AccessibilityInstructionsPage4ViewController: NSViewController {
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        progressIndicator.startAnimation(nil)
    }
}
