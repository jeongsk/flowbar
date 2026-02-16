# Menu Bar Icon Management Specification

## ADDED Requirements

### Requirement: Detect menu bar icons
The system SHALL detect all currently visible menu bar icons in the user's menu bar.

#### Scenario: Initial scan on first launch
- **WHEN** user launches Flowbar for the first time
- **THEN** system scans the menu bar and identifies all visible icons
- **AND** system stores icon metadata (name, position, bundle identifier)

#### Scenario: Detect new icons after app launch
- **WHEN** a new app that has a menu bar icon is launched
- **THEN** system detects the new icon within 5 seconds
- **AND** system adds it to the available icons list

### Requirement: Filter menu bar icons by mode
The system SHALL show or hide menu bar icons based on the current active mode.

#### Scenario: Switch to coding mode
- **WHEN** user switches to "coding" mode
- **THEN** system shows only icons assigned to coding mode (e.g., Git, CI, CPU)
- **AND** system hides all other icons

#### Scenario: Switch to focus mode
- **WHEN** user switches to "focus" mode
- **THEN** system hides all menu bar icons except Flowbar
- **AND** system maintains this state until mode changes

### Requirement: Manually assign icons to modes
The system SHALL allow users to assign menu bar icons to specific modes.

#### Scenario: Drag and drop icon to mode
- **WHEN** user drags a menu bar icon to a mode in settings
- **THEN** system assigns that icon to the mode
- **AND** system persists the assignment

#### Scenario: Remove icon from mode
- **WHEN** user removes an icon from a mode
- **THEN** system stops showing that icon when the mode is active
- **AND** system shows the icon in other modes where it's assigned

### Requirement: Handle system icons
The system SHALL identify and handle system icons differently from third-party app icons.

#### Scenario: Identify system icons
- **WHEN** system scans menu bar icons
- **THEN** system flags built-in macOS icons (Control Center, WiFi, Battery)
- **AND** system provides option to hide system icons

#### Scenario: System icon visibility
- **WHEN** user hides a system icon
- **THEN** system uses Accessibility API to hide the icon
- **AND** system provides warning about reduced system functionality

### Requirement: Icon visibility persistence
The system SHALL maintain icon visibility state across app restarts.

#### Scenario: Restore visibility after restart
- **WHEN** user restarts Flowbar
- **THEN** system restores the last active mode's icon visibility
- **AND** system applies the correct filters within 2 seconds of launch
