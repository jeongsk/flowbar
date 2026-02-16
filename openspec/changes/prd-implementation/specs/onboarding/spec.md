# Onboarding Specification

## ADDED Requirements

### Requirement: First launch detection
The system SHALL detect when user launches Flowbar for the first time.

#### Scenario: Detect first launch
- **WHEN** user launches Flowbar and no configuration exists
- **THEN** system starts onboarding flow
- **AND** system displays welcome screen

### Requirement: Accessibility permission request
The system SHALL request Accessibility permission during onboarding.

#### Scenario: Prompt for Accessibility access
- **WHEN** onboarding reaches permission step
- **THEN** system explains why Accessibility is needed
- **AND** system provides button to open System Preferences
- **AND** system detects when permission is granted

#### Scenario: Wait for permission grant
- **WHEN** user navigates to System Preferences
- **THEN** system waits and polls for permission status
- **AND** system automatically proceeds when permission detected

### Requirement: Menu bar icon scanning
The system SHALL scan and display current menu bar icons during onboarding.

#### Scenario: Scan menu bar icons
- **WHEN** onboarding reaches icon scanning step
- **THEN** system scans for visible menu bar icons
- **AND** system displays found icons in a grid
- **AND** system shows icon names and app names

#### Scenario: Icon scan progress
- **WHEN** system is scanning for icons
- **THEN** system shows progress indicator
- **AND** system provides estimated time remaining

### Requirement: Default mode creation
The system SHALL create 4 default modes during onboarding.

#### Scenario: Create default modes
- **WHEN** onboarding reaches mode creation step
- **THEN** system creates "coding", "design", "meeting", "focus" modes
- **AND** system displays each mode with explanation
- **AND** system allows user to skip or customize

#### Scenario: Explain each default mode
- **WHEN** system presents default modes
- **THEN** system shows what each mode is for
- **AND** system shows example apps for each mode

### Requirement: Icon assignment tutorial
The system SHALL guide users through assigning icons to modes.

#### Scenario: Drag and drop tutorial
- **WHEN** onboarding reaches icon assignment step
- **THEN** system shows interactive tutorial
- **AND** system demonstrates drag and drop
- **AND** system prompts user to try assigning an icon

#### Scenario: Suggested assignments
- **WHEN** user assigns icons
- **THEN** system suggests assignments based on app categories
- **AND** user can accept or override suggestions

### Requirement: Keyboard shortcut setup
The system SHALL guide users to set up keyboard shortcuts.

#### Scenario: Explain keyboard shortcuts
- **WHEN** onboarding reaches keyboard shortcuts step
- **THEN** system shows available shortcuts
- **AND** system demonstrates mode switch shortcut
- **AND** system allows customization

#### Scenario: Shortcut conflict detection
- **WHEN** user sets a shortcut that conflicts
- **THEN** system warns about conflict
- **AND** system suggests alternative shortcuts

### Requirement: Onboarding completion
The system SHALL complete onboarding and activate the app.

#### Scenario: Complete onboarding
- **WHEN** user finishes all onboarding steps
- **THEN** system displays completion screen
- **AND** system shows summary of configuration
- **AND** system activates Flowbar with default mode

#### Scenario: Skip onboarding
- **WHEN** user chooses to skip onboarding
- **THEN** system creates basic default configuration
- **AND** system offers to resume onboarding later

### Requirement: Onboarding resumption
The system SHALL allow users to resume onboarding if incomplete.

#### Scenario: Detect incomplete onboarding
- **WHEN** user launches Flowbar after incomplete onboarding
- **THEN** system offers to resume from last step
- **AND** system restores previous progress

#### Scenario: Restart onboarding
- **WHEN** user chooses to restart onboarding
- **THEN** system clears previous progress
- **AND** system starts from beginning
