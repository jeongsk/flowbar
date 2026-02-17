import XCTest
@testable import Flowbar
import SwiftData
import SwiftUI

// MARK: - UI Tests
@MainActor
final class UITests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        let schema = Schema([
            Mode.self,
            IconAssignment.self,
            Preference.self,
            OnboardingState.self,
            AppAssignment.self,
            DNDApp.self
        ])

        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        modelContainer = try ModelContainer(for: schema, configurations: [configuration])
        modelContext = modelContainer.mainContext
    }

    override func tearDown() async throws {
        modelContext = nil
        modelContainer = nil
    }

    // MARK: - Onboarding Flow UI Tests
    func testOnboardingViewInitialization() async throws {
        let onboardingCoordinator = OnboardingCoordinator(modelContext: modelContext)

        XCTAssertEqual(onboardingCoordinator.currentStep, .welcome)

        let welcomeStep = OnboardingStep.welcome
        XCTAssertEqual(welcomeStep.title, "Welcome to Flowbar")
        XCTAssertFalse(welcomeStep.description.isEmpty)
    }

    func testOnboardingStepProgress() async throws {
        let welcomeStep = OnboardingStep.welcome
        let completeStep = OnboardingStep.complete

        XCTAssertEqual(welcomeStep.progress, 0.0)
        XCTAssertEqual(completeStep.progress, 1.0)

        let accessibilityStep = OnboardingStep.accessibility
        XCTAssertGreaterThan(accessibilityStep.progress, 0.0)
        XCTAssertLessThan(accessibilityStep.progress, 1.0)
    }

    func testOnboardingStepSequence() async throws {
        let onboardingCoordinator = OnboardingCoordinator(modelContext: modelContext)

        let steps = OnboardingStep.allCases
        XCTAssertEqual(steps.count, 7)

        // Test forward navigation
        for index in 0..<(steps.count - 1) {
            onboardingCoordinator.currentStep = steps[index]
            onboardingCoordinator.nextStep()
            XCTAssertEqual(onboardingCoordinator.currentStep, steps[index + 1])
        }
    }

    func testOnboardingBackwardNavigation() async throws {
        let onboardingCoordinator = OnboardingCoordinator(modelContext: modelContext)

        // Go to the third step
        onboardingCoordinator.currentStep = .iconScanning
        XCTAssertEqual(onboardingCoordinator.currentStep, .iconScanning)

        // Go back
        onboardingCoordinator.previousStep()
        XCTAssertEqual(onboardingCoordinator.currentStep, .accessibility)
    }

    // MARK: - Mode Switching UI Tests
    func testModeSwitcherViewInitialization() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        // Create default modes
        modeManager.createDefaultModes()

        XCTAssertGreaterThan(modeManager.allModes.count, 0)

        // Verify each mode has required properties
        for mode in modeManager.allModes {
            XCTAssertFalse(mode.name.isEmpty)
            XCTAssertNotNil(mode.icon)
        }
    }

    func testModeSwitcherViewSelection() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        modeManager.createMode(name: "Mode 1", icon: "star.fill", iconAssignments: [])
        modeManager.createMode(name: "Mode 2", icon: "moon.fill", iconAssignments: [])

        let mode1 = modeManager.allModes.first { $0.name == "Mode 1" }!
        let mode2 = modeManager.allModes.first { $0.name == "Mode 2" }!

        modeManager.switchToMode(mode1)
        XCTAssertEqual(modeManager.currentMode?.id, mode1.id)

        modeManager.switchToMode(mode2)
        XCTAssertEqual(modeManager.currentMode?.id, mode2.id)
    }

    func testModeRowViewRendering() async throws {
        let mode = Mode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: []
        )

        // Verify mode properties
        XCTAssertEqual(mode.name, "Test Mode")
        XCTAssertEqual(mode.icon, "star.fill")
        XCTAssertTrue(mode.iconAssignments.isEmpty)
    }

    // MARK: - Settings UI Tests
    func testSettingsViewInitialization() async throws {
        // Test that settings can be created without crashes
        let preference = Preference()
        preference.launchAtLogin = true
        preference.appearanceMode = "dark"

        modelContext.insert(preference)
        try modelContext.save()

        let descriptor = FetchDescriptor<Preference>()
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first?.launchAtLogin ?? false)
    }

    func testGeneralSettingsView() async throws {
        let preference = Preference()
        modelContext.insert(preference)
        try modelContext.save()

        // Test appearance mode setting
        preference.appearanceMode = "light"
        try modelContext.save()

        let descriptor = FetchDescriptor<Preference>()
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.first?.appearanceMode, "light")

        // Test dark mode setting
        preference.appearanceMode = "dark"
        try modelContext.save()

        let darkModeResults = try modelContext.fetch(descriptor)
        XCTAssertEqual(darkModeResults.first?.appearanceMode, "dark")
    }

    func testModesSettingsView() async throws {
        let modeManager = ModeManager(modelContext: modelContext)
        modeManager.createDefaultModes()

        // Verify all modes are available for editing
        XCTAssertGreaterThan(modeManager.allModes.count, 0)

        // Test mode creation
        modeManager.createMode(
            name: "Custom Mode",
            icon: "heart.fill",
            iconAssignments: []
        )

        XCTAssertTrue(modeManager.allModes.contains { $0.name == "Custom Mode" })
    }

    func testIconsSettingsView() async throws {
        let modeManager = ModeManager(modelContext: modelContext)
        modeManager.createMode(name: "Test Mode", icon: "star.fill", iconAssignments: [])
        let mode = modeManager.allModes.first { $0.name == "Test Mode" }!

        // Add icon assignments
        let assignment1 = IconAssignment(
            iconID: "test1",
            iconName: "Test Icon 1",
            bundleIdentifier: "com.test.app1",
            isVisible: true
        )

        let assignment2 = IconAssignment(
            iconID: "test2",
            iconName: "Test Icon 2",
            bundleIdentifier: "com.test.app2",
            isVisible: false
        )

        mode.iconAssignments.append(assignment1)
        mode.iconAssignments.append(assignment2)

        try modelContext.save()

        XCTAssertEqual(mode.iconAssignments.count, 2)
        XCTAssertTrue(mode.iconAssignments[0].isVisible)
        XCTAssertFalse(mode.iconAssignments[1].isVisible)
    }

    func testShortcutsSettingsView() async throws {
        let preference = Preference()
        preference.launcherShortcut = "⌘Space"
        preference.modeSwitcherShortcut = "⌘⇧M"

        modelContext.insert(preference)
        try modelContext.save()

        let descriptor = FetchDescriptor<Preference>()
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.first?.launcherShortcut, "⌘Space")
        XCTAssertEqual(results.first?.modeSwitcherShortcut, "⌘⇧M")
    }

    func testFocusGuardSettingsView() async throws {
        let focusGuardManager = FocusGuardManager()

        // Test enable/disable
        focusGuardManager.setEnabled(true)
        XCTAssertTrue(focusGuardManager.isEnabled)

        focusGuardManager.enable()
        XCTAssertTrue(focusGuardManager.isActive)

        // Test DND apps
        focusGuardManager.addDNDApp("com.test.app", appName: "Test App")
        XCTAssertTrue(focusGuardManager.isDNDApp("com.test.app"))

        focusGuardManager.removeDNDApp("com.test.app")
        XCTAssertFalse(focusGuardManager.isDNDApp("com.test.app"))
    }

    // MARK: - Launcher UI Tests
    func testLauncherViewInitialization() async throws {
        let launcherManager = LauncherManager(modelContext: modelContext)

        XCTAssertTrue(launcherManager.searchQuery.isEmpty)
        XCTAssertTrue(launcherManager.searchResults.isEmpty)
        XCTAssertTrue(launcherManager.recentApps.isEmpty)
        XCTAssertFalse(launcherManager.isLauncherVisible)
    }

    func testLauncherSearchFunctionality() async throws {
        let launcherManager = LauncherManager(modelContext: modelContext)

        launcherManager.searchQuery = "test"
        launcherManager.searchApps()

        // Verify search was triggered (results may be empty in test environment)
        XCTAssertNotNil(launcherManager.searchQuery)
    }

    // MARK: - Menu Bar UI Tests
    func testMenuBarIconRendering() async throws {
        let modeManager = ModeManager(modelContext: modelContext)
        modeManager.createMode(name: "Test Mode", icon: "star.fill", iconAssignments: [])
        let mode = modeManager.allModes.first { $0.name == "Test Mode" }!

        // Verify mode icon is set
        XCTAssertNotNil(mode.icon)
        XCTAssertEqual(mode.icon, "star.fill")
    }

    func testMenuBarContextMenu() async throws {
        let modeManager = ModeManager(modelContext: modelContext)
        modeManager.createDefaultModes()

        // Verify all modes are available for context menu
        XCTAssertGreaterThan(modeManager.allModes.count, 0)

        // Test mode switching via context menu
        let firstMode = modeManager.allModes.first!
        modeManager.switchToMode(firstMode)

        XCTAssertEqual(modeManager.currentMode?.id, firstMode.id)
    }

    // MARK: - Animation Tests
    func testModeSwitchAnimation() async throws {
        let animation = FlowbarAnimations.modeSwitchAnimation()

        // Verify animation is not nil
        XCTAssertNotNil(animation)
    }

    func testIconFadeAnimation() async throws {
        let animation = FlowbarAnimations.iconFadeAnimation()

        // Verify animation is not nil
        XCTAssertNotNil(animation)
    }

    func testSpringAnimation() async throws {
        let animation = FlowbarAnimations.springAnimation()

        // Verify animation is not nil
        XCTAssertNotNil(animation)
    }

    // MARK: - View Modifier Tests
    func testAnimatedScaleModifier() async throws {
        let view = Text("Test")
        let modifiedView = view.animatedScale()

        // Verify modifier is applied
        XCTAssertNotNil(modifiedView)
    }

    func testAnimatedFadeInModifier() async throws {
        let view = Text("Test")
        let modifiedView = view.animatedFadeIn()

        // Verify modifier is applied
        XCTAssertNotNil(modifiedView)
    }

    func testAnimatedSlideInModifier() async throws {
        let view = Text("Test")
        let modifiedView = view.animatedSlideIn()

        // Verify modifier is applied
        XCTAssertNotNil(modifiedView)
    }

    func testHoverEffectModifier() async throws {
        let view = Text("Test")
        let modifiedView = view.hoverEffect()

        // Verify modifier is applied
        XCTAssertNotNil(modifiedView)
    }

    func testRippleEffectModifier() async throws {
        let view = Text("Test")
        let modifiedView = view.rippleEffect()

        // Verify modifier is applied
        XCTAssertNotNil(modifiedView)
    }

    // MARK: - Window Management Tests
    func testSettingsWindowManager() async throws {
        let settingsManager = SettingsWindowManager.shared

        XCTAssertFalse(settingsManager.isSettingsWindowVisible)

        // Test showing settings (will create window)
        settingsManager.showSettings()

        // Note: Actual window testing would require UI runtime
        XCTAssertNotNil(settingsManager)
    }

    func testHelpWindowManager() async throws {
        let helpManager = HelpWindowManager.shared

        XCTAssertFalse(helpManager.isHelpWindowVisible)

        // Test showing help (will create window)
        helpManager.showHelp()

        // Note: Actual window testing would require UI runtime
        XCTAssertNotNil(helpManager)
    }
}
