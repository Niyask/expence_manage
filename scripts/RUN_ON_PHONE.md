# Run on your iPhone

## Before you start

1. **Connect iPhone** with USB cable (or Wi‑Fi debugging if already paired).
2. **Unlock** the phone and tap **Trust This Computer**.
3. **Sign in to Xcode** with your Apple ID (free account works):
   - Xcode → **Settings** → **Accounts** → **+** → Apple ID
4. **Select a Team** in the project:
   - Open `DailyExpense.xcodeproj`
   - Click **DailyExpense** target → **Signing & Capabilities**
   - Check **Automatically manage signing**
   - **Team:** choose your personal team (your name)

## Run on phone (easiest)

1. At the top of Xcode, choose your iPhone (**Niyas Muhammed**) — not a simulator.
2. Press **⌘R**.

## Important: Xcode version

Your phone reports **iOS 26.x**. **Xcode 14.2** (in Downloads) only supports up to **iOS 16**.

To install on a current iPhone, install the **latest Xcode** from the Mac App Store, then:

```bash
sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
```

Open the project again and press **⌘R**.

## Command line (after Team is set in Xcode)

```bash
chmod +x scripts/run-on-device.sh
./scripts/run-on-device.sh
```
