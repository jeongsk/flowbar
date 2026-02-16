import Cocoa

class MenuBarController {
    var menuBarItems: [MenuBarItem] = []
    private var systemWideElement: AXUIElement
    
    init() {
        systemWideElement = AXUIElementCreateSystemWide()
        scanMenuBarItems()
    }
    
    // MARK: - Scanning
    
    func scanMenuBarItems() {
        menuBarItems.removeAll()
        
        // Get the menu bar element
        let app = NSRunningApplication.current
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        
        // Get all running applications
        let runningApps = NSWorkspace.shared.runningApplications.filter { $0.activationPolicy == .accessory }
        
        var position = 0
        
        for app in runningApps {
            let appElement = AXUIElementCreateApplication(app.processIdentifier)
            
            // Try to get menu bar items
            if let items = getMenuBarItems(from: appElement, for: app) {
                for item in items {
                    menuBarItems.append(MenuBarItem(
                        id: item.identifier,
                        bundleIdentifier: app.bundleIdentifier,
                        title: item.title,
                        icon: item.icon,
                        position: position,
                        axElement: item.element
                    ))
                    position += 1
                }
            }
        }
        
        // Also scan system menu bar extras
        scanSystemMenuBarExtras(position: &position)
    }
    
    private func getMenuBarItems(from appElement: AXUIElement, for app: NSRunningApplication) -> [ScannedItem]? {
        var items: [ScannedItem] = []
        
        // Get all windows for this app
        var windowsRef: CFTypeRef?
        let result = AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)
        
        guard result == .success, let windows = windowsRef as? [AXUIElement] else {
            return nil
        }
        
        for window in windows {
            // Check if this is a status bar window
            var subroleRef: CFTypeRef?
            AXUIElementCopyAttributeValue(window, kAXSubroleAttribute as CFString, &subroleRef)
            
            if let subrole = subroleRef as? String, subrole == "AXStatusItem" {
                // This is a status item window
                var titleRef: CFTypeRef?
                AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef)
                
                let title = titleRef as? String
                
                items.append(ScannedItem(
                    identifier: app.bundleIdentifier ?? UUID().uuidString,
                    title: title,
                    icon: app.icon,
                    element: window
                ))
            }
        }
        
        return items.isEmpty ? nil : items
    }
    
    private func scanSystemMenuBarExtras(position: inout Int) {
        // System menu bar extras (WiFi, Battery, Clock, etc.)
        // These require special handling as they're part of SystemUIServer
        
        let systemItems = [
            MenuBarItem(id: "system.apple", bundleIdentifier: "com.apple.systemui", title: "Apple Menu", icon: nil, position: position, axElement: nil),
            MenuBarItem(id: "system.wifi", bundleIdentifier: "com.apple.systemui", title: "WiFi", icon: nil, position: position + 1, axElement: nil),
            MenuBarItem(id: "system.bluetooth", bundleIdentifier: "com.apple.systemui", title: "Bluetooth", icon: nil, position: position + 2, axElement: nil),
            MenuBarItem(id: "system.battery", bundleIdentifier: "com.apple.systemui", title: "Battery", icon: nil, position: position + 3, axElement: nil),
            MenuBarItem(id: "system.clock", bundleIdentifier: "com.apple.systemui", title: "Clock", icon: nil, position: position + 4, axElement: nil),
        ]
        
        menuBarItems.append(contentsOf: systemItems)
        position += 5
    }
    
    // MARK: - Visibility Control
    
    func apply(_ mode: Mode) {
        // Show items in visibleItemIds, hide others
        for item in menuBarItems {
            let shouldShow = mode.visibleItemIds.contains(item.id)
            setItemVisibility(item, visible: shouldShow)
        }
    }
    
    func showItem(_ item: MenuBarItem) {
        setItemVisibility(item, visible: true)
    }
    
    func hideItem(_ item: MenuBarItem) {
        setItemVisibility(item, visible: false)
    }
    
    private func setItemVisibility(_ item: MenuBarItem, visible: Bool) {
        guard let element = item.axElement else { return }
        
        // Note: Hiding menu bar items via Accessibility is limited
        // Alternative approach: Quit or hide the owning application
        
        if visible {
            // Try to unhide
            var hiddenRef: CFTypeRef = false as CFTypeRef
            AXUIElementSetAttributeValue(element, kAXHiddenAttribute as CFString, hiddenRef)
        } else {
            // Try to hide
            var hiddenRef: CFTypeRef = true as CFTypeRef
            AXUIElementSetAttributeValue(element, kAXHiddenAttribute as CFString, hiddenRef)
        }
        
        // Alternative: Use app hiding
        // NSRunningApplication.runningApplications(withBundleIdentifier: item.bundleIdentifier ?? "")
        //     .first?.hide()
    }
    
    // MARK: - Helper
    
    private struct ScannedItem {
        let identifier: String
        let title: String?
        let icon: NSImage?
        let element: AXUIElement
    }
}
