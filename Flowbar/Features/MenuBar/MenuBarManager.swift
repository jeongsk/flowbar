import Foundation
import Cocoa
import ApplicationServices

// MARK: - Menu Bar Icon Metadata
struct MenuBarIcon: Identifiable, Hashable {
    let id: String
    let name: String
    let bundleIdentifier: String?
    let position: CGPoint
    let isSystemIcon: Bool
    let axElement: AXUIElement?

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Menu Bar Manager
@MainActor
final class MenuBarManager: ObservableObject {
    @Published var detectedIcons: [MenuBarIcon] = []
    @Published var hasAccessibilityPermission: Bool = false
    @Published var isScanning: Bool = false

    private var axObserver: AXObserver?
    private var systemWideElement: AXUIElement

    // System icon bundle identifiers
    private let systemIconIdentifiers = Set([
        "com.apple.controlcenter",
        "com.apple.systemuiserver",
        "com.apple.menuextra.clock",
        "com.apple.menuextra.battery",
        "com.apple.menuextra.airport",
        "com.apple.menuextra.volume",
        "com.apple.menuextra.bluetooth",
        "com.apple.menuextra.wifi",
        "com.apple.spotlight"
    ])

    init() {
        systemWideElement = AXUIElementCreateSystemWide()
    }

    // MARK: - Accessibility Permission
    func checkAccessibilityPermission() -> Bool {
        let options: [String: Bool] = [
            kAXTrustedCheckOptionPrompt.takeLog.takeUnretainedValue() as String: false
        ] as CFDictionary

        let accessEnabled = AXIsProcessTrustedWithOptions(options)

        DispatchQueue.main.async {
            self.hasAccessibilityPermission = accessEnabled

            // If permission is granted, start monitoring
            if accessEnabled {
                self.setupIconMonitoring()
            }
        }

        return accessEnabled
    }

    func requestAccessibilityPermission() {
        let options: [String: Bool] = [
            kAXTrustedCheckOptionPrompt.takeLog.takeUnretainedValue() as String: true
        ] as CFDictionary

        _ = AXIsProcessTrustedWithOptions(options)
    }

    // MARK: - Icon Detection
    func scanMenuBarIcons() {
        guard hasAccessibilityPermission else {
            print("Accessibility permission not granted")
            return
        }

        isScanning = true

        Task {
            let icons = await performIconScan()

            DispatchQueue.main.async {
                self.detectedIcons = icons
                self.isScanning = false

                print("Scanned \(icons.count) menu bar icons")
                for icon in icons {
                    print("  - \(icon.name) [\(icon.bundleIdentifier ?? "Unknown")]")
                }
            }
        }
    }

    private func performIconScan() async -> [MenuBarIcon] {
        var icons: [MenuBarIcon] = []
        var iconSet = Set<String>() // Track unique icons

        // Get menu bar UI element
        guard let menuBarElement = getMenuBarElement() else {
            print("Failed to get menu bar element")
            return []
        }

        // Get all children of menu bar
        var children: CFArray?
        let result = AXUIElementCopyAttributeValue(
            menuBarElement,
            kAXChildrenAttribute as CFString,
            &children
        )

        guard result == .success,
              let childrenArray = children as? [AXUIElement] else {
            print("Failed to get menu bar children: \(result)")
            return []
        }

        // Process each child element
        for (index, element) in childrenArray.enumerated() {
            if let icon = extractIconInfo(from: element, index: index) {
                // Avoid duplicates
                if !iconSet.contains(icon.id) {
                    iconSet.insert(icon.id)
                    icons.append(icon)
                }
            }
        }

        // Sort by position (left to right)
        icons.sort { $0.position.x < $1.position.x }

        return icons
    }

    private func getMenuBarElement() -> AXUIElement? {
        // Get the focused application
        var focusedApp: AnyObject?
        let focusedResult = AXUIElementCopyAttributeValue(
            systemWideElement,
            kAXFocusedApplicationAttribute as CFString,
            &focusedApp
        )

        guard focusedResult == .success,
              let focusedAppElement = focusedApp as? AXUIElement else {
            return nil
        }

        // Get menu bar of focused app
        var menuBar: AnyObject?
        let menuBarResult = AXUIElementCopyAttributeValue(
            focusedAppElement,
            kAXMenuBarAttribute as CFString,
            &menuBar
        )

        guard menuBarResult == .success,
              let menuBarElement = menuBar as? AXUIElement else {
            return nil
        }

        return menuBarElement
    }

