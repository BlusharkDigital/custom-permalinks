#!/usr/bin/env bash
# Usage: ./release.sh <new-version>
# Example: ./release.sh 2.9.0
#
# Updates all version strings in the plugin and renames versioned asset files.
# Run from the plugin root directory.
# After running, rename the plugin folder itself:
#   mv custom-permalinks-<old> custom-permalinks-<new>

set -euo pipefail

NEW_VERSION="${1:-}"
if [[ -z "$NEW_VERSION" ]]; then
  echo "Error: new version required."
  echo "Usage: ./release.sh <new-version>"
  exit 1
fi

# Detect current version from the main PHP file header
OLD_VERSION=$(grep -m1 '^\s*\* Version:' custom-permalinks.php | sed 's/.*Version: *//')
OLD_VERSION="${OLD_VERSION%$'\r'}"  # strip Windows line endings if any

if [[ -z "$OLD_VERSION" ]]; then
  echo "Error: could not detect current version from custom-permalinks.php"
  exit 1
fi

echo "Bumping $OLD_VERSION → $NEW_VERSION"

# 1. Plugin header
sed -i '' "s/\* Version: ${OLD_VERSION}/* Version: ${NEW_VERSION}/" custom-permalinks.php

# 2. Main class version property
sed -i '' "s/public \$version = '${OLD_VERSION}'/public \$version = '${NEW_VERSION}'/" \
  includes/class-custom-permalinks.php

# 3. readme.txt stable tag
sed -i '' "s/Stable tag: ${OLD_VERSION}/Stable tag: ${NEW_VERSION}/" readme.txt

# 4. Rename versioned CSS asset
OLD_CSS="assets/css/about-plugins-${OLD_VERSION}.min.css"
NEW_CSS="assets/css/about-plugins-${NEW_VERSION}.min.css"
if [[ -f "$OLD_CSS" ]]; then
  mv "$OLD_CSS" "$NEW_CSS"
  echo "Renamed: $OLD_CSS → $NEW_CSS"
else
  echo "Warning: $OLD_CSS not found — skipping"
fi

# 5. Rename versioned JS asset
OLD_JS="assets/js/script-form-${OLD_VERSION}.min.js"
NEW_JS="assets/js/script-form-${NEW_VERSION}.min.js"
if [[ -f "$OLD_JS" ]]; then
  mv "$OLD_JS" "$NEW_JS"
  echo "Renamed: $OLD_JS → $NEW_JS"
else
  echo "Warning: $OLD_JS not found — skipping"
fi

echo ""
echo "Done. Remaining manual steps:"
echo "  1. Add a changelog entry to readme.txt and changelog.txt"
echo "  2. Rename the plugin folder: mv custom-permalinks-${OLD_VERSION} custom-permalinks-${NEW_VERSION}"
