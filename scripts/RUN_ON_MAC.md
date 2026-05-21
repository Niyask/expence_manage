# Run in iOS Simulator (Mac only)

The simulator **cannot run on Windows**. Use a Mac with **Xcode 15+** installed.

## Fastest way (Xcode UI)

1. Copy this folder to your Mac (or clone from git).
2. Open **Terminal** on the Mac:

```bash
cd /path/to/expence_manage
brew install xcodegen   # one-time, if needed
xcodegen generate
open DailyExpense.xcodeproj
```

3. In Xcode, pick an **iPhone 15** (or any iPhone) simulator at the top.
4. Press **⌘R** (Run).

## One-command script

```bash
chmod +x scripts/run-simulator.sh
./scripts/run-simulator.sh
```

## If you do not have XcodeGen

1. Xcode → **File → New → Project → iOS → App**
2. Name: `DailyExpense`, SwiftUI, iOS 17+
3. Save in this folder, delete template files
4. Drag the `DailyExpense` folder into the project
5. Set `@main` in `DailyExpenseApp.swift`
6. Add notification usage description in target **Info**
7. **⌘R**

## Verify notifications (optional)

Simulator → the app may prompt for notifications when you enable them in **Settings** tab.
