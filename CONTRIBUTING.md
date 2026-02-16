# Contributing to Flowbar

Thank you for your interest in contributing to Flowbar! We welcome contributions from the community and appreciate your help in making Flowbar better.

## 🤝 How to Contribute

### Reporting Bugs

Before creating bug reports, please check existing issues to avoid duplicates. When creating a bug report, include:

- **Clear title**: Descriptive summary of the issue
- **Description**: Detailed explanation of the problem
- **Steps to reproduce**: Step-by-step instructions
- **Expected behavior**: What should happen
- **Actual behavior**: What actually happens
- **Environment**: macOS version, Flowbar version
- **Screenshots**: If applicable

### Suggesting Enhancements

Feature requests are welcome! Please include:

- **Use case**: Why would this feature be useful?
- **Proposed solution**: How should it work?
- **Alternatives**: What other approaches did you consider?
- **Impact**: Who would benefit and how?

## 🛠️ Development Workflow

### Setting Up Development Environment

1. **Fork the repository**
   ```bash
   # Fork on GitHub first, then:
   git clone https://github.com/YOUR-USERNAME/Flowbar.git
   cd Flowbar
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/Fission-AI/Flowbar.git
   ```

3. **Open in Xcode**
   ```bash
   open Flowbar.xcodeproj
   ```

4. **Build and run**
   - Press ⌘+R in Xcode
   - Or use: `xcodebuild -project Flowbar.xcodeproj -scheme Flowbar`

### Creating a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

Branch naming convention:
- `feature/` - New features
- `fix/` - Bug fixes
- `docs/` - Documentation updates
- `refactor/` - Code refactoring
- `test/` - Test additions or updates

### Making Changes

1. **Code style**: Follow existing code style and conventions
2. **Comments**: Document complex logic
3. **Tests**: Add tests for new functionality
4. **Commits**: Write clear, descriptive commit messages

#### Commit Message Format

```
type(scope): subject

body (optional)

footer (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Test additions or changes
- `chore`: Build process or auxiliary tool changes

Example:
```
feat(launcher): Add fuzzy search for app names

Implement fuzzy matching algorithm to find apps even with
partial or misspelled names. Improves user experience when
searching for applications.

Closes #123
```

### Testing

Before submitting, ensure:

1. **Tests pass**: Run all tests
   ```bash
   xcodebuild test -project Flowbar.xcodeproj -scheme Flowbar -destination 'platform=macOS'
   ```

2. **Manual testing**: Test your changes manually
   - Test on multiple macOS versions if possible
   - Test edge cases

3. **Code review**: Review your own changes
   - Check for bugs or issues
   - Ensure code is clean and readable

### Submitting Changes

1. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request**
   - Go to the Flowbar repository on GitHub
   - Click "New Pull Request"
   - Provide a clear description of your changes
   - Reference related issues

3. **PR Description Template**
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] Tests added/updated
   - [ ] Manual testing completed

   ## Checklist
   - [ ] Code follows project style
   - [ ] Self-review completed
   - [ ] Comments added to complex code
   - [ ] Documentation updated
   - [ ] No new warnings generated
   - [ ] Tests pass locally

   ## Related Issues
   Fixes #123
   ```

### Review Process

1. **Automated checks**: CI runs tests and linting
2. **Code review**: Maintainers review your changes
3. **Feedback**: Address review comments
4. **Approval**: Once approved, your PR will be merged

## 📝 Coding Guidelines

### Swift Style Guide

Follow these conventions:

1. **Naming**
   - Use `camelCase` for variables and functions
   - Use `PascalCase` for types and protocols
   - Use descriptive names, avoid abbreviations

2. **Organization**
   - Group related code with `// MARK:` comments
   - Separate public and private APIs
   - Keep files focused on a single responsibility

3. **Documentation**
   - Document public APIs
   - Use `///` for single-line documentation
   - Use `/** */` for multi-line documentation

