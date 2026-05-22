#!/usr/bin/env bash
# Point this Mac (macOS 12) at Xcode 14.2 in Downloads
set -euo pipefail

XCODE_APP="$HOME/Downloads/Xcode.app"

if [[ ! -d "$XCODE_APP" ]]; then
  echo "Xcode not found at $XCODE_APP"
  echo "Keep Xcode 14.2 in Downloads, or install the newest Xcode that supports macOS 12."
  exit 1
fi

export DEVELOPER_DIR="$XCODE_APP/Contents/Developer"
sudo xcode-select -s "$DEVELOPER_DIR"

echo "Active developer directory:"
xcode-select -p
xcodebuild -version

echo ""
echo "Next: open the project and run in Simulator (⌘R), or connect iPhone and run."
echo "  open $(cd "$(dirname "$0")/.." && pwd)/DailyExpense.xcodeproj"
