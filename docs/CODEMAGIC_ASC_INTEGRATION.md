# Fix TestFlight publish error (invalid PEM / missing Key ID)

Your **build succeeded**. Only **upload to App Store Connect** failed.

Log showed:
- `key-id '$APP_STORE_CONNECT_KEY_IDENTIFIER'` → Key ID variable **not set** in Codemagic
- `APP_STORE_CONNECT_PUBLISHER_PRIVATE_KEY` → **invalid PEM** (wrong paste of `.p8` file)

---

## Add 4 variables in Codemagic

**expense-tracker** app → **Environment variables** → add each (Secret = ON):

| Variable | Value |
|----------|--------|
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID from Apple (10 chars, e.g. `AB12CD34EF`) |
| `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID (UUID from Apple Keys page) |
| `APP_STORE_CONNECT_PRIVATE_KEY` | Full `.p8` file text (see below) |
| `APP_STORE_CONNECT_PUBLISHER_PRIVATE_KEY` | **Same** `.p8` text as row above |

Items 3 and 4 must be **identical** content.

---

## Paste `.p8` correctly (Mac)

In Terminal on your Mac:

```bash
pbcopy < ~/Downloads/AuthKey_XXXXXXXXXX.p8
```

Then in Codemagic paste into the variable value field.

Must look like:

```
-----BEGIN PRIVATE KEY-----
MIGTAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBHkwdwIBAQQg...
(many lines)
-----END PRIVATE KEY-----
```

**Do not** add extra quotes. **Do not** paste as one long line without breaks.

---

## Get Key ID and Issuer ID

1. [App Store Connect](https://appstoreconnect.apple.com)
2. **Users and Access** → **Integrations** → **App Store Connect API**
3. **Issuer ID** = at top of page
4. **Key ID** = in table for your key

---

## Start build again

Workflow: **Daily Expense - TestFlight** → branch **master**

First step should print:

```
OK: APP_STORE_CONNECT_KEY_IDENTIFIER is set.
OK: APP_STORE_CONNECT_ISSUER_ID is set.
OK: API private key is valid PEM.
```

---

## If upload still fails

Download **DailyExpense.ipa** from Codemagic **Artifacts** and upload with **Transporter** app (Mac App Store) using your Apple ID.

---

Reference: [Codemagic App Store Connect publishing](https://docs.codemagic.io/yaml-publishing/app-store-connect/)
