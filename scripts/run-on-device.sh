#!/usr/bin/env bash
# Install Daily Expense on a connected iPhone (requires Apple ID in Xcode)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -d "/Applications/Xcode.app" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
elif [[ -d "$HOME/Downloads/Xcode.app" ]]; then
  export DEVELOPER_DIR="$HOME/Downloads/Xcode.app/Contents/Developer"
else
  echo "Xcode not found. Install Xcode from the Mac App Store."
  exit 1
fi

PROJECT="DailyExpense.xcodeproj"
SCHEME="DailyExpense"
BUNDLE_ID="com.dailyexpense.app"
DEVICE_ID="00008150-000C74883ADA401C"

if [[ ! -d "$PROJECT" ]]; then
  echo "→ Generating Xcode project…"
  TMP=$(mktemp -d)
  curl -fsSL "https://github.com/yonaskolb/XcodeGen/releases/download/2.42.0/xcodegen.zip" -o "$TMP/xcodegen.zip"
  unzip -q "$TMP/xcodegen.zip" -d "$TMP"
  "$TMP/xcodegen/bin/xcodegen" generate
fi

echo "→ Connected devices:"
xcrun xctrace list devices 2>&1 | grep -E "==|Niyas|iPhone" || true

echo ""
echo "→ Building for iPhone (automatic signing)…"
echo "   If this fails: open Xcode → Settings → Accounts → add your Apple ID,"
echo "   then open DailyExpense.xcodeproj → Signing → select your Team → ⌘R"
echo ""

xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "id=$DEVICE_ID" \
  -configuration Debug \
  -allowProvisioningUpdates \
  build

APP_PATH="$(find ~/Library/Developer/Xcode/DerivedData -path "*Build/Products/Debug-iphoneos/DailyExpense.app" -print -quit)"
if [[ -z "$APP_PATH" ]]; then
  echo "Build succeeded but .app not found."
  exit 1
fi

echo "→ Installing on device…"
if command -v devicectl &>/dev/null; then
  xcrun devicectl device install app --device "$DEVICE_ID" "$APP_PATH"
else
  echo "Use Xcode: select your iPhone and press ⌘R to install."
  open "$ROOT/$PROJECT"
fi

echo "✓ Done. Open Daily Expense on your iPhone."
