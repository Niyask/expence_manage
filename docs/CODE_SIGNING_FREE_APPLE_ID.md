# Code signing with FREE Apple ID (no $99)

Email: **niyaspulath@gmail.com**  
Bundle ID: **com.dailyexpense.app**

You do **not** use Codemagic "Automatic" signing. You create files on your Mac, then upload them.

---

## Part 1 — Certificate (.p12) on your Mac (10 min)

### 1. Open Xcode

```bash
open ~/Downloads/Xcode.app
```

### 2. Add Apple ID

1. **Xcode** menu → **Settings** (or Preferences)
2. **Accounts** tab → **+** → **Apple ID**
3. Sign in: **niyaspulath@gmail.com**

### 3. Create development certificate

1. Select your account → **Manage Certificates…**
2. Bottom left **+** → **Apple Development**
3. You should see: **Apple Development: Niyas …** (or your name)
4. Click **Done**

### 4. Export .p12 file

1. Open **Keychain Access** (Spotlight → type `Keychain Access`)
2. Left side: **login** keychain
3. Category: **My Certificates**
4. Find **Apple Development: … (niyaspulath@gmail.com)**
5. Click the **arrow** next to it to expand
6. Select **both** the certificate **and** the private key (two items)
7. Right-click → **Export 2 items…**
8. File name: `DailyExpenseDev.p12`
9. Format: **Personal Information Exchange (.p12)**
10. Set a **password** (example: `DailyExpense2024`) — **write it down**
11. Mac may ask your Mac login password to allow export

Keep `DailyExpenseDev.p12` on Desktop.

---

## Part 2 — Register iPhone + app (15 min)

### 1. Register your iPhone

1. On iPhone: **Settings** → **General** → **About** — note nothing yet
2. Connect iPhone to Mac with cable (or use Xcode wireless later)
3. Open Xcode → **Window** → **Devices and Simulators**
4. Select your **iPhone** → if it says "Use for Development", click it
5. Or get UDID: in Xcode Devices, right-click iPhone → **Copy Identifier**

6. Open **https://developer.apple.com/account** → sign in
7. **Certificates, Identifiers & Profiles**
8. **Devices** → **+** → name `My iPhone` → paste **UDID** → Continue → Register

### 2. Register bundle ID

1. **Identifiers** → **+** → **App IDs** → **App** → Continue
2. Description: `Daily Expense`
3. Bundle ID: **Explicit** → `com.dailyexpense.app`
4. Continue → Register

### 3. Create provisioning profile

1. **Profiles** → **+**
2. **iOS App Development** → Continue
3. App ID: **com.dailyexpense.app** → Continue
4. Certificate: tick your **Apple Development** cert → Continue
5. Devices: tick **your iPhone** → Continue
6. Profile name: `DailyExpense Dev` → Generate
7. **Download** the file → `DailyExpense_Dev.mobileprovision`

---

## Part 3 — Upload to Codemagic (5 min)

### 1. Upload certificate

1. Codemagic → **Code signing identities** (the page you saw)
2. **iOS certificates** tab
3. **Choose file** → select `DailyExpenseDev.p12`
4. **Certificate password**: the password you set in Part 1
5. **Reference name**: `daily_expense_dev` (type exactly)
6. Click **Add certificate**

### 2. Upload provisioning profile

1. Same page → **iOS provisioning profiles** tab
2. Upload `DailyExpense_Dev.mobileprovision`
3. **Reference name**: `daily_expense_dev_profile`
4. **Add profile**

### 3. Connect to your app

1. Codemagic → open app **expense-tracker**
2. **App settings** → **Distribution** → **iOS code signing**
3. Method: **Manual**
4. Certificate: **daily_expense_dev**
5. Profile: **daily_expense_dev_profile**

---

## Part 4 — Build and install

1. **Environment variables**: `FIREBASE_TOKEN` (Secure) — still required
2. **Start new build** → **Daily Expense - Firebase** → branch **master**
3. Wait ~20 min
4. Email on iPhone → Firebase → **Install**

---

## Common problems

| Problem | Fix |
|---------|-----|
| No "Apple Development" in Keychain | Repeat Part 1 step 3 in Xcode |
| Can't export private key | Select certificate **and** private key together |
| developer.apple.com won't open Profiles | Sign in with same Apple ID; free account is OK |
| iPhone not in profile | Add device UDID in Part 2 step 1 |
| Build fails "no signing" | Reference names must match exactly |

---

## After first success

Rebuild when you add a new iPhone (update profile with new UDID in developer.apple.com).
