import Cocoa

class PopoverViewController: NSViewController {
    
    @IBOutlet weak var moveShift: NSButton!
    @IBOutlet weak var moveControl: NSButton!
    @IBOutlet weak var moveOption: NSButton!
    @IBOutlet weak var moveCommand: NSButton!
    
    @IBOutlet weak var resizeShift: NSButton!
    @IBOutlet weak var resizeControl: NSButton!
    @IBOutlet weak var resizeOption: NSButton!
    @IBOutlet weak var resizeCommand: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUiState()
    }
    
    private func setUiState() {
        let keyBindings = Settings.load()
        moveShift.state = keyBindings.moveKeys.contains(.shift) ? .on : .off
        moveControl.state = keyBindings.moveKeys.contains(.control) ? .on : .off
        moveOption.state = keyBindings.moveKeys.contains(.option) ? .on : .off
        moveCommand.state = keyBindings.moveKeys.contains(.command) ? .on : .off
        
        resizeShift.state = keyBindings.resizeKeys.contains(.shift) ? .on : .off
        resizeControl.state = keyBindings.resizeKeys.contains(.control) ? .on : .off
        resizeOption.state = keyBindings.resizeKeys.contains(.option) ? .on : .off
        resizeCommand.state = keyBindings.resizeKeys.contains(.command) ? .on : .off
    }
    
    private func setMoveKey(key: NSEvent.ModifierFlags, sourceButton: NSButton) {
        var keyBindings = Settings.load()
        keyBindings.moveKeys = setKey(
            key: key,
            inKeys: keyBindings.moveKeys,
            isOn: sourceButton.state.rawValue == 1)
        Settings.save(keyBindings: keyBindings)
    }
    
    private func setResizeKey(key: NSEvent.ModifierFlags, sourceButton: NSButton) {
        var keyBindings = Settings.load()
        keyBindings.resizeKeys = setKey(
            key: key,
            inKeys: keyBindings.resizeKeys,
            isOn: sourceButton.state.rawValue == 1)
        Settings.save(keyBindings: keyBindings)
    }
    
    @IBAction func moveShiftToggled(_ sender: NSButton) {
        setMoveKey(key: .shift, sourceButton: sender)
    }
    
    @IBAction func moveControlToggled(_ sender: NSButton) {
        setMoveKey(key: .control, sourceButton: sender)
    }
    
    @IBAction func moveOptionToggle(_ sender: NSButton) {
        setMoveKey(key: .option, sourceButton: sender)
    }
    
    @IBAction func moveCommandToggle(_ sender: NSButton) {
        setMoveKey(key: .command, sourceButton: sender)
    }
    
    @IBAction func resizeShiftToggled(_ sender: NSButton) {
        setResizeKey(key: .shift, sourceButton: sender)
    }
    
    @IBAction func resizeControlToggled(_ sender: NSButton) {
        setResizeKey(key: .control, sourceButton: sender)
    }
    
    @IBAction func resizeOptionToggle(_ sender: NSButton) {
        setResizeKey(key: .option, sourceButton: sender)
    }
    
    @IBAction func resizeCommandToggle(_ sender: NSButton) {
        setResizeKey(key: .command, sourceButton: sender)
    }
    
    @IBAction func quitButtonClicked(_ sender: Any) {
        NSApp.terminate(nil)
    }
    
}


extension PopoverViewController {
    static func instantiate() -> PopoverViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let identifier = NSStoryboard.SceneIdentifier("PopoverViewController")
        guard let viewController = storyboard.instantiateController(withIdentifier: identifier) as? PopoverViewController else {
            fatalError("Unable to get PopoverViewController")
        }
        return viewController
    }
}
