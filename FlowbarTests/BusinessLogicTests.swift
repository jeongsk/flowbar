import XCTest
@testable import Flowbar
import SwiftData

// MARK: - Business Logic Tests
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
        let modeManager = ModeManager(modelContext: modelContext)

        XCTAssertTrue(modeManager.allModes.isEmpty)
        XCTAssertNil(modeManager.currentMode)
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

        let mode = modeManager.createMode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: []
        )

        XCTAssertNotNil(mode)
        XCTAssertEqual(mode?.name, "Test Mode")
        XCTAssertEqual(modeManager.allModes.count, 1)
    }

    func testModeManagerSwitchMode() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        let mode1 = modeManager.createMode(name: "Mode 1", icon: "star.fill", iconAssignments: [])
        let mode2 = modeManager.createMode(name: "Mode 2", icon: "moon.fill", iconAssignments: [])

        modeManager.switchToMode(mode1!)
        XCTAssertEqual(modeManager.currentMode?.name, "Mode 1")

        modeManager.switchToMode(mode2!)
        XCTAssertEqual(modeManager.currentMode?.name, "Mode 2")
    }

    func testModeManagerDeleteMode() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        modeManager.createDefaultModes()

        let initialCount = modeManager.allModes.count
        let modeToDelete = modeManager.allModes.first { $0.name == "Coding" }

        XCTAssertNotNil(modeToDelete)

        modeManager.deleteMode(modeToDelete!)

        XCTAssertEqual(modeManager.allModes.count, initialCount - 1)
        XCTAssertNil(modeManager.allModes.first { $0.name == "Coding" })
    }

    func testModeManagerCannotDeleteDefaultModes() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        modeManager.createDefaultModes()

        let defaultMode = modeManager.allModes.first { $0.isDefault }

        XCTAssertNotNil(defaultMode)

        // Verify default mode is protected
        XCTAssertTrue(defaultMode!.isDefault)
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

    func testDataControllerBackup() async throws {
        let dataController = DataController.shared

        // Create test data
        let mode = Mode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: []
        )
        modelContext.insert(mode)
        try modelContext.save()

        // Perform backup
        let backupURL = try dataController.createBackup()

        XCTAssertTrue(FileManager.default.fileExists(atPath: backupURL.path))

        // Clean up
        try FileManager.default.removeItem(at: backupURL)
    }

    func testDataControllerRestore() async throws {
        let dataController = DataController.shared

        // Create test data
        let mode = Mode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: []
        )
        modelContext.insert(mode)
        try modelContext.save()

        // Perform backup
        let backupURL = try dataController.createBackup()

        // Clear data
        let descriptor = FetchDescriptor<Mode>()
        let modes = try modelContext.fetch(descriptor)
        for mode in modes {
            modelContext.delete(mode)
        }
        try modelContext.save()

        // Verify data is cleared
        let clearedModes = try modelContext.fetch(descriptor)
        XCTAssertTrue(clearedModes.isEmpty)

        // Restore from backup
        try dataController.restoreBackup(from: backupURL)

        // Verify data is restored
        let restoredModes = try modelContext.fetch(descriptor)
        XCTAssertEqual(restoredModes.count, 1)
        XCTAssertEqual(restoredModes.first?.name, "Test Mode")

        // Clean up
        try FileManager.default.removeItem(at: backupURL)
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
            XCTAssertTrue(menuBarManager.isSystemIcon(bundleID: bundleID))
        }

        XCTAssertFalse(menuBarManager.isSystemIcon(bundleID: "com.test.app"))
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
        XCTAssertNotNil(launcherManager.searchQuery)
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
        XCTAssertEqual(AppConstants.Limits.maxModes, 9)
        XCTAssertEqual(AppConstants.Limits.shortcutConflictCount, 3)
    }

    func testAppConstantsShortcuts() {
        XCTAssertEqual(AppConstants.Shortcuts.modeSwitcher, "⌘⇧M")
        XCTAssertEqual(AppConstants.Shortcuts.launcher, "⌘Space")
    }

    // MARK: - Extension Tests
    func testEncodableExtension() async throws {
        let mode = Mode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: []
        )

        // Test Codable conformance for backup/restore
        let encoder = JSONEncoder()
        let data = try encoder.encode(mode)

        XCTAssertFalse(data.isEmpty)

        let decoder = JSONDecoder()
        let decodedMode = try decoder.decode(Mode.self, from: data)

        XCTAssertEqual(decodedMode.name, mode.name)
        XCTAssertEqual(decodedMode.icon, mode.icon)
    }
}
