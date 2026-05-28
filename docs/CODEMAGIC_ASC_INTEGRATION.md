# Fix: integration does not exist + missing env vars

You do **NOT** need an integration named `codemagic` or `Daily Expense ASC`.

Add **3 variables on the app** in Codemagic (not a group name).

---

## Step 1 — Apple API key

1. [App Store Connect](https://appstoreconnect.apple.com) → **Users and Access** → **Integrations** → **App Store Connect API**
2. **+** → access **App Manager** → generate
3. Download **.p8** (once)
4. Copy **Issuer ID** + **Key ID**

---

## Step 2 — Add variables on the APP (important)

1. [codemagic.io](https://codemagic.io) → open application **expense-tracker** (or Expense Tracker)
2. Left menu: **Environment variables** (under this app, not only Team settings)
3. Click **Add variable** three times:

| Variable name | Value | Secret |
|---------------|--------|--------|
| `APP_STORE_CONNECT_PRIVATE_KEY` | Paste full `.p8` file text | Yes |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID | Yes |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID | Yes |

4. **Save** each variable
5. Do **not** require a group named `app_store_credentials` (removed from yaml)

### .p8 paste format

Must include lines like:

```
-----BEGIN PRIVATE KEY-----
...
-----END PRIVATE KEY-----
```

---

## Step 3 — Start build

1. **Start new build**
2. Workflow: **Daily Expense - TestFlight**
3. Branch: **master**

---

## If you already added a Codemagic integration

That is fine — you can ignore it. This yaml does not use `integrations: app_store_connect` anymore.

---

## If build fails at signing or upload

| Error | Fix |
|-------|-----|
| Private key invalid | Re-paste full `.p8` content |
| Bundle ID | Must be `com.dailyexpense.app` in Apple Developer + App Store Connect |
| No app in App Store Connect | Create app with that bundle ID |

---

## Optional: build IPA only (no TestFlight upload)

If upload keeps failing, download `.ipa` from Codemagic **Artifacts** and upload with **Transporter** app on any Mac with your Apple ID.
