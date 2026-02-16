# Flowbar Release Notes

## Version 1.0.0 (Initial Release)

### 🎉 Welcome to Flowbar

Flowbar is a menu bar utility that helps you focus by managing menu bar icons and blocking interruptions during your work sessions.

### ✨ Features

#### Mode Switching
- **4 Default Modes**: Coding, Design, Meeting, and Focus modes pre-configured
- **Custom Modes**: Create up to 9 custom modes for different work contexts
- **Quick Switching**: Use ⌘+Shift+M to open the mode switcher or ⌘+Shift+1-9 for direct mode switching
- **Smart Icons**: Each mode shows only relevant menu bar icons

#### Focus Guard
- **Focus Theft Prevention**: Blocks apps from stealing focus during work sessions
- **Do Not Disturb**: Per-app DND settings to block notifications
- **Auto-Hide Notifications**: Automatically dismiss notification banners after 3 seconds
- **Status Indicator**: Visual indicator shows when Focus Guard is active

#### Mini Launcher
- **Quick Launch**: Press ⌘+Space to quickly find and launch apps
- **Fuzzy Search**: Intelligent search that finds apps even with partial matches
- **Mode Filtering**: Filter apps by mode using "mode name app name" syntax
- **Recent Apps**: Quick access to your recently used applications

#### Menu Bar Icon Management
- **Smart Scanning**: Automatically detects and categorizes menu bar icons
- **System Icon Detection**: Identifies and preserves system icons
- **Icon Assignment**: Assign icons to modes based on your workflow
- **Visibility Control**: Toggle icon visibility per mode

#### Onboarding
- **Guided Setup**: Step-by-step setup wizard for first-time users
- **Accessibility Guidance**: Clear instructions for granting necessary permissions
- **Icon Scanning**: Automatic menu bar icon detection during setup
- **Mode Customization**: Configure default modes to match your workflow

### 🔧 System Requirements

- macOS 14.0 (Sonoma) or later
- Accessibility permission for menu bar icon control
- 50 MB disk space

### 📋 What's New in Version 1.0.0

**Initial Release Features:**
- Complete mode management system
- Focus Guard with notification blocking
- Mini launcher with fuzzy search
- Comprehensive settings UI
- Dark mode support
- Keyboard shortcuts for all major functions
- Built-in help and documentation
- Performance optimizations
- Crash reporting and feedback collection

### 🐛 Known Issues

- Focus Guard may not work with some third-party apps that use alternative focus-stealing methods
- Icon detection may not work for apps with custom menu bar implementations
- Launcher shortcut (⌘+Space) may conflict with Spotlight or other launchers

### 🔄 Upcoming Features

- [ ] Cloud sync for settings and modes
- [ ] Advanced icon filtering rules
- [ ] Custom themes and appearance options
- [ ] Analytics dashboard
- [ ] Team collaboration features
- [ ] iOS companion app

### 📝 Installation

1. Download Flowbar-1.0.0.dmg
2. Open the disk image and drag Flowbar to Applications
3. Launch Flowbar from Applications folder
4. Follow the onboarding wizard to set up your modes
5. Grant Accessibility permission when prompted

### ⚙️ Configuration

After installation, configure Flowbar through:
- **Settings** (⌘+,): Access all Flowbar settings
- **Mode Editor**: Customize mode icons and assigned apps
- **Shortcuts**: Set custom keyboard shortcuts
- **Focus Guard**: Configure DND apps and sensitivity

### 🆘 Support

- **Documentation**: https://github.com/Fission-AI/Flowbar/wiki
- **Issues**: https://github.com/Fission-AI/Flowbar/issues
- **Discussions**: https://github.com/Fission-AI/Flowbar/discussions

### 🙏 Acknowledgments

Flowbar is built with:
- SwiftUI for modern macOS UI
- SwiftData for data persistence
- Accessibility API for menu bar control
- CGEvent Tap for focus protection

### 📄 License

Flowbar is released under the MIT License. See LICENSE file for details.

---

## Previous Versions

*No previous versions - this is the initial release.*

### Upgrade Instructions

*No upgrade needed - this is the initial release.*

### Archive

*No archived versions - this is the initial release.*
