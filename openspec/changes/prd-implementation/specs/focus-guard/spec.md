# Focus Guard Specification

## ADDED Requirements

### Requirement: Prevent keyboard focus theft
The system SHALL prevent new windows from stealing keyboard focus without user action.

#### Scenario: Block focus steal on new window
- **WHEN** a new window opens while user is typing
- **THEN** system prevents the window from taking keyboard focus
- **AND** user continues typing in previous window
- **AND** new window opens in background

#### Scenario: Allow intentional focus changes
- **WHEN** user clicks on a new window
- **THEN** system allows the focus change
- **AND** system does not interfere with user-initiated actions

### Requirement: Do Not Disturb app list
The system SHALL allow users to specify apps that should never interrupt.

#### Scenario: Block notifications from DND apps
- **WHEN** an app in the DND list attempts to show a notification
- **THEN** system suppresses the notification
- **AND** system logs the blocked notification

#### Scenario: Add app to DND list
- **WHEN** user adds an app to DND list
- **THEN** system stores the app's bundle identifier
- **AND** system applies DND rules immediately

#### Scenario: Remove app from DND list
- **WHEN** user removes an app from DND list
- **THEN** system restores normal notification behavior
- **AND** future notifications are not blocked

### Requirement: Notification banner auto-hide
The system SHALL automatically hide notification banners after a configurable duration.

#### Scenario: Auto-hide banner after timeout
- **WHEN** a notification banner appears
- **THEN** system automatically hides it after 3 seconds (default)
- **AND** user can dismiss manually by clicking

#### Scenario: Configure auto-hide duration
- **WHEN** user changes auto-hide duration
- **THEN** system updates timeout value
- **AND** system applies new duration to future notifications

### Requirement: Focus guard activation
The system SHALL activate focus guard when focus mode is enabled.

#### Scenario: Enable focus guard in focus mode
- **WHEN** user switches to focus mode
- **THEN** system enables focus guard
- **AND** system blocks focus stealing
- **AND** system suppresses notifications (if configured)

#### Scenario: Disable focus guard when leaving focus mode
- **WHEN** user switches away from focus mode
- **THEN** system disables focus guard
- **AND** system restores normal window behavior
- **AND** system restores normal notifications

### Requirement: Focus guard status indicator
The system SHALL indicate when focus guard is active.

#### Scenario: Menu bar icon indicator
- **WHEN** focus guard is active
- **THEN** Flowbar icon shows shield or lock overlay
- **AND** system provides tooltip explaining active protection

#### Scenario: Notification when blocked
- **WHEN** focus guard blocks a focus steal event
- **THEN** system shows subtle notification (if enabled)
- **AND** system logs the event for review

### Requirement: Focus guard preferences
The system SHALL provide preferences for focus guard behavior.

#### Scenario: Toggle focus guard per mode
- **WHEN** user configures a mode
- **THEN** user can enable/disable focus guard for that mode
- **AND** system respects mode-specific settings

#### Scenario: Configure sensitivity level
- **WHEN** user adjusts focus guard sensitivity
- **THEN** system changes threshold for what constitutes focus stealing
- **AND** system provides preview of behavior
