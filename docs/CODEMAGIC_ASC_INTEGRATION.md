# Codemagic + TestFlight setup (simple)

Your build failed because App Store Connect keys were not loaded.  
Use **one integration in Codemagic** (no environment variable group needed).

---

## Step 1 — Create API key in Apple

1. [App Store Connect](https://appstoreconnect.apple.com)
2. **Users and Access** → **Integrations** → **App Store Connect API**
3. **+** Generate key → Access: **App Manager**
4. Download **.p8** file (once)
5. Note **Issuer ID** (top of page) and **Key ID** (table)

---

## Step 2 — Add integration in Codemagic (important name)

1. Open [codemagic.io](https://codemagic.io)
2. Click your **profile** (top right) → **Personal account settings**  
   (or **Team settings** if you use a team)
3. **Integrations** tab
4. Find **Developer Portal** (App Store Connect)
5. Click **Connect** or **Add key**
6. Fill in:

| Field | Value |
|-------|--------|
| **API key name** | `codemagic` ← must be exactly this word |
| **Issuer ID** | from Apple |
| **Key ID** | from Apple |
| **API key** | upload `.p8` file |

7. Click **Save**

The name **`codemagic`** must match `codemagic.yaml`:

```yaml
integrations:
  app_store_connect: codemagic
```

---

## Step 3 — Start build

1. Open app **expense-tracker**
2. **Start new build**
3. Workflow: **Daily Expense - TestFlight**
4. Branch: **master**

---

## Errors

| Message | Fix |
|---------|-----|
| Integration `codemagic` does not exist | Repeat Step 2 — API key name must be `codemagic` |
| Signing failed | Paid Apple Developer account + bundle `com.dailyexpense.app` in App Store Connect |
| App not found in App Store Connect | Create app with bundle ID `com.dailyexpense.app` |

---

## You do NOT need

- `app_store_credentials` variable group
- `APP_STORE_CONNECT_PRIVATE_KEY` env vars
- Firebase
- New Xcode on your old Mac

---

Reference: [Codemagic App Store Connect publishing](https://docs.codemagic.io/yaml-publishing/app-store-connect/)
