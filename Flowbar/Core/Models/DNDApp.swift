import Foundation
import SwiftData

@Model
final class DNDApp {
    var bundleIdentifier: String
    var appName: String
    var isEnabled: Bool

    init(bundleIdentifier: String, appName: String, isEnabled: Bool = true) {
        self.bundleIdentifier = bundleIdentifier
        self.appName = appName
        self.isEnabled = isEnabled
    }
}
