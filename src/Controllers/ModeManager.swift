import Foundation
import SwiftData

@MainActor
class ModeManager: ObservableObject {
    @Published var modes: [Mode] = []
    @Published var currentMode: Mode?
    
    private var modelContext: ModelContext?
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadModes()
    }
    
    func loadModes() {
        guard let context = modelContext else {
            // If no context, load defaults
            modes = Mode.defaultModes()
            currentMode = modes.first
            return
        }
        
        do {
            let descriptor = FetchDescriptor<Mode>(sortBy: [SortDescriptor(\.createdAt)])
            modes = try context.fetch(descriptor)
            
            if modes.isEmpty {
                // Create default modes
                modes = Mode.defaultModes()
                for mode in modes {
                    context.insert(mode)
                }
                try context.save()
            }
            
            // Set first mode as current
            currentMode = modes.first
        } catch {
            print("Failed to load modes: \(error)")
            modes = Mode.defaultModes()
            currentMode = modes.first
        }
    }
    
    func createMode(name: String, icon: String = "circle.grid.2x2") -> Mode {
        let mode = Mode(name: name, icon: icon)
        modes.append(mode)
        modelContext?.insert(mode)
        save()
        return mode
    }
    
    func deleteMode(_ mode: Mode) {
        modes.removeAll { $0.id == mode.id }
        modelContext?.delete(mode)
        save()
        
        if currentMode?.id == mode.id {
            currentMode = modes.first
        }
    }
    
    func switchTo(_ mode: Mode) {
        currentMode = mode
        mode.updatedAt = Date()
        save()
    }
    
    func updateMode(_ mode: Mode, name: String? = nil, icon: String? = nil, visibleItemIds: [String]? = nil) {
        if let name = name { mode.name = name }
        if let icon = icon { mode.icon = icon }
        if let visibleItemIds = visibleItemIds { mode.visibleItemIds = visibleItemIds }
        mode.updatedAt = Date()
        save()
    }
    
    private func save() {
        do {
            try modelContext?.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }
    
    func assignShortcut(_ mode: Mode, shortcut: String) {
        mode.keyboardShortcut = shortcut
        save()
    }
}
