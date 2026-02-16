import SwiftUI

// MARK: - Focus Guard Status Overlay
struct FocusGuardStatusOverlay: View {
    @ObservedObject var focusGuardManager: FocusGuardManager
    @State private var isVisible: Bool = false

    var body: some View {
        if focusGuardManager.isEnabled {
            HStack(spacing: 4) {
                Image(systemName: focusGuardManager.isActive ? "shield.fill" : "shield")
                    .foregroundColor(focusGuardManager.isActive ? .green : .orange)
                    .font(.system(size: 12))

                if isVisible {
                    Text(focusGuardManager.isActive ? "Focus Guard On" : "Focus Guard Ready")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(12)
            .shadow(radius: 2)
            .onHover { hovering in
                withAnimation(.easeInOut(duration: 0.2)) {
                    isVisible = hovering
                }
            }
        }
    }
}

// MARK: - Menu Bar Status Indicator View
struct MenuBarStatusIndicatorView: View {
    @ObservedObject var focusGuardManager: FocusGuardManager
    @ObservedObject var modeManager: ModeManager

    var body: some View {
        HStack(spacing: 8) {
            // Focus Guard Status
            if focusGuardManager.isEnabled {
                FocusGuardStatusIcon(isActive: focusGuardManager.isActive)
            }

            // Current Mode Indicator
            if let currentMode = modeManager.currentMode {
                CurrentModeIndicator(mode: currentMode)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Focus Guard Status Icon
struct FocusGuardStatusIcon: View {
    let isActive: Bool
    @State private var isPulsing: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .fill(isActive ? Color.green : Color.orange)
                .frame(width: 8, height: 8)

            if isActive {
                Circle()
                    .stroke(Color.green.opacity(0.5), lineWidth: 2)
                    .frame(width: 16, height: 16)
                    .scaleEffect(isPulsing ? 1.5 : 1.0)
                    .opacity(isPulsing ? 0 : 1)
                    .animation(
                        Animation.easeOut(duration: 1.5)
                            .repeatForever(autoreverses: false),
                        value: isPulsing
                    )
                    .onAppear {
                        isPulsing = true
                    }
            }
        }
        .accessibilityLabel(isActive ? "Focus Guard Active" : "Focus Guard Inactive")
    }
}

// MARK: - Current Mode Indicator
struct CurrentModeIndicator: View {
    let mode: Mode

    var body: some View {
        HStack(spacing: 4) {
            if let iconName = mode.icon {
                Image(systemName: iconName)
                    .font(.system(size: 10))
                    .foregroundColor(.accentColor)
            }

            Text(mode.name)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .accessibilityLabel("Current mode: \(mode.name)")
    }
}

// MARK: - Status Overlay Window Manager
@MainActor
final class StatusOverlayWindowManager: ObservableObject {
    static let shared = StatusOverlayWindowManager()

    @Published var isOverlayVisible: Bool = false
    private var overlayWindow: NSPanel?

    private init() {}

    func showOverlay(at point: CGPoint) {
        if let window = overlayWindow, window.isVisible {
            window.setFrameOrigin(point)
            return
        }

        let focusGuardManager = FocusGuardManager()
        let modeManager = ModeManager(modelContext: DataController.shared.modelContext)

        let overlayView = MenuBarStatusIndicatorView(
            focusGuardManager: focusGuardManager,
            modeManager: modeManager
        )

        let hostingView = NSHostingView(rootView: overlayView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 200, height: 30)

        let panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 200, height: 30),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        panel.contentViewController = NSViewController()
        panel.contentViewController?.view = hostingView
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.level = .floating
        panel.hasShadow = true

        panel.setFrameOrigin(point)
        panel.orderFrontRegardless()

        overlayWindow = panel
        isOverlayVisible = true
    }

    func hideOverlay() {
        overlayWindow?.close()
        overlayWindow = nil
        isOverlayVisible = false
    }

    func moveOverlay(to point: CGPoint) {
        overlayWindow?.setFrameOrigin(point)
    }
}

// MARK: - Menu Bar Overlay Controller
@MainActor
final class MenuBarOverlayController: ObservableObject {
    @Published var focusGuardStatus: String = ""
    @Published var currentModeName: String = ""

    private let focusGuardManager = FocusGuardManager()
    private let modeManager = ModeManager(modelContext: DataController.shared.modelContext)

    init() {
        updateStatus()
        setupObservers()
    }

    private func setupObservers() {
        // Observe focus guard changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("FocusGuardStateChanged"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateStatus()
        }

        // Observe mode changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("ModeDidChange"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.updateStatus()
        }
    }

    private func updateStatus() {
        focusGuardStatus = focusGuardManager.statusIndicator
        currentModeName = modeManager.currentMode?.name ?? ""
    }

    var overlayText: String {
        var text = ""
        if !focusGuardStatus.isEmpty {
            text += focusGuardStatus + " "
        }
        if !currentModeName.isEmpty {
            text += "[\(currentModeName)]"
        }
        return text
    }
}
