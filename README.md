# Flowbar

<div align="center">

**Focus-Enhancing Menu Bar Utility for macOS**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-14%2B-blue.svg)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Configuration](#configuration) • [Contributing](#contributing)

</div>

## Overview

Flowbar is a powerful menu bar utility that helps you maintain focus by intelligently managing menu bar icons and preventing interruptions during work sessions. Perfect for developers, designers, and anyone who wants to minimize distractions.

## ✨ Features

### 🔄 Mode Switching
- **Smart Modes**: Create up to 9 custom modes for different work contexts (Coding, Design, Meeting, etc.)
- **Icon Filtering**: Each mode shows only relevant menu bar icons
- **Quick Switching**: Lightning-fast mode switching via keyboard shortcuts
- **Custom Icons**: Personalize each mode with custom icons

### 🛡️ Focus Guard
- **Focus Theft Prevention**: Blocks apps from stealing focus
- **Do Not Disturb**: Per-app DND settings to block notifications
- **Auto-Hide**: Automatically dismiss notification banners
- **Visual Indicators**: Status overlay shows when Focus Guard is active

### 🚀 Mini Launcher
- **Quick Launch**: ⌘+Space to launch any app instantly
- **Fuzzy Search**: Find apps even with partial matches
- **Mode Filtering**: Search apps within specific modes
- **Recent Apps**: Quick access to recently used applications

### 🎯 Menu Bar Management
- **Smart Scanning**: Automatically detects and categorizes menu bar icons
- **System Icon Detection**: Identifies and preserves system icons
- **Icon Assignment**: Assign icons to modes based on your workflow
- **Visibility Control**: Fine-grained control over icon visibility

## 📥 Installation

### Requirements
- macOS 14.0 (Sonoma) or later
- Accessibility permission (for menu bar icon control)

### Install from Release

1. Download the latest [release](https://github.com/Fission-AI/Flowbar/releases)
2. Open `Flowbar-1.0.0.dmg`
3. Drag Flowbar to Applications folder
4. Launch Flowbar from Applications
5. Follow the onboarding wizard

### Build from Source

```bash
# Clone the repository
git clone https://github.com/Fission-AI/Flowbar.git
cd Flowbar

# Open in Xcode
open Flowbar.xcodeproj

# Build and run (⌘+R in Xcode)
```

## 🚀 Usage

### Quick Start

1. **Grant Accessibility Permission**
   - Flowbar will prompt you on first launch
   - Go to System Settings > Privacy & Security > Accessibility
   - Enable Flowbar

2. **Complete Onboarding**
   - Follow the guided setup wizard
   - Scan your menu bar icons
   - Customize default modes

3. **Start Using Flowbar**
   - Click the menu bar icon to switch modes
   - Use ⌘+Shift+M for the mode switcher
   - Press ⌘+Space to open the launcher

### Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘+Shift+M | Open mode switcher |
| ⌘+Shift+1-9 | Switch to mode 1-9 |
| ⌘+Space | Open launcher |
| ⌘+, | Open Settings |
| ESC | Close windows |

### Mode Management

**Creating Modes:**
1. Open Settings (⌘+,)
2. Go to Modes tab
3. Click "Add Mode"
4. Enter mode name and select icon
5. Assign icons to the mode

**Switching Modes:**
- Click menu bar icon → Select mode
- Use ⌘+Shift+M → Select from switcher
- Press ⌘+Shift+1-9 → Direct mode switch

## ⚙️ Configuration

### Modes

Customize each mode with:
- **Name**: Descriptive name for the mode
- **Icon**: Choose from 12+ SF Symbols
- **Icon Assignments**: Select which menu bar icons to show

### Focus Guard

Configure focus protection:
- **Enable/Disable**: Toggle Focus Guard on/off
- **DND Apps**: Add apps to Do Not Disturb list
- **Sensitivity**: Adjust focus theft detection threshold

### Shortcuts

Customize keyboard shortcuts:
- **Mode Switcher**: Default ⌘+Shift+M
- **Launcher**: Default ⌘+Space
- **Direct Mode Switch**: ⌘+Shift+1-9

### Appearance

Personalize the look:
- **Dark/Light Mode**: System, Light, or Dark
- **Menu Bar Icon**: Show/hide menu bar icon
- **Animations**: Enable/disable transitions

## 🔧 Development

### Project Structure

```
Flowbar/
├── App/                    # Application entry point
│   ├── FlowbarApp.swift
│   └── AppDelegate.swift
├── Core/                   # Core functionality
│   ├── Models/            # SwiftData models
│   ├── Persistence/       # Data controller
│   ├── Animations/        # UI animations
│   └── Utils/             # Utilities
├── Features/              # Feature modules
│   ├── MenuBar/          # Menu bar management
│   ├── ModeSwitcher/     # Mode switching
│   ├── FocusGuard/       # Focus protection
│   ├── Launcher/         # App launcher
│   ├── Onboarding/       # First-run setup
│   ├── Settings/         # Settings UI
│   └── Help/             # Help & documentation
└── FlowbarTests/         # Test suites
```

### Building

```bash
# Build for development
xcodebuild -project Flowbar.xcodeproj -scheme Flowbar -configuration Debug

# Build for release
xcodebuild -project Flowbar.xcodeproj -scheme Flowbar -configuration Release

# Run tests
xcodebuild test -project Flowbar.xcodeproj -scheme Flowbar -destination 'platform=macOS'
```

### Dependencies

Flowbar is built with:
- **SwiftUI**: Modern UI framework
- **SwiftData**: Data persistence
- **AppKit**: Native macOS integration
- **Accessibility API**: Menu bar control
- **CGEvent Tap**: Focus protection

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### How to Contribute

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/Flowbar.git
cd Flowbar

# Add upstream remote
git remote add upstream https://github.com/Fission-AI/Flowbar.git

# Install dependencies (if any)
# No external dependencies - pure Swift/SwiftUI!

# Open in Xcode
open Flowbar.xcodeproj
```

## 📄 License

Flowbar is released under the [MIT License](LICENSE).

## 🙏 Acknowledgments

- Built with [Swift](https://swift.org) and [SwiftUI](https://developer.apple.com/xcode/swiftui/)
- Inspired by [Bartender](https://www.macbartender.com/) and [HazeOver](https://hazeover.com/)
- Icons from [SF Symbols](https://developer.apple.com/sf-symbols/)

## 📞 Support

- **Documentation**: [Wiki](https://github.com/Fission-AI/Flowbar/wiki)
- **Issues**: [GitHub Issues](https://github.com/Fission-AI/Flowbar/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Fission-AI/Flowbar/discussions)

## 🗺️ Roadmap

### Version 1.1 (Planned)
- [ ] Cloud sync for settings
- [ ] Advanced filtering rules
- [ ] Custom themes
- [ ] Performance improvements

### Version 2.0 (Future)
- [ ] Team collaboration features
- [ ] iOS companion app
- [ ] Analytics dashboard
- [ ] Plugin system

---

<div align="center">

Made with ❤️ by the Flowbar team

[Website](https://flowbar.app) • [Blog](https://blog.flowbar.app) • [Twitter](https://twitter.com/flowbarapp)

</div>
