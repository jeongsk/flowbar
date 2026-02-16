import Cocoa
import SwiftUI
import SwiftData

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var onboardingWindow: NSWindow?

    // Managers
    private var menuBarManager: MenuBarManager?
    private var modeManager: ModeManager?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Initialize managers
        let modelContext = DataController.shared.modelContext
        menuBarManager = MenuBarManager()
        modeManager = ModeManager(modelContext: modelContext)

        // Setup status bar item
        setupStatusBar()

        // Check accessibility permission
        checkAccessibilityPermission()

        // Check onboarding state
        checkOnboarding()
    }

    func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSVariableStatusItemLength)

        if let button = statusItem?.button {
            // Use SF Symbol for status bar icon
            let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
            let image = NSImage(systemSymbolName: "line.3.horizontal.circle.fill", accessibilityDescription: "Flowbar")
            image?.symbolConfiguration = config
            button.image = image

            // Set click action
            button.action = #selector(statusBarClicked)
            button.target = self

            // Enable right-click menu
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }

    @objc func statusBarClicked(_ sender: NSStatusBarButton?) {
        guard let event = NSApp.currentEvent() else { return }

        if event.type == .rightMouseUp {
            showContextMenu(sender: sender)
        } else {
            togglePopover(sender: sender)
        }
    }

    func showContextMenu(sender: NSStatusBarButton?) {
        let menu = NSMenu()

        // Mode switching items
        if let modeManager = modeManager {
            for mode in modeManager.allModes {
                let item = NSMenuItem(
                    title: mode.name,
                    action: #selector(switchToMode(_:)),
                    keyEquivalent: ""
                )
                item.tag = modeManager.allModes.firstIndex(where: { $0.id == mode.id }) ?? 0
                item.target = self

                // Add checkmark for current mode
                if modeManager.currentMode?.id == mode.id {
                    item.state = .on
                }

                menu.addItem(item)
            }

            menu.addItem(NSMenuItem.separator())
        }

        // Settings
        let settingsItem = NSMenuItem(
            title: "Settings...",
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)

        // Quit
        let quitItem = NSMenuItem(
            title: "Quit Flowbar",
            action: #selector(quit),
            keyEquivalent: "q"
        )
        quitItem.target = self
        menu.addItem(quitItem)

        // Show menu
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    @objc func switchToMode(_ sender: NSMenuItem) {
        guard let modeManager = modeManager,
              sender.tag < modeManager.allModes.count else { return }

        let mode = modeManager.allModes[sender.tag]
        modeManager.switchToMode(mode)

        // Update status bar icon
        updateStatusBarIcon(for: mode)
    }

    func updateStatusBarIcon(for mode: Mode) {
        guard let button = statusItem?.button,
              let iconName = mode.icon else { return }

        let config = NSImage.SymbolConfiguration(pointSize: 16, weight: .regular)
        let image = NSImage(systemSymbolName: iconName, accessibilityDescription: mode.name)
        image?.symbolConfiguration = config
        button.image = image
    }

    func togglePopover(sender: NSStatusBarButton?) {
        if let popover = popover, popover.isShown {
            popover.performClose(sender)
            return
        }

        guard let button = statusItem?.button else { return }

        // Create popover if needed
        if popover == nil {
            popover = NSPopover()
            popover?.contentSize = NSSize(width: 300, height: 400)
            popover?.behavior = .transient
            popover?.contentViewController = NSHostingController(
                rootView: ModeSwitcherView()
                    .environment(\.modelContext, DataController.shared.modelContext)
            )
        }

        // Show popover
        popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)

        // Activate app to ensure popover gets focus
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func openSettings() {
        SettingsWindowManager.shared.showSettings()
    }

    @objc func quit() {
        NSApplication.shared.terminate(nil)
    }

    // MARK: - Accessibility Permission
    func checkAccessibilityPermission() {
        guard let menuBarManager = menuBarManager else { return }

        let hasPermission = menuBarManager.checkAccessibilityPermission()

        if !hasPermission {
            showAccessibilityPermissionAlert()
        }
    }

    func showAccessibilityPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Flowbar needs accessibility permission to detect and filter menu bar icons.\n\nPlease grant permission in System Settings > Privacy & Security > Accessibility."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            // Open System Settings
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility") {
                NSWorkspace.shared.open(url)
            }
        }
    }

    // MARK: - Onboarding
    func checkOnboarding() {
        let modelContext = DataController.shared.modelContext
        let onboardingCoordinator = OnboardingCoordinator(modelContext: modelContext)

        if !onboardingCoordinator.isOnboardingComplete {
            showOnboarding()
        }
    }

    func showOnboarding() {
        let modelContext = DataController.shared.modelContext
        let onboardingCoordinator = OnboardingCoordinator(modelContext: modelContext)
        onboardingCoordinator.startOnboarding()
    }

    // MARK: - Application Lifecycle
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        if !flag {
            // Show mode switcher when dock icon is clicked
            if let button = statusItem?.button {
                togglePopover(sender: button)
            }
        }
        return true
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Cleanup
        statusItem = nil
    }
}
