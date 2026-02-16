# GitHub Actions CI/CD Specification for Flowbar macOS Application

## Project Overview

**Project**: Flowbar
**Type**: Native macOS Application (.app bundle)
**Language**: Swift 5.9+
**UI Framework**: SwiftUI
**Minimum Deployment Target**: macOS 14.0 (Sonoma)
**Build System**: Xcode Build System (xcodebuild)
**Project Location**: `Flowbar/Flowbar.xcodeproj`

## Current State Analysis

### Version Configuration
- **Primary Info.plist**: `Flowbar/Info.plist`
- **Version Variables**: Uses Xcode build variables
  - `CFBundleShortVersionString`: `$(MARKETING_VERSION)` - Currently unset in project
  - `CFBundleVersion`: `$(CURRENT_PROJECT_VERSION)` - Currently unset in project
- **Fallback Info.plist**: `src/Info.plist` contains hardcoded values:
  - `CFBundleShortVersionString`: `1.0`
  - `CFBundleVersion`: `1`

### Project Structure
```
Flowbar/
├── Flowbar.xcodeproj/         # Xcode project
├── Flowbar.entitlements       # App entitlements (automation, file access)
├── Info.plist                 # Primary app configuration
├── App/                       # Application entry point
│   ├── FlowbarApp.swift
│   └── AppDelegate.swift
├── Core/                      # Core functionality
├── Features/                  # Feature modules
└── Resources/
    └── Assets.xcassets/       # App icons and assets
```

### Build Artifacts
- **Primary**: `Flowbar.app` bundle
- **Distribution**: `.dmg` disk image (to be created)

---

## Workflow Specification

### 1. Workflow File Structure

**Location**: `.github/workflows/release.yml`

**Triggers**:
- Manual workflow dispatch with version bump type selection
- Tag push events (for automatic releases on tag creation)

**Workflow Inputs** (for manual trigger):
```yaml
inputs:
  bump_type:
    description: 'Version bump type'
    required: true
    type: choice
    options:
      - major
      - minor
      - patch
    default: 'minor'
  pre_release:
    description: 'Mark as pre-release'
    required: false
    type: boolean
    default: false
```

---

## 2. Version Bumping Strategy

### Recommended Approach: Manual Trigger with Semi-Automatic Bumping

**Rationale**: Manual trigger provides control over release timing while automating the version calculation and tagging process.

### Version Storage Format
**Required**: Create a `VERSION` file in project root
```
1.0.0
```

**Alternative**: Use Git tags as source of truth (recommended for simplicity)

### Version Bumping Logic

```yaml
# Pseudo-code for version calculation
current_version = $(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
# Parse semver: MAJOR.MINOR.PATCH
if bump_type == "major":
    new_version = "${MAJOR + 1}.0.0"
elif bump_type == "minor":
    new_version = "${MAJOR}.${MINOR + 1}.0"
elif bump_type == "patch":
    new_version = "${MAJOR}.${MINOR}.${PATCH + 1}"
```

### Git Tag Format
- Format: `v{VERSION}` (e.g., `v1.0.0`, `v1.1.0`)
- Annotated tags with release notes

### Xcode Version Update
**Method**: Pass version as build argument

```bash
xcodebuild \
  -project Flowbar.xcodeproj \
  -scheme Flowbar \
  MARKETING_VERSION=${new_version} \
  CURRENT_PROJECT_VERSION=1 \
  # ... other args
```

---

## 3. Build Process Details

### Build Environment

**GitHub Actions Runner**: `macos-latest` (currently macOS 14)

**Required Tools**:
- Xcode Command Line Tools (pre-installed)
- Xcode (latest stable version via xcodes tool or pre-installed)
- `create-dmg` tool for DMG creation

### Build Steps

#### Step 1: Environment Setup
```yaml
- name: Select Xcode version
  run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

- name: Show Xcode version
  run: xcodebuild -version
```

#### Step 2: Install DMG Creation Tool
```yaml
- name: Install create-dmg
  run: brew install create-dmg
```

