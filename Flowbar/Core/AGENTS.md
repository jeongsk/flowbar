# Flowbar Core Module

## Purpose
The Core module provides the foundational functionality for the Flowbar application. It contains all data models, persistence logic, animations, utility functions, and extensions that power the app's core features.

## Directory Structure

```
Flowbar/Core/
├── Models/              # SwiftData model definitions
├── Persistence/         # Data persistence and management
├── Animations/          # SwiftUI animations and transitions
├── Extensions/          # Swift extensions (currently empty, reserved for future use)
└── Utils/              # Utility managers and helpers
```

## Key Files

### Persistence/DataController.swift
The central data management singleton that:
- Manages SwiftData ModelContainer and ModelContext
- Handles all SwiftData models (Mode, IconAssignment, Preference, OnboardingState, AppAssignment, DNDApp)
- Provides backup/restore functionality for user data
- Implements automatic backup management (keeps last 5 backups)
- Offers save() and clearAllData() methods for data operations

### Models/
All SwiftData models that define the app's data structure:

- **Mode.swift**: Represents user-defined modes with name, icon, icon assignments, and keyboard shortcuts
- **IconAssignment.swift**: Maps icons to specific applications within a mode
- **Preference.swift**: Stores app-wide preferences (theme, language, shortcuts, notification settings)
- **OnboardingState.swift**: Tracks user onboarding progress
- **AppAssignment.swift**: Associates applications with modes
- **DNDApp.swift**: Represents Do Not Disturb app configurations

### Animations/FlowbarAnimations.swift
Centralized animation definitions for consistent UI behavior:
- Mode switching animations
- Icon fade transitions
- Spring animations with configurable parameters
- Custom view modifiers for animated effects
- Pre-defined transitions (default, slide, scale)

### Utils/
Manager classes for specialized functionality:

- **FeedbackManager.swift**: Handles user feedback systems
- **OptimizationManager.swift**: Performance optimization utilities

## Dependencies

### Frameworks
- **SwiftUI**: Used throughout for view modifiers and animations
- **SwiftData**: Core persistence framework for all models
- **Foundation**: Base framework for data types and file operations

### External Dependencies
None (Core module uses only Apple frameworks)

## Architecture Patterns

### Singleton Pattern
- DataController uses @MainActor singleton for thread-safe data access
- Ensures single source of truth for all data operations

### Model-View Separation
- Models are pure SwiftData @Model classes
- No view logic in model files
- Animations are separate from views for reusability

### Backup Strategy
- JSON-based backup format for portability
- Automatic rotation (keeps 5 most recent backups)
- Manual backup/restore methods available

## AI Agent Instructions

When working with Core module code:

### Adding New Models
1. Create model file in Models/ directory
2. Mark with @Model and @MainActor if needed
3. Add to DataController's schema array
4. Add to clearAllData() method
5. Include in backup/restore logic if persistent
6. Follow naming convention: Capitalized, descriptive names

### Modifying Data Operations
1. Always use DataController.shared for data access
2. Call save() after modifying model contexts
3. Use @MainActor for UI-related data operations
4. Test backup/restore after schema changes
5. Consider migration strategies for existing data

### Animation Guidelines
1. Add new animations to FlowbarAnimations.swift
2. Use static methods for animations
3. Use view modifiers for reusable animation effects
4. Keep animation durations short (0.2-0.4s typical)
5. Test animations on different devices

### Code Style
- Use MARK comments for section organization
- Keep models focused on data only (no business logic)
- Document complex backup/restore logic
- Use dependency injection for utilities when possible
- Maintain thread safety with @MainActor annotations

### Testing Considerations
- DataController should be tested with in-memory configurations
- Mock data for UI previews in model files
- Test backup/restore with various data scenarios
- Verify animations don't cause performance issues

### Performance Notes
- Keep model queries efficient with proper FetchDescriptor usage
- Avoid N+1 queries with relationships
- Use lazy loading for large datasets
- Cache frequently accessed preferences
- Monitor SwiftData memory usage

## Related Modules
- Core provides data models used by Features views
- Animations consumed by UI components throughout the app
- Utils support both Core and Feature modules
