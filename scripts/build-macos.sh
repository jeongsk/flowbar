#!/bin/bash

# build-macos.sh - Build Flowbar macOS app
# Usage: ./build-macos.sh <version>

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

VERSION="$1"

if [ -z "$VERSION" ]; then
    echo "Error: Version argument is required"
    echo "Usage: $0 <version>"
    exit 1
fi

echo "Building Flowbar version $VERSION..."

# Select Xcode
echo "Selecting Xcode..."
sudo xcode-select -s /Applications/Xcode.app
xcodebuild -version

# Build configuration
BUILD_DIR="$PROJECT_ROOT/build"
ARCHIVE_PATH="$BUILD_DIR/Flowbar.xcarchive"
EXPORT_DIR="$BUILD_DIR/export"
APP_NAME="Flowbar"
SCHEME="Flowbar"
PROJECT="$PROJECT_ROOT/Flowbar/Flowbar.xcodeproj"

# Clean build directory
echo "Cleaning build directory..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# Build archive
echo "Building archive..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -archivePath "$ARCHIVE_PATH" \
    -configuration Release \
    MARKETING_VERSION="$VERSION" \
    CURRENT_PROJECT_VERSION="$VERSION" \
    ALLOW_NETWORK_IMPORTS=NO \
    -quiet || {
    echo "Error: Archive build failed"
    exit 1
}

# Export app
echo "Exporting app..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_DIR" \
    -exportOptionsPlist "$SCRIPT_DIR/ExportOptions.plist" \
    -quiet || {
    echo "Error: Export failed"
    exit 1
}

# Verify app bundle
APP_PATH="$EXPORT_DIR/$APP_NAME.app"
if [ ! -d "$APP_PATH" ]; then
    echo "Error: App bundle not found at $APP_PATH"
    exit 1
fi

echo "✓ App bundle created: $APP_PATH"

# Get app info
VERSION_STRING=$(defaults read "$(pwd)/$APP_PATH/Contents/Info.plist" CFBundleShortVersionString)
echo "✓ App version: $VERSION_STRING"

# Create DMG
echo "Creating DMG..."
DMG_PATH="$BUILD_DIR/$APP_NAME-$VERSION.dmg"

# Install create-dmg if not available
if ! command -v create-dmg &> /dev/null; then
    echo "Installing create-dmg..."
    brew install create-dmg
fi

# Create DMG
create-dmg \
    --volname "$APP_NAME" \
    --volicon "$APP_PATH/Contents/Resources/AppIcon.icns" \
    --window-pos 200 120 \
    --window-size 600 400 \
    --icon-size 100 \
    --app-drop-link 450 185 \
    --hide-extension "$APP_NAME" \
    "$APP_PATH" \
    "$DMG_PATH" || {
    echo "Warning: create-dmg failed, trying hdiutil fallback..."
    # Fallback to hdiutil
    hdiutil create -volname "$APP_NAME" -srcfolder "$APP_PATH" -ov -format UDZO "$DMG_PATH"
}

echo "✓ DMG created: $DMG_PATH"

# Get DMG size
DMG_SIZE=$(du -h "$DMG_PATH" | cut -f1)
echo "✓ DMG size: $DMG_SIZE"

# Output artifact paths for GitHub Actions
echo "build_artifact=$DMG_PATH" >> $GITHUB_OUTPUT
echo "app_bundle=$APP_PATH" >> $GITHUB_OUTPUT

echo "Build complete!"
