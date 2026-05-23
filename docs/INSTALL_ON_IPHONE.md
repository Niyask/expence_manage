# Install Daily Expense on your iPhone (download link)

## App Center is no longer available

**Microsoft retired Visual Studio App Center** (including Distribute / download links) on **31 March 2025**.

You cannot create a new App Center app or share an App Center install link anymore.

Use one of the options below instead — they work like App Center (build → link → install on phone).

---

## Recommended: TestFlight (best for iPhone 17 / iOS 26)

Works with your **Apple ID** team (`niyaspulath@gmail.com`) and supports **new iPhones**.

### What you need

1. **Apple Developer Program** — [developer.apple.com](https://developer.apple.com/programs/) ($99/year)  
   *Free “Personal Team” only installs for 7 days; TestFlight is more stable.*

2. **A Mac with Xcode 16+** (your MacBook Air 2015 cannot build for iOS 26 — use a newer Mac, friend’s Mac, or cloud build below).

### Steps

1. Open [App Store Connect](https://appstoreconnect.apple.com) → **My Apps** → **+** → New App  
   - Name: **Daily Expense**  
   - Bundle ID: **com.dailyexpense.app**

2. On a Mac with **Xcode 16+**:
   ```bash
   cd /path/to/expence_tracker
   chmod +x scripts/export-ipa.sh
   ./scripts/export-ipa.sh
   ```
   Or in Xcode: **Product → Archive** → **Distribute App** → **TestFlight**.

3. Upload the `.ipa` to App Store Connect (Xcode Organizer or Transporter app).

4. In App Store Connect → **TestFlight** → **Internal Testing** → add your Apple ID email.

5. On your iPhone, install **TestFlight** from the App Store, open the invite link, install **Daily Expense**.

You get a **link** you can open on your phone (same idea as App Center).

---

## Alternative: Firebase App Distribution (closest to old App Center)

Free tier, **download link per build**, email to testers.

1. [Firebase Console](https://console.firebase.google.com) → create project → add **iOS app**  
   - Bundle ID: `com.dailyexpense.app`

2. Build an `.ipa` (same `scripts/export-ipa.sh` on a Mac with matching Xcode).

3. Firebase → **App Distribution** → upload `.ipa` → add testers (your email).

4. Testers get an **email with an install link** (needs device registered for Ad Hoc / development profile).

Docs: [Firebase App Distribution iOS](https://firebase.google.com/docs/app-distribution/ios/distribute-console)

---

## Cloud build (if you only have the old MacBook)

Your Mac runs **macOS 12** and **Xcode 14** — it **cannot** build for **iPhone 17 / iOS 26**.

Use a cloud Mac service to produce the `.ipa`, then upload to TestFlight or Firebase:

| Service | Notes |
|--------|--------|
| [Codemagic](https://codemagic.io) | Free tier, connects to Bitbucket |
| [Bitbucket Pipelines](https://support.atlassian.com/bitbucket-cloud/docs/macos-runners/) | macOS runners (paid) |
| Borrow a newer Mac | Fastest one-time setup |

Repo: `https://bitbucket.org/niyaspulath/expense-tracker`

---

## Your project is already set up for signing

- Bundle ID: `com.dailyexpense.app`
- Team: `92VCTKP3LK` (Personal Team) in `project.yml`

On a **new enough Mac**, open `DailyExpense.xcodeproj` → **Signing** → select your team → archive.

---

## Quick comparison

| Method | App Center–style link? | Works on iPhone 17? |
|--------|------------------------|---------------------|
| App Center | ❌ Retired | ❌ |
| **TestFlight** | ✅ Invite link | ✅ |
| **Firebase App Distribution** | ✅ Email link | ✅ (with correct build) |
| Simulator on old Mac | N/A | ❌ (simulator only) |

---

## Need help?

Reply with:

1. Do you have **Apple Developer Program** ($99) or only free Apple ID?  
2. Can you use **another Mac** with Xcode 16+?  

Then we can add a **Codemagic** or **Bitbucket** config file to build automatically from your repo.
