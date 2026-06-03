# Daily Expense — App Store web pages

Static HTML pages themed to match the iOS app (`AppTheme` teal/violet gradients, cards, banners).

## Files

| File | App Store Connect field | Example URL |
|------|-------------------------|-------------|
| `index.html` | **Marketing URL** | `https://yourdomain.com/` |
| `support.html` | **Support URL** | `https://yourdomain.com/support.html` |
| `privacy.html` | **Privacy Policy URL** | `https://yourdomain.com/privacy.html` |

## Before you publish

1. Replace placeholder emails:
   - `support@dailyexpense.app` in `support.html`
   - `privacy@dailyexpense.app` in `privacy.html`
2. Replace App Store link in `index.html`:
   - `https://apps.apple.com/app/id0000000000` → your real App Store URL
3. Confirm developer name in `privacy.html` section 12 if needed.

## Deploy options

### GitHub Pages

1. Push the `web/` folder to your repo (or only host `web/` as site root).
2. Repo → **Settings → Pages** → Source: branch `main`, folder `/web` or copy files to `/docs`.
3. URLs: `https://username.github.io/repo/` (marketing), `.../support.html`, `.../privacy.html`.

### Firebase Hosting

```bash
cd web
firebase init hosting   # public directory = current folder
firebase deploy
```

### Any static host

Upload `index.html`, `support.html`, `privacy.html`, and `css/theme.css` keeping the same folder structure.

## App Store Connect

**App Information:**

- Marketing URL → `index.html` URL  
- Support URL → `support.html` URL  

**App Privacy** (questionnaire) should match `privacy.html` (no tracking, on-device data, optional notifications).

## Local preview (Windows)

Open `index.html` in a browser (double-click or drag into Chrome/Edge). CSS uses relative paths — keep `css/theme.css` beside the HTML files.