**Alternative**: Use built-in `hdiutil` (no installation required)

#### Step 3: Build Application
```yaml
- name: Build Flowbar.app
  run: |
    xcodebuild \
      -project Flowbar/Flowbar.xcodeproj \
      -scheme Flowbar \
      -configuration Release \
      -derivedDataPath ./build \
      MARKETING_VERSION=${{ env.VERSION }} \
      CURRENT_PROJECT_VERSION=1 \
      MACOSX_DEPLOYMENT_TARGET=14.0 \
      clean build \
      CODE_SIGN_IDENTITY="-" \
      CODE_SIGNING_REQUIRED=NO \
      CODE_SIGNING_ALLOWED=NO
```

**Notes**:
- `CODE_SIGN_IDENTITY="-"` disables code signing for CI builds
- Unsigned builds are acceptable for open-source distribution
- For signed builds, a Apple Developer certificate would be required as a GitHub Secret

#### Step 4: Locate Built App
```yaml
- name: Locate built app
  run: |
    APP_PATH=$(find build -name "Flowbar.app" -type d | head -1)
    echo "APP_PATH=$APP_PATH" >> $GITHUB_ENV
    ls -lh "$APP_PATH"
```

**Expected Output**: `build/Build/Products/Release/Flowbar.app`

#### Step 5: Create DMG
```yaml
- name: Create DMG
  run: |
    create-dmg \
      --volname "Flowbar" \
      --window-pos 200 120 \
      --window-size 600 400 \
      --icon-size 100 \
      --app-drop-link 450 185 \
      --icon "Flowbar.app" 150 185 \
      "Flowbar-${{ env.VERSION }}.dmg" \
      "$APP_PATH"
```

**Alternative (using hdiutil)**:
```yaml
- name: Create DMG (hdiutil)
  run: |
    # Create temporary DMG structure
    mkdir -p dmg-root
    cp -R "$APP_PATH" dmg-root/

    # Create DMG
    hdiutil create \
      -volname "Flowbar" \
      -srcfolder dmg-root \
      -ov \
      -format UDZO \
      "Flowbar-${{ env.VERSION }}.dmg"
```

#### Step 6: Generate Build Info
```yaml
- name: Generate build info
  run: |
    cat > build-info.txt << EOF
    Flowbar ${{ env.VERSION }}
    Build Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
    Commit: ${{ github.sha }}
    Branch: ${{ github.ref_name }}
    macOS Target: 14.0+
    EOF
```

---

## 4. Release Upload Configuration

### GitHub Release Creation

```yaml
- name: Create GitHub Release
  uses: softprops/action-gh-release@v1
  with:
    tag_name: v${{ env.VERSION }}
    name: Flowbar v${{ env.VERSION }}
    body: |
      ## Flowbar v${{ env.VERSION }}

      ### Download
      - **Flowbar-${{ env.VERSION }}.dmg**: Disk image installer

      ### Installation
      1. Download the DMG file
      2. Open the disk image
      3. Drag Flowbar to Applications
      4. Launch from Applications folder

      ### Release Notes
      See [RELEASE_NOTES.md](https://github.com/Fission-AI/Flowbar/blob/main/RELEASE_NOTES.md) for details.

      ---
      **Build Info**
      - Commit: ${{ github.sha }}
      - Build Date: ${{ github.event.head_commit.timestamp }}
    files: |
      Flowbar-${{ env.VERSION }}.dmg
    draft: false
    prerelease: ${{ inputs.pre_release || false }}
    generate_release_notes: true
  env:
    GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

### Artifacts to Upload
1. **Flowbar-{VERSION}.dmg** - Primary distribution format
2. **Flowbar-{VERSION}-build-info.txt** - Build metadata (optional)
3. **Flowbar.app.zip** - Archived app bundle (optional, for direct download)

---

## 5. Required Secrets and Permissions

### GitHub Token (Built-in)
```yaml
permissions:
  contents: write
