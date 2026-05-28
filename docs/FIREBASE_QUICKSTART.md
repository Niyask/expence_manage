# Quick start — install on your iPhone

**Your accounts (use the same email everywhere):**

| Service | Email |
|---------|--------|
| Apple ID | `niyaspulath@gmail.com` |
| Google / Firebase | `niyaspulath@gmail.com` |
| Codemagic notifications | `niyaspulath@gmail.com` |
| Firebase tester group `testers` | `niyaspulath@gmail.com` |

**Bundle ID (must match):** `com.dailyexpense.app`  
**Apple Team (already in project):** Personal Team — Niyas Muhammed

---

## Step 1 — Firebase (Google: niyaspulath@gmail.com)

1. Open [Firebase Console](https://console.firebase.google.com/) → sign in with **niyaspulath@gmail.com**
2. **Add project** → name: `Daily Expense`
3. **Add app** → **iOS** → Bundle ID: `com.dailyexpense.app`
4. Copy **App ID** (example: `1:1234567890:ios:abc123...`) → save as `FIREBASE_APP_ID`
5. Left menu → **App Distribution** → **Get started**
6. **Testers & Groups** → create group **`testers`** → add **`niyaspulath@gmail.com`**
7. Terminal (on your Mac — no global install needed):
   ```bash
   npx firebase-tools@latest login:ci
   ```
   Use **niyaspulath@gmail.com** in the browser. Copy the **token** → `FIREBASE_TOKEN` in Codemagic.

8. In project folder:
   ```bash
   cp .firebaserc.example .firebaserc
   ```
   Edit `.firebaserc` — set your Firebase **Project ID** (Firebase → Project settings → General).

---

## Step 2 — Codemagic (sign in with Bitbucket)

1. [codemagic.io](https://codemagic.io) → sign up → connect **Bitbucket** → repo **expense-tracker**
2. Codemagic picks up **`codemagic.yaml`** automatically
3. **Environment variables** (mark as secure):

   | Name | Value |
   |------|--------|
   | `FIREBASE_APP_ID` | from Step 1 |
   | `FIREBASE_TOKEN` | from `firebase login:ci` |

4. **Code signing** → Connect Apple ID → use **niyaspulath@gmail.com** + password / 2FA  
   - Bundle: `com.dailyexpense.app`  
   - Type: **Development** (for install on your phone)

5. **Start build** → workflow: **Daily Expense → Firebase**

---

## Step 3 — On your iPhone

1. Check **niyaspulath@gmail.com** on the phone (Gmail app or Mail)
2. Open email from **Firebase App Distribution**
3. Tap install → trust developer in Settings if asked
4. Open **Daily Expense**

---

## Push code first (if not done)

```bash
cd ~/Documents/expence_tracker
git add codemagic.yaml firebase.json docs/
git commit -m "Firebase distribution setup for niyaspulath@gmail.com"
git push origin master
```

Then start the Codemagic build.

---

Full guide: [FIREBASE_DISTRIBUTION.md](FIREBASE_DISTRIBUTION.md)
