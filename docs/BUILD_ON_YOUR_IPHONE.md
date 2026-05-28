# Install Daily Expense on your iPhone (no errors checklist)

Your Mac **cannot** build for iPhone 17. Use **Codemagic** (build) + **Firebase** (install link).

Email everywhere: **niyaspulath@gmail.com**

---

## Part A - Codemagic (one time, 15 minutes)

### 1. Sign up

1. Open **https://codemagic.io/signup**
2. **Sign up with Bitbucket**
3. Add app: **expense-tracker**

### 2. Environment variables

Codemagic -> your app -> **Environment variables** -> add:

| Name | Value | Secure |
|------|--------|--------|
| `FIREBASE_TOKEN` | From Terminal: `npx firebase-tools@latest login:ci` | ON |
| `FIREBASE_APP_ID` | `1:348319290522:ios:c5344f54c8f27d47017b23` | optional |

`FIREBASE_APP_ID` is also in `codemagic.yaml` as backup. **`FIREBASE_TOKEN` is required.**

### 3. Apple code signing (required)

1. Codemagic -> **Teams** -> **Code signing identities**
2. **Connect Apple Developer account**
3. Apple ID: **niyaspulath@gmail.com**
4. Enable **Automatic** signing
5. Bundle ID: **com.dailyexpense.app**
6. Type: **Development** (not App Store)

Wait until Codemagic shows a valid **development** certificate and profile.

### 4. Start build

1. **Start new build**
2. Workflow: **Daily Expense - Firebase**
3. Branch: **master**
4. Wait 15-25 minutes

### 5. If build fails

Open the build -> scroll to the **first red ERROR** line.

| Error message | Fix |
|---------------|-----|
| `FIREBASE_TOKEN` missing | Add variable in step 2 |
| `Shared scheme missing` | Pull latest `master` (we added the scheme) |
| `No signing certificate` | Repeat step 3 (Apple connection) |
| `Bundle identifier` mismatch | Must be `com.dailyexpense.app` |
| Firebase upload failed | New `login:ci` token, update `FIREBASE_TOKEN` |

Copy the error line and ask for help if stuck.

---

## Part B - Install on iPhone

1. Email **niyaspulath@gmail.com** -> **Firebase App Distribution**
2. Open link **on the iPhone**
3. Tap **Download** / **Install**
4. If asked: **Settings -> General -> VPN & Device Management** -> Trust
5. Open **Daily Expense**

---

## Part C - You do NOT need

- Bitbucket webhooks (optional only)
- Building on MacBook Air 2015 for the phone
- App Center (retired)
- Putting Firebase token in `codemagic.yaml` or chat

---

## Part D - Simulator on Mac (works today)

For testing on Mac only:

```bash
cd ~/Documents/expence_tracker
./scripts/run-simulator.sh
```

This does **not** install on your physical iPhone.

---

## Quick test before Codemagic

In Codemagic build log, you should see:

```
OK: project and scheme found.
```

If you see that, the YAML fix worked. Next failures are usually **Apple signing** (Part A step 3).

---

## Part E - Build for TestFlight

Use this only if your Apple Developer account has App Store Connect access configured in Codemagic.

1. Codemagic -> App settings -> Integrations -> connect **App Store Connect** (API key)
2. Confirm bundle ID is `com.dailyexpense.app`
3. Start new build -> workflow **Daily Expense - TestFlight**
4. After success, open App Store Connect -> TestFlight -> select latest build

If build fails with signing/publishing error, copy the first red error line and share it.