```
- `GITHUB_TOKEN`: Automatically provided by GitHub Actions
- Requires `contents: write` permission for creating releases and tags

### Optional Secrets for Signed Builds

If code signing is required (for distribution outside GitHub or reduced security warnings):

| Secret Name | Description | How to Generate |
|-------------|-------------|-----------------|
| `APPLE_DEVELOPER_CERTIFICATE` | Base64-encoded .p12 certificate | Export from Xcode/Keychain |
| `CERTIFICATE_PASSWORD` | Certificate password | Set during export |
| `KEYCHAIN_PASSWORD` | Temporary keychain password | Generate random password |
| `APPLE_ID` | Apple ID for notarization | Developer account email |
| `APP_SPECIFIC_PASSWORD` | App-specific password | Generate at appleid.apple.com |
| `TEAM_ID` | Apple Developer Team ID | Found in Apple Developer portal |

### Code Signing Workflow (Optional)

```yaml
- name: Import certificate
  run: |
    # Create temporary keychain
    security create-keychain -p "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain
    security default-keychain -s build.keychain
    security unlock-keychain -p "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain

    # Import certificate
    echo "${{ secrets.APPLE_DEVELOPER_CERTIFICATE }}" | base64 -d > certificate.p12
    security import certificate.p12 -k build.keychain -P "${{ secrets.CERTIFICATE_PASSWORD }}" -T /usr/bin/codesign
    security set-key-partition-list -S apple-tool:,apple: -s -k "${{ secrets.KEYCHAIN_PASSWORD }}" build.keychain

- name: Build (signed)
  run: |
    xcodebuild \
      # ... other args
      CODE_SIGN_IDENTITY="Developer ID Application" \
      CODE_SIGNING_REQUIRED=YES \
      OTHER_CODE_SIGN_FLAGS="--keychain build.keychain"
```

---

## 6. Complete Workflow File

### File: `.github/workflows/release.yml`

```yaml
name: Release Flowbar

on:
  workflow_dispatch:
    inputs:
      bump_type:
        description: 'Version bump type'
        required: true
        type: choice
        options:
          - major
          - minor
          - patch
        default: 'minor'
      pre_release:
        description: 'Mark as pre-release'
        required: false
        type: boolean
        default: false
  push:
    tags:
      - 'v*'

permissions:
  contents: write

