# Flowbar CI/CD Workflow Documentation

## Overview

This document describes the GitHub Actions workflow for automated version bumping, building, and releasing Flowbar macOS application.

## Workflow: Release

### Triggering

**Manual Trigger:**
- Go to Actions tab in GitHub
- Select "Release" workflow
- Choose bump type: `major`, `minor`, or `patch`
- Optionally mark as pre-release (beta/alpha)

### Workflow Steps

1. **Checkout Repository**
   - Fetches full git history
   - Uses GitHub token for pushing changes

2. **Configure Git**
   - Sets up git user for commits
   - Uses github-actions[bot] identity

3. **Get Current Version**
   - Reads latest git tag
   - Defaults to `0.0.0` if no tags exist

4. **Bump Version**
   - Executes `scripts/bump-version.sh`
   - Calculates new version based on bump type
   - Semantic versioning: `MAJOR.MINOR.PATCH`

5. **Set Pre-release Suffix** (optional)
   - Adds `-beta.0` suffix for pre-releases
   - Example: `1.0.0-beta.0`

6. **Create Git Tag**
   - Creates annotated tag with version
   - Pushes tag to repository
   - Format: `v{VERSION}`

7. **Install Dependencies**
   - Installs `create-dmg` for DMG creation

8. **Build macOS App**
   - Runs `scripts/build-macos.sh`
   - Builds archive using xcodebuild
   - Exports app bundle
   - Creates DMG disk image

9. **Get Build Artifacts**
   - Locates DMG and .app bundle
   - Verifies DMG is mountable
   - Outputs artifact paths

10. **Create Release**
    - Creates GitHub Release
    - Uploads DMG as artifact
    - Includes release notes template
    - Marks as pre-release if applicable

11. **Update Version Info** (final releases only)
    - Updates Info.plist with new version
    - Commits version bump
    - Pushes to main branch

## Scripts

### bump-version.sh

Calculates and outputs new version number.

```bash
./scripts/bump-version.sh [major|minor|patch]
```

**Logic:**
- `major`: Increments MAJOR, resets MINOR and PATCH to 0
- `minor`: Increments MINOR, resets PATCH to 0
- `patch`: Increments PATCH only

**Example:**
```bash
# Current: 1.2.3
./scripts/bump-version.sh minor  # Outputs: 1.3.0
./scripts/bump-version.sh patch  # Outputs: 1.2.4
./scripts/bump-version.sh major  # Outputs: 2.0.0
```

### build-macos.sh

Builds the macOS app and creates DMG.

```bash
./scripts/build-macos.sh <version>
```

**Process:**
1. Selects Xcode using `xcode-select`
2. Cleans build directory
3. Builds archive with xcodebuild
4. Exports app bundle
5. Verifies app bundle integrity
6. Creates DMG using create-dmg
7. Outputs artifact paths

**Outputs:**
- `build/Flowbar.xcarchive` - Xcode archive
- `build/export/Flowbar.app` - App bundle
- `build/Flowbar-{VERSION}.dmg` - Disk image

## Version Strategy

### Source of Truth

**Git Tags** are the source of truth for versioning.

- Version is stored in git tag format: `v{VERSION}`
- Tags are created by the workflow during release
- No VERSION file in project (avoids merge conflicts)

### Semantic Versioning

- **MAJOR**: Incompatible API changes
- **MINOR**: New functionality (backwards compatible)
- **PATCH**: Bug fixes (backwards compatible)

### Pre-release Versions

Pre-releases use suffix format:
- `1.0.0-beta.0`
- `1.0.0-beta.1`
- `1.0.0-rc.1`

## Build Artifacts

### DMG (Disk Image)

- **Location**: `build/Flowbar-{VERSION}.dmg`
- **Purpose**: Distribution to users
- **Format**: macOS disk image with app bundle
- **Size**: Typically 50-100MB

### App Bundle

