import SwiftUI
import SwiftData

// MARK: - Settings View
struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedTab: SettingsTab = .general
    @State private var isDarkMode: Bool = false

    private let modeManager = ModeManager(modelContext: DataController.shared.modelContext)

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }
                .tag(SettingsTab.general)

            ModesSettingsView()
                .tabItem {
                    Label("Modes", systemImage: "switch.2")
                }
                .tag(SettingsTab.modes)

            IconsSettingsView()
                .tabItem {
                    Label("Icons", systemImage: "app.dashed")
                }
                .tag(SettingsTab.icons)

            ShortcutsSettingsView()
                .tabItem {
                    Label("Shortcuts", systemImage: "command")
                }
                .tag(SettingsTab.shortcuts)

            FocusGuardSettingsView()
                .tabItem {
                    Label("Focus Guard", systemImage: "shield")
                }
                .tag(SettingsTab.focusGuard)

            AboutSettingsView()
                .tabItem {
                    Label("About", systemImage: "info.circle")
                }
                .tag(SettingsTab.about)
        }
        .frame(width: 700, height: 500)
        .onAppear {
            // Load appearance setting
            loadAppearanceSettings()
        }
    }

    private func loadAppearanceSettings() {
        let descriptor = FetchDescriptor<Preference>()
        if let preference = try? modelContext.fetch(descriptor).first {
            isDarkMode = preference.appearanceMode == "dark"
        }
    }
}

// MARK: - Settings Tab
enum SettingsTab: String {
    case general
    case modes
    case icons
    case shortcuts
    case focusGuard
    case about
}

