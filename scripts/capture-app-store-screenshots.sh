#!/usr/bin/env bash
# Capture App Store screenshots from the iOS Simulator (6.7" display).
# Usage: ./scripts/capture-app-store-screenshots.sh
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT_DIR="$ROOT/AppStoreScreenshots"
SIM_ID="${SIM_ID:-293326FC-D069-47DE-AB7E-C918D673A649}" # iPhone 16 Pro Max (6.7")
SCHEME="DailyExpense"
BUNDLE="com.dailyexpense.app"
XCODE="/Applications/Xcode.app/Contents/Developer"

mkdir -p "$OUT_DIR"

echo "→ Building for simulator..."
"$XCODE/usr/bin/xcodebuild" \
  -project "$ROOT/DailyExpense.xcodeproj" \
  -scheme "$SCHEME" \
  -destination "platform=iOS Simulator,id=$SIM_ID" \
  -configuration Debug \
  build | tail -3

APP_PATH=$(find "$HOME/Library/Developer/Xcode/DerivedData"/DailyExpense-*/Build/Products/Debug-iphonesimulator/DailyExpense.app -maxdepth 0 2>/dev/null | head -1)
if [[ -z "$APP_PATH" ]]; then
  echo "Could not find DailyExpense.app in DerivedData"
  exit 1
fi

"$XCODE/usr/bin/simctl" boot "$SIM_ID" 2>/dev/null || true
open -a Simulator
"$XCODE/usr/bin/simctl" install "$SIM_ID" "$APP_PATH"
"$XCODE/usr/bin/simctl" launch "$SIM_ID" "$BUNDLE" >/dev/null

shot() {
  local file="$1"
  local hint="$2"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Navigate to: $hint"
  echo "Then press Enter to capture → $file"
  read -r _
  "$XCODE/usr/bin/simctl" io "$SIM_ID" screenshot "$OUT_DIR/$file"
  echo "Saved $OUT_DIR/$file"
}

echo ""
echo "Simulator: iPhone 16 Pro Max (App Store 6.7\" size)"
echo "Output: $OUT_DIR"
echo ""
echo "Tip: Use sample data (add income/expenses) so Home and Report look full."

shot "01-home-dashboard.png" "Home tab — summary card + recent transactions"
shot "02-add-expense.png" "Tap + → Add Expense sheet"
shot "03-financial-report.png" "Report tab"
shot "04-settings.png" "Settings tab"
shot "05-transactions.png" "Home → See all (transaction list)"

echo ""
echo "Done. Upload PNGs from AppStoreScreenshots/ to App Store Connect (6.7\" Display)."
