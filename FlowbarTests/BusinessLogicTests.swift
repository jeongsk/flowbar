import XCTest
@testable import Flowbar
import SwiftData
import SwiftUI

// MARK: - Business Logic Tests
@MainActor
final class BusinessLogicTests: XCTestCase {

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

    // MARK: - ModeManager Tests
    func testModeManagerCreation() async throws {
        // ModeManager is @MainActor isolated
        let modeManager = ModeManager(modelContext: modelContext)

        // After init, allModes should be empty (no default modes created yet)
        XCTAssertTrue(modeManager.allModes.isEmpty, "Expected empty modes but found \(modeManager.allModes.count)")
        XCTAssertNil(modeManager.currentMode, "Expected nil current mode")
    }

    func testModeManagerCreateDefaultModes() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        modeManager.createDefaultModes()

        XCTAssertEqual(modeManager.allModes.count, 4)

        let modeNames = modeManager.allModes.map { $0.name }
        XCTAssertTrue(modeNames.contains("Coding"))
        XCTAssertTrue(modeNames.contains("Design"))
        XCTAssertTrue(modeNames.contains("Meeting"))
        XCTAssertTrue(modeNames.contains("Focus"))
    }

    func testModeManagerCreateMode() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        modeManager.createMode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: []
        )

        XCTAssertEqual(modeManager.allModes.count, 1)
        XCTAssertEqual(modeManager.allModes.first?.name, "Test Mode")
    }

    func testModeManagerSwitchMode() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        modeManager.createMode(name: "Mode 1", icon: "star.fill", iconAssignments: [])
        modeManager.createMode(name: "Mode 2", icon: "moon.fill", iconAssignments: [])

        let mode1 = modeManager.allModes.first { $0.name == "Mode 1" }
        let mode2 = modeManager.allModes.first { $0.name == "Mode 2" }

        modeManager.switchToMode(mode1!)
        XCTAssertEqual(modeManager.currentMode?.name, "Mode 1")

        modeManager.switchToMode(mode2!)
        XCTAssertEqual(modeManager.currentMode?.name, "Mode 2")
    }

    func testModeManagerDeleteMode() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        // Create a non-default mode that can be deleted
        modeManager.createMode(name: "Custom Mode", icon: "star.fill", iconAssignments: [])

        let initialCount = modeManager.allModes.count
        let modeToDelete = modeManager.allModes.first { $0.name == "Custom Mode" }

        XCTAssertNotNil(modeToDelete)
        XCTAssertFalse(modeToDelete!.isDefault) // Cannot delete default modes

        modeManager.deleteMode(modeToDelete!)

        XCTAssertEqual(modeManager.allModes.count, initialCount - 1)
        XCTAssertNil(modeManager.allModes.first { $0.name == "Custom Mode" })
    }

    func testModeManagerCannotDeleteDefaultModes() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        modeManager.createDefaultModes()

        let defaultMode = modeManager.allModes.first { $0.isDefault }
        let initialCount = modeManager.allModes.count

        XCTAssertNotNil(defaultMode)

        // Try to delete default mode - should not work
        modeManager.deleteMode(defaultMode!)

        // Verify default mode is protected - count should be the same
        XCTAssertEqual(modeManager.allModes.count, initialCount)
        XCTAssertNotNil(modeManager.allModes.first { $0.name == defaultMode!.name })
    }

    // MARK: - DataController Tests
    func testDataControllerSingleton() async throws {
        let controller1 = DataController.shared
        let controller2 = DataController.shared

        XCTAssertTrue(controller1 === controller2)
    }

    func testDataControllerModelContainer() async throws {
        let container = DataController.shared.modelContainer

        XCTAssertNotNil(container)
    }

    func testDataControllerModelContext() async throws {
        let context = DataController.shared.modelContext

        XCTAssertNotNil(context)
    }

    // MARK: - MenuBarManager Tests (Mock)
    func testMenuBarManagerInitialization() async throws {
        let menuBarManager = MenuBarManager()

        XCTAssertNotNil(menuBarManager)
        XCTAssertTrue(menuBarManager.detectedIcons.isEmpty)
    }

    func testMenuBarManagerSystemIcons() async throws {
        let menuBarManager = MenuBarManager()

        // Test system icon detection
        let systemBundleIDs = [
            "com.apple.systemuiserver",
            "com.apple.controlcenter",
            "com.apple.Spotlight"
        ]

        for bundleID in systemBundleIDs {
            XCTAssertTrue(menuBarManager.isSystemIcon(bundleID))
        }

        XCTAssertFalse(menuBarManager.isSystemIcon("com.test.app"))
    }

    // MARK: - LauncherManager Tests (Mock)
    func testLauncherManagerInitialization() async throws {
        let launcherManager = LauncherManager(modelContext: modelContext)

        XCTAssertNotNil(launcherManager)
        XCTAssertTrue(launcherManager.searchQuery.isEmpty)
        XCTAssertTrue(launcherManager.searchResults.isEmpty)
    }

    func testLauncherManagerFuzzyMatch() async throws {
        // This would require actual implementation testing
        // For now, we're just testing the structure
        let launcherManager = LauncherManager(modelContext: modelContext)

        XCTAssertNotNil(launcherManager)

        // Test search functionality with mock data
        launcherManager.searchQuery = "test"
        XCTAssertEqual(launcherManager.searchQuery, "test")
    }

    // MARK: - FocusGuardManager Tests
    func testFocusGuardManagerInitialization() async throws {
        let focusGuardManager = FocusGuardManager()

        XCTAssertNotNil(focusGuardManager)
        XCTAssertFalse(focusGuardManager.isEnabled)
        XCTAssertFalse(focusGuardManager.isActive)
    }

    func testFocusGuardManagerDNDApps() async throws {
        let focusGuardManager = FocusGuardManager()

        focusGuardManager.addDNDApp("com.test.app", appName: "Test App")

        XCTAssertEqual(focusGuardManager.dndAppsList.count, 1)
        XCTAssertTrue(focusGuardManager.isDNDApp("com.test.app"))

        focusGuardManager.removeDNDApp("com.test.app")

        XCTAssertEqual(focusGuardManager.dndAppsList.count, 0)
        XCTAssertFalse(focusGuardManager.isDNDApp("com.test.app"))
    }

    func testFocusGuardManagerEnableDisable() async throws {
        let focusGuardManager = FocusGuardManager()

        focusGuardManager.setEnabled(true)
        XCTAssertTrue(focusGuardManager.isEnabled)

        focusGuardManager.enable()
        XCTAssertTrue(focusGuardManager.isActive)

        focusGuardManager.disable()
        XCTAssertFalse(focusGuardManager.isActive)

        focusGuardManager.setEnabled(false)
        XCTAssertFalse(focusGuardManager.isEnabled)
    }

    // MARK: - OnboardingCoordinator Tests
    func testOnboardingCoordinatorInitialization() async throws {
        let onboardingCoordinator = OnboardingCoordinator(modelContext: modelContext)

        XCTAssertNotNil(onboardingCoordinator)
        XCTAssertFalse(onboardingCoordinator.isOnboardingComplete)
        XCTAssertEqual(onboardingCoordinator.currentStep, .welcome)
    }

    func testOnboardingCoordinatorNavigation() async throws {
        let onboardingCoordinator = OnboardingCoordinator(modelContext: modelContext)

        XCTAssertEqual(onboardingCoordinator.currentStep, .welcome)

        onboardingCoordinator.nextStep()
        XCTAssertEqual(onboardingCoordinator.currentStep, .accessibility)

        onboardingCoordinator.previousStep()
        XCTAssertEqual(onboardingCoordinator.currentStep, .welcome)
    }

    func testOnboardingCoordinatorSkip() async throws {
        let onboardingCoordinator = OnboardingCoordinator(modelContext: modelContext)

        XCTAssertFalse(onboardingCoordinator.isOnboardingComplete)

        onboardingCoordinator.skipOnboarding()

        XCTAssertTrue(onboardingCoordinator.isOnboardingComplete)
    }

    // MARK: - Constants Tests
    func testAppConstants() {
        XCTAssertEqual(AppConstants.Limits.maxRecentApps, 5)
        XCTAssertEqual(AppConstants.Limits.maxCustomModes, 20)
    }
}
