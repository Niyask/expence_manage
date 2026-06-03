# App Store screenshots — Daily Expense

All PNGs are **real app UI** captures, resized to **1284 × 2778** px (portrait) for App Store Connect.

## Upload in App Store Connect

1. Open your app → **App Store** tab → version → **Screenshots**
2. Select **6.7" Display** (or the slot that accepts these sizes)
3. Drag up to **10 screenshots** (portrait), in this order:

| # | File | Screen |
|---|------|--------|
| 1 | `01-onboarding.png` | Welcome |
| 2 | `02-home-dashboard.png` | Home |
| 3 | `03-financial-report.png` | Report |
| 4 | `04-settings.png` | Settings |
| 5 | `05-add-expense.png` | Add expense |
| 6 | `06-all-transactions.png` | All transactions |

## Accepted sizes (Apple)

Use **one** portrait size for all screenshots in a set:

| Display | Portrait size |
|---------|----------------|
| **6.7"** (recommended — matches our export) | **1284 × 2778** |
| 6.5" | 1242 × 2688 |

Landscape (if needed): **2778 × 1284** or **2688 × 1242**.

All files in this folder are **1284 × 2778** so they upload without size errors.

## Re-capture + resize

```bash
cd /Users/niyasmuhammed/Documents/expence_manage
./scripts/capture-exact-screenshots.sh
```

Captures from the simulator, then auto-resizes.

Resize only (existing PNGs):

```bash
./scripts/resize-app-store-screenshots.sh
```

To use **6.5"** size instead, edit `scripts/resize-app-store-screenshots.sh` and set `WIDTH=1242` `HEIGHT=2688`.

## App icon

`DailyExpense/Assets.xcassets/AppIcon.appiconset/AppIcon.png` — **1024 × 1024** px.
