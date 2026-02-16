# Data Persistence Specification

## ADDED Requirements

### Requirement: Store mode configurations
The system SHALL persist all mode configurations using SwiftData.

#### Scenario: Save new mode
- **WHEN** user creates a new mode
- **THEN** system saves mode to SwiftData store
- **AND** system includes mode name, icon assignments, and settings

#### Scenario: Update existing mode
- **WHEN** user modifies a mode
- **THEN** system updates mode record in SwiftData
- **AND** changes persist across app restarts

### Requirement: Store icon assignments
The system SHALL persist which icons are assigned to which modes.

#### Scenario: Save icon assignment
- **WHEN** user assigns an icon to a mode
- **THEN** system stores assignment relationship
- **AND** system includes icon metadata and mode reference

#### Scenario: Load icon assignments
- **WHEN** user switches modes
- **THEN** system loads icon assignments for target mode
- **AND** system applies visibility filters based on assignments

### Requirement: Store user preferences
The system SHALL persist user preferences and settings.

#### Scenario: Save preferences
- **WHEN** user changes any preference (shortcuts, themes, etc.)
- **THEN** system updates preference store
- **AND** changes take effect immediately

#### Scenario: Load preferences on launch
- **WHEN** user launches Flowbar
- **THEN** system loads all saved preferences
- **AND** system applies preferences before UI appears

### Requirement: Store onboarding state
The system SHALL track onboarding completion status.

#### Scenario: Mark onboarding complete
- **WHEN** user completes onboarding
- **THEN** system sets onboarding flag to true
- **AND** system skips onboarding on future launches

#### Scenario: Detect incomplete onboarding
- **WHEN** onboarding was not completed
- **THEN** system offers to resume onboarding
- **AND** system stores last completed step

### Requirement: Data migration
The system SHALL handle data migration between app versions.

#### Scenario: Migrate from v1.0 to v1.1
- **WHEN** user upgrades to newer version
- **THEN** system detects schema changes
- **AND** system migrates existing data automatically
- **AND** system preserves user data

#### Scenario: Handle migration failure
- **WHEN** data migration fails
- **THEN** system logs error details
- **AND** system creates backup of existing data
- **AND** system offers to restore defaults

### Requirement: Data export/import
The system SHALL allow users to export and import their configurations.

#### Scenario: Export configuration
- **WHEN** user chooses to export settings
- **THEN** system creates JSON file with all configurations
- **AND** system prompts for save location

#### Scenario: Import configuration
- **WHEN** user imports configuration file
- **THEN** system validates file format
- **AND** system merges with existing settings
- **AND** system creates backup before import

### Requirement: Data backup
The system SHALL automatically backup configuration data.

#### Scenario: Automatic backup
- **WHEN** user makes significant changes
- **THEN** system creates backup before applying changes
- **AND** system keeps last 5 backups

#### Scenario: Restore from backup
- **WHEN** user needs to restore settings
- **THEN** system offers list of available backups
- **AND** system allows restore from selected backup

### Requirement: Core Data integration
The system SHALL use SwiftData for persistence with Core Data compatibility.

#### Scenario: Initialize SwiftData
- **WHEN** app launches
- **THEN** system initializes SwiftData container
- **AND** system creates persistent store if needed
- **AND** system handles store errors gracefully

#### Scenario: Query modes efficiently
- **WHEN** system needs to load modes
- **THEN** system uses SwiftData queries
- **AND** system fetches only needed data
- **AND** system completes query within 100ms
