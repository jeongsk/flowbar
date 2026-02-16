import Foundation
import Carbon

// MARK: - Keyboard Shortcut
struct KeyboardShortcut: Codable, Hashable {
    let keyCode: UInt32
    let modifiers: UInt32

    var description: String {
        var parts: [String] = []

        if modifiers & cmdKey != 0 {
            parts.append("⌘")
        }
        if modifiers & optionKey != 0 {
            parts.append("⌥")
        }
        if modifiers & controlKey != 0 {
            parts.append("⌃")
        }
        if modifiers & shiftKey != 0 {
            parts.append("⇧")
        }

        // TODO: Map keyCode to character
        parts.append("Key")

        return parts.joined(separator: "+")
    }

    static let cmdKey: UInt32 = 0x10000000
    static let optionKey: UInt32 = 0x08000000
    static let controlKey: UInt32 = 0x04000000
    static let shiftKey: UInt32 = 0x02000000

    static func from(string: String) -> KeyboardShortcut? {
        // TODO: Parse string representation
        return nil
    }
}

// MARK: - Shortcut Recorder
final class ShortcutRecorder {
    var callback: ((KeyboardShortcut) -> Void)?

    func startMonitoring(shortcut: KeyboardShortcut) {
        // TODO: Implement global keyboard shortcut monitoring
        // This will use CGEvent tap or NSEvent monitoring
    }

    func stopMonitoring() {
        // TODO: Stop monitoring
    }
}
