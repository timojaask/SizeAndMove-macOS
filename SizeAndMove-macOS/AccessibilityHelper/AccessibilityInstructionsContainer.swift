import Cocoa

class AccessibilityInstructionsContainer: NSTabViewController {
    
    var checkAccessTimer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCallbacks()
        self.tabStyle = .unspecified
        checkAccessTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: true)
    }
    
    @objc func timerTick() {
        let hasAccess = AccessibilityHelper.checkAccess()
        guard hasAccess else { return }
        checkAccessTimer?.invalidate()
        checkAccessTimer = nil
        selectedTabViewItemIndex = 4
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func setupCallbacks() {
        guard let page1VC = tabViewItems[0].viewController as? AccessibilityInstructionsPage1ViewController else {
            fatalError("Page 1 is not the first page in tabViewController")
        }
        guard let page2VC = tabViewItems[1].viewController as? AccessibilityInstructionsPage2ViewController else {
            fatalError("Page 2 is not the first page in tabViewController")
        }
        guard let page3VC = tabViewItems[2].viewController as? AccessibilityInstructionsPage3ViewController else {
            fatalError("Page 3 is not the first page in tabViewController")
        }
        guard let page5VC = tabViewItems[4].viewController as? AccessibilityInstructionsPage5ViewController else {
            fatalError("Page 5 is not the first page in tabViewController")
        }
        page1VC.openAccessibilityPreferncesButtonClicked = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.selectedTabViewItemIndex = strongSelf.selectedTabViewItemIndex + 1
            // Opening system preferences essentially blocks the entire app and takes a couple of seconds
            // this is why I'm running it after a slight delay, so that the tab view would be able to
            // change to the next tab and user would get some sort of feedback.
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                AccessibilityHelper.openAccessibilityPreferences()
            }
        }
        page2VC.nextButtonClicked = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.selectedTabViewItemIndex = strongSelf.selectedTabViewItemIndex + 1
        }
        page3VC.nextButtonClicked = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.selectedTabViewItemIndex = strongSelf.selectedTabViewItemIndex + 1
        }
        page5VC.doneButtonClicked = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.view.window?.close()
        }
    }
}
