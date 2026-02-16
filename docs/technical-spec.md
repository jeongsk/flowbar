# Flowbar - Technical Specification

## 아키텍처 개요

```
┌─────────────────────────────────────────────────────────┐
│                    Flowbar App                          │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │   UI Layer  │  │ Mode Manager│  │Focus Guard  │    │
│  │  (SwiftUI)  │  │  (Core)     │  │ (Monitor)   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐    │
│  │MenuBar Ctrl │  │Workflow Eng │  │  Launcher   │    │
│  │ (AppKit)    │  │ (Core Data) │  │ (SwiftUI)   │    │
│  └─────────────┘  └─────────────┘  └─────────────┘    │
├─────────────────────────────────────────────────────────┤
│              System Integration Layer                    │
│  ┌─────────────────────────────────────────────────┐   │
│  │ Accessibility API │ NSWorkspace │ Apple Events  │   │
│  └─────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

---

## 핵심 모듈

### 1. MenuBarController (AppKit)

**책임:** 메뉴바 아이콘 읽기, 표시/숨김 제어

```swift
import Cocoa
import Accessibility

class MenuBarController {
    // 시스템 메뉴바 아이콘 스캔
    func scanMenuBarItems() -> [MenuBarItem]

    // 특정 아이콘 숨김
    func hideItem(_ item: MenuBarItem)

    // 특정 아이콘 표시
    func showItem(_ item: MenuBarItem)

    // 현재 표시된 아이콘 목록
    func getVisibleItems() -> [MenuBarItem]
}

struct MenuBarItem: Identifiable {
    let id: String
    let bundleIdentifier: String?
    let title: String?
    let icon: NSImage?
    let position: Int
}
```

**구현 방법:**

1. Accessibility API로 `AXUIElement` 접근
2. `kAXMenuBarRole` 가진 요소 탐색
3. 각 `AXUIElement`에서 `kAXTitleAttribute`, `kAXChildrenAttribute` 추출

**주의사항:**

- Accessibility 권한 필수
- 일부 앱은 보호되어 접근 불가능할 수 있음
- Big Sur+에서 UI 변경됨 → 버전별 분기 처리

---

### 2. ModeManager (Core)

**책임:** 모드 정의, 저장, 전환

```swift
import Foundation
import SwiftData

@Model
class Mode {
    var id: UUID
    var name: String
    var icon: String
    var keyboardShortcut: String?
    var visibleItems: [String]  // MenuBarItem IDs
    var hiddenItems: [String]
    var launchApps: [String]    // Bundle IDs
    var focusGuardEnabled: Bool
    var createdAt: Date
    var updatedAt: Date
}

class ModeManager {
    var currentMode: Mode?
    var modes: [Mode]

    func switchTo(_ mode: Mode)
    func createMode(name: String) -> Mode
    func deleteMode(_ mode: Mode)
    func assignShortcut(_ mode: Mode, shortcut: String)
}
```

**SwiftData 스키마:**

```swift
@Model
class Workflow {
    var id: UUID
    var name: String
    var modeId: UUID
    var windowPositions: Data  // Serialized
    var runningApps: [String]
    var createdAt: Date
}
```

---

### 3. FocusGuard (Monitor)

**책임:** 포커스 가로채기 방지

```swift
import Cocoa

class FocusGuard {
    private var monitor: Any?
    private var blockedApps: Set<String> = []

    func enable()
    func disable()
    func blockApp(_ bundleId: String)
    func unblockApp(_ bundleId: String)
}

// 구현: NSWorkspace notifications
extension FocusGuard {
    func enable() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillLaunch),
            name: NSWorkspace.willLaunchApplicationNotification,
            object: nil
        )
    }

    @objc private func appWillLaunch(_ notification: Notification) {
        guard let app = notification.userInfo?[NSWorkspace.applicationUserInfoKey]
                as? NSRunningApplication else { return }

        if blockedApps.contains(app.bundleIdentifier ?? "") {
            // Prevent window from taking focus
            app.hide()
        }
    }
}
```

**고급 구현 (CGEvent tap):**

```swift
import Carbon

