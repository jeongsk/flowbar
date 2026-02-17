import SwiftUI

// MARK: - Help View
struct HelpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab: HelpTab = .gettingStarted

    var body: some View {
        TabView(selection: $selectedTab) {
            GettingStartedView()
                .tabItem {
                    Label("Getting Started", systemImage: "star.fill")
                }
                .tag(HelpTab.gettingStarted)

            UserGuideView()
                .tabItem {
                    Label("User Guide", systemImage: "book.fill")
                }
                .tag(HelpTab.userGuide)

            KeyboardShortcutsView()
                .tabItem {
                    Label("Shortcuts", systemImage: "command")
                }
                .tag(HelpTab.shortcuts)

            TroubleshootingView()
                .tabItem {
                    Label("Troubleshooting", systemImage: "wrench.and.screwdriver")
                }
                .tag(HelpTab.troubleshooting)

            DocumentationLinksView()
                .tabItem {
                    Label("Documentation", systemImage: "link")
                }
                .tag(HelpTab.documentation)
        }
        .frame(width: 700, height: 500)
    }
}

// MARK: - Help Tab
enum HelpTab: String {
    case gettingStarted
    case userGuide
    case shortcuts
    case troubleshooting
    case documentation
}

// MARK: - Getting Started View
struct GettingStartedView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Getting Started with Flowbar")
                    .font(.title)
                    .bold()

                VStack(alignment: .leading, spacing: 12) {
                    StepView(
                        number: 1,
                        title: "Grant Accessibility Permission",
                        description: "Flowbar needs accessibility permission to detect and control menu bar icons. Go to System Settings > Privacy & Security > Accessibility and enable Flowbar."
                    )

                    StepView(
                        number: 2,
                        title: "Complete Onboarding",
                        description: "Follow the onboarding wizard to scan your menu bar icons and create custom modes for different work contexts."
                    )

                    StepView(
                        number: 3,
                        title: "Customize Your Modes",
                        description: "Open Settings > Modes to edit existing modes or create new ones. Assign icons to each mode based on your workflow."
                    )

                    StepView(
                        number: 4,
                        title: "Enable Focus Guard",
                        description: "Turn on Focus Guard in Settings to prevent apps from stealing focus and block distracting notifications."
                    )

                    StepView(
                        number: 5,
                        title: "Use Keyboard Shortcuts",
                        description: "Press ⌘+Shift+M to open the mode switcher, or use ⌘+Shift+1-9 to switch directly to a specific mode."
                    )
                }

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Step View
struct StepView: View {
    let number: Int
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 32, height: 32)

                Text("\(number)")
                    .font(.headline)
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)

                Text(description)
                    .font(.body)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - User Guide View
struct UserGuideView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("User Guide")
                    .font(.title)
                    .bold()

                SectionView(
                    title: "Understanding Modes",
                    content: """
                    Modes are the core of Flowbar. Each mode represents a different work context (e.g., Coding, Design, Meeting). When you switch modes, Flowbar automatically shows only the menu bar icons relevant to that context.

                    • Switch modes using the menu bar icon or keyboard shortcuts
                    • Each mode can have custom icons and settings
                    • Create up to 9 modes for different workflows
                    """
                )

                SectionView(
                    title: "Menu Bar Icon Management",
                    content: """
                    Flowbar scans your menu bar and allows you to assign icons to specific modes:

                    • Icons not assigned to the current mode are hidden
                    • System icons are always visible
                    • Use drag and drop to assign icons to modes
                    • Toggle icon visibility independently for each mode
                    """
                )

                SectionView(
                    title: "Focus Guard",
                    content: """
                    Focus Guard prevents interruptions during focused work sessions:

                    • Blocks focus-stealing behavior from other apps
                    • Hides notification banners from DND apps
                    • Customizable sensitivity threshold
                    • Per-app Do Not Disturb settings
                    """
                )

                SectionView(
                    title: "Mini Launcher",
                    content: """
                    The built-in launcher provides quick access to your applications:

                    • Press ⌘+Space to open the launcher
                    • Type to search apps with fuzzy matching
                    • Filter by mode using "mode name app name"
                    • Recent apps are shown by default
                    """
                )

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Section View
struct SectionView: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)

            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Keyboard Shortcuts View
struct KeyboardShortcutsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Keyboard Shortcuts")
                    .font(.title)
                    .bold()

                ShortcutCategoryView(
                    title: "Global Shortcuts",
                    shortcuts: [
                        ("⌘+Shift+M", "Open mode switcher"),
                        ("⌘+Shift+1-9", "Switch to mode 1-9"),
                        ("⌘+Space", "Open launcher"),
                        ("⌘+,", "Open Settings"),
                        ("⌘+Q", "Quit Flowbar")
                    ]
                )

                ShortcutCategoryView(
                    title: "Launcher Shortcuts",
                    shortcuts: [
                        ("ESC", "Close launcher"),
                        ("↑/↓", "Navigate results"),
                        ("Enter", "Launch selected app"),
                        ("Tab", "Toggle between recent and search results")
                    ]
                )

                ShortcutCategoryView(
                    title: "Mode Switcher Shortcuts",
                    shortcuts: [
                        ("←/→", "Navigate modes"),
                        ("Enter", "Switch to selected mode"),
                        ("ESC", "Close switcher")
                    ]
                )

                ShortcutCategoryView(
                    title: "Custom Shortcuts",
                    content: "You can customize these shortcuts in Settings > Shortcuts. Some shortcuts may conflict with system shortcuts or other applications."
                )

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Shortcut Category View
struct ShortcutCategoryView: View {
    let title: String
    let shortcuts: [(String, String)]?
    let content: String?

