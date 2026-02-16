<!-- Generated: 2026-02-16 | Updated: 2026-02-16 -->

# Flowbar

## Purpose
Flowbar is a focus-enhancing menu bar utility for macOS that helps users maintain focus by intelligently managing menu bar icons and preventing interruptions during work sessions.

## Key Files

| File | Description |
|------|-------------|
| `README.md` | Project overview and setup instructions |
| `CONTRIBUTING.md` | Development workflow and guidelines |
| `PRIVACY_POLICY.md` | Privacy policy and data handling |
| `RELEASE_NOTES.md` | Version 1.0.0 release notes |
| `docs/PRD.md` | Product Requirements Document |

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `Flowbar/` | Main macOS application (see `Flowbar/AGENTS.md`) |
| `docs/` | Documentation and specifications (see `docs/AGENTS.md`) |
| `openspec/` | OpenSpec workflow artifacts (see `openspec/AGENTS.md`) |
| `landing/` | Landing page for marketing |
| `src/` | Legacy source code directory |

## For AI Agents

### Working In This Directory
- This is a macOS app project using Swift and SwiftUI
- Primary development happens in the `Flowbar/` directory
- Use Xcode for building and testing
- Follow Swift coding conventions

### Testing Requirements
- Run tests with `xcodebuild test -project Flowbar/Flowbar.xcodeproj`
- Test on macOS 14.0 (Sonoma) or later
- Ensure Accessibility permission is granted for menu bar features

### Common Patterns
- SwiftUI for UI components
- SwiftData for persistence
- @MainActor for UI-related classes
- MVVM + Coordinator pattern for architecture

## Dependencies

### External
- Swift 5.9+ - Programming language
- SwiftUI - UI framework
- SwiftData - Data persistence (macOS 14+)
- AppKit - Native macOS integration
- Accessibility API - Menu bar control
- CGEvent Tap - Focus protection

### Development Tools
- Xcode 15.0+ - IDE
- SwiftLint - Code linting (recommended)

## Project Status

**Version**: 1.0.0 (Initial Release)

**Implementation Status**: All 96 tasks completed across 12 sections

## Build Instructions

```bash
# Open in Xcode
open Flowbar/Flowbar.xcodeproj

# Build from command line
xcodebuild -project Flowbar/Flowbar.xcodeproj -scheme Flowbar -configuration Release

# Run tests
xcodebuild test -project Flowbar/Flowbar.xcodeproj -scheme Flowbar
```

<!-- MANUAL: -->