- **Location**: `build/export/Flowbar.app`
- **Purpose**: macOS application
- **Contents**: Executable, resources, Info.plist

## Testing the Workflow

### Local Testing

Before triggering the workflow:

1. **Test Scripts Locally**
   ```bash
   ./scripts/bump-version.sh patch
   ./scripts/build-macos.sh 1.0.0
   ```

2. **Verify Build Output**
   - Mount DMG: `hdiutil attach build/Flowbar-1.0.0.dmg`
   - Test app: Open Flowbar.app
   - Unmount: `hdiutil detach /Volumes/Flowbar`

3. **Check Version Injection**
   ```bash
   defaults read /path/to/Flowbar.app/Contents/Info.plist CFBundleShortVersionString
   ```

### Workflow Testing

1. **Test Patch Release**
   - Trigger workflow with `patch` bump type
   - Verify all steps complete successfully
   - Check GitHub Release creation

2. **Test Pre-release**
   - Enable `pre_release` option
   - Verify `-beta.0` suffix
   - Confirm pre-release marking

3. **Test Major Release**
   - Trigger workflow with `major` bump type
   - Verify version jump (e.g., 1.0.0 → 2.0.0)
   - Confirm DMG upload

## Troubleshooting

### Build Failures

**xcodebuild fails:**
- Check Xcode project configuration
- Verify scheme name matches `Flowbar`
- Ensure all required files exist

**Archive export fails:**
- Check ExportOptions.plist
- Verify signing configuration
- Check for code signing issues

### DMG Creation Failures

**create-dmg fails:**
- Install via: `brew install create-dmg`
- Check app icon path
- Verify app bundle is valid

**hdiutil fallback fails:**
- Check disk space
- Verify app bundle structure
- Check source app path

### Git Issues

**Tag push fails:**
- Tag already exists (delete old tag first)
- Permission denied (check GITHUB_TOKEN)
- Branch protection rules

### Release Creation Failures

**Release already exists:**
- Delete existing release first
- Or use different version number

**Upload fails:**
- Check DMG file size (<100MB recommended)
- Verify DMG is not corrupted
- Check permissions

## Requirements

### Runner

- **OS**: macOS-latest
- **Tools**: Xcode, create-dmg, hdiutil

### Permissions

- `contents: write` - For creating releases
- `GITHUB_TOKEN` - Automatically provided

### Secrets

No additional secrets required for unsigned builds.

For signed builds (future):
- `APPLE_DEVELOPER_ID` - Apple Developer Team ID
- `CERTIFICATES_P12` - Code signing certificates
- `CERTIFICATES_P12_PASSWORD` - Certificate password

## Future Enhancements

### Code Signing (Optional)

Add code signing to build process:
1. Import certificates from secrets
2. Configure keychain
3. Sign app bundle
4. Notarize with Apple

### Automated Testing

Add test steps before release:
1. Run unit tests
2. Run UI tests
3. Perform smoke tests

### Release Notes Automation

Auto-generate release notes:
1. Parse commit messages since last release
2. Categorize changes (features, fixes, breaking)
3. Format as markdown

## Security Considerations

### Secrets Management

- Never commit secrets to repository
- Use GitHub Secrets for sensitive data
- Rotate certificates periodically

### Access Control

- Limit who can trigger releases
- Use branch protection rules
- Require review for releases

## Maintenance

### Regular Updates

- Update Xcode version when needed
- Update create-dmg formula
- Review and update dependencies

### Monitoring

- Check workflow runs regularly
- Monitor build times
- Track failure rates

## Related Documentation

- [README.md](../README.md) - Project overview
- [CONTRIBUTING.md](../CONTRIBUTING.md) - Development workflow
- [RELEASE_NOTES.md](../RELEASE_NOTES.md) - Release notes

## Support

For issues or questions:
- [GitHub Issues](https://github.com/jeongsk/flowbar/issues)
- [GitHub Discussions](https://github.com/jeongsk/flowbar/discussions)
