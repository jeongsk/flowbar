import Foundation
import SwiftData

// MARK: - Data Controller
@MainActor
final class DataController {
    static let shared = DataController()

    let modelContainer: ModelContainer
    let modelContext: ModelContext

    private init() {
        let schema = Schema([
            Mode.self,
            IconAssignment.self,
            Preference.self,
            OnboardingState.self,
            AppAssignment.self,
            DNDApp.self
        ])

        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            modelContext = modelContainer.mainContext
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    // MARK: - Save
    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }

    // MARK: - Backup/Restore
    func backupData() -> URL? {
        let dateFormatter = ISO8601DateFormatter()
        let timestamp = dateFormatter.string(from: Date())

        let fileName = "Flowbar_Backup_\(timestamp).json"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupURL = documentsPath.appendingPathComponent(fileName)

        do {
            // Fetch all data
            let modes = try modelContext.fetch(FetchDescriptor<Mode>())
            let preferences = try modelContext.fetch(FetchDescriptor<Preference>())
            let onboardingState = try modelContext.fetch(FetchDescriptor<OnboardingState>())

            // Create backup dictionary using Codable
            let backup = BackupData(
                version: AppConstants.version,
                timestamp: timestamp,
                modes: modes.map { ModeBackup(from: $0) },
                preferences: preferences.map { PreferenceBackup(from: $0) },
                onboardingState: onboardingState.map { OnboardingStateBackup(from: $0) }
            )

            let data = try JSONEncoder().encode(backup)
            try data.write(to: backupURL)

            print("Backup created at: \(backupURL.path)")
            return backupURL
        } catch {
            print("Failed to create backup: \(error)")
            return nil
        }
    }

    func restoreData(from url: URL) -> Bool {
        do {
            let data = try Data(contentsOf: url)
            let backup = try JSONDecoder().decode(BackupData.self, from: data)

            // Clear existing data
            clearAllData()

            // Restore data
            for modeBackup in backup.modes {
                let mode = Mode(
                    name: modeBackup.name,
                    icon: modeBackup.icon,
                    isDefault: modeBackup.isDefault,
                    order: modeBackup.order,
                    shortcut: modeBackup.shortcut
                )
                modelContext.insert(mode)
            }

            for prefBackup in backup.preferences {
                let preference = Preference(
                    focusGuardEnabled: prefBackup.focusGuardEnabled,
                    notificationAutoHideEnabled: prefBackup.notificationAutoHideEnabled,
                    notificationAutoHideDuration: prefBackup.notificationAutoHideDuration,
                    launcherShortcut: prefBackup.launcherShortcut,
                    modeSwitchShortcut: prefBackup.modeSwitchShortcut,
                    theme: prefBackup.theme,
                    language: prefBackup.language
                )
                modelContext.insert(preference)
            }

            for stateBackup in backup.onboardingState {
                let state = OnboardingState(
                    isComplete: stateBackup.isComplete,
                    lastStep: stateBackup.lastStep
                )
                state.completedDate = stateBackup.completedDate
                modelContext.insert(state)
            }

            try modelContext.save()
            print("Data restored from: \(url.path)")
            return true
        } catch {
            print("Failed to restore backup: \(error)")
            return false
        }
    }

    private func clearAllData() {
        do {
            try modelContext.delete(model: Mode.self)
            try modelContext.delete(model: IconAssignment.self)
            try modelContext.delete(model: Preference.self)
            try modelContext.delete(model: OnboardingState.self)
            try modelContext.delete(model: AppAssignment.self)
            try modelContext.delete(model: DNDApp.self)
        } catch {
            print("Failed to clear data: \(error)")
        }
    }

    func createAutomaticBackupIfNeeded() -> URL? {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let backupsPath = documentsPath.appendingPathComponent("Flowbar/Backups")

        try? FileManager.default.createDirectory(at: backupsPath, withIntermediateDirectories: true)

        guard let backupFiles = try? FileManager.default.contentsOfDirectory(
            at: backupsPath,
            includingPropertiesForKeys: [.creationDateKey],
            options: .skipsHiddenFiles
        ) else {
            return nil
        }

        var sortedBackups = backupFiles.sorted { file1, file2 in
            let date1 = (try? file1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
            let date2 = (try? file2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
            return date1 > date2
        }

        while sortedBackups.count > 5 {
            if let oldBackup = sortedBackups.popLast() {
                try? FileManager.default.removeItem(at: oldBackup)
            }
        }

        let backupURL = backupData()
        if let backup = backupURL {
            let destination = backupsPath.appendingPathComponent(backup.lastPathComponent)
            try? FileManager.default.moveItem(at: backup, to: destination)
            return destination
        }

        return nil
    }
}

// MARK: - Backup Data Structures
struct BackupData: Codable {
    let version: String
    let timestamp: String
    let modes: [ModeBackup]
    let preferences: [PreferenceBackup]
    let onboardingState: [OnboardingStateBackup]
}

struct ModeBackup: Codable {
    let name: String
    let icon: String?
    let isDefault: Bool
    let order: Int
    let shortcut: String?

    init(from mode: Mode) {
        self.name = mode.name
        self.icon = mode.icon
        self.isDefault = mode.isDefault
        self.order = mode.order
        self.shortcut = mode.shortcut
    }
}

struct PreferenceBackup: Codable {
    let focusGuardEnabled: Bool
    let notificationAutoHideEnabled: Bool
    let notificationAutoHideDuration: TimeInterval
    let launcherShortcut: String
    let modeSwitchShortcut: String
    let theme: String
    let language: String

    init(from preference: Preference) {
        self.focusGuardEnabled = preference.focusGuardEnabled
        self.notificationAutoHideEnabled = preference.notificationAutoHideEnabled
        self.notificationAutoHideDuration = preference.notificationAutoHideDuration
        self.launcherShortcut = preference.launcherShortcut
        self.modeSwitchShortcut = preference.modeSwitchShortcut
        self.theme = preference.theme
        self.language = preference.language
    }
}

struct OnboardingStateBackup: Codable {
    let isComplete: Bool
    let lastStep: String
    let completedDate: Date?

    init(from state: OnboardingState) {
        self.isComplete = state.isComplete
        self.lastStep = state.lastStep
        self.completedDate = state.completedDate
    }
}
