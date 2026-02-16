# Implementation Plan: GitHub Actions CI/CD for Flowbar

**Status**: Ready for Implementation
**Created**: 2026-02-16
**Based on**: `.omc/autopilot/spec.md`

---

## Summary

This plan implements a complete GitHub Actions CI/CD pipeline for the Flowbar macOS application. The workflow handles version bumping, building unsigned releases on macOS, creating DMG disk images, and publishing releases to GitHub.

**Key Design Decisions**:
- Use git tags as the source of truth for version numbers (no VERSION file)
- Skip code signing for initial implementation (acceptable for open-source distribution)
- Use `create-dmg` Homebrew formula for styled disk images
- Support both manual dispatch and tag-based triggers

---

## Current State Analysis

### Project Structure (Verified)
```
Flowbar/
├── Flowbar.xcodeproj/         # Xcode project (simplified structure)
├── Info.plist                 # Uses $(MARKETING_VERSION) and $(CURRENT_PROJECT_VERSION)
├── App/                       # Application entry point
│   ├── FlowbarApp.swift
│   └── AppDelegate.swift
└── [rest of app structure]
```

### Critical Finding: Xcode Project Configuration
The project.pbxproj at `/home/ubuntu/.openclaw/workspace/projects/flowbar/Flowbar/Flowbar.xcodeproj/project.pbxproj` appears to be a simplified stub. The actual project configuration will need to be completed as part of the implementation, or a new Xcode project may need to be created.

### Info.plist Configuration
- **CFBundleShortVersionString**: `$(MARKETING_VERSION)` - Will be passed via xcodebuild
- **CFBundleVersion**: `$(CURRENT_PROJECT_VERSION)` - Will be passed via xcodebuild
- **LSMinimumSystemVersion**: `$(MACOSX_DEPLOYMENT_TARGET)` - Target 14.0

---

## Implementation Phases

### Phase 1: Directory Structure and Configuration Files

#### 1.1 Create GitHub Workflows Directory
```bash
mkdir -p .github/workflows
```

**File**: `.github/workflows/release.yml`
- Implements the complete workflow from spec.md
- Supports workflow_dispatch with bump_type choice
- Supports tag push for automatic releases

#### 1.2 Create Scripts Directory
```bash
mkdir -p scripts
```

**Purpose**: Store utility scripts for version management and building

---

### Phase 2: Version Management Script

#### 2.1 Create Version Bump Script

**File**: `scripts/bump-version.sh`

```bash
#!/bin/bash
# bump-version.sh - Calculate next semantic version

set -euo pipefail

BUMP_TYPE="${1:-minor}"
CURRENT_VERSION="${2:-}"

# Default to 0.0.0 if no tags exist
if [[ -z "$CURRENT_VERSION" ]]; then
    CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")
    CURRENT_VERSION="${CURRENT_VERSION#v}"  # Remove 'v' prefix
fi

# Parse semver components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Ensure numeric values
MAJOR=$((MAJOR + 0))
MINOR=$((MINOR + 0))
PATCH=$((PATCH + 0))

# Calculate new version
case "$BUMP_TYPE" in
    major)
        NEW_VERSION="$((MAJOR + 1)).0.0"
        ;;
    minor)
        NEW_VERSION="${MAJOR}.$((MINOR + 1)).0"
        ;;
    patch)
        NEW_VERSION="${MAJOR}.${MINOR}.$((PATCH + 1))"
        ;;
    *)
        echo "Error: Invalid bump_type '$BUMP_TYPE'. Use: major, minor, or patch" >&2
        exit 1
        ;;
esac

echo "$NEW_VERSION"
```

**Usage**: `./scripts/bump-version.sh [major|minor|patch] [current_version]`

---

### Phase 3: Build Script

#### 3.1 Create macOS Build Script

**File**: `scripts/build-macos.sh`

```bash
#!/bin/bash
# build-macos.sh - Build Flowbar.app for distribution

set -euo pipefail

VERSION="${1:-1.0.0}"
PROJECT_DIR="${2:-Flowbar}"
CONFIGURATION="${3:-Release}"
DERIVED_DATA_PATH="${4:-./build}"

echo "Building Flowbar v${VERSION}"

# Select Xcode
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
xcodebuild -version

# Build the app
xcodebuild \
    -project "${PROJECT_DIR}/Flowbar.xcodeproj" \
    -scheme Flowbar \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA_PATH" \
    MARKETING_VERSION="$VERSION" \
    CURRENT_PROJECT_VERSION=1 \
    MACOSX_DEPLOYMENT_TARGET=14.0 \
    clean build \
    CODE_SIGN_IDENTITY="-" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGNING_ALLOWED=NO

# Locate and output the app path
APP_PATH=$(find "$DERIVED_DATA_PATH" -name "Flowbar.app" -type d | head -1)

if [[ -z "$APP_PATH" ]]; then
    echo "Error: Flowbar.app not found in build output" >&2
    exit 1
fi

echo "Built app: $APP_PATH"
ls -lh "$APP_PATH"

# Verify app bundle
test -d "$APP_PATH"
test -f "$APP_PATH/Contents/Info.plist"
test -f "$APP_PATH/Contents/MacOS/Flowbar"

# Output version from Info.plist
/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist"

echo "BUILD_SUCCESS=$APP_PATH"
```

