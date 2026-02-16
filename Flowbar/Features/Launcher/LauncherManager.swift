import Foundation
import Cocoa
import SwiftData

// MARK: - App Info
struct AppInfo: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleIdentifier: String
    let icon: NSImage?
    var isRecent: Bool = false
    var lastUsed: Date?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Launcher Manager
@MainActor
final class LauncherManager: ObservableObject {
    @Published var searchQuery: String = ""
    @Published var searchResults: [AppInfo] = []
    @Published var recentApps: [AppInfo] = []
    @Published var modeApps: [AppInfo] = []
    @Published var isLauncherVisible: Bool = false

    private let modelContext: ModelContext
    private var allInstalledApps: [AppInfo] = []
    private var launcherWindow: NSPanel?
    private var launcherShortcut: KeyPress?

    // Fuzzy matching configuration
    private let fuzzyMatchThreshold: Double = 0.6

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadInstalledApps()
        loadRecentApps()
        setupLauncherShortcut()
    }

    deinit {
        removeLauncherShortcut()
    }

    // MARK: - App Loading
    private func loadInstalledApps() {
        var apps: [AppInfo] = []

        // Get all applications from /Applications folder
        let applicationDirectories = [
            "/Applications",
            "/System/Applications",
            "~/Applications"
        ]

        for directoryPath in applicationDirectories {
            guard let directoryURL = URL(string: directoryPath)?.expandingTildeInPath else { continue }

            guard let enumerator = FileManager.default.enumerator(
                at: directoryURL,
                includingPropertiesForKeys: [.isApplicationKey, .localizedNameFileIdentifier, .fileTypeIdentifierKey],
                options: [.skipsHiddenFiles]
            ) else {
                continue
            }

            for case let fileURL as URL in enumerator {
                if fileURL.pathExtension == "app" {
                    if let appInfo = createAppInfo(from: fileURL) {
                        apps.append(appInfo)
                    }
                }
            }
        }

        allInstalledApps = apps.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    private func createAppInfo(from url: URL) -> AppInfo? {
        let bundle = Bundle(url: url)

        guard let bundleIdentifier = bundle?.bundleIdentifier,
              let appName = bundle?.infoDictionary?["CFBundleName"] as? String ??
                      bundle?.infoDictionary?["CFBundleDisplayName"] as? String else {
            return nil
        }

        let icon = bundle?.icon ?? NSImage(named: "Application")

        return AppInfo(
            id: bundleIdentifier,
            name: appName,
            bundleIdentifier: bundleIdentifier,
            icon: icon
        )
    }

    private func loadRecentApps() {
        let descriptor = FetchDescriptor<AppAssignment>(
            predicate: #Predicate { $0.isRecent },
            sortBy: [SortDescriptor(\.lastUsed, order: .reverse)]
        )

        do {
            let assignments = try modelContext.fetch(descriptor)

            // Limit to recent apps limit
            let recentAssignments = Array(assignments.prefix(AppConstants.Limits.maxRecentApps))

            recentApps = recentAssignments.compactMap { assignment in
                AppInfo(
                    id: assignment.bundleIdentifier,
                    name: assignment.appName,
                    bundleIdentifier: assignment.bundleIdentifier,
                    icon: getAppIcon(for: assignment.bundleIdentifier),
                    isRecent: true,
                    lastUsed: assignment.lastUsed
                )
            }
        } catch {
            print("Failed to load recent apps: \(error)")
        }
    }

    private func getAppIcon(for bundleIdentifier: String) -> NSImage? {
        if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
            return NSWorkspace.shared.icon(forFile: appURL.path)
        }
        return NSImage(named: "Application")
    }

    func loadModeApps(for mode: Mode) {
        modeApps = mode.iconAssignments.compactMap { assignment in
            guard let bundleID = assignment.bundleIdentifier else { return nil }

            return AppInfo(
                id: bundleID,
                name: assignment.iconName,
                bundleIdentifier: bundleID,
                icon: getAppIcon(for: bundleID)
            )
        }
    }

    // MARK: - Search
    func searchApps() {
        guard !searchQuery.isEmpty else {
            searchResults = recentApps // Show recent apps when query is empty
            return
        }

        let query = searchQuery.trimmingCharacters(in: .whitespaces)

        // If query starts with mode name, filter by mode
        if let mode = modeForQuery(query) {
            let modeName = mode.name.lowercased()
            let searchTerms = query.dropFirst(modeName.count + 1).trimmingCharacters(in: .whitespaces)

            if searchTerms.isEmpty {
                searchResults = modeApps
            } else {
                searchResults = modeApps.filter { app in
                    fuzzyMatch(query: String(searchTerms), target: app.name)
                }
            }
        } else {
            // Global search
            searchResults = allInstalledApps.filter { app in
                fuzzyMatch(query: query, target: app.name)
            }
        }

        // Sort by relevance
        searchResults.sort { app1, app2 in
            let score1 = fuzzyScore(query: query, target: app1.name)
            let score2 = fuzzyScore(query: query, target: app2.name)
            return score1 > score2
        }
    }

    private func modeForQuery(_ query: String) -> Mode? {
        // Check if query starts with a mode name
        let modelContext = DataController.shared.modelContext
        let descriptor = FetchDescriptor<Mode>()

        do {
            let modes = try modelContext.fetch(descriptor)
            return modes.first { mode in
                query.lowercased().starts(with: mode.name.lowercased() + " ")
            }
        } catch {
            return nil
        }
    }

    private func fuzzyMatch(query: String, target: String) -> Bool {
        return fuzzyScore(query: query, target: target) >= fuzzyMatchThreshold
    }

    private func fuzzyScore(query: String, target: String) -> Double {
        let queryLower = query.lowercased()
        let targetLower = target.lowercased()

        // Exact match
        if queryLower == targetLower {
            return 1.0
        }

        // Prefix match
        if targetLower.hasPrefix(queryLower) {
            return 0.9
        }

        // Contains match
        if targetLower.contains(queryLower) {
            return 0.7
        }

        // Fuzzy match (subsequence)
        var queryIndex = queryLower.startIndex
        var targetIndex = targetLower.startIndex
        var matches = 0

        while queryIndex < queryLower.endIndex && targetIndex < targetLower.endIndex {
            if queryLower[queryIndex] == targetLower[targetIndex] {
                matches += 1
                queryIndex = queryLower.index(after: queryIndex)
            }
            targetIndex = targetLower.index(after: targetIndex)
        }

        if queryIndex == queryLower.endIndex {
            let score = Double(matches) / Double(queryLower.count)
            return score * 0.5
        }

        return 0.0
    }

    // MARK: - App Launch
    func launchApp(_ app: AppInfo) {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: app.bundleIdentifier) else {
            print("Failed to find app: \(app.name)")
            return
        }

        let config = NSWorkspace.OpenConfiguration()
        config.activates = true

        NSWorkspace.shared.openApplication(at: url, configuration: config) { runningApp, error in
            if let error = error {
                print("Failed to launch app: \(error)")
            } else if let runningApp = runningApp {
                print("Launched app: \(app.name)")
                self.markAppAsLaunched(app)
                self.hideLauncher()
            }
        }
    }

    private func markAppAsLaunched(_ app: AppInfo) {
        let descriptor = FetchDescriptor<AppAssignment>(
            predicate: #Predicate { $0.bundleIdentifier == app.bundleIdentifier }
        )

        do {
            let results = try modelContext.fetch(descriptor)
            let assignment = if let existing = results.first {
                existing
            } else {
                let newAssignment = AppAssignment(
                    bundleIdentifier: app.bundleIdentifier,
                    appName: app.name,
                    isRecent: true
                )
                modelContext.insert(newAssignment)
                newAssignment
            }

            assignment.markAsUsed()
            try modelContext.save()

            // Maintain only recent apps limit
            cleanupRecentApps()

            DispatchQueue.main.async {
                self.loadRecentApps()
            }
        } catch {
            print("Failed to update app usage: \(error)")
        }
    }

    private func cleanupRecentApps() {
        let descriptor = FetchDescriptor<AppAssignment>(
            predicate: #Predicate { $0.isRecent },
            sortBy: [SortDescriptor(\.lastUsed, order: .reverse)]
        )

        do {
            let assignments = try modelContext.fetch(descriptor)

            // Mark excess apps as not recent
            let excessApps = assignments.dropFirst(AppConstants.Limits.maxRecentApps)
            for app in excessApps {
                app.isRecent = false
            }

            try modelContext.save()
        } catch {
            print("Failed to cleanup recent apps: \(error)")
        }
    }

    // MARK: - Launcher Window
    func showLauncher() {
        if launcherWindow != nil {
            hideLauncher()
            return
        }

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 400),
            styleMask: [.titled, .closable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        panel.title = "Launcher"
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.titlebarAppearsTransparent = true
        panel.titleVisibility = .hidden

        let contentView = LauncherView()
        panel.contentView = NSHostingView(rootView: contentView)

        panel.center()
        panel.makeKeyAndOrderFront(nil)

        launcherWindow = panel
        isLauncherVisible = true

        // Focus search field
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            NotificationCenter.default.post(name: .launcherShouldFocus, object: nil)
        }
    }

    func hideLauncher() {
        launcherWindow?.close()
        launcherWindow = nil
        isLauncherVisible = false
        searchQuery = ""
        searchResults = []
    }

    // MARK: - Keyboard Shortcuts
    private func setupLauncherShortcut() {
        // Monitor for launcher shortcut
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            self?.handleLauncherKeyEvent(event) ?? event
        }
    }

    private func removeLauncherShortcut() {
        // Cleanup is handled by weak reference
    }

    private func handleLauncherKeyEvent(_ event: NSEvent) -> NSEvent? {
        let flags = event.modifierFlags

        // Check for Cmd+Space (default launcher shortcut)
        // Can be customized later
        if flags.contains(.command) && event.keyCode == 49 { // Space key
            showLauncher()
            return nil // Consume the event
        }

        // Handle ESC to close launcher
        if isLauncherVisible && event.keyCode == 53 { // ESC key
            hideLauncher()
            return nil
        }

        // Handle Enter to launch selected app
        if isLauncherVisible && event.keyCode == 36 { // Return key
            launchSelectedApp()
            return nil
        }

        return event
    }

    private func launchSelectedApp() {
        if let selectedApp = searchResults.first {
            launchApp(selectedApp)
        }
    }

    // MARK: - Mode-Specific App Assignment
    func assignAppToMode(_ app: AppInfo, mode: Mode) {
        let assignment = IconAssignment(
            iconID: app.bundleIdentifier,
            iconName: app.name,
            bundleIdentifier: app.bundleIdentifier,
            isVisible: true
        )

        modelContext.insert(assignment)
        try? modelContext.save()
    }

    func removeAppFromMode(_ app: AppInfo, mode: Mode) {
        let assignmentsToRemove = mode.iconAssignments.filter { $0.bundleIdentifier == app.bundleIdentifier }

        for assignment in assignmentsToRemove {
            modelContext.delete(assignment)
        }

        try? modelContext.save()
    }
}