// MARK: - General Settings View
struct GeneralSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var launchAtLogin: Bool = false
    @State private var showMenuBarIcon: Bool = true
    @State private var selectedAppearance: AppearanceMode = .system

    var body: some View {
        Form {
            Section("Startup") {
                Toggle("Launch at login", isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, _ in
                        saveLaunchAtLogin()
                    }
            }

            Section("Appearance") {
                Picker("Appearance", selection: $selectedAppearance) {
                    Text("System").tag(AppearanceMode.system)
                    Text("Light").tag(AppearanceMode.light)
                    Text("Dark").tag(AppearanceMode.dark)
                }
                .onChange(of: selectedAppearance) { _, _ in
                    saveAppearance()
                }
            }

            Section("Menu Bar") {
                Toggle("Show menu bar icon", isOn: $showMenuBarIcon)
                    .onChange(of: showMenuBarIcon) { _, _ in
                        saveMenuBarIcon()
                    }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        let descriptor = FetchDescriptor<Preference>()
        if let preference = try? modelContext.fetch(descriptor).first {
            launchAtLogin = preference.launchAtLogin
            showMenuBarIcon = preference.showMenuBarIcon
            switch preference.appearanceMode {
            case "light":
                selectedAppearance = .light
            case "dark":
                selectedAppearance = .dark
            default:
                selectedAppearance = .system
            }
        }
    }

    private func saveLaunchAtLogin() {
        let descriptor = FetchDescriptor<Preference>()
        if let preference = try? modelContext.fetch(descriptor).first {
            preference.launchAtLogin = launchAtLogin
            try? modelContext.save()
        }
    }

    private func saveAppearance() {
        let descriptor = FetchDescriptor<Preference>()
        if let preference = try? modelContext.fetch(descriptor).first {
            preference.appearanceMode = selectedAppearance.rawValue
            try? modelContext.save()
        }
    }

    private func saveMenuBarIcon() {
        let descriptor = FetchDescriptor<Preference>()
        if let preference = try? modelContext.fetch(descriptor).first {
            preference.showMenuBarIcon = showMenuBarIcon
            try? modelContext.save()
        }
    }
}

// MARK: - Appearance Mode
enum AppearanceMode: String {
    case system = "system"
    case light = "light"
    case dark = "dark"
}

// MARK: - Modes Settings View
struct ModesSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var modes: [Mode] = []
    @State private var showingAddMode = false
    @State private var editingMode: Mode?

    private let modeManager = ModeManager(modelContext: DataController.shared.modelContext)

    var body: some View {
        VStack(spacing: 0) {
            // Mode list
            List(selection: $editingMode) {
                ForEach(modes) { mode in
                    ModeRowView(mode: mode)
                        .tag(mode)
                        .contextMenu {
                            Button("Edit...") {
                                editMode(mode)
                            }
                            if !mode.isDefault {
                                Divider()
                                Button("Delete", role: .destructive) {
                                    deleteMode(mode)
                                }
                            }
                        }
                }
            }
            .frame(minHeight: 200)

            Divider()

            // Actions
            HStack {
                Button(action: { showingAddMode = true }) {
                    Label("Add Mode", systemImage: "plus")
                }

                Spacer()

                if let editingMode = editingMode {
                    Button("Edit") {
                        editMode(editingMode)
                    }
                    .disabled(editingMode.isDefault)

                    if !editingMode.isDefault {
                        Button("Delete", role: .destructive) {
                            deleteMode(editingMode)
                        }
                    }
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingAddMode) {
            ModeEditView(mode: nil) { newMode in
                addMode(newMode)
            }
        }
        .sheet(item: $editingMode) { mode in
            ModeEditView(mode: mode) { updatedMode in
                updateMode(updatedMode)
            }
        }
        .onAppear {
            loadModes()
        }
    }

    private func loadModes() {
        modes = modeManager.allModes
    }

    private func addMode(_ mode: Mode) {
        modeManager.createMode(
            name: mode.name,
            icon: mode.icon ?? "star.fill",
            iconAssignments: mode.iconAssignments
        )
        loadModes()
    }

    private func updateMode(_ mode: Mode) {
        mode.name = mode.name
        mode.icon = mode.icon
        try? modelContext.save()
        loadModes()
    }

    private func deleteMode(_ mode: Mode) {
        modeManager.deleteMode(mode)
        loadModes()
    }

    private func editMode(_ mode: Mode) {
        editingMode = mode
    }
}

// MARK: - Mode Row View
struct ModeRowView: View {
    let mode: Mode

    var body: some View {
        HStack(spacing: 12) {
            if let iconName = mode.icon {
                Image(systemName: iconName)
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
                    .frame(width: 32)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(mode.name)
                    .font(.body)

                if mode.isDefault {
                    Text("Default mode")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            Text("\(mode.iconAssignments.count) icons")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Mode Edit View
struct ModeEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let mode: Mode?
    let onSave: (Mode) -> Void

    @State private var name: String
    @State private var selectedIcon: String

    private let availableIcons = [
        "star.fill", "hammer.fill", "paintbrush.fill",
        "video.fill", "moon.zzz.fill", "sun.max.fill",
        "briefcase.fill", "gamecontroller.fill", "book.fill",
        "music.note", "globe", "heart.fill"
    ]

    init(mode: Mode?, onSave: @escaping (Mode) -> Void) {
        self.mode = mode
        self.onSave = onSave
        _name = State(initialValue: mode?.name ?? "")
        _selectedIcon = State(initialValue: mode?.icon ?? "star.fill")
    }

    var body: some View {
        VStack(spacing: 20) {
            Text(mode == nil ? "New Mode" : "Edit Mode")
                .font(.title)
                .bold()

            Form {
                Section("Mode Details") {
                    TextField("Mode Name", text: $name)
                        .textFieldStyle(.roundedBorder)

                    Picker("Icon", selection: $selectedIcon) {
                        ForEach(availableIcons, id: \.self) { icon in
                            HStack {
                                Image(systemName: icon)
                                Text(icon)
                            }
                            .tag(icon)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
            .formStyle(.grouped)

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button("Save") {
                    saveMode()
                }
                .keyboardShortcut(.defaultAction)
                .disabled(name.isEmpty)
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .frame(width: 400, height: 300)
    }

    private func saveMode() {
        let modeToSave: Mode
        if let existingMode = mode {
            modeToSave = existingMode
            existingMode.name = name
            existingMode.icon = selectedIcon
        } else {
            modeToSave = Mode(
                name: name,
                icon: selectedIcon,
                iconAssignments: []
            )
            modelContext.insert(modeToSave)
        }

        try? modelContext.save()
        onSave(modeToSave)
        dismiss()
    }
}

// MARK: - Icons Settings View
struct IconsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var modes: [Mode] = []
    @State private var selectedMode: Mode?
    @State private var availableIcons: [MenuBarIcon] = []
    @State private var showingIconScanner = false

    private let modeManager = ModeManager(modelContext: DataController.shared.modelContext)
    private let menuBarManager = MenuBarManager()

    var body: some View {
        VStack(spacing: 0) {
            // Mode selector
            Picker("Mode", selection: $selectedMode) {
                Text("Select a mode").tag(nil as Mode?)
                ForEach(modes) { mode in
                    Text(mode.name).tag(mode as Mode?)
                }
            }
            .pickerStyle(.menu)
            .padding()

            Divider()

            if let selectedMode = selectedMode {
                // Mode icons
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Icons in \(selectedMode.name)")
                            .font(.headline)

                        Spacer()

                        Button("Scan Icons") {
                            scanIcons()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)

                    if selectedMode.iconAssignments.isEmpty {
                        Text("No icons assigned")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ScrollView {
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(selectedMode.iconAssignments) { assignment in
                                    IconAssignmentCard(
                                        assignment: assignment,
                                        mode: selectedMode
                                    )
                                }
                            }
                            .padding()
                        }
                    }
                }
            } else {
                VStack {
                    Image(systemName: "switch.2")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)

                    Text("Select a mode to manage its icons")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .sheet(isPresented: $showingIconScanner) {
            IconScannerView { icons in
                self.availableIcons = icons
            }
        }
        .onAppear {
            loadModes()
        }
        .onChange(of: selectedMode) { _, _ in
            loadModeIcons()
        }
    }

    private func loadModes() {
        modes = modeManager.allModes
    }

    private func loadModeIcons() {
        guard let selectedMode = selectedMode else { return }
        // Icons are already loaded via @Model relationship
    }

    private func scanIcons() {
        menuBarManager.scanMenuBarIcons()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            availableIcons = menuBarManager.detectedIcons
            showingIconScanner = true
        }
    }
}

// MARK: - Icon Assignment Card
struct IconAssignmentCard: View {
    @Environment(\.modelContext) private var modelContext
    let assignment: IconAssignment
    let mode: Mode
    @State private var isVisible: Bool

    init(assignment: IconAssignment, mode: Mode) {
        self.assignment = assignment
        self.mode = mode
        _isVisible = State(initialValue: assignment.isVisible)
    }

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "app")
                .font(.system(size: 32))
                .foregroundColor(isVisible ? .primary : .secondary)

            Text(assignment.iconName)
                .font(.caption)
                .lineLimit(1)

            Toggle("", isOn: $isVisible)
                .labelsHidden()
                .onChange(of: isVisible) { _, _ in
                    assignment.isVisible = isVisible
                    try? modelContext.save()
                }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Icon Scanner View
struct IconScannerView: View {
    @Environment(\.dismiss) private var dismiss
    let onIconsScanned: ([MenuBarIcon]) -> Void

    @State private var isScanning = true
    @State private var scannedIcons: [MenuBarIcon] = []

    private let menuBarManager = MenuBarManager()

    var body: some View {
        VStack(spacing: 20) {
            Text("Scan Menu Bar Icons")
                .font(.title)
                .bold()

            if isScanning {
                ProgressView("Scanning...")
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Found \(scannedIcons.count) icons:")
                        .font(.headline)

                    List(scannedIcons, id: \.id) { icon in
                        HStack {
                            Image(systemName: icon.isSystemIcon ? "applelogo" : "app")
                            Text(icon.name)
                            if let bundleID = icon.bundleIdentifier {
                                Text("(\(bundleID))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .frame(height: 200)
                }

                HStack {
                    Button("Cancel") {
                        dismiss()
                    }

                    Spacer()

                    Button("Add Icons") {
                        onIconsScanned(scannedIcons)
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .padding()
        .frame(width: 500, height: 400)
        .onAppear {
            startScan()
        }
    }

    private func startScan() {
        menuBarManager.scanMenuBarIcons()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            scannedIcons = menuBarManager.detectedIcons
            isScanning = false
        }
    }
}

// MARK: - Shortcuts Settings View
struct ShortcutsSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var launcherShortcut: String = "⌘Space"
    @State private var modeSwitcherShortcut: String = "⌘⇧M"
    @State private var customShortcuts: [String: String] = [:]

    var body: some View {
        Form {
            Section("Global Shortcuts") {
                HStack {
                    Text("Launcher")
                    Spacer()
                    Text(launcherShortcut)
                        .foregroundColor(.secondary)
                    Button("Record...") {
                        // TODO: Implement shortcut recording
                    }
                }

                HStack {
                    Text("Mode Switcher")
                    Spacer()
                    Text(modeSwitcherShortcut)
                        .foregroundColor(.secondary)
                    Button("Record...") {
                        // TODO: Implement shortcut recording
                    }
                }
            }

            Section("Mode-Specific Shortcuts") {
                ForEach(Array(customShortcuts.keys.sorted()), id: \.self) { key in
                    HStack {
                        Text(key)
                        Spacer()
                        Text(customShortcuts[key] ?? "")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .formStyle(.grouped)
        .onAppear {
            loadShortcuts()
        }
    }

    private func loadShortcuts() {
        let descriptor = FetchDescriptor<Preference>()
        if let preference = try? modelContext.fetch(descriptor).first {
            launcherShortcut = preference.launcherShortcut
            modeSwitcherShortcut = preference.modeSwitcherShortcut
            customShortcuts = preference.customShortcuts ?? [:]
        }
    }
}

// MARK: - Focus Guard Settings View
struct FocusGuardSettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var isEnabled: Bool = false
    @State private var dndApps: [DNDApp] = []
    @State private var showingAddDNDApp = false

    private let focusGuardManager = FocusGuardManager()

    var body: some View {
        VStack(spacing: 0) {
            Form {
                Section("Focus Guard") {
                    Toggle("Enable Focus Guard", isOn: $isEnabled)
                        .onChange(of: isEnabled) { _, _ in
                            toggleFocusGuard()
                        }

                    Text("Focus Guard prevents applications from stealing focus and blocks notifications during work sessions.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Section("Do Not Disturb Apps") {
                    if dndApps.isEmpty {
                        Text("No DND apps configured")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(dndApps, id: \.bundleIdentifier) { app in
                            HStack {
                                Toggle(app.appName, isOn: Binding(
                                    get: { app.isEnabled },
                                    set: { newValue in
                                        app.isEnabled = newValue
                                        updateDNDApp(app)
                                    }
                                ))

                                Spacer()

                                Button("Remove") {
                                    removeDNDApp(app)
                                }
                                .buttonStyle(.borderless)
                            }
                        }
                    }

                    Button("Add App") {
                        showingAddDNDApp = true
                    }
                }
            }
            .formStyle(.grouped)
        }
        .sheet(isPresented: $showingAddDNDApp) {
            DNDAppAddView { app in
                addDNDApp(app)
            }
        }
        .onAppear {
            loadSettings()
        }
    }

    private func loadSettings() {
        isEnabled = focusGuardManager.isEnabled
        dndApps = focusGuardManager.dndAppsList
    }

    private func toggleFocusGuard() {
        if isEnabled {
            focusGuardManager.enable()
        } else {
            focusGuardManager.disable()
        }
        focusGuardManager.setEnabled(isEnabled)
    }

    private func addDNDApp(_ app: DNDApp) {
        focusGuardManager.addDNDApp(app.bundleIdentifier, appName: app.appName)
        loadSettings()
    }

    private func removeDNDApp(_ app: DNDApp) {
        focusGuardManager.removeDNDApp(app.bundleIdentifier)
        loadSettings()
    }

    private func updateDNDApp(_ app: DNDApp) {
        focusGuardManager.updateDNDApp(app)
    }
}

// MARK: - DND App Add View
struct DNDAppAddView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (DNDApp) -> Void

    @State private var selectedApp: String?
    @State private var runningApps: [(name: String, bundleID: String)] = []

    var body: some View {
        VStack(spacing: 20) {
            Text("Add DND App")
                .font(.title)
                .bold()

            List(runningApps, id: \.bundleID) { app in
                Button(app.name) {
                    addDNDApp(name: app.name, bundleID: app.bundleID)
                }
            }
            .frame(height: 200)

            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.cancelAction)
            }
        }
        .padding()
        .frame(width: 400, height: 350)
        .onAppear {
            loadRunningApps()
        }
    }

    private func loadRunningApps() {
        let workspace = NSWorkspace.shared
        if let runningApps = workspace.runningApplications {
            self.runningApps = runningApps.compactMap { app in
                guard let bundleID = app.bundleIdentifier,
                      let localizedName = app.localizedName else {
                    return nil
                }
                return (localizedName, bundleID)
            }
        }
    }

    private func addDNDApp(name: String, bundleID: String) {
        let app = DNDApp(bundleIdentifier: bundleID, appName: name)
        onAdd(app)
        dismiss()
    }
}

// MARK: - About Settings View
struct AboutSettingsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "line.3.horizontal.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(.accentColor)

            Text("Flowbar")
                .font(.title)
                .bold()

            Text("Version 1.0.0")
                .font(.body)
                .foregroundColor(.secondary)

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                Link(destination: URL(string: "https://github.com/Fission-AI/Flowbar")!) {
                    Label("Website", systemImage: "globe")
                }

                Link(destination: URL(string: "https://github.com/Fission-AI/Flowbar/issues")!) {
                    Label("Report an Issue", systemImage: "exclamationmark.bubble")
                }

                Link(destination: URL(string: "https://github.com/Fission-AI/Flowbar/blob/main/LICENSE")!) {
                    Label("License", systemImage: "doc.text")
                }
            }
            .buttonStyle(.link)

            Spacer()

            Text("Made with ❤️ for focused work")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Settings Window Manager
@MainActor
final class SettingsWindowManager: ObservableObject {
    static let shared = SettingsWindowManager()

    @Published var isSettingsWindowVisible: Bool = false
    private var settingsWindow: NSWindow?

    private init() {}

    func showSettings() {
        if let window = settingsWindow, !window.isVisible {
            window.makeKeyAndOrderFront(nil)
            isSettingsWindowVisible = true
            return
        }

        if settingsWindow == nil {
            let settingsView = SettingsView()
                .environment(\.modelContext, DataController.shared.modelContext)

            let hostingController = NSHostingController(rootView: settingsView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )

            window.title = "Flowbar Settings"
            window.contentViewController = hostingController
            window.center()
            window.isReleasedWhenClosed = false

            settingsWindow = window
        }

        settingsWindow?.makeKeyAndOrderFront(nil)
        isSettingsWindowVisible = true
    }

    func hideSettings() {
        settingsWindow?.close()
        isSettingsWindowVisible = false
    }
}