**Usage**: `./scripts/build-macos.sh [version] [project_dir] [configuration] [derived_data_path]`

---

### Phase 4: GitHub Actions Workflow

#### 4.1 Create Release Workflow

**File**: `.github/workflows/release.yml`

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

            # Calculate new version using bump script
            VERSION=$(./scripts/bump-version.sh "${{ inputs.bump_type }}" "$CURRENT")
          else
            # Extract version from tag
            VERSION=${GITHUB_REF#refs/tags/v}
          fi

          echo "VERSION=$VERSION" >> $GITHUB_ENV
          echo "VERSION=$VERSION" >> $GITHUB_OUTPUT
          echo "Current version: ${CURRENT:-0.0.0}"
          echo "New version: $VERSION"

      - name: Select Xcode
        run: sudo xcode-select -s /Applications/Xcode.app/Contents/Developer

      - name: Show Xcode version
        run: xcodebuild -version

      - name: Install create-dmg
        run: brew install create-dmg

      - name: Build Flowbar.app
        run: |
          ./scripts/build-macos.sh "${{ env.VERSION }}"

      - name: Locate built app
        run: |
          APP_PATH=$(find build -name "Flowbar.app" -type d | head -1)
          echo "APP_PATH=$APP_PATH" >> $GITHUB_ENV
          echo "Built app: $APP_PATH"
          ls -lh "$APP_PATH"

      - name: Verify app bundle
        run: |
          test -d "$APP_PATH"
          test -f "$APP_PATH/Contents/Info.plist"
          test -f "$APP_PATH/Contents/MacOS/Flowbar"
          /usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$APP_PATH/Contents/Info.plist"

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

      - name: Generate build info
        run: |
          cat > build-info.txt << EOF
          Flowbar ${{ env.VERSION }}
          Build Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
          Commit: ${{ github.sha }}
          Branch: ${{ github.ref_name }}
          macOS Target: 14.0+
          EOF
          cat build-info.txt

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

### Phase 5: Documentation

#### 5.1 Create Workflow Documentation

**File**: `docs/workflow.md`

```markdown
# GitHub Actions Workflow Documentation

## Release Process

### Manual Release (Workflow Dispatch)

1. Navigate to the Actions tab in the GitHub repository
2. Select "Release Flowbar" workflow
3. Click "Run workflow"
4. Choose the version bump type:
   - **major**: Breaking changes (1.0.0 -> 2.0.0)
   - **minor**: New features (1.0.0 -> 1.1.0)
   - **patch**: Bug fixes (1.0.0 -> 1.0.1)
5. Optionally mark as pre-release
6. Click "Run workflow"

### Automatic Release (Tag Push)

```bash
git tag v1.0.0 -a -m "Release v1.0.0"
git push origin v1.0.0
```

## Build Artifacts

Each release produces:
- `Flowbar-{VERSION}.dmg` - Disk image installer
- `build-info.txt` - Build metadata (included in release notes)

## Version Bumping Logic

The workflow uses semantic versioning based on the latest git tag:
- Latest tag is determined via `git describe --tags --abbrev=0`
- Version components are incremented based on bump_type
- New tag is pushed and used to create the GitHub release

## Local Testing

### Test Build Script
```bash
./scripts/build-macos.sh 1.0.0
```

### Test Version Bump
```bash
./scripts/bump-version.sh minor v1.0.0  # Outputs: 1.1.0
```

### Manual DMG Creation (requires create-dmg)
```bash
brew install create-dmg
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
```

---

### Phase 6: Testing Strategy

#### 6.1 Workflow Testing Checklist

**Before First Release**:
- [ ] Verify `.github/workflows/release.yml` is syntactically valid
- [ ] Test `scripts/bump-version.sh` locally with various inputs
- [ ] Test `scripts/build-macos.sh` locally (requires macOS with Xcode)
- [ ] Verify scripts are executable: `chmod +x scripts/*.sh`
- [ ] Run workflow in "dry-run" mode (build without creating release)

**Post-Implementation Testing**:
- [ ] Trigger workflow_dispatch with patch bump
- [ ] Verify DMG is created and downloadable
- [ ] Verify DMG can be mounted and app launched
- [ ] Test automatic tag-triggered release
- [ ] Verify pre-release flag works correctly

#### 6.2 Local Build Verification

```bash
# On macOS with Xcode installed:
cd /home/ubuntu/.openclaw/workspace/projects/flowbar
chmod +x scripts/*.sh

# Test version bumping
./scripts/bump-version.sh minor v0.0.0    # Expected: 0.1.0
./scripts/bump-version.sh major v1.2.3   # Expected: 2.0.0
./scripts/bump-version.sh patch v1.2.3   # Expected: 1.2.4

# Test building (if on macOS)
./scripts/build-macos.sh 1.0.0
```

---

## File Creation Summary

| File Path | Purpose | Executable |
|-----------|---------|------------|
| `.github/workflows/release.yml` | Main CI/CD workflow | N/A |
| `scripts/bump-version.sh` | Version calculation | Yes |
| `scripts/build-macos.sh` | Build automation | Yes |
| `docs/workflow.md` | Workflow documentation | N/A |
| `.gitignore` | Update to ignore build artifacts | N/A |

---

## .gitignore Updates

Add the following entries to `.gitignore`:

```gitignore
# Build artifacts
build/
DerivedData/
*.dmg

# macOS
.DS_Store
```

---

## Implementation Steps (In Order)

### Step 1: Create Directory Structure
```bash
mkdir -p .github/workflows
mkdir -p scripts
```

### Step 2: Create Scripts (make executable)
```bash
cat > scripts/bump-version.sh << 'EOF'
[insert bump-version.sh content from Phase 2.1]
EOF

cat > scripts/build-macos.sh << 'EOF'
[insert build-macos.sh content from Phase 3.1]
EOF

chmod +x scripts/*.sh
```

### Step 3: Create Workflow File
```bash
cat > .github/workflows/release.yml << 'EOF'
[insert release.yml content from Phase 4.1]
EOF
```

### Step 4: Create Documentation
```bash
cat > docs/workflow.md << 'EOF'
[insert workflow.md content from Phase 5.1]
EOF
```

### Step 5: Verify Scripts Locally
```bash
# Test version bump
./scripts/bump-version.sh minor

# If on macOS, test build
# ./scripts/build-macos.sh 1.0.0
```

### Step 6: Commit and Push
```bash
git add .github/workflows/ scripts/ docs/
git commit -m "Add GitHub Actions CI/CD workflow for Flowbar releases"
git push
```

### Step 7: Test Workflow
1. Go to GitHub Actions tab
2. Run "Release Flowbar" workflow
3. Select "patch" bump type
4. Verify successful release creation

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Xcode project is stub/incomplete | Full Xcode project setup required before first build |
| Unsigned app security warnings | Document in README; add code signing later if needed |
| DMG creation failure | Fallback to hdiutil included in spec |
| Git tag conflicts | Workflow checks for existing tags before creating |

---

## Open Questions from Spec (Recommended Answers)

| Question | Recommendation |
|----------|----------------|
| **Code Signing Strategy** | Skip for initial implementation; unsigned builds acceptable for open-source distribution |
| **Version Storage** | Git tags as source of truth (no VERSION file needed) |
| **Notarization** | Not required for initial release; can add later with Apple Developer account |
| **DMG Customization** | Use create-dmg with default styling (background images optional) |
| **Release Notes Integration** | Use GitHub's `generate_release_notes: true` auto-generation |
| **Pre-release Versioning** | Use boolean pre-release flag; no special version format needed |

---

## Success Criteria

- [ ] Workflow file is valid YAML and runs without syntax errors
- [ ] Version bump script correctly calculates next version
- [ ] Build script produces valid Flowbar.app bundle
- [ ] DMG is created and downloadable from releases
- [ ] Git tags are created automatically on workflow_dispatch
- [ ] GitHub releases include DMG, release notes, and build info
- [ ] Pre-release flag correctly marks releases as pre-release

---

## Post-Implementation Enhancements (Optional)

1. **Code Signing**: Add Apple Developer certificate integration
2. **Notarization**: Implement Apple notarization for reduced security warnings
3. **Testing**: Add Swift test execution step before release
4. **Notifications**: Add Slack/Discord webhooks for release announcements
5. **Checksums**: Generate SHA256 checksums for DMG files
6. **Sparkle Feed**: Create appcast.xml for auto-update support

---

## References

- Specification: `.omc/autopilot/spec.md`
- Xcode Project: `Flowbar/Flowbar.xcodeproj/project.pbxproj`
- Info.plist: `Flowbar/Info.plist`
- GitHub Actions Docs: https://docs.github.com/en/actions
- softprops/action-gh-release: https://github.com/softprops/action-gh-release
- create-dmg: https://github.com/create-dmg/create-dmg