// MARK: - Launcher View
struct LauncherView: View {
    @StateObject private var manager = LauncherManager(modelContext: DataController.shared.modelContext)

    var body: some View {
        VStack(spacing: 0) {
            // Search field
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)

                TextField("Search apps...", text: $manager.searchQuery)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18))
                    .onChange(of: manager.searchQuery) { _, _ in
                        manager.searchApps()
                    }
                    .onReceive(NotificationCenter.default.publisher(for: .launcherShouldFocus)) { _ in
                        // Focus search field
                    }
            }
            .padding()

            Divider()

            // Recent apps
            if manager.searchQuery.isEmpty && !manager.recentApps.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent")
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)

                    ForEach(manager.recentApps) { app in
                        AppRowView(app: app) {
                            manager.launchApp(app)
                        }
                    }
                }
            }

            // Search results
            if !manager.searchResults.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(manager.searchResults) { app in
                            AppRowView(app: app) {
                                manager.launchApp(app)
                            }
                        }
                    }
                }
            }
        }
        .frame(minHeight: 400)
    }
}

struct AppRowView: View {
    let app: AppInfo
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                } else {
                    Image(systemName: "app")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.secondary)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(app.name)
                        .font(.body)

                    if let lastUsed = app.lastUsed {
                        Text("Last used: \(lastUsed, style: .relative)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let launcherShouldFocus = Notification.Name("launcherShouldFocus")
}
