# Start your first Firebase build (after phone connected)

You connected Firebase on your **iPhone** — that registers you as a **tester**.

**Firebase does not compile the iOS app.** Something must **build the `.ipa` file** and **upload** it. On your MacBook Air 2015 that is **Codemagic** (free cloud Mac). Codemagic uploads to Firebase; you get an **email with Install**.

---

## Checklist (do in order)

### ✅ Done (you said)
- [x] Firebase project created
- [x] Tester connected on mobile (`niyaspulath@gmail.com`)

### ✅ Step A — Your Firebase (already found)

| | Value |
|---|--------|
| Project ID | `daily-expense-64007` |
| **FIREBASE_APP_ID** | `1:348319290522:ios:c5344f54c8f27d47017b23` |

Group **`testers`** should include **`niyaspulath@gmail.com`** (phone connect does this).

**Easier guide:** [DO_THIS_NOW.md](DO_THIS_NOW.md)

### ⬜ Step B — Firebase token (on your Mac, one time)

In Terminal:

```bash
npx firebase-tools@latest login:ci
```

- Browser opens → sign in with **niyaspulath@gmail.com**  
- Copy the **long token** → this is **`FIREBASE_TOKEN`** (keep secret)

### ⬜ Step C — Codemagic (build + upload)

1. Open **[https://codemagic.io](https://codemagic.io)** → **Sign up with Bitbucket**  
2. Allow access to repo: **`niyaspulath/expense-tracker`**  
3. **Add application** → select **expense-tracker**  
4. Codemagic should detect workflow: **Daily Expense → Firebase** (`codemagic.yaml`)

5. **Environment variables** (app or team settings → add both, mark **Secure**):

   | Name | Value |
   |------|--------|
   | `FIREBASE_APP_ID` | App ID from Step A |
   | `FIREBASE_TOKEN` | Token from Step B |

6. **Teams** → **Code signing** (or app → **Code signing identities**):  
   - Connect **Apple ID**: `niyaspulath@gmail.com`  
   - Bundle ID: `com.dailyexpense.app`  
   - **Development** signing (for install on your iPhone)

7. **Start new build**  
   - Workflow: **Daily Expense → Firebase**  
   - Branch: **master**  
   - Click **Start build**

8. Wait **15–25 minutes** (first build is slower)

### ⬜ Step D — Install on iPhone

When Codemagic shows **Success**:

1. Check email **niyaspulath@gmail.com** (and spam)  
2. Subject from **Firebase App Distribution**  
3. Tap **Download** / **Install** on the **iPhone** (same phone you connected)  
4. If needed: **Settings → General → VPN & Device Management** → trust developer  

---

## Auto-build on every push (optional)

After Codemagic works once, pushing to **`master`** can start a new build automatically (`codemagic.yaml` is configured for that).

```bash
cd ~/Documents/expence_tracker
git push origin master
```

---

## Why your Mac cannot do this step alone

| Tool | Can build for iPhone 17 / iOS 26? |
|------|-----------------------------------|
| Your Mac (Xcode 14.2) | ❌ No |
| Firebase Console / mobile app | ❌ No (only distributes builds) |
| **Codemagic** (latest Xcode) | ✅ Yes |

---

## If build fails in Codemagic

Open the failed build → read the **red log line**. Common fixes:

| Error | Fix |
|-------|-----|
| `FIREBASE_APP_ID` missing | Add env var in Codemagic |
| `FIREBASE_TOKEN` invalid | Run `npx firebase-tools@latest login:ci` again |
| Code signing failed | Reconnect Apple ID; bundle must be `com.dailyexpense.app` |
| No install email | Confirm `testers` group has your email |

---

## Need help?

Reply with:
1. Screenshot or text from Codemagic build status (success / failed)  
2. Your **Firebase App ID** (first/last 4 characters only, e.g. `1:1234…abcd`)  
3. Whether Codemagic account is connected to Bitbucket  

Full guide: [FIREBASE_DISTRIBUTION.md](FIREBASE_DISTRIBUTION.md)
