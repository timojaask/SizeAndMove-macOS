import AppKit
import Foundation

struct AccessibilityHelper {
    static func askForAccessibilityIfNeeded() {
        let key: String = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: true]
        let enabled = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if enabled {
            return
        }
        
        let alert = NSAlert()
        alert.messageText = "Enable Accessibility First"
        alert.informativeText = "Find the popup right behind this one, click \"Open System Preferences\" and enable ModMove. Then launch ModMove again."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Quit")
        alert.runModal()
        NSApp.terminate(nil)
    }
    
    static func checkAccess() -> Bool{
        //get the value for accesibility
        let checkOptPrompt = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as NSString
        //set the options: false means it wont ask
        //true means it will popup and ask
        let options = [checkOptPrompt: true]
        //translate into boolean value
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary?)
        return accessEnabled
    }
    
    static func acquirePrivileges() -> Bool {
        let trusted = kAXTrustedCheckOptionPrompt.takeUnretainedValue()
        let privOptions = [trusted: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(privOptions as CFDictionary)
        return accessEnabled
    }
}
