import Foundation
import SwiftData
import Cocoa
import Carbon
import SwiftUI

// MARK: - Mode Manager
@MainActor
final class ModeManager: ObservableObject {
    @Published var currentMode: Mode?
    @Published var allModes: [Mode] = []

    private let modelContext: ModelContext
    private var keyboardMonitor: Any?

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadModes()
        setupKeyboardShortcuts()
    }

    deinit {
        Task { @MainActor in
            removeKeyboardShortcuts()
        }
    }

    // MARK: - Mode CRUD
    func createDefaultModes() {
        let codingMode = Mode(
            name: "Coding",
            icon: "hammer",
            isDefault: true,
            order: 0
        )

        let designMode = Mode(
            name: "Design",
            icon: "paintbrush",
            isDefault: true,
            order: 1
        )

        let meetingMode = Mode(
            name: "Meeting",
            icon: "video",
            isDefault: true,
            order: 2
        )

        let focusMode = Mode(
            name: "Focus",
            icon: "moon.zzz",
            isDefault: true,
            order: 3
        )

        modelContext.insert(codingMode)
        modelContext.insert(designMode)
        modelContext.insert(meetingMode)
        modelContext.insert(focusMode)

        try? modelContext.save()
        loadModes()
    }

    func loadModes() {
        let descriptor = FetchDescriptor<Mode>(sortBy: [SortDescriptor(\.order)])
        do {
            allModes = try modelContext.fetch(descriptor)
            if currentMode == nil, let firstMode = allModes.first {
                currentMode = firstMode
            }
        } catch {
            print("Failed to load modes: \(error)")
        }
    }

    func createMode(name: String, icon: String?, iconAssignments: [IconAssignment] = []) {
        guard allModes.count < AppConstants.Limits.maxCustomModes else {
            print("Maximum number of custom modes reached")
            return
        }

        let newMode = Mode(
            name: name,
            icon: icon,
            isDefault: false,
            order: allModes.count,
            iconAssignments: iconAssignments
        )
        modelContext.insert(newMode)
        try? modelContext.save()
        loadModes()
    }

    func updateMode(_ mode: Mode, name: String, icon: String?) {
        mode.name = name
        mode.icon = icon
        try? modelContext.save()
        loadModes()
    }

    func deleteMode(_ mode: Mode) {
        guard !mode.isDefault else {
            print("Cannot delete default modes")
            return
        }

        // If deleting current mode, switch to another
        if mode.id == currentMode?.id {
            if let nextMode = allModes.first(where: { $0.id != mode.id }) {
                switchToMode(nextMode)
            }
        }

        modelContext.delete(mode)
        try? modelContext.save()
        loadModes()
    }

    // MARK: - Mode Switching
    func switchToMode(_ mode: Mode) {
        guard let index = allModes.firstIndex(where: { $0.id == mode.id }) else {
            print("Mode not found")
            return
        }

        let previousMode = currentMode
        currentMode = allModes[index]

        // Update icon assignments based on mode
        updateIconVisibility(for: mode)

        // Update focus guard if needed
        updateFocusGuard(for: mode)

        postModeChangeNotification(mode, previous: previousMode)
    }

    private func updateIconVisibility(for mode: Mode) {
        // Notify MenuBarManager to update icon visibility
        NotificationCenter.default.post(
            name: .iconVisibilityShouldUpdate,
            object: nil,
            userInfo: ["mode": mode]
        )
    }

    private func updateFocusGuard(for mode: Mode) {
        // Enable focus guard for Focus mode
        let shouldEnable = (mode.name.lowercased() == "focus")

        NotificationCenter.default.post(
            name: .focusGuardShouldUpdate,
            object: nil,
            userInfo: ["enabled": shouldEnable]
        )
    }

    private func postModeChangeNotification(_ mode: Mode, previous: Mode?) {
        NotificationCenter.default.post(
            name: .modeDidChange,
            object: nil,
            userInfo: [
                "mode": mode,
                "previous": previous as Any
            ]
        )
    }

    // MARK: - Keyboard Shortcuts
    private func setupKeyboardShortcuts() {
        // Monitor for keyboard shortcuts
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            return self?.handleKeyEvent(event) ?? event
        }
    }

    private func removeKeyboardShortcuts() {
        keyboardMonitor = nil
    }

    private func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        let flags = event.modifierFlags
        let keyCode = event.keyCode

        // Check for Cmd+Shift+M (mode switcher)
        if flags.contains([.command, .shift]) && keyCode == 46 { // M key
            showModeSwitcher()
            return nil // Consume the event
        }

        // Check for Cmd+Shift+1-9 (direct mode switch)
        if flags.contains([.command, .shift]) && keyCode >= 18 && keyCode <= 26 {
            let modeIndex = Int(keyCode - 18) // Convert to 0-8 index
            if modeIndex < allModes.count {
                switchToMode(allModes[modeIndex])
                return nil // Consume the event
            }
        }

        return event // Don't consume
    }

    private func showModeSwitcher() {
        // TODO: Show mode switcher popup
        print("Show mode switcher popup")
        NotificationCenter.default.post(name: .modeSwitcherShouldShow, object: nil)
    }

    // MARK: - Current Mode Indicator
    var currentModeIndicator: String {
        guard let mode = currentMode else {
            return "?"
        }

        if let icon = mode.icon {
            return icon
        }

        return String(mode.name.prefix(1)).uppercased()
    }

    // MARK: - Mode Transition Animation
    func animateModeTransition(to mode: Mode, completion: @escaping () -> Void) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMode = mode
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion()
        }
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let modeDidChange = Notification.Name("modeDidChange")
    static let modeSwitcherShouldShow = Notification.Name("modeSwitcherShouldShow")
    static let iconVisibilityShouldUpdate = Notification.Name("iconVisibilityShouldUpdate")
    static let focusGuardShouldUpdate = Notification.Name("focusGuardShouldUpdate")
}
