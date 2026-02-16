import Foundation
import SwiftData
import Cocoa

// MARK: - Onboarding Step
enum OnboardingStep: String, CaseIterable {
    case welcome = "welcome"
    case accessibility = "accessibility"
    case iconScanning = "iconScanning"
    case iconAssignment = "iconAssignment"
    case modeCreation = "modeCreation"
    case shortcuts = "shortcuts"
    case complete = "complete"

    var title: String {
        switch self {
        case .welcome: return "Welcome to Flowbar"
        case .accessibility: return "Accessibility Permission"
        case .iconScanning: return "Scan Menu Bar"
        case .iconAssignment: return "Assign Icons"
        case .modeCreation: return "Create Modes"
        case .shortcuts: return "Set Shortcuts"
        case .complete: return "All Set!"
        }
    }

    var description: String {
        switch self {
        case .welcome:
            return "Flowbar helps you focus by managing menu bar icons and blocking interruptions."
        case .accessibility:
            return "Flowbar needs accessibility permission to detect and control menu bar icons."
        case .iconScanning:
            return "We'll scan your menu bar to detect all visible icons."
        case .iconAssignment:
            return "Assign icons to different modes based on your work context."
        case .modeCreation:
            return "We've created 4 default modes for you. You can customize them later."
        case .shortcuts:
            return "Set up keyboard shortcuts to quickly switch between modes."
        case .complete:
            return "You're all set! Flowbar is ready to help you focus."
        }
    }

    var progress: Double {
        switch self {
        case .welcome: return 0.0
        case .accessibility: return 1.0 / 6.0
        case .iconScanning: return 2.0 / 6.0
        case .iconAssignment: return 3.0 / 6.0
        case .modeCreation: return 4.0 / 6.0
        case .shortcuts: return 5.0 / 6.0
        case .complete: return 1.0
        }
    }
}

// MARK: - Onboarding Coordinator
@MainActor
final class OnboardingCoordinator: ObservableObject {
    @Published var currentStep: OnboardingStep = .welcome
    @Published var isOnboardingComplete: Bool = false
    @Published var detectedIcons: [MenuBarIcon] = []
    @Published var accessibilityGranted: Bool = false

    private let modelContext: ModelContext
    private var onboardingState: OnboardingState?
    private var onboardingWindow: NSWindow?
    private var menuBarManager: MenuBarManager?

