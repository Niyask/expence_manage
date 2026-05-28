# App Store Connect for Codemagic (optional auto-upload)

## Recommended: use Transporter instead

If you see empty env var errors, use:

**docs/UPLOAD_TESTFLIGHT_TRANSPORTER.md**

Workflow: **Daily Expense - Build IPA** → download IPA → Transporter app.

---

## Optional: auto TestFlight upload

Workflow: **Daily Expense - TestFlight**

### One-time: create integration in Codemagic

1. [codemagic.io](https://codemagic.io) → profile → **Personal account settings**
2. **Integrations** → **Developer Portal** (App Store Connect)
3. **Connect** / **Add key**
4. **API key name:** `codemagic`  ← must match yaml exactly
5. **Issuer ID** + **Key ID** + upload **.p8** from App Store Connect
6. Save

### Apple: create API key

App Store Connect → Users and Access → Integrations → App Store Connect API → **+**

---

## Env vars (only if you edit yaml to use api_key instead of integration)

| Variable | Required |
|----------|----------|
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Full .p8 text |
| `APP_STORE_CONNECT_PUBLISHER_PRIVATE_KEY` | Same .p8 text |

Add on: app **expense-tracker** → **Environment variables** → Secret ON.

Paste .p8 on Mac:

```bash
pbcopy < ~/Downloads/AuthKey_XXXXX.p8
```
