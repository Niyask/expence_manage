# Build validation checklist

Run before every Codemagic / Xcode build.

## 1. Generate Xcode project

```bash
brew install xcodegen   # once
xcodegen generate
```

## 2. Build in Xcode

1. Open `DailyExpense.xcodeproj`
2. Select scheme **DailyExpense**
3. **Product → Clean Build Folder** (⇧⌘K)
4. **Product → Build** (⌘B)

All targets should compile with **0 errors**.

## 3. Automated checks (optional)

From repo root:

```powershell
# Brace balance + no old theme APIs
$errors = @()
Get-ChildItem -Path "DailyExpense" -Filter "*.swift" -Recurse | ForEach-Object {
  $c = Get-Content $_.FullName -Raw
  if (([regex]::Matches($c, '\{')).Count -ne ([regex]::Matches($c, '\}')).Count) {
    $errors += "BRACE: $($_.Name)"
  }
}
if ($errors) { $errors } else { "OK" }
```

## 4. Regression test (manual)

See the QA screen list in chat — test **Light** and **Dark** in Settings → Appearance.

## 5. Codemagic

Workflow `daily-expense-testflight` runs:

- `xcodegen generate`
- `xcode-project build-ipa`

Push only after local build succeeds.