    // Mode data collected during onboarding
    private var modeIcons: [String: [MenuBarIcon]] = [:]
    private var customShortcuts: [String: String] = [:]

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        checkOnboardingState()
    }

    // MARK: - State Management
    private func checkOnboardingState() {
        let descriptor = FetchDescriptor<OnboardingState>()

        do {
            let results = try modelContext.fetch(descriptor)
            if let state = results.first {
                onboardingState = state
                isOnboardingComplete = state.isComplete
                if !state.isComplete, let lastStep = OnboardingStep(rawValue: state.lastStep) {
                    currentStep = lastStep
                }
            } else {
                // Create new onboarding state
                let newState = OnboardingState()
                modelContext.insert(newState)
                onboardingState = newState
                try modelContext.save()
            }
        } catch {
            print("Failed to check onboarding state: \(error)")
        }
    }

    // MARK: - Onboarding Flow
    func startOnboarding() {
        showOnboardingWindow()
    }

    func skipOnboarding() {
        completeOnboarding()
    }

    func restartOnboarding() {
        onboardingState?.isComplete = false
        onboardingState?.lastStep = ""
        currentStep = .welcome
        try? modelContext.save()
        isOnboardingComplete = false

        // Clear partial data
        modeIcons.removeAll()
        customShortcuts.removeAll()

        showOnboardingWindow()
    }

    // MARK: - Navigation
    func nextStep() {
        guard let index = OnboardingStep.allCases.firstIndex(of: currentStep),
              index < OnboardingStep.allCases.count - 1 else {
            completeOnboarding()
            return
        }

        let nextStep = OnboardingStep.allCases[index + 1]

        // Perform step-specific actions
        switch nextStep {
        case .accessibility:
            checkAccessibilityPermission()
        case .iconScanning:
            scanMenuBarIcons()
        case .modeCreation:
            createDefaultModes()
        case .shortcuts:
            detectShortcutConflicts()
        default:
            break
        }

        moveToStep(nextStep)
    }

    func previousStep() {
        guard let index = OnboardingStep.allCases.firstIndex(of: currentStep),
              index > 0 else {
            return
        }

        let previousStep = OnboardingStep.allCases[index - 1]
        currentStep = previousStep
        onboardingState?.markStepComplete(previousStep.rawValue)
        try? modelContext.save()
    }

    private func moveToStep(_ step: OnboardingStep) {
        currentStep = step
        onboardingState?.markStepComplete(step.rawValue)
        try? modelContext.save()

        updateOnboardingWindow()
    }

    // MARK: - Step-Specific Actions
    private func checkAccessibilityPermission() {
        let manager = MenuBarManager()
        menuBarManager = manager
        accessibilityGranted = manager.checkAccessibilityPermission()
    }

    func requestAccessibilityPermission() {
        menuBarManager?.requestAccessibilityPermission()
    }

    func monitorAccessibilityPermission() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            if let manager = self.menuBarManager {
                let granted = manager.checkAccessibilityPermission()
                DispatchQueue.main.async {
                    self.accessibilityGranted = granted

                    if granted {
                        timer.invalidate()
                    }
                }
            }
        }
    }

    private func scanMenuBarIcons() {
        guard let manager = menuBarManager else {
            print("MenuBarManager not initialized")
            return
        }

        manager.scanMenuBarIcons()

        // Wait a moment for scanning to complete
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.detectedIcons = manager.detectedIcons
        }
    }

    private func createDefaultModes() {
        let modeManager = ModeManager(modelContext: modelContext)

        if modeManager.allModes.isEmpty {
            modeManager.createDefaultModes()
        }

        // Assign scanned icons to modes based on heuristics
        assignIconsToModes()
    }

    private func assignIconsToModes() {
        // Assign icons to modes based on common patterns
        for icon in detectedIcons {
            if let bundleID = icon.bundleIdentifier {
                if let mode = suggestModeForIcon(icon, bundleID: bundleID) {
                    if modeIcons[mode.name] == nil {
                        modeIcons[mode.name] = []
                    }
                    modeIcons[mode.name]?.append(icon)
                }
            }
        }
    }

    private func suggestModeForIcon(_ icon: MenuBarIcon, bundleID: String) -> Mode? {
        let modelContext = DataController.shared.modelContext
        let descriptor = FetchDescriptor<Mode>()

        do {
            let modes = try modelContext.fetch(descriptor)

            // Suggest mode based on bundle identifier
            if bundleID.contains("git") || bundleID.contains("github") {
                return modes.first { $0.name.lowercased().contains("coding") }
            } else if bundleID.contains("code") || bundleID.contains("xcode") {
                return modes.first { $0.name.lowercased().contains("coding") }
            } else if bundleID.contains("fig") || bundleID.contains("sketch") {
                return modes.first { $0.name.lowercased().contains("design") }
            } else if bundleID.contains("slack") || bundleID.contains("zoom") {
                return modes.first { $0.name.lowercased().contains("meeting") }
            }
        } catch {
            print("Failed to fetch modes for icon assignment")
        }

        return nil
    }

    private func detectShortcutConflicts() {
        // Check for conflicts with common shortcuts
        let conflictingApps = [
            "Spotlight": "Cmd+Space",
            "Siri": "Cmd+Space (Hold)",
            "Launchbar": "Cmd+Space"
        ]

        // Add suggestions to customShortcuts
        customShortcuts["launcher"] = "Cmd+Option+Space"
    }

    func setShortcut(for action: String, shortcut: String) {
        customShortcuts[action] = shortcut
    }

    // MARK: - Onboarding Window
    private func showOnboardingWindow() {
        let onboardingView = OnboardingView()
            .environmentObject(self)

        let hostingView = NSHostingView(rootView: onboardingView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 600, height: 500)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 600, height: 500),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )

        window.title = "Flowbar Setup"
        window.contentView = hostingView
        window.center()
        window.makeKeyAndOrderFront(nil)
        window.level = .floating

        onboardingWindow = window
    }

    private func updateOnboardingWindow() {
        // Update window content for current step
        hostingView?.rootView = OnboardingView()
            .environmentObject(self)
    }

    private func hideOnboardingWindow() {
        onboardingWindow?.close()
        onboardingWindow = nil
    }

    // MARK: - Completion
    private func completeOnboarding() {
        currentStep = .complete
        onboardingState?.complete()
        try? modelContext.save()
        isOnboardingComplete = true

        // Save collected mode configurations
        saveModeConfigurations()

        // Save custom shortcuts
        saveCustomShortcuts()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.hideOnboardingWindow()

            // Post completion notification
            NotificationCenter.default.post(
                name: .onboardingDidComplete,
                object: nil
            )
        }
    }

    private func saveModeConfigurations() {
        // Create icon assignments based on collected data
        let modeManager = ModeManager(modelContext: modelContext)

        for (modeName, icons) in modeIcons {
            if let mode = modeManager.allModes.first(where: { $0.name == modeName }) {
                for icon in icons {
                    if let bundleID = icon.bundleIdentifier {
                        let assignment = IconAssignment(
                            iconID: icon.id,
                            iconName: icon.name,
                            bundleIdentifier: bundleID,
                            isVisible: true
                        )

                        mode.iconAssignments.append(assignment)
                    }
                }
            }
        }

        try? modelContext.save()
    }

    private func saveCustomShortcuts() {
        // Save custom shortcuts to preferences
        let descriptor = FetchDescriptor<Preference>()

        do {
            var preferences = try modelContext.fetch(descriptor)

            let preference = if let existing = preferences.first {
                existing
            } else {
                let newPref = Preference()
                modelContext.insert(newPref)
                newPref
            }

            if let launcherShortcut = customShortcuts["launcher"] {
                preference.launcherShortcut = launcherShortcut
            }

            try modelContext.save()
        } catch {
            print("Failed to save shortcuts: \(error)")
        }
    }
}

