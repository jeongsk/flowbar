#!/bin/bash

# bump-version.sh - Bump version for Flowbar releases
# Usage: ./bump-version.sh [major|minor|patch]

set -e

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Default to patch if no argument provided
BUMP_TYPE="${1:-patch}"

# Validate bump type
case "$BUMP_TYPE" in
    major|minor|patch)
        ;;
    *)
        echo "Error: Invalid bump type '$BUMP_TYPE'. Use major, minor, or patch."
        exit 1
        ;;
esac

echo "Bumping $BUMP_TYPE version..."

# Get current version from git tags
CURRENT_VERSION=$(git describe --tags --abbrev=0 2>/dev/null || echo "0.0.0")

echo "Current version: $CURRENT_VERSION"

# Parse version components
IFS='.' read -r MAJOR MINOR PATCH <<< "$CURRENT_VERSION"

# Remove 'v' prefix if present
MAJOR="${MAJOR#v}"
MINOR="${MINOR#v}"
PATCH="${PATCH#v}"

# Bump version based on type
case "$BUMP_TYPE" in
    major)
        MAJOR=$((MAJOR + 1))
        MINOR=0
        PATCH=0
        ;;
    minor)
        MINOR=$((MINOR + 1))
        PATCH=0
        ;;
    patch)
        PATCH=$((PATCH + 1))
        ;;
esac

# Construct new version
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo "New version: $NEW_VERSION"

# Update version in Xcode project if needed
# For now, we'll rely on build arguments
# In the future, this could update Info.plist or project.pbxproj

# Output new version for GitHub Actions
echo "$NEW_VERSION"
