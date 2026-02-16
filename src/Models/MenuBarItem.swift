import Cocoa

struct MenuBarItem: Identifiable, Hashable {
    let id: String
    let bundleIdentifier: String?
    let title: String?
    let icon: NSImage?
    let position: Int
    let axElement: AXUIElement?
    
    var displayName: String {
        if let title = title, !title.isEmpty {
            return title
        }
        if let bundleId = bundleIdentifier {
            return bundleId.components(separatedBy: ".").last ?? bundleId
        }
        return "Unknown Item \(position)"
    }
    
    static func == (lhs: MenuBarItem, rhs: MenuBarItem) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
