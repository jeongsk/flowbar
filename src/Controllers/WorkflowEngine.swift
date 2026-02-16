import Cocoa

class WorkflowEngine {
    func captureCurrentState() -> Workflow {
        var positions: [WindowPosition] = []
        
        // Get all running apps
        let runningApps = NSWorkspace.shared.runningApplications.filter { 
            $0.activationPolicy == .regular 
        }
        
        for app in runningApps {
            // Get window info using CGWindowList
            let windowList = CGWindowListCopyWindowInfo(
                [.optionOnScreenOnly, .excludeDesktopElements],
                kCGNullWindowID
            ) as? [[String: Any]] ?? []
            
            for windowInfo in windowList {
                guard let pid = windowInfo[kCGWindowOwnerPID as String] as? Int32,
                      pid == app.processIdentifier else { continue }
                
                guard let windowName = windowInfo[kCGWindowName as String] as? String,
                      let bounds = windowInfo[kCGWindowBounds as String] as? [String: CGFloat] else { continue }
                
                let position = WindowPosition(
                    appName: app.localizedName ?? "Unknown",
                    windowTitle: windowName,
                    x: bounds["X"] ?? 0,
                    y: bounds["Y"] ?? 0,
                    width: bounds["Width"] ?? 800,
                    height: bounds["Height"] ?? 600,
                    isMinimized: app.isHidden,
                    isFullscreen: false // TODO: Detect fullscreen
                )
                
                positions.append(position)
            }
        }
        
        let workflow = Workflow(
            name: "Workflow \(Date().formatted(date: .abbreviated, time: .shortened))",
            windowPositions: positions,
            runningAppBundleIds: runningApps.compactMap { $0.bundleIdentifier }
        )
        
        return workflow
    }
    
    func restore(_ workflow: Workflow) {
        // 1. Launch apps that aren't running
        for bundleId in workflow.runningAppBundleIds {
            if NSWorkspace.shared.runningApplications.contains(where: { $0.bundleIdentifier == bundleId }) {
                continue
            }
            
            // Launch the app
            if let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleId) {
                NSWorkspace.shared.openApplication(at: url, configuration: NSWorkspace.OpenConfiguration())
            }
        }
        
        // 2. Wait for apps to launch
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.restoreWindowPositions(workflow.windowPositions)
        }
    }
    
    private func restoreWindowPositions(_ positions: [WindowPosition]) {
        // Note: Moving windows requires Accessibility API
        // This is a simplified version
        
        for position in positions {
            guard let app = NSWorkspace.shared.runningApplications.first(where: { 
                $0.localizedName == position.appName 
            }) else { continue }
            
            let appElement = AXUIElementCreateApplication(app.processIdentifier)
            
            // Get windows
            var windowsRef: CFTypeRef?
            AXUIElementCopyAttributeValue(appElement, kAXWindowsAttribute as CFString, &windowsRef)
            
            guard let windows = windowsRef as? [AXUIElement] else { continue }
            
            for window in windows {
                // Find matching window by title
                var titleRef: CFTypeRef?
                AXUIElementCopyAttributeValue(window, kAXTitleAttribute as CFString, &titleRef)
                
                if let title = titleRef as? String, title == position.windowTitle {
                    // Set position and size
                    let origin = AXValueCreate(.cgPoint, CGPoint(x: position.x, y: position.y))!
                    let size = AXValueCreate(.cgSize, CGSize(width: position.width, height: position.height))!
                    
                    AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, origin)
                    AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, size)
                }
            }
        }
    }
}
