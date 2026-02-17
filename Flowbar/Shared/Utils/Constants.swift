import Foundation

// MARK: - App Constants
enum AppConstants {
    static let bundleIdentifier = "com.flowbar.app"
    static let appName = "Flowbar"
    static let version = "1.0.0"

    enum Defaults {
        static let launcherShortcut = "Cmd+Space"
        static let modeSwitchShortcut = "Cmd+Shift+M"
        static let notificationAutoHideDuration: TimeInterval = 3.0
    }

    enum Modes {
        static let defaultModes = ["Coding", "Design", "Meeting", "Focus"]
    }

    enum Limits {
        static let maxRecentApps = 5
        static let maxCustomModes = 20
        static let minNotificationDuration: TimeInterval = 1.0
        static let maxNotificationDuration: TimeInterval = 10.0
    }
}

// MARK: - Error Types
enum FlowbarError: LocalizedError {
    case accessibilityPermissionDenied
    case modeNotFound
    case invalidConfiguration
    case backupFailed
    case restoreFailed

    var errorDescription: String? {
        switch self {
        case .accessibilityPermissionDenied:
            return "Accessibility permission is required for this feature."
        case .modeNotFound:
            return "The requested mode was not found."
        case .invalidConfiguration:
            return "Invalid configuration detected."
        case .backupFailed:
            return "Failed to create backup."
        case .restoreFailed:
            return "Failed to restore from backup."
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .accessibilityPermissionDenied:
            return "Please grant Accessibility permission in System Settings > Privacy & Security > Accessibility."
        default:
            return nil
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let accessibilityPermissionDidChange = Notification.Name("accessibilityPermissionDidChange")
    static let launcherShouldOpen = Notification.Name("launcherShouldOpen")
    static let onboardingDidComplete = Notification.Name("onboardingDidComplete")
}
