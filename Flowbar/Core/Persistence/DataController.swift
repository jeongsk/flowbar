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
            let modes: [Mode] = modelContext.fetch(FetchDescriptor())
            let preferences: [Preference] = modelContext.fetch(FetchDescriptor())
            let onboardingState: [OnboardingState] = modelContext.fetch(FetchDescriptor())

            // Create backup dictionary
            let backup: [String: Any] = [
                "version": AppConstants.version,
                "timestamp": timestamp,
                "modes": modes.map { $0.encode() },
                "preferences": preferences.map { $0.encode() },
                "onboardingState": onboardingState.map { $0.encode() }
            ]

            let data = try JSONSerialization.data(withJSONObject: backup, options: .prettyPrinted)
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
            let backup = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]

            guard let backup = backup else {
                print("Invalid backup format")
                return false
            }

            // Clear existing data
            clearAllData()

            // Restore data
            if let modesData = backup["modes"] as? [[String: Any]] {
                for modeData in modesData {
                    let mode = Mode(from: modeData)
                    modelContext.insert(mode)
                }
            }

            if let preferencesData = backup["preferences"] as? [[String: Any]] {
                for prefData in preferencesData {
                    let preference = Preference(from: prefData)
                    modelContext.insert(preference)
                }
            }

            if let onboardingStateData = backup["onboardingState"] as? [[String: Any]] {
                for stateData in onboardingStateData {
                    let state = OnboardingState(from: stateData)
                    modelContext.insert(state)
                }
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

        let sortedBackups = backupFiles.sorted { file1, file2 in
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

// MARK: - Model Encoding Extensions
extension Encodable {
    func encode() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self),
              let dict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
            return [:]
        }
        return dict
    }
}
