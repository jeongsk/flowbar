import Foundation
import SwiftData

@Model
final class Mode {
    var name: String
    var icon: String?
    var isDefault: Bool
    var order: Int
    var iconAssignments: [IconAssignment]
    var shortcut: String?

    init(name: String, icon: String? = nil, isDefault: Bool = false, order: Int = 0, shortcut: String? = nil) {
        self.name = name
        self.icon = icon
        self.isDefault = isDefault
        self.order = order
        self.iconAssignments = []
        self.shortcut = shortcut
    }
}
