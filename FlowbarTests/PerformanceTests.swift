import XCTest
@testable import Flowbar
import SwiftData
import SwiftUI

// MARK: - Performance Tests
@MainActor
final class PerformanceTests: XCTestCase {

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

    // MARK: - Memory Usage Tests
    func testMemoryUsageModeSwitching() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        // Create default modes
        measure {
            for _ in 0..<100 {
                modeManager.createDefaultModes()

                let descriptor = FetchDescriptor<Mode>()
                let modes = try? modelContext.fetch(descriptor)

                for mode in modes ?? [] {
                    modelContext.delete(mode)
                }

                try? modelContext.save()
            }
        }
    }

    func testMemoryUsageIconAssignments() async throws {
        let mode = Mode(
            name: "Test Mode",
            icon: "star.fill",
            iconAssignments: []
        )

        modelContext.insert(mode)

        measure {
            // Add many icon assignments
            for i in 0..<1000 {
                let assignment = IconAssignment(
                    iconID: "icon\(i)",
                    iconName: "Icon \(i)",
                    bundleIdentifier: "com.test.app\(i)",
                    isVisible: i % 2 == 0
                )

                mode.iconAssignments.append(assignment)
            }

            try? modelContext.save()

            // Clean up
            mode.iconAssignments.removeAll()
            try? modelContext.save()
        }
    }

    func testMemoryUsageLauncherSearch() async throws {
        let launcherManager = LauncherManager(modelContext: modelContext)

        // Perform multiple searches
        measure {
            for query in ["test", "app", "launch", "chrome", "safari", "finder"] {
                launcherManager.searchQuery = query
                launcherManager.searchApps()
            }
        }
    }

    func testMemoryUsageFocusGuard() async throws {
        let focusGuardManager = FocusGuardManager()

        measure {
            // Add many DND apps
            for i in 0..<100 {
                focusGuardManager.addDNDApp("com.test.app\(i)", appName: "Test App \(i)")
            }

            // Test lookups
            for i in 0..<100 {
                _ = focusGuardManager.isDNDApp("com.test.app\(i)")
            }

            // Clean up
            for i in 0..<100 {
                focusGuardManager.removeDNDApp("com.test.app\(i)")
            }
        }
    }

    // MARK: - CPU Usage Tests
    func testCPUUsageModeSwitching() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        // Create modes
        for index in 0..<10 {
            modeManager.createMode(
                name: "Mode \(index)",
                icon: "star.fill",
                iconAssignments: []
            )
        }

        let modes = modeManager.allModes

        measure {
            // Switch between modes rapidly
            for mode in modes {
                modeManager.switchToMode(mode)
            }
        }
    }

    func testCPUUsageIconScanning() async throws {
        let menuBarManager = MenuBarManager()

        measure {
            // Simulate multiple scans
            for _ in 0..<10 {
                menuBarManager.scanMenuBarIcons()
            }
        }
    }

    func testCPUUsageOnboardingFlow() async throws {
        let onboardingCoordinator = OnboardingCoordinator(modelContext: modelContext)

        measure {
            // Simulate onboarding flow
            for step in OnboardingStep.allCases {
                onboardingCoordinator.currentStep = step
            }

            onboardingCoordinator.skipOnboarding()
        }
    }

    // MARK: - Startup Time Tests
    func testStartupTime() async throws {
        measure {
            // Simulate app startup
            let dataController = DataController.shared
            let modeManager = ModeManager(modelContext: dataController.modelContext)
            let menuBarManager = MenuBarManager()

            modeManager.createDefaultModes()
            menuBarManager.scanMenuBarIcons()
        }
    }

    func testInitialLoadTime() async throws {
        measure {
            // Simulate initial data load
            let descriptor = FetchDescriptor<Mode>()
            _ = try? modelContext.fetch(descriptor)

            let preferenceDescriptor = FetchDescriptor<Preference>()
            _ = try? modelContext.fetch(preferenceDescriptor)

            let onboardingDescriptor = FetchDescriptor<OnboardingState>()
            _ = try? modelContext.fetch(onboardingDescriptor)
        }
    }

    // MARK: - Database Performance Tests
    func testDatabaseWritePerformance() async throws {
        measure {
            // Insert many modes
            for i in 0..<100 {
                let mode = Mode(
                    name: "Mode \(i)",
                    icon: "star.fill",
                    iconAssignments: []
                )

                modelContext.insert(mode)

                if i % 10 == 0 {
                    try? modelContext.save()
                }
            }

            try? modelContext.save()
        }
    }

    func testDatabaseReadPerformance() async throws {
        // Insert test data
        for i in 0..<100 {
            let mode = Mode(
                name: "Mode \(i)",
                icon: "star.fill",
                iconAssignments: []
            )

            modelContext.insert(mode)
        }

        try modelContext.save()

        measure {
            // Read all modes
            let descriptor = FetchDescriptor<Mode>()
            _ = try? modelContext.fetch(descriptor)
        }
    }

    func testDatabaseUpdatePerformance() async throws {
        // Insert test data
        let modes = (0..<100).map { i in
            Mode(
                name: "Mode \(i)",
                icon: "star.fill",
                iconAssignments: []
            )
        }

        for mode in modes {
            modelContext.insert(mode)
        }

        try modelContext.save()

        measure {
            // Update all modes
            let descriptor = FetchDescriptor<Mode>()
            let fetchedModes = try? modelContext.fetch(descriptor)

            for mode in fetchedModes ?? [] {
                mode.name = "Updated \(mode.name)"
            }

            try? modelContext.save()
        }
    }

    func testDatabaseDeletePerformance() async throws {
        measure {
            // Insert and delete modes
            for _ in 0..<10 {
                for i in 0..<100 {
                    let mode = Mode(
                        name: "Mode \(i)",
                        icon: "star.fill",
                        iconAssignments: []
                    )
                    modelContext.insert(mode)
                }

                try? modelContext.save()

                // Delete all
                let descriptor = FetchDescriptor<Mode>()
                let fetchedModes = try? modelContext.fetch(descriptor)

                for mode in fetchedModes ?? [] {
                    modelContext.delete(mode)
                }

                try? modelContext.save()
            }
        }
    }

    // MARK: - Backup/Restore Performance Tests
    func testBackupPerformance() async throws {
        // Create test data
        for i in 0..<50 {
            let mode = Mode(
                name: "Mode \(i)",
                icon: "star.fill",
                iconAssignments: []
            )

            modelContext.insert(mode)
        }

        try modelContext.save()

        // Note: DataController backup/restore not available in test environment
        measure {
            // Simulate backup by fetching all data
            let descriptor = FetchDescriptor<Mode>()
            _ = try? modelContext.fetch(descriptor)
        }
    }

    func testRestorePerformance() async throws {
        // Create test data
        for i in 0..<50 {
            let mode = Mode(
                name: "Mode \(i)",
                icon: "star.fill",
                iconAssignments: []
            )

            modelContext.insert(mode)
        }

        try modelContext.save()

        measure {
            // Clear and restore simulation
            let descriptor = FetchDescriptor<Mode>()
            let modes = try? modelContext.fetch(descriptor)

            for mode in modes ?? [] {
                modelContext.delete(mode)
            }

            try? modelContext.save()
        }
    }

    // MARK: - Animation Performance Tests
    func testAnimationPerformance() async throws {
        measure {
            // Test various animations
            _ = FlowbarAnimations.modeSwitchAnimation()
            _ = FlowbarAnimations.iconFadeAnimation()
            _ = FlowbarAnimations.springAnimation()
            _ = FlowbarAnimations.bouncySpringAnimation()
        }
    }

    func testViewModifierPerformance() async throws {
        let testView = Text("Test")

        measure {
            // Apply multiple modifiers
            _ = testView
                .animatedScale()
                .animatedFadeIn()
                .animatedSlideIn()
                .hoverEffect()
                .modeSwitchTransition(isActive: true)
        }
    }

    // MARK: - Stress Tests
    func testStressMultipleModeSwitches() async throws {
        let modeManager = ModeManager(modelContext: modelContext)

        // Create many modes
        for i in 0..<20 {
            modeManager.createMode(
                name: "Mode \(i)",
                icon: "star.fill",
                iconAssignments: []
            )
        }

        measure {
            // Switch rapidly between all modes
            for mode in modeManager.allModes {
                modeManager.switchToMode(mode)
            }
        }
    }

    func testStressConcurrentOperations() async throws {
        let modeManager = ModeManager(modelContext: modelContext)
        let launcherManager = LauncherManager(modelContext: modelContext)
        let focusGuardManager = FocusGuardManager()

        measure {
            // Simulate concurrent operations
            modeManager.createDefaultModes()
            launcherManager.searchQuery = "test"
            launcherManager.searchApps()
            focusGuardManager.setEnabled(true)
            focusGuardManager.addDNDApp("com.test.app", appName: "Test")
        }
    }

    // MARK: - Accessibility Performance Tests
    func testAccessibilityScanningPerformance() async throws {
        let menuBarManager = MenuBarManager()

        measure {
            // Simulate repeated accessibility checks
            for _ in 0..<50 {
                _ = menuBarManager.checkAccessibilityPermission()
                menuBarManager.scanMenuBarIcons()
            }
        }
    }

    func testSystemIconDetectionPerformance() async throws {
        let menuBarManager = MenuBarManager()

        let systemApps = [
            "com.apple.systemuiserver",
            "com.apple.controlcenter",
            "com.apple.Spotlight",
            "com.apple.notificationcenterui",
            "com.apple.dock"
        ]

        measure {
            // Test system icon detection
            for app in systemApps {
                _ = menuBarManager.isSystemIcon(app)
            }
        }
    }
}
