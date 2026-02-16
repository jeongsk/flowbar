# Mode Switching Specification

## ADDED Requirements

### Requirement: Define custom modes
The system SHALL allow users to create custom modes with unique names and icon sets.

#### Scenario: Create new mode
- **WHEN** user creates a new mode
- **THEN** system prompts for mode name
- **AND** system creates empty mode configuration
- **AND** system adds mode to mode list

#### Scenario: Rename existing mode
- **WHEN** user renames a mode
- **THEN** system updates mode name
- **AND** system preserves all mode assignments

### Requirement: Switch between modes
The system SHALL provide multiple methods for switching between modes.

#### Scenario: Menu bar mode switcher
- **WHEN** user clicks Flowbar menu bar icon
- **THEN** system displays available modes in dropdown
- **AND** system highlights current active mode
- **AND** user can select different mode

#### Scenario: Keyboard shortcut mode switch
- **WHEN** user presses ⌘ + Shift + M
- **THEN** system displays mode switcher popup
- **AND** user can type mode name or use arrow keys
- **AND** system switches to selected mode on Enter

#### Scenario: Direct keyboard shortcut
- **WHEN** user presses ⌘ + Shift + 1 through 9
- **THEN** system switches directly to corresponding mode (1-9)

### Requirement: Default modes
The system SHALL create 4 default modes on first launch.

#### Scenario: Initial mode creation
- **WHEN** user completes onboarding
- **THEN** system creates "coding" mode
- **AND** system creates "design" mode
- **AND** system creates "meeting" mode
- **AND** system creates "focus" mode

#### Scenario: Default mode configurations
- **WHEN** default modes are created
- **THEN** "coding" mode includes Git, CI, CPU monitoring icons
- **AND** "design" mode includes color picker, asset folder icons
- **AND** "meeting" mode includes calendar, notes, microphone icons
- **AND** "focus" mode includes only Flowbar icon

### Requirement: Mode deletion
The system SHALL allow users to delete custom modes but not default modes.

#### Scenario: Delete custom mode
- **WHEN** user deletes a custom mode
- **THEN** system removes mode from list
- **AND** system prompts to assign affected icons to another mode

#### Scenario: Prevent default mode deletion
- **WHEN** user attempts to delete a default mode
- **THEN** system shows error message
- **AND** system prevents deletion

### Requirement: Active mode indicator
The system SHALL clearly indicate which mode is currently active.

#### Scenario: Menu bar current mode display
- **WHEN** any mode is active
- **THEN** Flowbar icon shows mode name or icon
- **AND** system updates display when mode changes

#### Scenario: Mode switcher current mode
- **WHEN** user opens mode switcher
- **THEN** system highlights current active mode
- **AND** system shows checkmark next to active mode

### Requirement: Mode transition animation
The system SHALL animate menu bar icon changes during mode transitions.

#### Scenario: Smooth icon transition
- **WHEN** user switches modes
- **THEN** system fades out icons being hidden
- **AND** system fades in icons being shown
- **AND** transition completes within 500ms
