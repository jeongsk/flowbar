import Foundation
import Cocoa
import ApplicationServices

// MARK: - Focus Guard Manager
@MainActor
final class FocusGuardManager: ObservableObject {
    @Published var isEnabled: Bool = false
    @Published var isActive: Bool = false
    @Published var dndAppsList: [DNDApp] = []
    @Published var notificationAutoHideEnabled: Bool = true
    @Published var notificationAutoHideDuration: TimeInterval = 3.0

    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var notificationObservers: [NSObjectProtocol] = []

    // Focus theft detection
    private var lastFocusTime: Date = Date()
    private var focusThreshold: TimeInterval = 0.5 // seconds

    // MARK: - Setup
    func setupEventTap() {
        let eventMask = (1 << CGEventType.keyDown.rawValue) |
                       (1 << CGEventType.keyUp.rawValue) |
                       (1 << CGEventType.leftMouseDown.rawValue) |
                       (1 << CGEventType.leftMouseUp.rawValue)

        guard let tap = CGEvent.tapCreate(
            tap: .cgAnnotatedSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(eventMask),
            callback: { proxy, type, event, refcon in
                return FocusGuardManager.eventCallback(
                    proxy: proxy,
                    type: type,
                    event: event,
                    refcon: refcon
                )
            },
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            print("Failed to create event tap")
            return
        }

        eventTap = tap

        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        self.runLoopSource = runLoopSource
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)

        // Start disabled
        CGEvent.tapEnable(tap: tap, enable: false)

        print("Focus Guard event tap created")
    }

    // MARK: - Control
    func enable() {
        guard isEnabled else { return }

        isActive = true
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: true)
            print("Focus Guard enabled")
        }

        setupNotificationMonitoring()
    }

    func disable() {
        isActive = false
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            print("Focus Guard disabled")
        }

        removeNotificationMonitoring()
    }

    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled

        if !enabled {
            disable()
        }
    }

    // MARK: - Focus Theft Detection
    private func shouldBlockFocusSteal() -> Bool {
        let now = Date()
        let timeSinceLastFocus = now.timeIntervalSince(lastFocusTime)

        // Block if focus change happens too quickly after user input
        return timeSinceLastFocus < focusThreshold
    }

    private func updateLastFocusTime() {
        lastFocusTime = Date()
    }

    // MARK: - DND Apps
    func addDNDApp(_ bundleIdentifier: String, appName: String) {
        let dndApp = DNDApp(bundleIdentifier: bundleIdentifier, appName: appName)
        dndAppsList.append(dndApp)
    }

    func removeDNDApp(_ bundleIdentifier: String) {
        dndAppsList.removeAll { $0.bundleIdentifier == bundleIdentifier }
    }

    func isDNDApp(_ bundleIdentifier: String) -> Bool {
        return dndAppsList.contains(where: { $0.bundleIdentifier == bundleIdentifier && $0.isEnabled })
    }

    func updateDNDApp(_ app: DNDApp) {
        if let index = dndAppsList.firstIndex(where: { $0.bundleIdentifier == app.bundleIdentifier }) {
            dndAppsList[index] = app
        }
    }

    // MARK: - Notification Control
    private func setupNotificationMonitoring() {
        // Monitor for notification banners
        let center = NotificationCenter.default

        // Observe notification-related events
        notificationObservers.append(
            center.addObserver(
                forName: NSApplication.didBecomeActiveNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.handleApplicationActivation()
            }
        )

        if notificationAutoHideEnabled {
            setupAutoHideTimer()
        }
    }

    private func removeNotificationMonitoring() {
        notificationObservers.forEach { NotificationCenter.default.removeObserver($0) }
        notificationObservers.removeAll()
    }

    private func handleApplicationActivation() {
        // Check if newly activated app is in DND list
        guard let focusedApp = NSWorkspace.shared.frontmostApplication,
              let bundleID = focusedApp.bundleIdentifier else {
            return
        }

        if isDNDApp(bundleID) {
            // Should block this app's notifications
            print("Blocking notifications for DND app: \(bundleID)")

            // Hide any visible notification banners
            hideNotificationBanners()
        }
    }

    private func hideNotificationBanners() {
        // Use AppleScript to dismiss notification banners
        let script = """
        tell application "System Events"
            tell process "NotificationCenter"
                if exists window 1 then
                    click button 1 of window 1
                end if
            end tell
        end tell
        """

        if let appleScript = NSAppleScript(source: script) {
            appleScript.executeAndReturnError(nil)
        }
    }

    private func setupAutoHideTimer() {
        // Continuous timer to auto-hide notifications
        Timer.scheduledTimer(withTimeInterval: notificationAutoHideDuration, repeats: true) { [weak self] _ in
            self?.hideNotificationBanners()
        }
    }

    func setNotificationAutoHideEnabled(_ enabled: Bool) {
        notificationAutoHideEnabled = enabled
        if enabled && isActive {
            setupAutoHideTimer()
        }
    }

    func setNotificationAutoHideDuration(_ duration: TimeInterval) {
        notificationAutoHideDuration = duration
    }

    // MARK: - Status Indicator
    var statusIndicator: String {
        if isActive {
            return "🛡️"
        } else if isEnabled {
            return "⚠️"
        }
        return ""
    }

    // MARK: - Event Callback
    private static func eventCallback(
        proxy: CGEventTapProxy,
        type: CGEventType,
        event: CGEvent,
        refcon: UnsafeMutableRawPointer?
    ) -> Unmanaged<CGEvent>? {
        guard let refcon = refcon else {
            return Unmanaged.passUnretained(event)
        }

        let manager = Unmanaged<FocusGuardManager>.fromOpaque(refcon).takeUnretainedValue()

        guard manager.isActive else {
            return Unmanaged.passUnretained(event)
        }

        switch type {
        case .keyDown:
            return manager.handleKeyDown(event: event)
        case .leftMouseDown:
            return manager.handleMouseClick(event: event)
        default:
            return Unmanaged.passUnretained(event)
        }
    }

    private func handleKeyDown(event: CGEvent) -> Unmanaged<CGEvent>? {
        let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
        let flags = event.flags

        // Update last focus time for valid key presses
        if flags.contains(.maskNonCoalesced) {
            updateLastFocusTime()
        }

        // Block focus-stealing keys if threshold not met
        if shouldBlockFocusSteal() {
            print("Blocking potential focus steal via keyboard")
            return nil // Block the event
        }

        return Unmanaged.passUnretained(event)
    }

    private func handleMouseClick(event: CGEvent) -> Unmanaged<CGEvent>? {
        // Check if this is a focus-stealing click
        if shouldBlockFocusSteal() {
            // Get window info
            if let windowNumber = event.windowNumber {
                print("Blocking focus steal to window \(windowNumber)")
                return nil // Block the event
            }
        }

        updateLastFocusTime()
        return Unmanaged.passUnretained(event)
    }

    // MARK: - Cleanup
    deinit {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        }

        Task { @MainActor in
            removeNotificationMonitoring()
        }
    }
}

// MARK: - CGEvent Extensions
extension CGEvent {
    var windowNumber: Int? {
        // Window number is not directly available via CGEvent
        // This is a placeholder implementation
        return nil
    }
}
