import Foundation
import SwiftData

@Model
final class Preference {
    var focusGuardEnabled: Bool
    var notificationAutoHideEnabled: Bool
    var notificationAutoHideDuration: TimeInterval
    var launcherShortcut: String
    var modeSwitchShortcut: String
    var modeSwitcherShortcut: String
    var theme: String
    var language: String
    var appearanceMode: String
    var launchAtLogin: Bool
    var showMenuBarIcon: Bool
    var customShortcuts: [String: String]

    init(focusGuardEnabled: Bool = false,
         notificationAutoHideEnabled: Bool = true,
         notificationAutoHideDuration: TimeInterval = 3.0,
         launcherShortcut: String = "Cmd+Space",
         modeSwitchShortcut: String = "Cmd+Shift+M",
         modeSwitcherShortcut: String = "Cmd+Shift+M",
         theme: String = "auto",
         language: String = "en",
         appearanceMode: String = "system",
         launchAtLogin: Bool = false,
         showMenuBarIcon: Bool = true,
         customShortcuts: [String: String] = [:]) {
        self.focusGuardEnabled = focusGuardEnabled
        self.notificationAutoHideEnabled = notificationAutoHideEnabled
        self.notificationAutoHideDuration = notificationAutoHideDuration
        self.launcherShortcut = launcherShortcut
        self.modeSwitchShortcut = modeSwitchShortcut
        self.modeSwitcherShortcut = modeSwitcherShortcut
        self.theme = theme
        self.language = language
        self.appearanceMode = appearanceMode
        self.launchAtLogin = launchAtLogin
        self.showMenuBarIcon = showMenuBarIcon
        self.customShortcuts = customShortcuts
    }
}
