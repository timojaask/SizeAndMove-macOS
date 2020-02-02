import AppKit
import Foundation

struct AccessibilityHelper {
    static func openAccessibilityPreferences() {
        let openAccessibilityPreferncesScript = """
            tell application \"System Preferences\"
            reveal anchor \"Privacy_Accessibility\" of pane id \"com.apple.preference.security\"
            activate
            end tell
            """
        
        NSAppleScript(source: openAccessibilityPreferncesScript)?.executeAndReturnError(nil)
    }
    
    static func checkAccess() -> Bool {
        let key: String = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: false]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
}
