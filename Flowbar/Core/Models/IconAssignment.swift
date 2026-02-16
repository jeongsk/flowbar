import Foundation
import SwiftData

@Model
final class IconAssignment {
    var iconID: String
    var iconName: String
    var bundleIdentifier: String?
    var isVisible: Bool
    var position: Int?
    var mode: Mode?

    init(iconID: String, iconName: String, bundleIdentifier: String? = nil, isVisible: Bool = true, position: Int? = nil) {
        self.iconID = iconID
        self.iconName = iconName
        self.bundleIdentifier = bundleIdentifier
        self.isVisible = isVisible
        self.position = position
    }
}
