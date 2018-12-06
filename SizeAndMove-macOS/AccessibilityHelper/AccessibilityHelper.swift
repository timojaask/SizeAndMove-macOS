import AppKit
import Foundation

struct AccessibilityHelper {
    
    static func openAccessibilityPreferences() {
        let macOS10version = ProcessInfo.processInfo.operatingSystemVersion.minorVersion
        
        let script = macOS10version < 9
            ? "tell application \"System Preferences\" \n set the current pane to pane id \"com.apple.preference.universalaccess\" \n activate \n end tell"
            : "tell application \"System Preferences\" \n reveal anchor \"Privacy_Accessibility\" of pane id \"com.apple.preference.security\" \n activate \n end tell"
        
        NSAppleScript(source: script)?.executeAndReturnError(nil)
    }
    
    static func checkAccess() -> Bool {
        let key: String = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}
