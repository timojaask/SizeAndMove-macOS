import Cocoa

let defaultKeyBindings = KeyBindings(
    moveKeys: NSEvent.ModifierFlags([.shift, .command]),
    resizeKeys: NSEvent.ModifierFlags([.shift, .option])
)

extension NSEvent.ModifierFlags: Codable {}

struct KeyBindings: Codable {
    var moveKeys: NSEvent.ModifierFlags
    var resizeKeys: NSEvent.ModifierFlags
}

func setKey(key: NSEvent.ModifierFlags, inKeys: NSEvent.ModifierFlags, isOn: Bool) -> NSEvent.ModifierFlags {
    var newKeys = inKeys
    if isOn {
        newKeys.insert(key)
    } else {
        newKeys.remove(key)
    }
    return newKeys
}

struct Settings {
    
    static func save(keyBindings: KeyBindings) {
        guard let encoded = try? JSONEncoder().encode(keyBindings) else { return }
        UserDefaults.standard.set(encoded, forKey: "keyBindings")
    }
    
    static func load() -> KeyBindings {
        guard let data = UserDefaults.standard.object(forKey: "keyBindings") as? Data else { return defaultKeyBindings }
        return (try? JSONDecoder().decode(KeyBindings.self, from: data))
            ?? defaultKeyBindings
    }
}
