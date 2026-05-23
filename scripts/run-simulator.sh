#!/usr/bin/env bash
# Run Daily Expense on iOS Simulator (macOS + Xcode only)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

PROJECT="DailyExpense.xcodeproj"
SCHEME="DailyExpense"
BUNDLE_ID="com.dailyexpense.app"

# Use full Xcode (simctl lives here — Command Line Tools alone are not enough)
resolve_xcode() {
  if [[ -d "/Applications/Xcode.app/Contents/Developer" ]]; then
    export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
  elif [[ -d "$HOME/Downloads/Xcode.app/Contents/Developer" ]]; then
    export DEVELOPER_DIR="$HOME/Downloads/Xcode.app/Contents/Developer"
  else
    echo "Xcode not found."
    echo "  Install Xcode, or keep Xcode.app in ~/Downloads (macOS 12)."
    echo "  Then run once:  ./scripts/setup-macos12.sh"
    exit 1
  fi
  export PATH="$DEVELOPER_DIR/usr/bin:$PATH"
}

resolve_xcode

if ! xcrun simctl help &>/dev/null; then
  echo "simctl is not available. Active developer path:"
  xcode-select -p 2>&1 || true
  echo ""
  echo "Fix (one time, needs password):"
  echo "  ./scripts/setup-macos12.sh"
  echo "Or:"
  echo "  sudo xcode-select -s \"$DEVELOPER_DIR\""
  exit 1
fi

echo "→ Using $(xcodebuild -version | head -1) from $DEVELOPER_DIR"

if [[ ! -d "$PROJECT" ]]; then
  echo "→ Generating Xcode project with XcodeGen…"
  if command -v xcodegen &>/dev/null; then
    xcodegen generate
  else
    TMP=$(mktemp -d)
    curl -fsSL "https://github.com/yonaskolb/XcodeGen/releases/download/2.42.0/xcodegen.zip" -o "$TMP/xcodegen.zip"
    unzip -q "$TMP/xcodegen.zip" -d "$TMP"
    "$TMP/xcodegen/bin/xcodegen" generate
  fi
fi

echo "→ Booting default iPhone simulator…"
DEVICE_UDID=""
if DEVICE_JSON="$(xcrun simctl list devices available -j 2>/dev/null)"; then
  DEVICE_UDID="$(printf '%s' "$DEVICE_JSON" | python3 -c "
import json, sys
data = json.load(sys.stdin)
for runtime, devices in data.get('devices', {}).items():
    if 'iOS' not in runtime:
        continue
    for d in devices:
        if d.get('isAvailable') and 'iPhone' in d.get('name', ''):
            print(d['udid'])
            sys.exit(0)
" 2>/dev/null || true)"
fi

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

APP_PATH=""
while IFS= read -r candidate; do
  if [[ -f "$candidate/Info.plist" ]]; then
    APP_PATH="$candidate"
    break
  fi
done < <(find ~/Library/Developer/Xcode/DerivedData -path "*/Build/Products/Debug-iphonesimulator/DailyExpense.app" -print 2>/dev/null | grep -v "Index.noindex" || true)

if [[ -z "$APP_PATH" ]]; then
  APP_PATH="$HOME/Library/Developer/Xcode/DerivedData/DailyExpense-avdfcbydufzidndbvjjhkahemjlt/Build/Products/Debug-iphonesimulator/DailyExpense.app"
fi
if [[ ! -f "$APP_PATH/Info.plist" ]]; then
  echo "Could not find built app at DerivedData."
  exit 1
fi

echo "→ Installing & launching ($BUNDLE_ID)…"
xcrun simctl install "$DEVICE_UDID" "$APP_PATH"
xcrun simctl launch "$DEVICE_UDID" "$BUNDLE_ID"

echo "✓ Daily Expense is running in the simulator."