    private func extractIconInfo(from element: AXUIElement, index: Int) -> MenuBarIcon? {
        // Get position
        var position: AnyObject?
        let positionResult = AXUIElementCopyAttributeValue(
            element,
            kAXPositionAttribute as CFString,
            &position
        )

        var point = CGPoint.zero
        if let positionValue = position as? [String: CGFloat],
           let x = positionValue["x"],
           let y = positionValue["y"] {
            point = CGPoint(x: x, y: y)
        } else if let positionValue = position as? AXValue {
            AXValueGetValue(positionValue, .cgPoint, &point)
        }

        // Get role and title
        var role: AnyObject?
        var title: AnyObject?

        AXUIElementCopyAttributeValue(element, kAXRoleAttribute as CFString, &role)
        AXUIElementCopyAttributeValue(element, kAXTitleAttribute as CFString, &title)

        let roleValue = (role as? String) ?? ""
        let titleValue = (title as? String) ?? ""

        // Skip non-menu bar items
        if roleValue != kAXMenuBarItemRole && roleValue != kAXMenuRole {
            return nil
        }

        // Get bundle identifier
        var bundleID: AnyObject?
        var isSystemIcon = false
        var bundleIdentifier: String? = nil

        if AXUIElementCopyAttributeValue(
            element,
            kAXApplicationAttribute as CFString,
            &bundleID
        ) == .success,
           let appElement = bundleID as? AXUIElement {

            var appBundleID: AnyObject?
            if AXUIElementCopyAttributeValue(
                appElement,
                kAXBundleIdentifierAttribute as CFString,
                &appBundleID
            ) == .success,
               let bundleIDString = appBundleID as? String {
                bundleIdentifier = bundleIDString
                isSystemIcon = systemIconIdentifiers.contains(bundleIDString)
            }
        }

        // Generate unique ID
        let iconID = "\(bundleIdentifier ?? "system")_\(titleValue)_\(index)"

        return MenuBarIcon(
            id: iconID,
            name: titleValue.isEmpty ? "Menu Item \(index)" : titleValue,
            bundleIdentifier: bundleIdentifier,
            position: point,
            isSystemIcon: isSystemIcon,
            axElement: element
        )
    }

    // MARK: - Icon Visibility Control
    func setIconVisibility(_ iconID: String, visible: Bool) {
        guard hasAccessibilityPermission else { return }

        // Find the icon element
        guard let icon = detectedIcons.first(where: { $0.id == iconID }),
              let element = icon.axElement else {
            return
        }

        // Set AXHidden attribute
        let hiddenValue: CFBoolean = visible ? kCFBooleanFalse : kCFBooleanTrue
        let result = AXUIElementSetAttributeValue(
            element,
            kAXHiddenAttribute as CFString,
            hiddenValue
        )

        if result != .success {
            print("Failed to set icon visibility: \(result)")
        }
    }

    func setIconAlpha(_ iconID: String, alpha: CGFloat) {
        guard hasAccessibilityPermission else { return }

        guard let icon = detectedIcons.first(where: { $0.id == iconID }),
              let element = icon.axElement else {
            return
        }

        // Note: This may not work for all apps due to macOS restrictions
        // Alternative approach is to use CGEvent manipulation
    }

    // MARK: - Setup Monitoring
    func setupIconMonitoring() {
        guard hasAccessibilityPermission else { return }

        // Create observer for menu bar changes
        let callback: AXObserverCallback = { observer, element, notification, refcon in
            guard let refcon = refcon else { return }

            let manager = Unmanaged<MenuBarManager>.fromOpaque(refcon).takeUnretainedValue()

            DispatchQueue.main.async {
                manager.scanMenuBarIcons()
            }
        }

        let result = AXObserverCreate(
            pid_t(getpid()),
            callback,
            &axObserver
        )

        guard result == .success, let observer = axObserver else {
            print("Failed to create AX observer: \(result)")
            return
        }

        // Add notifications to observe
        let notifications = [
            kAXMenuOpenedNotification as CFString,
            kAXMenuClosedNotification as CFString,
            kAXMenuItemSelectedNotification as CFString,
            kAXUIElementDestroyedNotification as CFString,
            kAXCreatedNotification as CFString
        ]

        for notification in notifications {
            AXObserverAddNotification(observer, systemWideElement, notification, Unmanaged.passUnretained(self).toOpaque())
        }

        // Add to run loop
        CFRunLoopAddSource(
            CFRunLoopGetCurrent(),
            AXObserverGetRunLoopSource(observer),
            .defaultMode
        )

        // Start monitoring
        AXObserverRunLoopSource(observer, CFRunLoopGetCurrent())
        CFRunLoopRunInMode(.defaultMode, 0, true)
    }

    func stopMonitoring() {
        if let observer = axObserver {
            CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), observer, .commonModes)
            axObserver = nil
        }
    }

    // MARK: - System Icon Detection
    func isSystemIcon(_ bundleIdentifier: String) -> Bool {
        return systemIconIdentifiers.contains(bundleIdentifier)
    }

    func getSystemIconIdentifiers() -> Set<String> {
        return systemIconIdentifiers
    }
}
