import Foundation
import SwiftData

@Model
final class Preference {
    var focusGuardEnabled: Bool
    var notificationAutoHideEnabled: Bool
    var notificationAutoHideDuration: TimeInterval
    var launcherShortcut: String
    var modeSwitchShortcut: String
    var theme: String
    var language: String

    init(focusGuardEnabled: Bool = false,
         notificationAutoHideEnabled: Bool = true,
         notificationAutoHideDuration: TimeInterval = 3.0,
         launcherShortcut: String = "Cmd+Space",
         modeSwitchShortcut: String = "Cmd+Shift+M",
         theme: String = "auto",
         language: String = "en") {
        self.focusGuardEnabled = focusGuardEnabled
        self.notificationAutoHideEnabled = notificationAutoHideEnabled
        self.notificationAutoHideDuration = notificationAutoHideDuration
        self.launcherShortcut = launcherShortcut
        self.modeSwitchShortcut = modeSwitchShortcut
        self.theme = theme
        self.language = language
    }
}
