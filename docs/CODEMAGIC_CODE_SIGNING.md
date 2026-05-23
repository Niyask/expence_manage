# Codemagic code signing — what that screen means

You are on: **Code signing identities** → **Upload a certificate file (.p12)**

That page is for **manual** upload. You usually **do not** start there.

---

## What to do instead (choose A or B)

### Path A — Automatic (best if you have Apple Developer $99/year)

1. Open **https://appstoreconnect.apple.com** → sign in **niyaspulath@gmail.com**
2. **Users and Access** → **Integrations** → **App Store Connect API**
3. Click **+** → name: `Codemagic` → access: **App Manager** → **Generate**
4. **Download** the `.p8` file (only once)
5. Note **Issuer ID** (top of page) and **Key ID** (in the table)

6. In **Codemagic** (not the p12 upload page):
   - Click your **profile/avatar** (top right)
   - **Team settings** OR **Personal account settings**
   - **Team integrations** (or **Integrations**)
   - Find **Developer Portal** → **Connect** / **Manage keys**
   - Add key: name, Issuer ID, Key ID, upload `.p8` → **Save**

7. Open your **app** (expense-tracker) in Codemagic:
   - **App settings** → **Distribution** → **iOS code signing**
   - Method: **Automatic**
   - Profile type: **Development**
   - Bundle ID: **com.dailyexpense.app**

8. **Start build** again.

---

### Path B — Manual .p12 (Personal Team / free Apple ID)

Use this if you **do not** have paid Apple Developer and only see the upload screen.

#### Step 1 — Create certificate in Xcode on your Mac

1. Open **Xcode** (Downloads/Xcode.app)
2. **Xcode** → **Settings** → **Accounts** → add **niyaspulath@gmail.com**
3. Select account → **Manage Certificates…**
4. Click **+** → **Apple Development**
5. Close windows

#### Step 2 — Export .p12 from Keychain

1. Open **Keychain Access** (Spotlight: Keychain Access)
2. Category: **My Certificates**
3. Find **Apple Development: your name (niyaspulath@gmail.com)**
4. Expand it → select **certificate + private key** (both)
5. Right-click → **Export 2 items…**
6. Save as `DailyExpense.p12` → set a **password** (remember it)

#### Step 3 — Register app ID (if needed)

1. Open **https://developer.apple.com/account** → sign in
2. **Certificates, Identifiers & Profiles**
3. **Identifiers** → **+** → **App IDs** → **App**
4. Bundle ID: **com.dailyexpense.app** → Register

#### Step 4 — Create provisioning profile

1. **Profiles** → **+** → **iOS App Development**
2. App ID: **com.dailyexpense.app**
3. Certificate: your **Apple Development** cert
4. Devices: select your **iPhone** (register iPhone UDID first under **Devices** if missing)
5. Name: `Daily Expense Dev` → **Generate** → **Download** `.mobileprovision`

#### Step 5 — Upload to Codemagic (the page you see now)

1. Codemagic → **Code signing identities** → **iOS certificates**
2. **Upload** your `DailyExpense.p12` + enter **password** + reference name: `daily_expense_dev`
3. Tab **iOS provisioning profiles** → upload `.mobileprovision` + reference name: `daily_expense_dev_profile`

4. Open **app** → **Distribution** → **iOS code signing** → **Manual**
5. Select those certificate and profile

6. **Start build**

---

## Do NOT worry about

- **Android keystores** — this is an iOS app only
- Uploading random files — only `.p12` + `.mobileprovision` from steps above

---

## Still stuck?

Reply with:

1. Do you pay for **Apple Developer Program** ($99/year)? **Yes / No**
2. Screenshot of Codemagic left menu (what items you see)

We will pick Path A or B for you.
