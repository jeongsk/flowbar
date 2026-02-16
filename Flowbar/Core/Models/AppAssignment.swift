import Foundation
import SwiftData

@Model
final class AppAssignment {
    var bundleIdentifier: String
    var appName: String
    var mode: Mode?
    var isRecent: Bool
    var lastUsed: Date?

    init(bundleIdentifier: String, appName: String, isRecent: Bool = false) {
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.isRecent = isRecent
        self.lastUsed = nil
    }

    func markAsUsed() {
        self.lastUsed = Date()
        self.isRecent = true
    }
}
