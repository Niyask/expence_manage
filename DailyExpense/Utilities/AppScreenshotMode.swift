import Foundation

/// Launch the app with `-ScreenshotScreen <name>` to show a fixed screen with sample data (for App Store captures).
enum AppScreenshotScreen: String {
    case onboarding
    case home
    case report
    case settings
    case addExpense
    case transactions

    static func fromProcessArguments() -> AppScreenshotScreen? {
        let args = ProcessInfo.processInfo.arguments
        guard let index = args.firstIndex(of: "-ScreenshotScreen"),
              args.index(after: index) < args.endIndex else { return nil }
        return AppScreenshotScreen(rawValue: args[args.index(after: index)])
    }

    static var isActive: Bool { fromProcessArguments() != nil }
}

enum SampleDataSeeder {
    static func makePersistedState() -> PersistenceService.PersistedState {
        let tags = ExpenseStore.defaultTags
        func tag(named name: String) -> ExpenseTag {
            tags.first { $0.name == name } ?? tags[0]
        }

        var settings = AppSettings()
        settings.displayName = "Niyas"
        settings.hasCompletedOnboarding = true
        settings.hasConfiguredBedtime = true
        settings.currencyCode = "USD"
        settings.appearance = .light

        let calendar = Calendar.current
        let now = Date()
        let day = { (offset: Int) -> Date in
            calendar.date(byAdding: .day, value: offset, to: now) ?? now
        }

        let transactions: [Transaction] = [
            Transaction(amount: 4_500, tagId: tag(named: "Salary").id, note: "Monthly salary", date: day(-3), type: .income),
            Transaction(amount: 320, tagId: tag(named: "Freelance").id, note: "Design project", date: day(-5), type: .income),
            Transaction(amount: 68.50, tagId: tag(named: "Petrol").id, note: "Fuel", date: day(-1), type: .expense),
            Transaction(amount: 124.30, tagId: tag(named: "Grocery").id, note: "Weekly shop", date: day(-1), type: .expense),
            Transaction(amount: 42, tagId: tag(named: "Food").id, note: "Lunch", date: day(0), type: .expense),
            Transaction(amount: 18.99, tagId: tag(named: "Transport").id, note: "Metro", date: day(-2), type: .expense),
            Transaction(amount: 89, tagId: tag(named: "Bills").id, note: "Internet", date: day(-4), type: .expense),
            Transaction(amount: 35, tagId: tag(named: "Entertainment").id, note: "Streaming", date: day(-6), type: .expense),
        ]

        return PersistenceService.PersistedState(
            transactions: transactions,
            tags: tags,
            settings: settings
        )
    }

    static func makeOnboardingState() -> PersistenceService.PersistedState {
        var settings = AppSettings()
        settings.hasCompletedOnboarding = false
        return PersistenceService.PersistedState(
            transactions: [],
            tags: ExpenseStore.defaultTags,
            settings: settings
        )
    }
}
