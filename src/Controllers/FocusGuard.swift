import Cocoa

class FocusGuard {
    private var isEnabled = false
    private var blockedApps: Set<String> = []
    private var monitor: Any?
    private var eventTap: CFMachPort?
    
    // MARK: - Control
    
    func enable() {
        guard !isEnabled else { return }
        isEnabled = true
        
        // Monitor app launches
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillLaunch(_:)),
            name: NSWorkspace.willLaunchApplicationNotification,
            object: nil
        )
        
        // Monitor window activation
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidActivate(_:)),
            name: NSWorkspace.didActivateApplicationNotification,
            object: nil
        )
        
        // Optional: Event tap for more granular control
        // enableEventTap()
    }
    
    func disable() {
        guard isEnabled else { return }
        isEnabled = false
        
        NotificationCenter.default.removeObserver(self)
        
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            eventTap = nil
        }
    }
    
    // MARK: - App Blocking
    
    func blockApp(_ bundleId: String) {
        blockedApps.insert(bundleId)
    }
    
    func unblockApp(_ bundleId: String) {
        blockedApps.remove(bundleId)
    }
    
    func setBlockedApps(_ bundleIds: [String]) {
        blockedApps = Set(bundleIds)
    }
    
    // MARK: - Notifications
    
    @objc private func appWillLaunch(_ notification: Notification) {
        guard isEnabled else { return }
        
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                as? NSRunningApplication,
              let bundleId = app.bundleIdentifier else { return }
        
        if blockedApps.contains(bundleId) {
            // Hide the app immediately
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                app.hide()
            }
            
            // Optionally: terminate it
            // app.terminate()
        }
    }
    
    @objc private func appDidActivate(_ notification: Notification) {
        guard isEnabled else { return }
        
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                as? NSRunningApplication,
              let bundleId = app.bundleIdentifier else { return }
        
        if blockedApps.contains(bundleId) {
            // Hide it
            app.hide()
            
            // Restore previous app
            if let previousApp = NSWorkspace.shared.frontmostApplication {
                previousApp.activate()
            }
        }
    }
    
    // MARK: - Event Tap (Advanced)
    
    private func enableEventTap() {
        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard let refcon = refcon else {
                return Unmanaged.passUnretained(event)
            }
            
            let guard = Unmanaged<FocusGuard>.fromOpaque(refcon).takeUnretainedValue()
            
            if guard.shouldBlockEvent(type, event: event) {
                return nil // Block the event
            }
            
            return Unmanaged.passUnretained(event)
        }
        
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(
                (1 << CGEventType.applicationDefined.rawValue) |
                (1 << CGEventType.kbdDown.rawValue)
            ),
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("Failed to create event tap")
            return
        }
        
        eventTap = tap
        CGEvent.tapEnable(tap: tap, enable: true)
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
    }
    
    private func shouldBlockEvent(_ type: CGEventType, event: CGEvent) -> Bool {
        guard isEnabled else { return false }
        
        // Check if event would steal focus
        // This is complex and requires analyzing the event
        
        return false
    }
}
