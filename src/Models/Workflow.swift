import Foundation
import SwiftData

@Model
final class Workflow {
    var id: UUID
    var name: String
    var modeId: UUID?
    var windowPositionsData: Data?
    var runningAppBundleIds: [String]
    var createdAt: Date
    
    var windowPositions: [WindowPosition] {
        get {
            guard let data = windowPositionsData else { return [] }
            return (try? JSONDecoder().decode([WindowPosition].self, from: data)) ?? []
        }
        set {
            windowPositionsData = try? JSONEncoder().encode(newValue)
        }
    }
    
    init(name: String, modeId: UUID? = nil, windowPositions: [WindowPosition] = [], runningAppBundleIds: [String] = []) {
        self.id = UUID()
        self.name = name
        self.modeId = modeId
        self.windowPositionsData = try? JSONEncoder().encode(windowPositions)
        self.runningAppBundleIds = runningAppBundleIds
        self.createdAt = Date()
    }
}

struct WindowPosition: Codable {
    let appName: String
    let windowTitle: String
    let x: Double
    let y: Double
    let width: Double
    let height: Double
    let isMinimized: Bool
    let isFullscreen: Bool
}
