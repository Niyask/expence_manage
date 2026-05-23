#!/usr/bin/env bash
# Export an .ipa for TestFlight, Firebase App Distribution, or manual install.
# Requires: full Xcode, Apple ID team in project, iPhone registered for development.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if [[ -d "/Applications/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="/Applications/Xcode.app/Contents/Developer"
elif [[ -d "$HOME/Downloads/Xcode.app/Contents/Developer" ]]; then
  export DEVELOPER_DIR="$HOME/Downloads/Xcode.app/Contents/Developer"
else
  echo "Xcode not found."
  exit 1
fi
export PATH="$DEVELOPER_DIR/usr/bin:$PATH"

PROJECT="DailyExpense.xcodeproj"
SCHEME="DailyExpense"
ARCHIVE_PATH="$ROOT/build/DailyExpense.xcarchive"
IPA_DIR="$ROOT/build/ipa"
EXPORT_PLIST="$ROOT/ExportOptions.plist"

if [[ ! -d "$PROJECT" ]]; then
  TMP=$(mktemp -d)
  curl -fsSL "https://github.com/yonaskolb/XcodeGen/releases/download/2.42.0/xcodegen.zip" -o "$TMP/z.zip"
  unzip -q "$TMP/z.zip" -d "$TMP"
  "$TMP/xcodegen/bin/xcodegen" generate
fi

mkdir -p "$ROOT/build"

echo "→ Archive (Generic iOS Device)…"
xcodebuild \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -destination "generic/platform=iOS" \
  -archivePath "$ARCHIVE_PATH" \
  -allowProvisioningUpdates \
  archive

echo "→ Export IPA…"
rm -rf "$IPA_DIR"
xcodebuild \
  -exportArchive \
  -archivePath "$ARCHIVE_PATH" \
  -exportPath "$IPA_DIR" \
  -exportOptionsPlist "$EXPORT_PLIST" \
  -allowProvisioningUpdates

IPA="$(find "$IPA_DIR" -name "*.ipa" -print -quit)"
if [[ -z "$IPA" ]]; then
  echo "IPA export failed."
  exit 1
fi

echo ""
echo "✓ IPA ready:"
echo "  $IPA"
echo ""
echo "Upload this file to TestFlight or Firebase App Distribution (see docs/INSTALL_ON_IPHONE.md)."
