# Daily Expense on macOS 12 (Monterey)

Your **MacBook Air (2015)** can run **macOS 12.7.6** at most. It **cannot** install macOS 13+ or the latest Xcode from the App Store.

That is a hardware limit, not something you did wrong.

## What works on your Mac today

| Option | Works? |
|--------|--------|
| **iPhone Simulator** in Xcode 14.2 | Yes |
| **Build in Xcode 14.2** (`~/Downloads/Xcode.app`) | Yes |
| **Install on a very new iPhone (iOS 18+)** from this Mac | Usually **no** — Xcode 14 does not include support files for new iOS versions |
| **Install on iPhone with iOS 15–16.1** | Often **yes**, if the phone is connected, trusted, and Developer Mode is on |

## One-time Terminal setup (use every new terminal, or add to `~/.zshrc`)

```bash
export DEVELOPER_DIR="$HOME/Downloads/Xcode.app/Contents/Developer"
sudo xcode-select -s "$DEVELOPER_DIR"
```

Check:

```bash
xcodebuild -version
# Should show: Xcode 14.2
```

## Run in Simulator (recommended on this Mac)

```bash
cd ~/Documents/expence_tracker
chmod +x scripts/run-simulator.sh
./scripts/run-simulator.sh
```

Or in Xcode: open `DailyExpense.xcodeproj` → pick **iPhone 14** simulator → **⌘R**.

## Run on your physical iPhone (same Mac)

1. Connect iPhone with cable, **unlock**, tap **Trust**.
2. On iPhone: **Settings → Privacy & Security → Developer Mode → ON** (restart if asked).
3. In Xcode: **Settings → Accounts** → signed in with Apple ID.
4. Project → **DailyExpense** target → **Signing** → Team: **Niyas Muhammed (Personal Team)**.
5. Top bar: select your **iPhone** (not simulator) → **⌘R**.

If Xcode says **“Could not locate device support files”**, your iPhone’s iOS is **too new** for Xcode 14.2. Check on the phone: **Settings → General → About → iOS Version**.

- **iOS 15.x – 16.1** → try again on this Mac after the steps above.
- **iOS 17 or newer** → use one of the options below.

## If your iPhone iOS is too new for this Mac

You can still use the app on your phone without upgrading the Mac:

1. **Borrow / use another Mac** with newer macOS + Xcode, sign in with the same Apple ID, open this project, **⌘R** once.
2. **Cloud Mac build** (Bitbucket Pipelines, GitHub Actions, Codemagic) — build there, download the app, install with Apple **Configurator** on your Mac (macOS 12 supports Configurator).
3. **Keep developing in the Simulator** on your MacBook Air — full UI testing, no cable needed.

## Check your iPhone iOS version

On the iPhone: **Settings → General → About → iOS Version**.

Tell your developer (or note for yourself) that number when asking for help.

## Project already configured for this Mac

- iOS deployment target: **16.0** (works with Xcode 14.2)
- Signing team: **92VCTKP3LK** (Personal Team)
- Xcode project included in the repo

## Need help?

Reply with:

1. **iOS version** on your iPhone (from Settings → About)
2. Whether the phone shows **online** or **offline** in Xcode’s device menu
3. The **exact red error** from Xcode when you press ⌘R
