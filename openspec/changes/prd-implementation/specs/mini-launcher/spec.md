# Mini Launcher Specification

## ADDED Requirements

### Requirement: Launch mini launcher
The system SHALL provide a keyboard shortcut to launch the mini launcher.

#### Scenario: Open launcher with keyboard
- **WHEN** user presses configurable keyboard shortcut (default: ⌘ + Space)
- **THEN** system displays mini launcher overlay
- **AND** system focuses search input immediately
- **AND** system dims background

#### Scenario: Close launcher
- **WHEN** user presses Escape
- **THEN** system closes mini launcher
- **AND** system returns focus to previous window

### Requirement: Display mode-filtered apps
The system SHALL show only apps relevant to the current mode in the launcher.

#### Scenario: Show coding mode apps
- **WHEN** user opens launcher in coding mode
- **THEN** system shows development apps (Xcode, Terminal, VS Code)
- **AND** system hides non-relevant apps (Music, Photos)

#### Scenario: Show focus mode apps
- **WHEN** user opens launcher in focus mode
- **THEN** system shows only essential apps defined for focus mode
- **AND** system limits list to 5-10 apps maximum

### Requirement: Search applications
The system SHALL provide real-time search filtering of applications.

#### Scenario: Search by app name
- **WHEN** user types app name in search field
- **THEN** system filters apps in real-time
- **AND** system highlights matches as user types

#### Scenario: Fuzzy matching
- **WHEN** user types partial match (e.g., "xcod" for "Xcode")
- **THEN** system finds and displays matching apps
- **AND** system ranks results by relevance

### Requirement: Launch selected application
The system SHALL launch the selected application when activated.

#### Scenario: Launch on Enter
- **WHEN** user selects an app and presses Enter
- **THEN** system launches the application
- **AND** system closes the launcher
- **AND** application comes to foreground

#### Scenario: Launch on click
- **WHEN** user clicks on an app in the launcher
- **THEN** system launches the application
- **AND** system closes the launcher

### Requirement: Recent applications
The system SHALL display recently used applications at the top of the launcher.

#### Scenario: Show recent apps first
- **WHEN** user opens launcher
- **THEN** system shows recently used apps at top
- **AND** system separates recent apps from other apps

#### Scenario: Update recent apps
- **WHEN** user launches an app through launcher
- **THEN** system adds app to recent list
- **AND** system limits recent list to 5 apps

### Requirement: Mode-specific app assignments
The system SHALL allow users to assign apps to specific modes.

#### Scenario: Assign app to mode
- **WHEN** user assigns an app to a mode
- **THEN** system shows that app in launcher when mode is active
- **AND** system hides app in other modes (unless also assigned)

#### Scenario: Quick assign from launcher
- **WHEN** user right-clicks an app in launcher
- **THEN** system shows option to assign to current mode
- **AND** system saves assignment immediately

### Requirement: Launcher appearance customization
The system SHALL allow users to customize the launcher appearance.

#### Scenario: Adjust launcher size
- **WHEN** user changes launcher size preference
- **THEN** system adjusts launcher window dimensions
- **AND** system persists the setting

#### Scenario: Toggle launcher theme
- **WHEN** user switches between light/dark theme
- **THEN** system updates launcher appearance
- **AND** system respects system theme by default
