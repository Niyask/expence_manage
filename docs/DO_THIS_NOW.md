# Do this now — 3 steps (phone already connected ✅)

Your Firebase is ready:

| Item | Your value |
|------|------------|
| Project | **Daily Expense** |
| Project ID | `daily-expense-64007` |
| iOS App ID (for Codemagic) | `1:348319290522:ios:c5344f54c8f27d47017b23` |
| Email | `niyaspulath@gmail.com` |

**Phone connected to Firebase = you are a tester.**  
You still need **one cloud build** (Codemagic). I cannot click Codemagic for you — only you can log in there.

---

## Step 1 — Open Codemagic (5 minutes)

1. On your Mac, open: **https://codemagic.io/signup**
2. Tap **Sign up with Bitbucket**
3. Log in with your Bitbucket account
4. Allow access to repo: **`expense-tracker`**
5. Tap **Add application** → choose **`expense-tracker`**

You should see workflow: **Daily Expense → Firebase**

---

## Step 2 — Paste these two secrets in Codemagic

In Codemagic → your app → **Environment variables** → **Add**

### Variable 1
- **Name:** `FIREBASE_APP_ID`  
- **Value:** copy this exactly:

```
1:348319290522:ios:c5344f54c8f27d47017b23
```

- Turn on **Secure** → Save

### Variable 2 — get token on your Mac

Open **Terminal** and run:

```bash
npx firebase-tools@latest login:ci
```

- Browser opens → choose **niyaspulath@gmail.com**
- Terminal shows a **long token** → copy all of it

In Codemagic add:
- **Name:** `FIREBASE_TOKEN`  
- **Value:** paste the token  
- **Secure** → Save

---

## Step 3 — Apple signing + Start build

1. Codemagic → **Teams** (left) → **Code signing**  
2. **Connect Apple ID** → `niyaspulath@gmail.com` + password  
3. Bundle ID: **`com.dailyexpense.app`**  
4. Type: **Development**

5. Go back to app → **Start new build**  
6. Workflow: **Daily Expense → Firebase**  
7. Branch: **master**  
8. Tap **Start build**

Wait **15–25 minutes**.

---

## Step 4 — On iPhone

1. Open email **niyaspulath@gmail.com**  
2. Email from **Firebase App Distribution**  
3. Tap **Install**

---

## If you get stuck

Reply with a screenshot of Codemagic (home page or build error).  
Common issue: forgot Step 2 variables → build fails at the end.
