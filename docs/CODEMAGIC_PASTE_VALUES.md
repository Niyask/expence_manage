# Paste these in Codemagic (not in chat, not in git)

Your Firebase token is a **secret**. Paste it only in Codemagic → **Environment variables**.

## Variable 1

| Field | Value |
|-------|--------|
| Name | `FIREBASE_APP_ID` |
| Value | `1:348319290522:ios:c5344f54c8f27d47017b23` |
| Secure | ✅ ON |

## Variable 2

| Field | Value |
|-------|--------|
| Name | `FIREBASE_TOKEN` |
| Value | Your token from `npx firebase-tools@latest login:ci` |
| Secure | ✅ ON |

**Do not** put the token in email, chat, or commit it to Bitbucket.

## Then

1. **Code signing** → Apple ID `niyaspulath@gmail.com`
2. **Start build** → **Daily Expense → Firebase** → branch **master**

---

## If you shared your token publicly

1. Run: `npx firebase-tools@latest login:ci` again  
2. Replace `FIREBASE_TOKEN` in Codemagic with the **new** token  
3. Old token may stop working (that is good for security)
