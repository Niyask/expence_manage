# Upload to TestFlight without Codemagic env vars (easiest)

Your build failed at **Verify App Store Connect credentials** because those 3 variables are **not set in Codemagic**.

Use this path instead — it works with your **old Mac** and **no env vars**.

---

## Step 1 — Build IPA in Codemagic

1. [codemagic.io](https://codemagic.io) → app **expense-tracker**
2. **Start new build**
3. Workflow: **Daily Expense - Build IPA**  ← not TestFlight workflow
4. Branch: **master**
5. Wait until **success**

---

## Step 2 — Download IPA

1. Open the finished build
2. **Artifacts** tab
3. Download **DailyExpense.ipa**

---

## Step 3 — Upload with Transporter (on your Mac)

1. Install **Transporter** from Mac App Store (free, by Apple)
2. Open Transporter
3. Sign in with your **Apple Developer** Apple ID
4. Drag **DailyExpense.ipa** into Transporter
5. Click **Deliver**

---

## Step 4 — TestFlight on iPhone

1. Open [App Store Connect](https://appstoreconnect.apple.com)
2. **My Apps** → Daily Expense → **TestFlight**
3. Wait for build **Processing** (10–30 min)
4. Add yourself as internal tester
5. Install **TestFlight** app on iPhone → open invite

---

## When to use "Daily Expense - TestFlight" workflow

Only after you add Codemagic integration:

- Settings → Integrations → Developer Portal
- API key name: **`codemagic`** (exact)
- Issuer ID, Key ID, `.p8` file

See **CODEMAGIC_ASC_INTEGRATION.md**.

---

## Why env var errors happened

Codemagic could not see:

- `APP_STORE_CONNECT_KEY_IDENTIFIER`
- `APP_STORE_CONNECT_ISSUER_ID`
- `APP_STORE_CONNECT_PRIVATE_KEY`

They must be added on the **app** page → Environment variables, or use Transporter path above.
