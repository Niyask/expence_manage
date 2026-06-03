#!/usr/bin/env bash
# Capture exact App Store screenshots from the real app (iPhone 16 Pro Max simulator).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/AppStoreScreenshots"
SIM_ID="${SIM_ID:-293326FC-D069-47DE-AB7E-C918D673A649}"
BUNDLE="com.dailyexpense.app"
XCODE="/Applications/Xcode.app/Contents/Developer"

mkdir -p "$OUT_DIR"
rm -f "$OUT_DIR"/*-mockup.png 2>/dev/null || true

echo "→ Building Daily Expense…"
"$XCODE/usr/bin/xcodebuild" \
  -project "$ROOT/DailyExpense.xcodeproj" \
  -scheme DailyExpense \
  -destination "platform=iOS Simulator,id=$SIM_ID" \
  -configuration Debug \
  build | tail -3

APP_PATH=$(find "$HOME/Library/Developer/Xcode/DerivedData"/DailyExpense-*/Build/Products/Debug-iphonesimulator/DailyExpense.app -maxdepth 0 2>/dev/null | head -1)

"$XCODE/usr/bin/simctl" boot "$SIM_ID" 2>/dev/null || true
open -a Simulator
"$XCODE/usr/bin/simctl" install "$SIM_ID" "$APP_PATH"

capture() {
  local name="$1"
  local screen="$2"
  local wait="${3:-2.5}"
  local outfile="$OUT_DIR/${name}.png"

  "$XCODE/usr/bin/simctl" terminate "$SIM_ID" "$BUNDLE" 2>/dev/null || true
  sleep 0.5
  "$XCODE/usr/bin/simctl" launch "$SIM_ID" "$BUNDLE" -ScreenshotScreen "$screen" >/dev/null
  sleep "$wait"
  "$XCODE/usr/bin/simctl" io "$SIM_ID" screenshot "$outfile"
  echo "✓ $outfile"
}

echo ""
echo "→ Capturing exact app screens…"
capture "01-onboarding" "onboarding" 2
capture "02-home-dashboard" "home" 2.5
capture "03-financial-report" "report" 2.5
capture "04-settings" "settings" 2.5
capture "05-add-expense" "addExpense" 3
capture "06-all-transactions" "transactions" 3

echo ""
echo "→ Resizing to App Store size (1284×2778)…"
"$ROOT/scripts/resize-app-store-screenshots.sh"

echo ""
echo "Done. Upload-ready screenshots in: $OUT_DIR"
open "$OUT_DIR"