4. **Error Handling**
   - Use `throw` for recoverable errors
   - Use `fatalError` for unrecoverable errors
   - Provide meaningful error messages

### SwiftUI Guidelines

1. **View organization**
   - Keep views focused and small
   - Extract reusable components
   - Use `@ViewBuilder` for complex view builders

2. **State management**
   - Use `@State` for local view state
   - Use `@ObservedObject` for external objects
   - Use `@EnvironmentObject` for shared objects

3. **Performance**
   - Avoid unnecessary view redraws
   - Use lazy loading for large lists
   - Profile with Instruments

### Accessibility

1. **Test with VoiceOver**
   - Ensure all UI elements are accessible
   - Provide accessibility labels
   - Test navigation flow

2. **Keyboard navigation**
   - Support keyboard shortcuts
   - Ensure tab order is logical
   - Provide visual feedback

## 🧪 Testing Guidelines

### Unit Tests

- Test public APIs
- Test edge cases
- Mock external dependencies
- Keep tests fast and focused

### UI Tests

- Test user workflows
- Test on different screen sizes
- Test with different system settings

### Integration Tests

- Test feature interactions
- Test data persistence
- Test performance

## 🐛 Debugging

### Common Issues

1. **Accessibility permission not granted**
   - Check System Settings > Privacy & Security > Accessibility
   - Restart Flowbar after granting permission

2. **Icons not detected**
   - Verify Accessibility permission
   - Rescan menu bar icons
   - Check Console.app for errors

3. **Focus Guard not working**
   - Ensure Focus Guard is enabled
   - Check DND app settings
   - Verify event tap is installed

### Logging

Use `Logger` for logging:

```swift
import os.log

let logger = Logger(subsystem: "com.flowbar.app", category: "YourCategory")

logger.info("Information message")
logger.error("Error: \(error)")
logger.debug("Debug: \(value)")
```

## 📚 Resources

### Documentation
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [Accessibility Programming Guide](https://developer.apple.com/library/archive/documentation/Accessibility/Conceptual/AccessibilityProgrammingGuideForMac/)

### Tools
- [Xcode](https://developer.apple.com/xcode/)
- [Instruments](https://developer.apple.com/library/archive/documentation/DeveloperTools/Conceptual/InstrumentsUserGuide/)
- [SwiftLint](https://github.com/realm/SwiftLint)

### Community
- [Swift Forums](https://forums.swift.org/)
- [macOS Developers Slack](https://macos-slack.com/)

## 🎯 Project-Specific Guidelines

### Architecture Decisions

- **MVVM + Coordinator**: Use for complex UI flows
- **SwiftData**: For data persistence
- **Accessibility API**: For menu bar control
- **CGEvent Tap**: For focus protection

### Feature Implementation

When implementing new features:

1. **Design first**: Create spec or design doc
2. **Discuss**: Open issue to discuss approach
3. **Implement**: Follow coding guidelines
4. **Test**: Add comprehensive tests
5. **Document**: Update user and dev docs

## ⚖️ Code of Conduct

Be respectful, inclusive, and professional:
- Treat others with respect
- Welcome newcomers
- Focus on constructive feedback
- Avoid personal attacks

## 📞 Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and ideas
- **Code Reviews**: For code-specific feedback

## 🙏 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in significant features

Thank you for contributing to Flowbar! 🎉

---

## Quick Reference

```bash
# Setup
git clone https://github.com/YOUR-USERNAME/Flowbar.git
cd Flowbar
git remote add upstream https://github.com/Fission-AI/Flowbar.git

# Development
git checkout -b feature/amazing-feature
# ... make changes ...
git commit -m "feat: add amazing feature"
git push origin feature/amazing-feature

# Sync with upstream
git fetch upstream
git rebase upstream/main

# Testing
xcodebuild test -project Flowbar.xcodeproj -scheme Flowbar
```

Happy contributing! 🚀
