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

echo "→ Setting active developer directory (requires password)…"
sudo xcode-select -s "$DEVELOPER_DIR"

echo ""
echo "Active developer directory:"
xcode-select -p
xcodebuild -version

if xcrun simctl help &>/dev/null; then
  echo "✓ simctl is available"
else
  echo "✗ simctl still missing — restart Terminal and try again"
fi

echo ""
echo "Run the app in Simulator:"
echo "  cd $(cd "$(dirname "$0")/.." && pwd)"
echo "  ./scripts/run-simulator.sh"
