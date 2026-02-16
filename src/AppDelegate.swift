import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var modeManager = ModeManager()
    var menuBarController = MenuBarController()
    var focusGuard = FocusGuard()
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Check Accessibility permissions
        checkAccessibilityPermissions()
        
        // Setup status bar item
        setupStatusBar()
        
        // Load saved modes
        modeManager.loadModes()
        
        // Start Focus Guard if enabled
        if let currentMode = modeManager.currentMode, currentMode.focusGuardEnabled {
            focusGuard.enable()
        }
    }
    
    private func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let trusted = AXIsProcessTrustedWithOptions(options as CFDictionary)
        
        if !trusted {
            // Show permission guide
            showPermissionAlert()
        }
    }
    
    private func showPermissionAlert() {
        let alert = NSAlert()
        alert.messageText = "Accessibility Permission Required"
        alert.informativeText = "Flowbar needs Accessibility access to manage your menu bar. Please grant permission in System Settings > Privacy & Security > Accessibility."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Open System Settings")
        alert.addButton(withTitle: "Later")
        
        if alert.runModal() == .alertFirstButtonReturn {
            NSWorkspace.shared.open(URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!)
        }
    }
    
    private func setupStatusBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "circle.grid.2x2", accessibilityDescription: "Flowbar")
            button.action = #selector(statusBarButtonClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    @objc func statusBarButtonClicked() {
        guard let event = NSApp.currentEvent else { return }
        
        if event.type == .rightMouseUp {
            // Show settings
            openSettings(nil)
        } else {
            // Show mode picker
            showModePopover()
        }
    }
    
    private func showModePopover() {
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 400)
        popover.behavior = .transient
        
        let modePickerView = ModePickerView(
            modes: modeManager.modes,
            currentMode: modeManager.currentMode,
            onSelectMode: { [weak self] mode in
                self?.switchToMode(mode)
                popover.close()
            }
        )
        
        popover.contentViewController = NSHostingController(rootView: modePickerView)
        popover.show(relativeTo: statusItem?.button?.bounds ?? .zero, of: statusItem?.button ?? NSView(), preferredEdge: .minY)
        
        self.popover = popover
    }
    
    private func switchToMode(_ mode: Mode) {
        modeManager.switchTo(mode)
        menuBarController.apply(mode)
        
        if mode.focusGuardEnabled {
            focusGuard.enable()
        } else {
            focusGuard.disable()
        }
        
        // Update menu bar icon
        updateStatusBarIcon()
        
        // Send notification
        sendModeChangeNotification(mode)
    }
    
    private func updateStatusBarIcon() {
        if let mode = modeManager.currentMode {
            statusItem?.button?.image = NSImage(systemSymbolName: mode.icon, accessibilityDescription: mode.name)
        }
    }
    
    private func sendModeChangeNotification(_ mode: Mode) {
        let notification = NSUserNotification()
        notification.title = "Mode Changed"
        notification.informativeText = "Switched to \(mode.name) mode"
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
    }
    
    @objc func openSettings(_ sender: Any?) {
        let settingsView = SettingsView(
            modes: modeManager.modes,
            menuBarItems: menuBarController.menuBarItems
        )
        
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .miniaturizable, .resizable],
            backing: .buffered,
            defer: false
        )
        
        window.title = "Flowbar Settings"
        window.contentViewController = NSHostingController(rootView: settingsView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quit() {
        NSApp.terminate(nil)
    }
    
    func buildMenu() -> NSMenu {
        let menu = NSMenu()
        
        // Current mode indicator
        let currentModeItem = NSMenuItem(
            title: "Current: \(modeManager.currentMode?.name ?? "None")",
            action: nil,
            keyEquivalent: ""
        )
        currentModeItem.isEnabled = false
        menu.addItem(currentModeItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // Mode list
        for (index, mode) in modeManager.modes.enumerated() {
            let item = NSMenuItem(
                title: mode.name,
                action: #selector(menuSwitchMode(_:)),
                keyEquivalent: "\(index + 1)"
            )
            item.representedObject = mode
            item.keyEquivalentModifierMask = [.command, .shift]
            
            if modeManager.currentMode?.id == mode.id {
                item.state = .on
            }
            
            menu.addItem(item)
        }
        
        menu.addItem(NSMenuItem.separator())
        
        // Quick actions
        menu.addItem(NSMenuItem(
            title: "Capture Workflow",
            action: #selector(captureWorkflow),
            keyEquivalent: "s"
        ))
        
        menu.addItem(NSMenuItem.separator())
        
        // Settings
        menu.addItem(NSMenuItem(
            title: "Preferences...",
            action: #selector(openSettings),
            keyEquivalent: ","
        ))
        
        menu.addItem(NSMenuItem(
            title: "Quit Flowbar",
            action: #selector(quit),
            keyEquivalent: "q"
        ))
        
        return menu
    }
    
    @objc func menuSwitchMode(_ sender: NSMenuItem) {
        guard let mode = sender.representedObject as? Mode else { return }
        switchToMode(mode)
    }
    
    @objc func captureWorkflow() {
        // TODO: Implement workflow capture
    }
}
