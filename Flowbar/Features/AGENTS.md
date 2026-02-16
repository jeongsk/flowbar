# Flowbar Features Module

## Purpose
The Features directory contains modular components that implement specific application functionality for Flowbar. Each feature is self-contained with its own manager/coordinator and view components, enabling independent development and testing of app capabilities.

## Directory Structure

```
Features/
├── FocusGuard/          # Distraction blocking and focus management
├── Help/                # In-app help and documentation
├── Launcher/            # Application launching functionality
├── MenuBar/             # Menu bar integration and management
├── ModeSwitcher/        # Mode switching and state management
├── Onboarding/          # User onboarding flow
└── Settings/            # Application settings and preferences
```

## Feature Modules

### 1. FocusGuard
- **Key File**: `FocusGuardManager.swift`
- **Purpose**: Manages distraction blocking and focus mode features
- **Responsibilities**:
  - Monitor and block distracting applications
  - Enforce focus rules based on current mode
  - Manage DND (Do Not Disturb) settings

### 2. Help
- **Key File**: `HelpView.swift`
- **Purpose**: Provides in-app help and user guidance
- **Responsibilities**:
  - Display documentation and tutorials
  - Context-sensitive help
  - FAQ and troubleshooting guidance

### 3. Launcher
- **Key File**: `LauncherManager.swift`
- **Purpose**: Handles application launching and management
- **Responsibilities**:
  - Launch applications based on mode/context
  - Manage application assignments
  - Track running applications

### 4. MenuBar
- **Key File**: `MenuBarManager.swift`
- **Purpose**: Manages menu bar integration and UI
- **Responsibilities**:
  - Display menu bar icon and status
  - Handle menu bar interactions
  - Update menu bar based on current state

### 5. ModeSwitcher
- **Key File**: `ModeManager.swift`
- **Purpose**: Core mode switching functionality
- **Responsibilities**:
  - Manage mode transitions
  - Track current active mode
  - Apply mode-specific settings and behaviors

### 6. Onboarding
- **Key File**: `OnboardingCoordinator.swift`
- **Purpose**: Guides new users through initial setup
- **Responsibilities**:
  - Manage onboarding flow state
  - Present introduction and setup steps
  - Track onboarding completion

### 7. Settings
- **Key File**: `SettingsView.swift`
- **Purpose**: Application settings and preferences management
- **Responsibilities**:
  - Display and edit user preferences
  - Manage app settings persistence
  - Handle settings validation

## Dependencies

### Internal Dependencies
- **Core/Models**: Shared data models (Mode, AppAssignment, Preference, etc.)
- **Core/Services**: Core application services and utilities
- **FlowbarApp**: Main app coordination

### External Dependencies
- **AppKit**: macOS UI framework for menu bar and native UI components
- **SwiftUI**: Modern UI framework for feature views
- **Accessibility API**: For application monitoring and control
- **Combine**: Reactive programming for state management

## AI Agent Instructions for Feature Development

### When Working on Features:

1. **Feature Isolation**: Each feature should be self-contained with minimal dependencies on other features. Use the Core models for shared data.

2. **Manager Pattern**: Each feature should have a Manager (or Coordinator) that:
   - Manages the feature's state
   - Handles business logic
   - Coordinates with other components
   - Follows single responsibility principle

3. **View Separation**: Keep UI logic in View files separate from business logic in Manager files.

4. **Model Usage**: Always use models from Core/Models/ for data structures:
   - `Mode`: Represents user-defined modes
   - `AppAssignment`: Application assignments to modes
   - `Preference`: User preference settings
   - `OnboardingState`: Onboarding progress tracking

5. **State Management**:
   - Use Combine publishers for reactive state updates
   - Ensure thread-safe access to shared state
   - Implement proper error handling

6. **Accessibility Integration**:
   - Use Accessibility API responsibly for app monitoring
   - Request necessary permissions
   - Handle permission denials gracefully

7. **Testing Considerations**:
   - Design features to be testable in isolation
   - Consider dependency injection for managers
   - Mock external dependencies (Accessibility API)

### Adding New Features:

1. Create a new subdirectory with a descriptive name
2. Implement a Manager/Coordinator class for business logic
3. Create View files for UI components
4. Update the main app coordinator to register the new feature
5. Add any new models to Core/Models/ if needed
6. Update this AGENTS.md file with the new feature documentation

### Code Style Guidelines:

- Follow Swift naming conventions
- Use meaningful variable and function names
- Add documentation comments for public interfaces
- Keep functions focused and concise
- Handle errors gracefully with user-friendly messages

## Common Patterns

### Manager Initialization
```swift
class FeatureManager {
    @Published var state: FeatureState

    init(dependencies: Dependencies) {
        // Initialize with dependencies
    }

    func performAction() {
        // Business logic
    }
}
```

### State Updates
```swift
func updateState() {
    DispatchQueue.main.async {
        self.state = newState
    }
}
```

### Dependency Access
```swift
// Access core models
let currentMode = modeManager.currentMode
let preferences = preferenceManager.preferences
```

## Notes

- Features should communicate through the main app coordinator, not directly with each other
- Use notification center or Combine for cross-feature communication when needed
- Keep UI responsive by performing heavy operations on background threads
- Always test feature behavior in different modes and states
