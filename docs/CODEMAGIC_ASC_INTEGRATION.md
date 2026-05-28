# What to use for TestFlight (no integration name needed)

You do **not** need an integration named `Daily Expense ASC` anymore.

Add **3 environment variables** in Codemagic instead.

---

## Step 1 — Create API key in Apple (one time)

1. Open [App Store Connect](https://appstoreconnect.apple.com)
2. **Users and Access** → **Integrations** → **App Store Connect API**
3. Click **+** to generate a key
4. Name: `Codemagic` (any name is fine on Apple side)
5. Access: **App Manager** (or Admin)
6. **Download** the `.p8` file (only once)
7. Copy:
   - **Issuer ID** (top of the Keys page)
   - **Key ID** (in the table for your key)

---

## Step 2 — Add 3 variables in Codemagic (required)

1. Codemagic → **Teams** (or Personal account) → **Environment variables**
2. Create a **group** named exactly: **`app_store_credentials`**
3. Inside that group, add these 3 variables (turn **Secure** ON for all):

Or: app **expense-tracker** → Environment variables → same group name **`app_store_credentials`**

**Important:** The group name must be `app_store_credentials` (matches `codemagic.yaml`).

| Variable name | What to paste |
|---------------|----------------|
| `APP_STORE_CONNECT_PRIVATE_KEY` | Open the `.p8` file in TextEdit — paste **all** text including `-----BEGIN PRIVATE KEY-----` lines |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID (e.g. `AB12CD34EF`) |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID (e.g. `12345678-abcd-...`) |

Save.

---

## Step 3 — Start build

1. **Start new build**
2. Workflow: **Daily Expense - TestFlight**
3. Branch: **master**

Build log should show: `OK: App Store Connect variables present.`

---

## Still need Apple signing

`distribution_type: app_store` uses your Apple Developer account via the same API key during the build.

Requirements:

- Paid **Apple Developer Program** ($99/year)
- App **com.dailyexpense.app** created in App Store Connect
- Bundle ID registered in [developer.apple.com](https://developer.apple.com/account)

---

## Optional: use Codemagic UI integration instead

If you prefer the UI integration (no 3 env vars):

1. Codemagic → **Integrations** → **Developer Portal** → **Add key**
2. Pick any name you like (e.g. `My Apple Key`)
3. In `codemagic.yaml` use:

```yaml
integrations:
  app_store_connect: My Apple Key

publishing:
  app_store_connect:
    auth: integration
    submit_to_testflight: true
```

Names must match **exactly**. The env-var method avoids that problem.

---

## Troubleshooting

| Error | Fix |
|-------|-----|
| Integration does not exist | Use env vars (this guide) — no integration name |
| Missing `APP_STORE_CONNECT_*` | Add all 3 variables in Codemagic |
| Signing failed | Confirm paid developer account + bundle ID |
| Upload failed | Check API key has App Manager access |

Reference: [Codemagic App Store Connect publishing](https://docs.codemagic.io/yaml-publishing/app-store-connect/)
