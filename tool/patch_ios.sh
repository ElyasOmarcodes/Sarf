#!/usr/bin/env bash
# Applied after `flutter create --platforms=ios` in CI: sets the springboard
# display name. iOS mirrors RTL automatically from the app's Directionality.
set -euo pipefail

P=ios/Runner/Info.plist
[ -f "$P" ] || { echo "No Info.plist at $P"; exit 1; }

/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName تصريف" "$P" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string تصريف" "$P"
/usr/libexec/PlistBuddy -c "Print :CFBundleDisplayName" "$P"
