#!/usr/bin/env bash
# Run Daily Expense on iOS Simulator (macOS + Xcode only)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROJECT="DailyExpense.xcodeproj"
SCHEME="DailyExpense"
BUNDLE_ID="com.dailyexpense.app"

if [[ ! -d "$PROJECT" ]]; then
  echo "→ Generating Xcode project with XcodeGen…"
  if ! command -v xcodegen &>/dev/null; then
    echo "Install: brew install xcodegen"
    exit 1
  fi
  xcodegen generate
fi

echo "→ Booting default iPhone simulator…"
DEVICE_UDID="$(xcrun simctl list devices available -j | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' not in runtime:
        continue
    for d in devices:
        if d.get('isAvailable') and 'iPhone' in d.get('name', ''):
            print(d['udid'])
            sys.exit(0)
")"

if [[ -z "${DEVICE_UDID:-}" ]]; then
  echo "No iPhone simulator found. Open Xcode → Settings → Platforms and install an iOS simulator."
  exit 1
fi

xcrun simctl boot "$DEVICE_UDID" 2>/dev/null || true
open -a Simulator

echo "→ Building…"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "id=$DEVICE_UDID" \
  -configuration Debug \
  build \
  CODE_SIGNING_ALLOWED=NO

APP_PATH="$(find ~/Library/Developer/Xcode/DerivedData -path "*Build/Products/Debug-iphonesimulator/DailyExpense.app" 2>/dev/null | head -1)"
if [[ -z "$APP_PATH" || ! -d "$APP_PATH" ]]; then
  APP_PATH="$(xcodebuild -project "$PROJECT" -scheme "$SCHEME" -destination "id=$DEVICE_UDID" -showBuildSettings 2>/dev/null | awk -F' = ' '/TARGET_BUILD_DIR/ {dir=$2} /FULL_PRODUCT_NAME/ {name=$2} END {print dir"/"name}')"
fi

echo "→ Installing & launching ($BUNDLE_ID)…"
xcrun simctl install "$DEVICE_UDID" "$APP_PATH"
xcrun simctl launch "$DEVICE_UDID" "$BUNDLE_ID"

echo "✓ Daily Expense is running in the simulator."
