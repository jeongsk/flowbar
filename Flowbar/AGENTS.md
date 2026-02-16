<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-02-16 | Updated: 2026-02-16 -->

# Flowbar App

## Purpose
Main macOS application directory containing all source code, resources, and test files for the Flowbar menu bar utility.

## Key Files

| File | Description |
|------|-------------|
| `App/FlowbarApp.swift` | Main app entry point with SwiftData container |
| `App/AppDelegate.swift` | NSApplicationDelegate for app lifecycle and menu bar setup |
| `Flowbar.xcodeproj/` | Xcode project file |
| `FlowbarTests/` | Test suite directory |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `App/` | Application entry point and delegate (see `App/AGENTS.md`) |
| `Core/` | Core functionality (models, persistence, animations, utils) (see `Core/AGENTS.md`) |
| `Features/` | Feature modules (see `Features/AGENTS.md`) |
| `Shared/` | Shared utilities and views (see `Shared/AGENTS.md`) |
| `Resources/` | App resources and assets (see `Resources/AGENTS.md`) |
| `FlowbarTests/` | Test suites (see `FlowbarTests/AGENTS.md`) |

## For AI Agents

### Working In This Directory
- All Swift source files are organized into logical subdirectories
- Use @MainActor annotation for UI-related classes
- SwiftData models are defined in Core/Models/
- Feature-based modularization in Features/ directory

### Testing Requirements
- Unit tests in FlowbarTests/ directory
- Run tests before committing changes
- Test Accessibility API interactions manually

### Common Patterns
- @Published properties for SwiftUI reactivity
- @ObservableObject for state management
- Error handling with do-catch blocks
- Logger for debugging (os.log framework)

## Dependencies

### Internal
- All features depend on Core/Models for data structures
- Features depend on Core/Persistence/DataController
- Views depend on various Managers for business logic

### External
- SwiftUI - UI framework
- SwiftData - Persistence layer
- AppKit - macOS-specific APIs
- Cocoa - Foundation framework

## Architecture

**Pattern**: MVVM + Coordinator

- **Models**: SwiftData models in Core/Models/
- **Views**: SwiftUI views in Features/ and Shared/Views/
- **ViewModels**: Managers in Features/ and Core/Utils/
- **Coordinators**: OnboardingCoordinator, ModeManager, etc.

## Build Configuration

- **Target**: Flowbar (macOS App)
- **Minimum OS**: macOS 14.0
- **Language**: Swift 5.9
- **Interface**: SwiftUI + AppKit hybrid

<!-- MANUAL: -->