class FocusGuard {
    var eventTap: CFMachPort?

    func enableEventTap() {
        let callback: CGEventTapCallBack = { proxy, type, event, refcon in
            guard let refcon = refcon else { return Unmanaged.passUnretained(event) }
            let guard = Unmanaged<FocusGuard>.fromOpaque(refcon).takeUnretainedValue()

            // Intercept window activation events
            if type == .flagsChanged {
                // Check if focus should be blocked
            }

            return Unmanaged.passUnretained(event)
        }

        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(1 << CGEventType.flagsChanged.rawValue),
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        )
    }
}
```

---

### 4. WorkflowEngine

**책임:** 워크플로우 저장/복원

```swift
import Cocoa

struct WindowPosition: Codable {
    let appName: String
    let windowTitle: String
    let frame: CGRect
}

class WorkflowEngine {
    func captureCurrentState() -> Workflow {
        let apps = NSWorkspace.shared.runningApplications
        let positions = apps.compactMap { app -> WindowPosition? in
            guard let windows = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID)
                    as? [[String: Any]] else { return nil }

            // Extract window positions
            // ...
        }

        return Workflow(positions: positions)
    }

    func restore(_ workflow: Workflow) {
        // 1. Launch apps if not running
        // 2. Move windows to saved positions
        // 3. Switch to associated mode
    }
}
```

---

### 5. MiniLauncher (SwiftUI)

**책임:** 앱 런처 UI

```swift
import SwiftUI

struct LauncherView: View {
    @State private var searchText = ""
    @State private var apps: [App] = []
    let mode: Mode

    var body: some View {
        VStack(spacing: 0) {
            TextField("Search apps...", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()

            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))]) {
                    ForEach(filteredApps) { app in
                        AppIconView(app: app)
                            .onTapGesture { launchApp(app) }
                    }
                }
                .padding()
            }
        }
        .frame(width: 400, height: 500)
    }

    var filteredApps: [App] {
        if searchText.isEmpty {
            return apps.filter { mode.launchApps.contains($0.bundleId) }
        }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }
}
```

---

## UI 구조 (SwiftUI)

### 메인 메뉴바 아이콘

```swift
import SwiftUI

