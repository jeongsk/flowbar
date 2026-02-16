import Foundation
import SwiftData

@Model
final class Mode {
    var id: UUID
    var name: String
    var icon: String
    var keyboardShortcut: String?
    var visibleItemIds: [String]
    var launchAppBundleIds: [String]
    var focusGuardEnabled: Bool
    var blockedAppBundleIds: [String]
    var createdAt: Date
    var updatedAt: Date
    
    init(
        name: String,
        icon: String = "circle.grid.2x2",
        keyboardShortcut: String? = nil,
        visibleItemIds: [String] = [],
        launchAppBundleIds: [String] = [],
        focusGuardEnabled: Bool = false,
        blockedAppBundleIds: [String] = []
    ) {
        self.id = UUID()
        self.name = name
        self.icon = icon
        self.keyboardShortcut = keyboardShortcut
        self.visibleItemIds = visibleItemIds
        self.launchAppBundleIds = launchAppBundleIds
        self.focusGuardEnabled = focusGuardEnabled
        self.blockedAppBundleIds = blockedAppBundleIds
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    static func defaultModes() -> [Mode] {
        let codingMode = Mode(
            name: "Coding",
            icon: "chevron.left.forwardslash.chevron.right",
            keyboardShortcut: "1",
            focusGuardEnabled: true
        )
        
        let designMode = Mode(
            name: "Design",
            icon: "paintbrush.pointed",
            keyboardShortcut: "2",
            focusGuardEnabled: true
        )
        
        let meetingMode = Mode(
            name: "Meeting",
            icon: "video",
            keyboardShortcut: "3",
            focusGuardEnabled: false
        )
        
        let focusMode = Mode(
            name: "Focus",
            icon: "brain.head.profile",
            keyboardShortcut: "4",
            focusGuardEnabled: true
        )
        
        return [codingMode, designMode, meetingMode, focusMode]
    }
}