    init(title: String, shortcuts: [(String, String)]? = nil, content: String? = nil) {
        self.title = title
        self.shortcuts = shortcuts
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            if let shortcuts = shortcuts {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(shortcuts, id: \.0) { shortcut, description in
                        HStack {
                            Text(shortcut)
                                .font(.system(.body, design: .monospaced))
                                .fontWeight(.semibold)
                                .foregroundColor(.accentColor)

                            Text(description)
                                .foregroundColor(.secondary)

                            Spacer()
                        }
                    }
                }
                .padding(.leading, 16)
            }

            if let content = content {
                Text(content)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.leading, 16)
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Troubleshooting View
struct TroubleshootingView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Troubleshooting")
                    .font(.title)
                    .bold()

                TroubleshootingItemView(
                    title: "Accessibility Permission Issues",
                    symptoms: "Menu bar icons not detected or controlled",
                    solution: """
                    1. Open System Settings > Privacy & Security > Accessibility
                    2. Find Flowbar in the list
                    3. Toggle the switch to enable
                    4. Restart Flowbar if needed
                    """
                )

                TroubleshootingItemView(
                    title: "Icons Not Hiding",
                    symptoms: "Menu bar icons remain visible when switching modes",
                    solution: """
                    1. Verify accessibility permission is granted
                    2. Rescan menu bar icons in Settings > Icons
                    3. Ensure icons are assigned to the correct mode
                    4. Check that icon visibility is enabled for the mode
                    """
                )

                TroubleshootingItemView(
                    title: "Focus Guard Not Working",
                    symptoms: "Apps still steal focus or show notifications",
                    solution: """
                    1. Ensure Focus Guard is enabled in Settings
                    2. Check that the app is in the DND list
                    3. Adjust the focus theft threshold if needed
                    4. Verify Focus Guard is active (shield icon in menu bar)
                    """
                )

                TroubleshootingItemView(
                    title: "Launcher Not Opening",
                    symptoms: "⌘+Space doesn't open the launcher",
                    solution: """
                    1. Check if another app is using ⌘+Space (Spotlight, Launchbar, etc.)
                    2. Change the launcher shortcut in Settings > Shortcuts
                    3. Ensure Flowbar is running (check menu bar icon)
                    """
                )

                TroubleshootingItemView(
                    title: "App Crashes or Freezes",
                    symptoms: "Flowbar becomes unresponsive",
                    solution: """
                    1. Restart Flowbar from Activity Monitor
                    2. Check Console.app for crash logs
                    3. Try resetting preferences in Settings
                    4. Report the issue on GitHub with crash logs
                    """
                )

                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Troubleshooting Item View
struct TroubleshootingItemView: View {
    let title: String
    let symptoms: String
    let solution: String
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(symptoms)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    HStack(alignment: .top) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(solution)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.leading, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(Color(nsColor: .controlBackgroundColor))
        .cornerRadius(8)
    }
}

// MARK: - Documentation Links View
struct DocumentationLinksView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Documentation & Resources")
                    .font(.title)
                    .bold()

                LinkRowView(
                    title: "GitHub Repository",
                    description: "Source code, issues, and contributions",
                    url: "https://github.com/Fission-AI/Flowbar",
                    icon: "link"
                )

                LinkRowView(
                    title: "Privacy Policy",
                    description: "Learn how Flowbar handles your data",
                    url: "https://github.com/Fission-AI/Flowbar/blob/main/PRIVACY.md",
                    icon: "hand.raised.fill"
                )

                LinkRowView(
                    title: "Report an Issue",
                    description: "Found a bug? Let us know",
                    url: "https://github.com/Fission-AI/Flowbar/issues",
                    icon: "exclamationmark.bubble.fill"
                )

                LinkRowView(
                    title: "Feature Requests",
                    description: "Suggest new features or improvements",
                    url: "https://github.com/Fission-AI/Flowbar/discussions",
                    icon: "lightbulb.fill"
                )

                LinkRowView(
                    title: "Contributing Guide",
                    description: "Want to contribute? Read our guide",
                    url: "https://github.com/Fission-AI/Flowbar/blob/main/CONTRIBUTING.md",
                    icon: "hammer.fill"
                )

                LinkRowView(
                    title: "Changelog",
                    description: "See what's new in each version",
                    url: "https://github.com/Fission-AI/Flowbar/blob/main/CHANGELOG.md",
                    icon: "list.bullet"
                )

                Spacer()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Need More Help?")
                        .font(.headline)

                    Text("Join our community discussions or contact support for personalized assistance.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.accentColor.opacity(0.1))
                .cornerRadius(8)
            }
            .padding()
        }
    }
}

// MARK: - Link Row View
struct LinkRowView: View {
    let title: String
    let description: String
    let url: String
    let icon: String

    var body: some View {
        Link(destination: URL(string: url)!) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(.accentColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.body)
                        .fontWeight(.medium)

                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right.square.fill")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(nsColor: .controlBackgroundColor))
            .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Help Window Manager
@MainActor
final class HelpWindowManager: ObservableObject {
    static let shared = HelpWindowManager()

    @Published var isHelpWindowVisible: Bool = false
    private var helpWindow: NSWindow?

    private init() {}

    func showHelp() {
        if let window = helpWindow, !window.isVisible {
            window.makeKeyAndOrderFront(nil)
            isHelpWindowVisible = true
            return
        }

        if helpWindow == nil {
            let helpView = HelpView()

            let hostingController = NSHostingController(rootView: helpView)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 700, height: 500),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )

            window.title = "Flowbar Help"
            window.contentViewController = hostingController
            window.center()
            window.isReleasedWhenClosed = false

            helpWindow = window
        }

        helpWindow?.makeKeyAndOrderFront(nil)
        isHelpWindowVisible = true
    }

    func hideHelp() {
        helpWindow?.close()
        isHelpWindowVisible = false
    }
}
