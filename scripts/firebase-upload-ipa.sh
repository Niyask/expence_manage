#!/usr/bin/env bash
# Upload an existing .ipa to Firebase App Distribution.
# Requires: npm install -g firebase-tools, firebase login, .firebaserc configured.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

IPA="${1:-}"
if [[ -z "$IPA" ]]; then
  IPA="$(find "$ROOT/build/ipa" -name "*.ipa" -print -quit 2>/dev/null || true)"
fi
if [[ -z "$IPA" || ! -f "$IPA" ]]; then
  echo "Usage: $0 [path/to/DailyExpense.ipa]"
  echo "  Or run ./scripts/export-ipa.sh first (needs Mac with Xcode 16+)."
  exit 1
fi

if [[ -z "${FIREBASE_APP_ID:-}" ]]; then
  echo "Set FIREBASE_APP_ID (from Firebase Console → Project settings → Your apps → iOS App ID)."
  exit 1
fi

if command -v firebase &>/dev/null; then
  FIREBASE_CMD=(firebase)
elif command -v npx &>/dev/null; then
  FIREBASE_CMD=(npx firebase-tools@latest)
else
  echo "Install Node.js from https://nodejs.org then run: npx firebase-tools@latest login"
  exit 1
fi

if [[ ! -f "$ROOT/.firebaserc" ]]; then
  echo "Copy .firebaserc.example to .firebaserc and set your Firebase project ID."
  exit 1
fi

GROUP="${FIREBASE_TESTER_GROUP:-testers}"
NOTES="${RELEASE_NOTES:-Daily Expense build $(date '+%Y-%m-%d %H:%M')}"

echo "→ Uploading $IPA to Firebase App Distribution…"
"${FIREBASE_CMD[@]}" appdistribution:distribute "$IPA" \
  --app "$FIREBASE_APP_ID" \
  --groups "$GROUP" \
  --release-notes "$NOTES"

echo "✓ Testers in group '$GROUP' will receive an email with the install link."
