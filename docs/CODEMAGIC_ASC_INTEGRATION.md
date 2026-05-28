# Fix: App Store Connect integration does not exist

Codemagic shows:

`App Store Connect integration "DAILY_EXPENSE_ASC" does not exist`

That name came from **`codemagic.yaml`** in your repo (not from Firebase).

---

## Fix in 2 minutes

### Option A — Create integration with the name in yaml (easiest)

1. Codemagic → **Personal account** or **Team settings** → **Integrations**
2. **Developer Portal** (App Store Connect) → **Add key** / **Connect**
3. When asked for **API key name**, type exactly:

   **`Daily Expense ASC`**

   (same spelling as in `codemagic.yaml`)

4. Paste **Issuer ID**, **Key ID**, upload **.p8** from App Store Connect
5. Save
6. Start build → **Daily Expense - TestFlight**

### Option B — Use your existing integration name

If you already added a key with another name (e.g. `Daily Expence`):

1. Open `codemagic.yaml`
2. Change this line to your **exact** Codemagic integration name:

   ```yaml
   app_store_connect: Your Exact Name Here
   ```

3. Commit/push or paste updated yaml in Codemagic
4. Start build again

---

## Where the name is set

Only here in the repo:

```yaml
integrations:
  app_store_connect: Daily Expense ASC
```

Codemagic does **not** invent `DAILY_EXPENSE_ASC` — it was in an older version of your yaml file.

---

## TestFlight only

This project uses **one** workflow: **Daily Expense - TestFlight**.  
No Firebase workflow in `codemagic.yaml`.
