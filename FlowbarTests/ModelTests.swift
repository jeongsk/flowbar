import XCTest
@testable import Flowbar
import SwiftData

// MARK: - Model Tests
final class ModelTests: XCTestCase {

    var modelContainer: ModelContainer!
    var modelContext: ModelContext!

    override func setUp() async throws {
        // Create in-memory container for testing
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

    // MARK: - Mode Model Tests
    func testModeCreation() throws {
        let mode = Mode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: []
        )

        modelContext.insert(mode)
        try modelContext.save()

        let descriptor = FetchDescriptor<Mode>(
            predicate: #Predicate { $0.name == "Test Mode" }
        )
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.name, "Test Mode")
        XCTAssertEqual(results.first?.icon, "star.fill")
    }

    func testModeWithIconAssignments() throws {
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

        let mode = Mode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: [assignment1, assignment2]
        )

        modelContext.insert(mode)
        try modelContext.save()

        XCTAssertFalse(mode.iconAssignments.isEmpty)
        XCTAssertEqual(mode.iconAssignments.count, 2)
        XCTAssertTrue(mode.iconAssignments[0].isVisible)
        XCTAssertFalse(mode.iconAssignments[1].isVisible)
    }

    func testModeDeletion() throws {
        let mode = Mode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: []
        )

        modelContext.insert(mode)
        try modelContext.save()

        let descriptor = FetchDescriptor<Mode>()
        var results = try modelContext.fetch(descriptor)
        XCTAssertEqual(results.count, 1)

        modelContext.delete(mode)
        try modelContext.save()

        results = try modelContext.fetch(descriptor)
        XCTAssertEqual(results.count, 0)
    }

    // MARK: - IconAssignment Model Tests
    func testIconAssignmentCreation() throws {
        let assignment = IconAssignment(
            iconID: "test-id",
            iconName: "Test Icon",
            bundleIdentifier: "com.test.app",
            isVisible: true
        )

        modelContext.insert(assignment)
        try modelContext.save()

        let descriptor = FetchDescriptor<IconAssignment>()
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.iconID, "test-id")
        XCTAssertEqual(results.first?.iconName, "Test Icon")
        XCTAssertEqual(results.first?.bundleIdentifier, "com.test.app")
        XCTAssertTrue(results.first?.isVisible ?? false)
    }

    // MARK: - Preference Model Tests
    func testPreferenceCreation() throws {
        let preference = Preference()
        preference.launchAtLogin = true
        preference.appearanceMode = "dark"
        preference.showMenuBarIcon = true
        preference.focusGuardEnabled = true

        modelContext.insert(preference)
        try modelContext.save()

        let descriptor = FetchDescriptor<Preference>()
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first?.launchAtLogin ?? false)
        XCTAssertEqual(results.first?.appearanceMode, "dark")
        XCTAssertTrue(results.first?.focusGuardEnabled ?? false)
    }

    // MARK: - OnboardingState Model Tests
    func testOnboardingStateCreation() throws {
        let onboardingState = OnboardingState()

        XCTAssertFalse(onboardingState.isComplete)

        onboardingState.markStepComplete("welcome")
        onboardingState.markStepComplete("accessibility")

        modelContext.insert(onboardingState)
        try modelContext.save()

        let descriptor = FetchDescriptor<OnboardingState>()
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.completedSteps.count, 2)
    }

    func testOnboardingCompletion() throws {
        let onboardingState = OnboardingState()

        // Mark all steps as complete
        let steps = ["welcome", "accessibility", "iconScanning", "iconAssignment",
                     "modeCreation", "shortcuts", "complete"]

        for step in steps {
            onboardingState.markStepComplete(step)
        }

        onboardingState.complete()

        XCTAssertTrue(onboardingState.isComplete)
    }

    // MARK: - AppAssignment Model Tests
    func testAppAssignmentCreation() throws {
        let assignment = AppAssignment(
            bundleIdentifier: "com.test.app",
            appName: "Test App",
            isRecent: true
        )

        modelContext.insert(assignment)
        try modelContext.save()

        let descriptor = FetchDescriptor<AppAssignment>()
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bundleIdentifier, "com.test.app")
        XCTAssertTrue(results.first?.isRecent ?? false)
        XCTAssertNotNil(results.first?.lastUsed)
    }

    func testAppAssignmentMarkAsUsed() throws {
        let assignment = AppAssignment(
            bundleIdentifier: "com.test.app",
            appName: "Test App",
            isRecent: true
        )

        let originalDate = assignment.lastUsed

        // Wait a moment
        Thread.sleep(forTimeInterval: 0.1)

        assignment.markAsUsed()

        XCTAssertTrue(assignment.lastUsed > originalDate)
    }

    // MARK: - DNDApp Model Tests
    func testDNDAppCreation() throws {
        let dndApp = DNDApp(
            bundleIdentifier: "com.dnd.app",
            appName: "DND App"
        )

        XCTAssertTrue(dndApp.isEnabled)

        modelContext.insert(dndApp)
        try modelContext.save()

        let descriptor = FetchDescriptor<DNDApp>()
        let results = try modelContext.fetch(descriptor)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.bundleIdentifier, "com.dnd.app")
        XCTAssertTrue(results.first?.isEnabled ?? false)
    }

    func testDNDAppToggle() throws {
        let dndApp = DNDApp(
            bundleIdentifier: "com.dnd.app",
            appName: "DND App"
        )

        XCTAssertTrue(dndApp.isEnabled)

        dndApp.isEnabled = false
        XCTAssertFalse(dndApp.isEnabled)

        dndApp.isEnabled = true
        XCTAssertTrue(dndApp.isEnabled)
    }

    // MARK: - Model Relationship Tests
    func testModeIconAssignmentRelationship() throws {
        let mode = Mode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: []
        )

        let assignment = IconAssignment(
            iconID: "test-id",
            iconName: "Test Icon",
            bundleIdentifier: "com.test.app",
            isVisible: true
        )

        mode.iconAssignments.append(assignment)

        modelContext.insert(mode)
        try modelContext.save()

        XCTAssertFalse(mode.iconAssignments.isEmpty)
        XCTAssertEqual(mode.iconAssignments.first?.iconID, "test-id")
    }
}