@main
struct FlowbarApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var modeManager = ModeManager()
    var menuBarController = MenuBarController()

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "flowbar", accessibilityDescription: "Flowbar")
            button.action = #selector(showMenu)
        }

        buildMenu()
    }

    @objc func showMenu() {
        statusItem?.menu?.popUp(positioning: nil, at: NSEvent.mouseLocation, in: nil)
    }

    func buildMenu() {
        let menu = NSMenu()

        // Current Mode
        menu.addItem(NSMenuItem(title: "Current: Coding", action: nil, keyEquivalent: ""))

        menu.addItem(NSMenuItem.separator())

        // Modes
        for mode in modeManager.modes {
            let item = NSMenuItem(title: mode.name, action: #selector(switchMode(_:)), keyEquivalent: "")
            item.representedObject = mode
            item.keyEquivalent = mode.keyboardShortcut ?? ""
            menu.addItem(item)
        }

        menu.addItem(NSMenuItem.separator())

        // Settings
        menu.addItem(NSMenuItem(title: "Preferences...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem(title: "Quit Flowbar", action: #selector(quit), keyEquivalent: "q"))

        statusItem?.menu = menu
    }

    @objc func switchMode(_ sender: NSMenuItem) {
        guard let mode = sender.representedObject as? Mode else { return }
        modeManager.switchTo(mode)
        menuBarController.apply(mode)
    }
}
```

### 설정 윈도우

```swift
import SwiftUI

struct SettingsView: View {
    @State private var modes: [Mode]
    @State private var selectedMode: Mode?

    var body: some View {
        NavigationSplitView {
            List(modes, selection: $selectedMode) { mode in
                Label(mode.name, systemImage: mode.icon)
            }
            .toolbar {
                Button(action: addMode) { Image(systemName: "plus") }
            }
        } detail: {
            if let mode = selectedMode {
                ModeEditorView(mode: mode)
            } else {
                Text("Select a mode")
            }
        }
        .frame(width: 800, height: 600)
    }
}

struct ModeEditorView: View {
    @Bindable var mode: Mode
    @State private var menuBarItems: [MenuBarItem] = []

    var body: some View {
        Form {
            Section("General") {
                TextField("Name", text: $mode.name)
                TextField("Icon", text: $mode.icon)
                TextField("Shortcut", text: $mode.keyboardShortcut ?? "")
            }

            Section("Menu Bar Items") {
                ForEach(menuBarItems) { item in
                    Toggle(item.title ?? "", isOn: Binding(
                        get: { mode.visibleItems.contains(item.id) },
                        set: { isVisible in
                            if isVisible {
                                mode.visibleItems.append(item.id)
                            } else {
                                mode.visibleItems.removeAll { $0 == item.id }
                            }
                        }
                    ))
                }
            }

            Section("Apps to Launch") {
                // App picker
            }

            Section("Focus Guard") {
                Toggle("Enable Focus Guard", isOn: $mode.focusGuardEnabled)
            }
        }
        .formStyle(.grouped)
    }
}
```

---

## 파일 구조

```
Flowbar/
├── FlowbarApp.swift           # @main
├── AppDelegate.swift          # Status bar, menu
├── Models/
│   ├── Mode.swift
│   ├── Workflow.swift
│   └── MenuBarItem.swift
├── Controllers/
│   ├── MenuBarController.swift
│   ├── ModeManager.swift
│   ├── FocusGuard.swift
│   └── WorkflowEngine.swift
├── Views/
│   ├── SettingsView.swift
│   ├── ModeEditorView.swift
│   ├── LauncherView.swift
│   └── Components/
│       └── AppIconView.swift
├── Utils/
│   ├── AccessibilityHelper.swift
│   └── PermissionsManager.swift
├── Resources/
│   ├── Assets.xcassets
│   └── Flowbar.entitlements
└── Info.plist
```

---

## 권한 요청

### Info.plist

```xml
<key>NSAppleEventsUsageDescription</key>
<string>Flowbar needs to control other applications to manage your menu bar.</string>

<key>NSAccessibilityUsageDescription</key>
<string>Flowbar needs Accessibility access to detect and manage menu bar icons.</string>
```

### Entitlements

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <false/>
    <key>com.apple.security.automation.apple-events</key>
    <true/>
</dict>
</plist>
```

---

## 성능 목표

| 메트릭 | 목표 |
|--------|------|
| 앱 크기 | < 10 MB |
| 메모리 사용 | < 50 MB |
| 모드 전환 시간 | < 100 ms |
| CPU 사용 (idle) | < 1% |
| 시작 시간 | < 1 s |

---

## 테스트 전략

### Unit Tests

```swift
class ModeManagerTests: XCTestCase {
    func testCreateMode() {
        let manager = ModeManager()
        let mode = manager.createMode(name: "Test")
        XCTAssertEqual(mode.name, "Test")
    }

    func testSwitchMode() {
        // Test mode switching
    }
}
```

### UI Tests

```swift
class FlowbarUITests: XCTestCase {
    func testMenuBarAppears() {
        let app = XCUIApplication()
        app.launch()
        // Verify status item exists
    }
}
```

### Integration Tests

- Accessibility 권한 시나리오
- 다양한 macOS 버전 테스트 (Ventura, Sonoma, Sequoia, Tahoe)
- M1/M2/M3 + Intel 테스트

---

## 릴리스 체크리스트

- [ ] Accessibility 권한 요청 UX 완성
- [ ] 모든 기능 Ventura+ 호환 확인
- [ ] 메모리 누수 체크 (Instruments)
- [ ] 코드 서인 + Notarization
- [ ] Sparkle (자동 업데이트) 통합
- [ ] 크래시 리포팅 (Sentry/Backtrace)
- [ ] 앱 아이콘 디자인
- [ ] 마케팅 스크린샷 준비

---

_작성일: 2025-02-17_
_버전: 1.0_