// MARK: - Onboarding View
struct OnboardingView: View {
    @EnvironmentObject var coordinator: OnboardingCoordinator

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressView(value: coordinator.currentStep.progress)
                .padding()

            // Content
            ScrollView {
                VStack(spacing: 24) {
                    // Step icon
                    Image(systemName: stepIcon)
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)

                    // Title
                    Text(coordinator.currentStep.title)
                        .font(.title)
                        .bold()

                    // Description
                    Text(coordinator.currentStep.description)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)

                    // Step-specific content
                    stepContent
                        .frame(maxHeight: 300)
                }
                .padding()
            }

            Divider()

            // Navigation buttons
            HStack {
                if coordinator.currentStep != .welcome {
                    Button("Back") {
                        coordinator.previousStep()
                    }
                    .keyboardShortcut(.leftArrow)
                }

                Spacer()

                if coordinator.currentStep != .complete {
                    Button("Next") {
                        coordinator.nextStep()
                    }
                    .keyboardShortcut(.rightArrow)
                    .buttonStyle(.borderedProminent)
                } else {
                    Button("Get Started") {
                        coordinator.completeOnboarding()
                    }
                    .buttonStyle(.borderedProminent)
                }

                if coordinator.currentStep != .welcome {
                    Button("Skip") {
                        coordinator.skipOnboarding()
                    }
                    .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .frame(width: 600, height: 500)
    }

    private var stepIcon: String {
        switch coordinator.currentStep {
        case .welcome: return "hand.wave.fill"
        case .accessibility: return "hand.raised.fill"
        case .iconScanning: return "magnifyingglass"
        case .iconAssignment: return "square.grid.3x3.fill"
        case .modeCreation: return "gear"
        case .shortcuts: return "command"
        case .complete: return "checkmark.circle.fill"
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch coordinator.currentStep {
        case .welcome:
            welcomeContent
        case .accessibility:
            accessibilityContent
        case .iconScanning:
            iconScanningContent
        case .iconAssignment:
            iconAssignmentContent
        case .modeCreation:
            modeCreationContent
        case .shortcuts:
            shortcutsContent
        case .complete:
            completeContent
        }
    }

    private var welcomeContent: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("What is Flowbar?")
                .font(.headline)

            Text("Flowbar is a menu bar utility that helps you:")
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "eye.slash.fill")
                    Text("Hide distracting menu bar icons")
                }
                HStack(spacing: 8) {
                    Image(systemName: "shield")
                    Text("Block focus-stealing interruptions")
                }
                HStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                    Text("Switch between work contexts")
                }
            }

            Text("This onboarding will take about 2 minutes.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var accessibilityContent: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Why Accessibility Permission?")
                    .font(.headline)

                Text("Flowbar needs this permission to:")
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text("Detect menu bar icons")
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text("Show/hide icons by mode")
                    }
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                        Text("Block unwanted focus changes")
                    }
                }
            }

            if !coordinator.accessibilityGranted {
                Button("Open System Settings") {
                    coordinator.requestAccessibilityPermission()
                    coordinator.monitorAccessibilityPermission()
                }
                .buttonStyle(.borderedProminent)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                    Text("Permission granted!")
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
    }

    private var iconScanningContent: some View {
        VStack(spacing: 16) {
            if coordinator.detectedIcons.isEmpty {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Scanning menu bar...")
                        .foregroundColor(.secondary)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Found \(coordinator.detectedIcons.count) icons:")
                        .font(.headline)

                    ForEach(coordinator.detectedIcons, id: \.id) { icon in
                        HStack {
                            if icon.isSystemIcon {
                                Image(systemName: "applelogo")
                            } else {
                                Image(systemName: "app")
                            }
                            Text(icon.name)
                                .font(.caption)
                            if let bundleID = icon.bundleIdentifier {
                                Text("(\(bundleID))")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding()
    }

    private var iconAssignmentContent: some View {
        VStack(spacing: 16) {
            Text("Icons will be automatically assigned to modes.")
                .foregroundColor(.secondary)

            Text("You can customize these later in Settings.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }

    private var modeCreationContent: some View {
        VStack(spacing: 16) {
            Text("We've created 4 default modes:")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "hammer")
                    Text("Coding - For development work")
                }
                HStack {
                    Image(systemName: "paintbrush")
                    Text("Design - For creative work")
                }
                HStack {
                    Image(systemName: "video")
                    Text("Meeting - For discussions")
                }
                HStack {
                    Image(systemName: "moon.zzz")
                    Text("Focus - For deep work")
                }
            }
        }
        .padding()
    }

    private var shortcutsContent: some View {
        VStack(spacing: 16) {
            Text("Default Shortcuts:")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("⌘⇧M")
                        .font(.system(.monospaced))
                    Text("Show mode switcher")
                    Spacer()
                }
                HStack {
                    Text("⌘⇧1-9")
                        .font(.system(.monospaced))
                    Text("Switch to mode 1-9")
                    Spacer()
                }
                HStack {
                    Text("⌘Space")
                        .font(.system(.monospaced))
                    Text("Open launcher")
                    Spacer()
                }
            }
        }
        .padding()
    }

    private var completeContent: some View {
        VStack(spacing: 24) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)

            Text("You're all set!")
                .font(.title)

            Text("Click the Flowbar icon in your menu bar to switch modes.")
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

// MARK: - Notifications
extension Notification.Name {
    static let onboardingDidComplete = Notification.Name("onboardingDidComplete")
}
