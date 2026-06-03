# Data persistence across App Store updates

Daily Expense keeps all user data on the device. **Updating from the App Store does not delete transactions, tags, or settings.**

## Where data is stored

| Data | Location |
|------|----------|
| Transactions, tags, settings | `Application Support/DailyExpense/state.json` |
| Last good copy (backup) | `Application Support/DailyExpense/state.json.backup` |

Apple **preserves** the app’s Application Support folder when users install an update from the App Store. Data is only removed if the user **deletes the app** from the device.

## What survives an update

- All transactions (within the 2‑month retention window)
- Custom tags
- Settings (name, currency, appearance, notifications, onboarding completed, etc.)

## What does *not* wipe data on update

- New app version number (`MARKETING_VERSION` / `CURRENT_PROJECT_VERSION`)
- New SwiftUI screens or bug fixes
- Adding new fields to settings (decoded with defaults for older saves)

## What *would* wipe data (avoid in releases)

| Action | Effect |
|--------|--------|
| User deletes the app | All local data removed |
| Changing **Bundle ID** (`PRODUCT_BUNDLE_IDENTIFIER`) | Treated as a different app; old container not used |
| Reinstalling after delete | Fresh empty state |

**Keep `com.dailyexpense.app` unchanged** for every App Store build unless you intentionally migrate with a documented plan.

## Built-in safeguards (code)

1. **Stable storage path** — Application Support, not Caches or tmp.
2. **Schema version** — `schemaVersion` in `state.json` for forward-compatible decoding.
3. **Backup file** — Before each save, the previous `state.json` is copied to `state.json.backup`.
4. **Recovery** — If the primary file fails to decode, the app loads from backup and rewrites primary.
5. **No overwrite on corrupt load** — If both files fail to decode, the app does not save empty data over existing files.

## 2‑month retention (not an “update wipe”)

Transactions **older than 2 months** are removed automatically when the app opens or when you save. That is intentional retention, not an App Store update. Users are told during onboarding.

## Before each App Store release

1. Do **not** change bundle ID without a migration strategy.
2. When adding new settings fields, use `decodeIfPresent` with defaults (see `AppSettings`).
3. Test upgrade path: install old build → add transactions → install new build → confirm data still there.
4. Bump `MARKETING_VERSION` only; user data file format stays compatible.

## Upgrade test (simulator or device)

1. Run build A, add income/expense, change Settings.
2. Install build B over A (same bundle ID, higher build number).
3. Open app — totals, list, and settings should match build A.
