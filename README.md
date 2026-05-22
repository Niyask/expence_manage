# Daily Expense — iOS (SwiftUI)

Native SwiftUI app implementing the [Figma design](https://www.figma.com/design/4zxKTpdb6MGqaQHnA8FdJt/Daily-Expense---iOS-App).

Built for **iOS 17+** with production-minded defaults: local persistence, notification permissions, input validation, spring animations, and accessibility (Reduce Motion).

---

## For Drupal developers (first iOS app)

| Drupal concept | iOS equivalent in this project |
|----------------|------------------------------|
| Entity / fields | `Transaction`, `ExpenseTag` models |
| Config export | `AppSettings` in `state.json` |
| Cache | In-memory `ExpenseStore` + debounced disk save |
| Cron | `UNCalendarNotificationTrigger` (evening report) |
| Form validation | `InputValidator` before save |
| Theme / design tokens | `AppTheme.swift` |
| Twig partials | `SharedComponents.swift` |
| Routing | `NavigationStack`, `TabView`, `.sheet` |

You **must use a Mac** with Xcode to build and run iOS apps. Windows can edit Swift files; the simulator runs only on macOS.

---

## Open in Xcode

### Option A — New project (recommended)

1. Xcode → **File → New → Project → iOS → App**
2. Product Name: `DailyExpense`, Interface: **SwiftUI**, Language: **Swift**, minimum **iOS 17**
3. Save inside this folder
4. Delete template `ContentView.swift`
5. Drag the `DailyExpense` folder into the project (Copy items, Create groups)
6. Add **PrivacyInfo.xcprivacy** to the target (Build Phases → Copy Bundle Resources if needed)
7. In target **Info**, add key: **Privacy - Notifications Usage Description**  
   `Daily Expense sends your evening spending summary at the time you set in Settings.`
8. Entry point: `DailyExpenseApp.swift` (`@main`)
9. **Product → Run** (⌘R)

### Option B — XcodeGen (on Mac)

```bash
brew install xcodegen
cd /path/to/expence_manage
xcodegen generate
open DailyExpense.xcodeproj
```

---

## Features

### Onboarding (first launch)
- **4-screen walkthrough** aligned with the [Figma design system](https://www.figma.com/design/4zxKTpdb6MGqaQHnA8FdJt/Daily-Expense---iOS-App) (teal/violet gradients, emoji hero cards)
- Explains: start at **0 transactions**, track income & expenses, **2-month** week-wise retention, **bedtime** notifications
- Optional name for the Home greeting · Skip or Get Started

### Transactions
- App launches with **no transactions** (no demo data in Release or Debug)
- **Income** and **expenses** accumulate from the first entry (“since you started” totals in All Transactions)
- **Edit** and **delete** any transaction (Home long-press / tap, or All Transactions swipe + edit sheet)
- **All Transactions** list with sort by **price** or **date**

### Data retention
- Stores at most **2 months** of history
- Organized **month → week** in All Transactions, Financial Report (This Month), and Settings
- Older transactions are **removed automatically** on app open and after each save
- Policy shown in onboarding, Settings, and transaction list

### Bedtime notifications
- Daily **local notification** at bedtime (Settings → **Bedtime Reminder**, default **8:00 PM**)
- Notification title includes configured time (or default until user changes the picker)
- **Tap notification** → full-day summary with every income/expense line, **sorted by amount** (highest first)

### Reports & insights
- Daily **expenses** and **income** (Salary, Bonus, Freelance, etc.)
- **Net balance** on Home
- **Bedtime summary** screen (same content as notification deep link)
- **Weekly insights** — top category + week-over-week text
- **Financial report** — Today / This Week / This Month with quick stats
- **8 expense** + **6 income** default tags
- **Animations**: spring tag chips, staggered home cards, animated progress bars, FAB pulse (disabled when Reduce Motion is on)
- **Persistence**: JSON in Application Support with **file protection**
- **Security**: amount limits, note sanitization, no network in v1.0

---

## iOS quality checklist (implemented)

### Security & privacy

- [x] Data stored only on device (`Application Support/DailyExpense/state.json`)
- [x] Writes use `.completeFileProtection`
- [x] Amount capped (`InputValidator.maxAmount`), notes length-limited and control characters stripped
- [x] No API keys, analytics, or third-party SDKs in v1.0
- [x] `PrivacyInfo.xcprivacy` (no tracking, no collected data types)
- [x] Fresh install starts with **0 transactions** (no demo seed)

### Permissions

- [x] **Notifications** — requested only when user enables the toggle in Settings
- [x] `NSUserNotificationsUsageDescription` in `project.yml` / Info.plist
- [x] Deep link to iOS Settings if user denies permission
- [x] No camera, location, contacts, or photo library (not needed)

### Performance

- [x] Shared `NumberFormatter` / `DateFormatter` instances (`MoneyFormat`)
- [x] Debounced save (350 ms) to avoid disk writes on every keystroke
- [x] Lists limited on Home (`prefix(8)`)
- [x] `Decimal` for money (avoids floating-point errors)

### Memory & architecture

- [x] `@MainActor` on `ExpenseStore` (UI-bound state)
- [x] Value types for models (`struct`)
- [x] `ObservableObject` + `@EnvironmentObject` (single store, no duplicate sources of truth)
- [x] Weak cancellation of persist/notification `Task`s on new changes

### Accessibility & UX

- [x] FAB accessibility label + hint
- [x] Respects **Reduce Motion** (`accessibilityReduceMotion`)
- [x] Primary buttons scale feedback
- [x] Display name for greeting (Settings)

### App Store readiness (when you ship)

- [ ] App icons & launch screen in Assets
- [ ] Screenshots for App Store Connect
- [ ] Test on a physical iPhone (notifications behave differently than Simulator)
- [ ] Archive → Validate → Distribute (Apple Developer account required)

---

## Project structure

```
DailyExpense/
├── DailyExpenseApp.swift          # @main, notification delegate
├── PrivacyInfo.xcprivacy
├── Theme/AppTheme.swift
├── Models/Transaction.swift       # Transaction, AppSettings, MonthArchive
├── Services/
│   ├── ExpenseStore.swift           # CRUD, 2-month prune, week archives
│   ├── PersistenceService.swift
│   ├── NotificationScheduler.swift
│   └── AppNotificationHandler.swift
├── Utilities/
│   ├── Formatters.swift
│   ├── InputValidator.swift
│   └── AppAnimations.swift
├── Components/SharedComponents.swift
└── Views/
    ├── Onboarding/OnboardingView.swift
    ├── Root/RootView.swift
    ├── Transactions/TransactionListView.swift, EditTransactionView.swift
    └── ...
```

---

## Figma screens

| Screen | Node ID |
|--------|---------|
| Home | `6:2` |
| Add Expense | `5:2` |
| Evening Report / Bedtime summary | `7:2` |
| Settings | `8:2` |
| Onboarding (4 pages) | In-app · matches Figma tokens |
| Add Income | `13:2` |
| Weekly Insights | `14:2` |
| Financial Report | `16:2` |

---

## Next steps (optional)

- Core Data or SwiftData for large histories
- Export CSV / PDF (Settings placeholders)
- Custom tags UI
- WidgetKit home-screen summary
- Sign in with Apple + iCloud sync (only if you need multi-device)

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Build errors on Windows | Expected — open project on Mac in Xcode |
| Notifications not firing | Enable toggle in app, then check **Settings → Notifications → Daily Expense** |
| Empty Home after first install | Expected — add income or expense with + |
| Onboarding shows again | `hasCompletedOnboarding` in `state.json`; complete onboarding once |
| Old transactions missing | Only last **2 months** kept by design |
| Strict concurrency warnings | In Xcode target, set **Swift Concurrency Checking** to `Minimal` if needed |

---

Daily Expense v1.0 · Local-first personal finance tracker
