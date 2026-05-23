# Firebase App Distribution — install on your iPhone

This lets you open a **link on your phone** and install **Daily Expense** (like the old App Center flow).

Your **MacBook Air 2015 cannot build** for **iPhone 17 / iOS 26**, so we use **Codemagic** (free cloud Mac) to build the `.ipa` and send it to **Firebase**.

---

## Part 1 — Firebase (15 minutes, one time)

### 1. Create a Firebase project

1. Open [Firebase Console](https://console.firebase.google.com/)
2. **Add project** → name: `Daily Expense` (or any name)
3. Google Analytics: optional (you can skip)

### 2. Add an iOS app

1. Project overview → **Add app** → **iOS**
2. **Bundle ID:** `com.dailyexpense.app` (must match exactly)
3. App nickname: `Daily Expense`
4. **Register app** — you do **not** need to download `GoogleService-Info.plist` for distribution-only (optional for later)
5. Copy the **Firebase App ID** — looks like:  
   `1:123456789012:ios:abcdef1234567890abcdef`

Save it as `FIREBASE_APP_ID`.

### 3. Enable App Distribution

1. In Firebase left menu → **App Distribution** (under Release)
2. **Get started**
3. **Testers & Groups** → **Add group**
   - Name: `testers`
   - Add your email: `niyaspulath@gmail.com`
4. Save

### 4. Firebase CLI token (for Codemagic)

On any computer with Node.js:

```bash
npm install -g firebase-tools
firebase login
firebase login:ci
```

Copy the **token** shown (keep it secret). You will paste it into Codemagic as `FIREBASE_TOKEN`.

### 5. Project config in this repo

```bash
cd ~/Documents/expence_tracker
cp .firebaserc.example .firebaserc
```

Edit `.firebaserc` — replace `YOUR_FIREBASE_PROJECT_ID` with your Firebase **Project ID** (Project settings → General).

`.firebaserc` is in `.gitignore` — do not commit secrets.

---

## Part 2 — Codemagic cloud build (20 minutes, one time)

### 1. Sign up

1. [codemagic.io](https://codemagic.io) → Sign up with **Bitbucket**
2. Grant access to repo: `niyaspulath/expense-tracker`

### 2. Add the app

1. **Add application** → select **expense-tracker**
2. Codemagic detects `codemagic.yaml` in the repo

### 3. Environment variables

In Codemagic → your app → **Environment variables** (or in `codemagic.yaml` team secrets):

| Variable | Value | Secure? |
|----------|--------|---------|
| `FIREBASE_APP_ID` | `1:xxxx:ios:xxxx` from Firebase | Yes |
| `FIREBASE_TOKEN` | token from `firebase login:ci` | Yes |

### 4. Apple code signing (required for iPhone install)

In Codemagic → **Code signing**:

1. Connect **Apple Developer** account (same Apple ID: `niyaspulath@gmail.com`)
2. **Automatic** signing for bundle `com.dailyexpense.app`
3. Distribution type: **Development** (registers your iPhone for install)

If install fails later, add your iPhone UDID in Codemagic / Firebase when prompted.

### 5. Start a build

1. **Start new build** → workflow: **Daily Expense → Firebase**
2. Wait ~10–20 minutes (first build)

When it succeeds:

- Firebase emails **testers** with an install link
- Codemagic also emails you

---

## Part 3 — Install on your iPhone

1. Open the **email from Firebase App Distribution** on your iPhone
2. Tap **Download** / **Install**
3. If iOS asks: **Settings → General → VPN & Device Management** → trust the developer profile
4. Open **Daily Expense**

First install may ask to register the device — follow Firebase’s page if it requests your UDID.

---

## Manual upload (if you already have an `.ipa`)

On a Mac with **Xcode 16+**:

```bash
cd ~/Documents/expence_tracker
./scripts/export-ipa.sh
export FIREBASE_APP_ID="1:YOUR:ios:APP_ID"
cp .firebaserc.example .firebaserc   # edit project id
chmod +x scripts/firebase-upload-ipa.sh
./scripts/firebase-upload-ipa.sh build/ipa/DailyExpense.ipa
```

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| “Unable to install” on iPhone | Use **Development** signing; register device UDID in Apple Developer + rebuild |
| Build fails on Codemagic | Open build logs; usually signing or bundle ID mismatch |
| No email from Firebase | Check spam; confirm email is in group `testers` |
| Old Mac can’t build | Always use **Codemagic** — do not use Xcode 14 on MacBook 2015 for iPhone 17 |

---

## Files in this repo

| File | Purpose |
|------|---------|
| `codemagic.yaml` | Cloud build + auto-upload to Firebase |
| `firebase.json` | Tester group `testers` |
| `scripts/firebase-upload-ipa.sh` | Manual IPA upload |
| `ExportOptions.plist` | IPA export settings |

---

## Quick checklist

- [ ] Firebase project + iOS app `com.dailyexpense.app`
- [ ] `FIREBASE_APP_ID` copied
- [ ] Group `testers` with your email
- [ ] `FIREBASE_TOKEN` for Codemagic
- [ ] Codemagic + Bitbucket connected
- [ ] Apple signing connected in Codemagic
- [ ] Build finished → open link on iPhone