jobs:
  release:
    name: Build and Release
    runs-on: macos-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4
        with:
          fetch-depth: 0

      - name: Get current version
        id: version
        run: |
          if [[ "${{ github.event_name }}" == "workflow_dispatch" ]]; then
            # Get latest tag
            CURRENT=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
            CURRENT=${CURRENT#v}  # Remove 'v' prefix

            # Parse version
            IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT"

            # Bump version
            case "${{ inputs.bump_type }}" in
              major)
                VERSION="$((MAJOR + 1)).0.0"
                ;;
              minor)
                VERSION="${MAJOR}.$((MINOR + 1)).0"
                ;;
              patch)
                VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"
                ;;
            esac
          else
            # Extract version from tag
            VERSION=${GITHUB_REF#refs/tags/v}
          fi

          echo "VERSION=$VERSION" >> $GITHUB_ENV
          echo "Current version: ${CURRENT:-0.0.0}"
          echo "New version: $VERSION"

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

      - name: Show Xcode version
        run: xcodebuild -version

      - name: Build Flowbar.app
        run: |
          xcodebuild \
            -project Flowbar/Flowbar.xcodeproj \
            -scheme Flowbar \
            -configuration Release \
            -derivedDataPath ./build \
            MARKETING_VERSION=${{ env.VERSION }} \
            CURRENT_PROJECT_VERSION=1 \
            MACOSX_DEPLOYMENT_TARGET=14.0 \
            clean build \
            CODE_SIGN_IDENTITY="-" \
            CODE_SIGNING_REQUIRED=NO \
            CODE_SIGNING_ALLOWED=NO

      - name: Locate built app
        run: |
          APP_PATH=$(find build -name "Flowbar.app" -type d | head -1)
          echo "APP_PATH=$APP_PATH" >> $GITHUB_ENV
          echo "Built app: $APP_PATH"
          ls -lh "$APP_PATH"

      - name: Create DMG
        run: |
          brew install create-dmg
          create-dmg \
            --volname "Flowbar" \
            --window-pos 200 120 \
            --window-size 600 400 \
            --icon-size 100 \
            --app-drop-link 450 185 \
            --icon "Flowbar.app" 150 185 \
            "Flowbar-${{ env.VERSION }}.dmg" \
            "$APP_PATH"

      - name: Generate build info
        run: |
          cat > build-info.txt << EOF
          Flowbar ${{ env.VERSION }}
          Build Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
          Commit: ${{ github.sha }}
          Branch: ${{ github.ref_name }}
          macOS Target: 14.0+
          EOF

      - name: Create Git Tag (workflow_dispatch only)
        if: github.event_name == 'workflow_dispatch'
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git tag -a "v${{ env.VERSION }}" -m "Release v${{ env.VERSION }}"
          git push origin "v${{ env.VERSION }}"

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v1
        with:
          tag_name: v${{ env.VERSION }}
          name: Flowbar v${{ env.VERSION }}
          body: |
            ## Flowbar v${{ env.VERSION }}

            ### Download
            - **Flowbar-${{ env.VERSION }}.dmg**: Disk image installer

            ### Installation
            1. Download the DMG file
            2. Open the disk image
            3. Drag Flowbar to Applications
            4. Launch from Applications folder

            ### Release Notes
            See [RELEASE_NOTES.md](https://github.com/Fission-AI/Flowbar/blob/main/RELEASE_NOTES.md) for details.

            ---
            **Build Info**
            - Commit: ${{ github.sha }}
            - Build Date: $(date -u +"%Y-%m-%d")
          files: |
            Flowbar-${{ env.VERSION }}.dmg
          draft: false
          prerelease: ${{ inputs.pre_release || false }}
          generate_release_notes: true
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

---

## 7. Version Control Integration

### Pre-commit Hook (Optional)

Create `.git/hooks/pre-commit` to prevent commits with version drift:

```bash
#!/bin/bash
# Ensure VERSION file matches git tags if it exists
if [ -f "VERSION" ]; then
  FILE_VERSION=$(cat VERSION)
  TAG_VERSION=$(git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//')
  if [ -n "$TAG_VERSION" ] && [ "$FILE_VERSION" != "$TAG_VERSION" ]; then
    echo "Warning: VERSION file ($FILE_VERSION) doesn't match latest tag ($TAG_VERSION)"
  fi
fi
```

---

## 8. Testing and Validation

### Pre-release Validation Steps

1. **Build Verification**
   ```yaml
   - name: Verify app bundle
     run: |
       # Verify app structure
       test -d "$APP_PATH"
       test -f "$APP_PATH/Contents/Info.plist"
       test -f "$APP_PATH/Contents/MacOS/Flowbar"

       # Verify version in Info.plist
       /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist"
   ```

2. **DMG Verification**
   ```yaml
   - name: Verify DMG
     run: |
       # Mount and verify
       hdiutil attach "Flowbar-${{ env.VERSION }}.dmg" -readonly
       test -d /Volumes/Flowbar/Flowbar.app
       hdiutil detach /Volumes/Flowbar
   ```

---

## 9. Open Questions

### Critical Decisions Required

- [ ] **Code Signing Strategy**: Should releases be code signed?
  - **Impact**: Unsigned apps show security warnings on first launch
  - **Decision**: Either (a) skip signing for open-source distribution, or (b) set up Apple Developer certificate in GitHub Secrets

- [ ] **Version Storage**: What is the source of truth for version numbers?
  - **Options**: Git tags only, VERSION file, or Xcode project settings
  - **Impact**: Determines how version is calculated and persisted

- [ ] **Notarization**: Should DMGs be notarized by Apple?
  - **Impact**: Required for macOS 13+ to avoid security dialogs
  - **Requirement**: Apple Developer Program membership ($99/year)

- [ ] **DMG Customization**: What level of DMG customization is desired?
  - **Options**: Simple hdiutil DMG vs. styled create-dmg with background images

- [ ] **Release Notes Integration**: How should release notes be generated?
  - **Options**: Manual entry, auto-generate from git commits, or parse RELEASE_NOTES.md

- [ ] **Pre-release Versioning**: How should pre-releases (beta, alpha) be versioned?
  - **Options**: SemVer pre-release identifiers (1.0.0-beta.1) or separate branch strategy

---

## 10. Security Considerations

### Build Environment
- Runner: `macos-latest` (GitHub-hosted, macOS 14)
- No external dependencies that require authentication
- Code signing certificates stored in GitHub Secrets (encrypted)

### Artifact Security
- DMG files uploaded to GitHub Releases are publicly accessible
- Consider private releases if needed for beta testing
- Use environment-specific secrets for development vs. production

---

## 11. Maintenance and Operations

### Workflow Updates Required When:
- Xcode version changes (update `xcode-select` path)
- macOS minimum deployment target changes (update `MACOSX_DEPLOYMENT_TARGET`)
- New dependencies are added (install in setup step)
- Build configuration changes (update xcodebuild arguments)

### Monitoring
- GitHub Actions run logs for build failures
- Release download metrics via GitHub API
- Issue tracker for user-reported installation problems

---

## 12. Implementation Checklist

### Phase 1: Basic Release Pipeline
- [ ] Create `.github/workflows/` directory
- [ ] Add `release.yml` workflow file
- [ ] Configure workflow dispatch inputs
- [ ] Implement version bumping logic
- [ ] Set up xcodebuild command with proper parameters
- [ ] Configure DMG creation using create-dmg
- [ ] Set up GitHub Release creation with softprops/action-gh-release

### Phase 2: Enhanced Features (Optional)
- [ ] Add code signing with Apple Developer certificate
- [ ] Implement app notarization
- [ ] Add automated testing before release
- [ ] Create release notes automation
- [ ] Set up Slack/Discord notifications for releases

### Phase 3: Distribution
- [ ] Update README.md with release download links
- [ ] Add installation instructions to releases
- [ ] Set up sparkle/updates feed for auto-updates
- [ ] Configure checksums verification for downloads

---

## Appendix: File Locations

| Item | Location |
|------|----------|
| Workflow file | `.github/workflows/release.yml` |
| Xcode project | `Flowbar/Flowbar.xcodeproj` |
| App entry point | `Flowbar/App/FlowbarApp.swift` |
| Info.plist | `Flowbar/Info.plist` |
| Entitlements | `Flowbar/Flowbar.entitlements` |
| Release notes | `RELEASE_NOTES.md` |
| Build output | `build/Build/Products/Release/Flowbar.app` |
| DMG output | `Flowbar-{VERSION}.dmg` |

---

## Appendix: Build Commands Reference

### Manual Local Build
```bash
cd Flowbar
xcodebuild -project Flowbar.xcodeproj -scheme Flowbar -configuration Release build
```

### Manual DMG Creation
```bash
create-dmg \
  --volname "Flowbar" \
  --window-pos 200 120 \
  --window-size 600 400 \
  --icon-size 100 \
  --app-drop-link 450 185 \
  --icon "Flowbar.app" 150 185 \
  "Flowbar-1.0.0.dmg" \
  "build/Build/Products/Release/Flowbar.app"
```

### Verify App Bundle
```bash
# Check structure
ls -R Flowbar.app

# Check Info.plist
/usr/libexec/PlistBuddy -c "Print" Flowbar.app/Contents/Info.plist

# Check code signature
codesign -dv Flowbar.app
```

---

*Specification Version: 1.0.0*
*Last Updated: 2025-02-16*
*Status: Ready for Implementation*
