# Flowbar User Guide

Welcome to Flowbar! This guide will help you get the most out of Flowbar's features.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Mode Management](#mode-management)
3. [Focus Guard](#focus-guard)
4. [Mini Launcher](#mini-launcher)
5. [Menu Bar Icons](#menu-bar-icons)
6. [Settings](#settings)
7. [Keyboard Shortcuts](#keyboard-shortcuts)
8. [Tips and Tricks](#tips-and-tricks)
9. [Troubleshooting](#troubleshooting)

## Getting Started

### First Launch

When you first launch Flowbar, you'll be guided through the onboarding process:

1. **Welcome Screen**: Introduction to Flowbar's features
2. **Accessibility Permission**: Grant permission for menu bar icon control
3. **Icon Scanning**: Flowbar scans your menu bar for icons
4. **Mode Setup**: Configure your default modes
5. **Shortcuts**: Set up keyboard shortcuts
6. **Complete**: You're ready to use Flowbar!

### Basic Usage

Once set up, you can:
- Click the Flowbar icon in your menu bar to switch modes
- Use keyboard shortcuts for quick access
- Open Settings to customize your experience

## Mode Management

### Understanding Modes

Modes are the core of Flowbar. Each mode represents a different work context:
- **Coding**: For development work
- **Design**: For creative work
- **Meeting**: For discussions and presentations
- **Focus**: For deep work sessions

### Switching Modes

**Method 1: Menu Bar Icon**
1. Click the Flowbar icon
2. Select your desired mode from the list

**Method 2: Mode Switcher**
1. Press ⌘+Shift+M
2. Use arrow keys to navigate
3. Press Enter to select

**Method 3: Direct Mode Switch**
1. Press ⌘+Shift+1-9
2. Flowbar switches directly to that mode

### Creating Custom Modes

1. Open Settings (⌘+,)
2. Go to the "Modes" tab
3. Click "Add Mode"
4. Enter mode name
5. Choose an icon from the picker
6. Click "Save"

### Editing Modes

1. Open Settings > Modes
2. Right-click on a mode
3. Select "Edit"
4. Make your changes
5. Click "Save"

### Deleting Modes

1. Open Settings > Modes
2. Right-click on a mode
3. Select "Delete"
4. Confirm deletion

**Note**: Default modes (Coding, Design, Meeting, Focus) cannot be deleted.

## Focus Guard

### What is Focus Guard?

Focus Guard prevents applications from stealing focus and blocks notifications during work sessions.

### Enabling Focus Guard

1. Open Settings
2. Go to "Focus Guard" tab
3. Toggle "Enable Focus Guard"
4. The shield icon appears when active

### Do Not Disturb Apps

Add apps to your DND list to block their notifications:

1. Open Settings > Focus Guard
2. Click "Add App"
3. Select from running applications
4. Toggle individual apps on/off

### Focus Guard Status

- 🛡️ **Green shield**: Focus Guard is active
- ⚠️ **Orange shield**: Focus Guard enabled but inactive
- No icon: Focus Guard disabled

## Mini Launcher

### Opening the Launcher

Press ⌘+Space to open the launcher.

### Searching for Apps

**Basic Search**: Type the app name
- "chr" → finds "Chrome"

**Fuzzy Search**: Type partial characters
- "gc" → finds "Google Chrome"

**Mode Filtering**: Search within a mode
- "coding term" → searches for Terminal in Coding mode

### Navigation

- **↑/↓**: Navigate results
- **Enter**: Launch selected app
- **ESC**: Close launcher
- **Tab**: Toggle between recent and search results

### Recent Apps

The launcher shows your recently used apps when opened with an empty search query.

## Menu Bar Icons

### Icon Scanning

Flowbar automatically scans your menu bar for icons:
- **System icons**: Always visible (Apple logo, control center, etc.)
- **App icons**: Can be hidden based on mode

### Assigning Icons to Modes

1. Open Settings > Icons
2. Select a mode from the dropdown
3. Click "Scan Icons" to refresh
4. Icons are automatically assigned based on heuristics

### Customizing Icon Visibility

1. Open Settings > Icons
2. Select a mode
3. Toggle individual icons on/off
4. Changes take effect immediately

### Icon Categories

**System Icons** (always visible):
- Apple menu
- Control Center
- Spotlight
- Notification Center

**App Icons** (mode-dependent):
- Third-party applications
- Development tools
- Communication apps

## Settings

### General Settings

- **Launch at login**: Automatically start Flowbar when you log in
- **Appearance**: Choose between System, Light, or Dark mode
- **Show menu bar icon**: Toggle Flowbar's menu bar icon

### Modes Settings

Create, edit, and delete modes. See [Mode Management](#mode-management) for details.

### Icons Settings

Manage icon assignments and visibility. See [Menu Bar Icons](#menu-bar-icons) for details.

### Shortcuts Settings

Customize keyboard shortcuts:
- **Launcher**: Default ⌘+Space
- **Mode Switcher**: Default ⌘+Shift+M
- **Mode 1-9**: Default ⌘+Shift+1-9

**Note**: Some shortcuts may conflict with system shortcuts or other apps.

### Focus Guard Settings

Configure Focus Guard behavior. See [Focus Guard](#focus-guard) for details.

## Keyboard Shortcuts

### Global Shortcuts

| Shortcut | Action |
|----------|--------|
| ⌘+Shift+M | Open mode switcher |
| ⌘+Shift+1-9 | Switch to mode 1-9 |
| ⌘+Space | Open launcher |
| ⌘+, | Open Settings |
| ⌘+Q | Quit Flowbar |

### Launcher Shortcuts

| Shortcut | Action |
|----------|--------|
| ESC | Close launcher |
| ↑/↓ | Navigate results |
| Enter | Launch selected app |
| Tab | Toggle recent/search |

### Mode Switcher Shortcuts

| Shortcut | Action |
|----------|--------|
| ←/→ | Navigate modes |
| Enter | Switch to selected mode |
| ESC | Close switcher |

## Tips and Tricks

### Productivity Tips

1. **Use Direct Mode Switching**: Assign frequently used modes to ⌘+Shift+1-4
2. **Create Context-Specific Modes**: Make modes for different projects or clients
3. **Customize Icon Assignments**: Show only what you need for each mode
4. **Enable Focus Guard During Deep Work**: Prevent interruptions
5. **Use Launcher for App Switching**: Faster than Command+Tab for many apps

### Advanced Usage

**Mode-Specific App Launching**:
- Open launcher with Flowbar
- Type mode name before app name
- Example: "coding xcode" launches Xcode in Coding mode

**Temporary Mode Switching**:
- Hold ⌘+Shift while pressing mode number
- Release to return to previous mode

**Quick Settings Access**:
- Right-click menu bar icon
- Select "Settings" to open preferences

### Customization Ideas

**Work Mode Icons**:
- 💻 Coding
- 🎨 Design
- 📊 Analytics
- ✍️ Writing
- 📧 Email
- 📞 Communication

**Color-Coded Modes**:
- Use red for "Do Not Disturb"
- Use green for "Available"
- Use yellow for "Focus Time"

## Troubleshooting

### Common Issues

**Icons not hiding**:
1. Check Accessibility permission is granted
2. Rescan menu bar icons in Settings > Icons
3. Restart Flowbar

**Focus Guard not working**:
1. Ensure Focus Guard is enabled
2. Check app is in DND list
3. Verify Focus Guard shows shield icon

**Launcher not opening**:
1. Check for shortcut conflicts (Spotlight, Launchbar, etc.)
2. Change launcher shortcut in Settings > Shortcuts
3. Ensure Flowbar is running

**App crashed or frozen**:
1. Force quit and restart Flowbar
2. Check Console.app for crash logs
3. Report issue on GitHub

### Getting Help

- **Help Menu**: Access built-in help (⌘+?)
- **Documentation**: Visit https://github.com/Fission-AI/Flowbar/wiki
- **Issues**: Report bugs at https://github.com/Fission-AI/Flowbar/issues
- **Discussions**: Ask questions at https://github.com/Fission-AI/Flowbar/discussions

### Resetting Flowbar

If all else fails, you can reset Flowbar:

1. Quit Flowbar
2. Delete `~/Library/Application Support/Flowbar/`
3. Relaunch Flowbar
4. Complete onboarding again

**Warning**: This will delete all your settings and customizations.

---

## Additional Resources

- **Privacy Policy**: See PRIVACY_POLICY.md
- **Release Notes**: See RELEASE_NOTES.md
- **Developer Guide**: See CONTRIBUTING.md
- **GitHub Repository**: https://github.com/Fission-AI/Flowbar

Enjoy using Flowbar! 🚀
