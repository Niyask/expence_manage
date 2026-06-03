import Foundation
import SwiftUI

@MainActor
final class ExpenseStore: ObservableObject {
    static let maxRetentionMonths = 2

    @Published var transactions: [Transaction] = [] {
        didSet { schedulePersist() }
    }
    @Published var tags: [ExpenseTag] = ExpenseStore.defaultTags {
        didSet { schedulePersist() }
    }
    @Published var settings = AppSettings() {
        didSet {
            schedulePersist()
            scheduleNotifications()
        }
    }
    @Published var pendingEveningReportDate: Date?

    private var persistTask: Task<Void, Never>?
    private var notificationTask: Task<Void, Never>?
    /// Prevents saving empty in-memory state over an existing file when load fails.
    private var persistenceWritesEnabled = false

    static let defaultTags: [ExpenseTag] = [
        ExpenseTag(name: "Petrol", emoji: "⛽", color: Color(red: 0.976, green: 0.451, blue: 0.086), type: .expense),
        ExpenseTag(name: "Grocery", emoji: "🛒", color: Color(red: 0.133, green: 0.773, blue: 0.369), type: .expense),
        ExpenseTag(name: "Food", emoji: "🍔", color: Color(red: 0.984, green: 0.749, blue: 0.141), type: .expense),
        ExpenseTag(name: "Transport", emoji: "🚌", color: Color(red: 0.231, green: 0.51, blue: 0.965), type: .expense),
        ExpenseTag(name: "Bills", emoji: "📄", color: Color(red: 0.545, green: 0.361, blue: 0.965), type: .expense),
        ExpenseTag(name: "Entertainment", emoji: "🎬", color: Color(red: 0.925, green: 0.282, blue: 0.6), type: .expense),
        ExpenseTag(name: "Health", emoji: "💊", color: Color(red: 0.078, green: 0.722, blue: 0.651), type: .expense),
        ExpenseTag(name: "Shopping", emoji: "🛍️", color: Color(red: 0.388, green: 0.4, blue: 0.945), type: .expense),
        ExpenseTag(name: "Salary", emoji: "💼", color: AppTheme.income, type: .income),
        ExpenseTag(name: "Bonus", emoji: "🎁", color: Color(red: 0.133, green: 0.773, blue: 0.369), type: .income),
        ExpenseTag(name: "Freelance", emoji: "💻", color: Color(red: 0.231, green: 0.51, blue: 0.965), type: .income),
        ExpenseTag(name: "Investment", emoji: "📈", color: Color(red: 0.545, green: 0.361, blue: 0.965), type: .income),
        ExpenseTag(name: "Refund", emoji: "↩️", color: Color(red: 0.961, green: 0.62, blue: 0.043), type: .income),
        ExpenseTag(name: "Other", emoji: "💰", color: AppTheme.primary, type: .income),
    ]

    init() {
        loadPersistedState()
        // Existing installs that already have transactions skip the welcome tour once.
        if !settings.hasCompletedOnboarding, !transactions.isEmpty {
            var next = settings
            next.hasCompletedOnboarding = true
            settings = next
        }
        pruneOldTransactions()
        scheduleNotifications()
    }

    func completeOnboarding(displayName: String = "") {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        var next = settings
        if !trimmed.isEmpty {
            next.displayName = trimmed
        }
        next.hasCompletedOnboarding = true
        settings = next
    }

    /// Show onboarding again (Settings → Replay onboarding).
    func resetOnboarding() {
        var next = settings
        next.hasCompletedOnboarding = false
        settings = next
    }

    func tag(for id: UUID) -> ExpenseTag? {
        tags.first { $0.id == id }
    }

    func tags(for type: TransactionType) -> [ExpenseTag] {
        tags.filter { $0.type == type }
    }

    var expenseTagCount: Int { tags.filter { $0.type == .expense }.count }
    var incomeTagCount: Int { tags.filter { $0.type == .income }.count }

    var lifetimeIncome: Decimal {
        transactions.filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    var lifetimeExpenses: Decimal {
        transactions.filter { $0.type == .expense }.reduce(0) { $0 + $1.amount }
    }

    var lifetimeNetBalance: Decimal {
        lifetimeIncome - lifetimeExpenses
    }

    /// Expenses in the calendar week containing `date` (used for week-only insights).
    func expenseTotalThisWeek(containing date: Date = Date(), calendar: Calendar = .current) -> Decimal {
        guard let interval = weekInterval(containing: date, calendar: calendar) else { return 0 }
        return expenseTotal(in: interval)
    }

    @discardableResult
    func addTransaction(amount: Decimal, tag: ExpenseTag, note: String, date: Date, type: TransactionType) -> Bool {
        guard amount > 0, amount <= InputValidator.maxAmount else { return false }
        transactions.insert(
            Transaction(
                amount: amount,
                tagId: tag.id,
                note: InputValidator.sanitizeNote(note),
                date: date,
                type: type
            ),
            at: 0
        )
        pruneOldTransactions()
        return true
    }

    @discardableResult
    func updateTransaction(
        id: UUID,
        amount: Decimal,
        tag: ExpenseTag,
        note: String,
        date: Date,
        type: TransactionType
    ) -> Bool {
        guard amount > 0, amount <= InputValidator.maxAmount,
              let index = transactions.firstIndex(where: { $0.id == id }) else { return false }
        transactions[index].amount = amount
        transactions[index].tagId = tag.id
        transactions[index].note = InputValidator.sanitizeNote(note)
        transactions[index].date = date
        transactions[index].type = type
        pruneOldTransactions()
        return true
    }

    func deleteTransaction(id: UUID) {
        transactions.removeAll { $0.id == id }
    }

    func transaction(id: UUID) -> Transaction? {
        transactions.first { $0.id == id }
    }

    func transactions(on date: Date, calendar: Calendar = .current) -> [Transaction] {
        transactions.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }

    func transactions(on date: Date, sortedByPrice: Bool) -> [Transaction] {
        let day = transactions(on: date)
        if sortedByPrice {
            return day.sorted {
                MoneyFormat.decimalValue($0.amount) > MoneyFormat.decimalValue($1.amount)
            }
        }
        return day.sorted { $0.date > $1.date }
    }

    func total(for type: TransactionType, on date: Date) -> Decimal {
        transactions(on: date)
            .filter { $0.type == type }
            .reduce(0) { $0 + $1.amount }
    }

    func netBalance(on date: Date) -> Decimal {
        total(for: .income, on: date) - total(for: .expense, on: date)
    }

    func weekInterval(containing date: Date, calendar: Calendar = .current) -> DateInterval? {
        calendar.dateInterval(of: .weekOfYear, for: date)
    }

    func transactions(in interval: DateInterval) -> [Transaction] {
        transactions.filter { interval.contains($0.date) }
    }

    func expenseTotal(in interval: DateInterval) -> Decimal {
        transactions(in: interval)
            .filter { $0.type == .expense }
            .reduce(0) { $0 + $1.amount }
    }

    func retentionStartDate(calendar: Calendar = .current) -> Date {
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .month, value: -Self.maxRetentionMonths, to: today) ?? today
    }

    func pruneOldTransactions(calendar: Calendar = .current) {
        let cutoff = retentionStartDate(calendar: calendar)
        let pruned = transactions.filter { $0.date < cutoff }
        guard !pruned.isEmpty else { return }
        transactions.removeAll { $0.date < cutoff }
    }

    func monthArchives(calendar: Calendar = .current) -> [MonthArchive] {
        let cutoff = retentionStartDate(calendar: calendar)
        let retained = transactions.filter { $0.date >= cutoff }
        guard !retained.isEmpty else { return [] }

        let formatter = DateFormatter()
        formatter.locale = Locale.current

        var monthKeys: [String] = []
        for tx in retained.sorted(by: { $0.date > $1.date }) {
            let comps = calendar.dateComponents([.year, .month], from: tx.date)
            let key = "\(comps.year ?? 0)-\(comps.month ?? 0)"
            if !monthKeys.contains(key) { monthKeys.append(key) }
        }

        return monthKeys.compactMap { key -> MonthArchive? in
            let parts = key.split(separator: "-")
            guard parts.count == 2,
                  let year = Int(parts[0]),
                  let month = Int(parts[1]),
                  let monthStart = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
                  let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart) else {
                return nil
            }

            let monthInterval = DateInterval(start: monthStart, end: monthEnd)
            let monthTx = retained.filter { monthInterval.contains($0.date) }
            guard !monthTx.isEmpty else { return nil }

            formatter.dateFormat = "MMMM yyyy"
            let title = formatter.string(from: monthStart)

            var weekStarts: [Date] = []
            for tx in monthTx {
                guard let week = weekInterval(containing: tx.date, calendar: calendar)?.start else { continue }
                if !weekStarts.contains(week) { weekStarts.append(week) }
            }
            weekStarts.sort(by: >)

            let weeks: [WeekArchive] = weekStarts.compactMap { weekStart in
                guard let interval = weekInterval(containing: weekStart, calendar: calendar) else { return nil }
                let weekTx = monthTx.filter { interval.contains($0.date) }
                guard !weekTx.isEmpty else { return nil }

                formatter.dateFormat = "'Week' w · MMM d"
                let label = formatter.string(from: interval.start)

                let income = weekTx.filter { $0.type == .income }.reduce(Decimal(0)) { $0 + $1.amount }
                let expense = weekTx.filter { $0.type == .expense }.reduce(Decimal(0)) { $0 + $1.amount }
                let weekKey = "\(key)-\(calendar.component(.weekOfYear, from: interval.start))"

                return WeekArchive(
                    id: weekKey,
                    label: label,
                    interval: interval,
                    income: income,
                    expense: expense,
                    transactionCount: weekTx.count
                )
            }

            let income = monthTx.filter { $0.type == .income }.reduce(Decimal(0)) { $0 + $1.amount }
            let expense = monthTx.filter { $0.type == .expense }.reduce(Decimal(0)) { $0 + $1.amount }

            return MonthArchive(
                id: key,
                title: title,
                weeks: weeks,
                income: income,
                expense: expense
            )
        }
    }

    struct CategorySpend: Identifiable {
        let id: UUID
        let tag: ExpenseTag
        let amount: Decimal
        let percentage: Double
    }

    func categoryBreakdown(in interval: DateInterval) -> [CategorySpend] {
        let expenses = transactions(in: interval).filter { $0.type == .expense }
        let total = expenses.reduce(Decimal(0)) { $0 + $1.amount }
        guard total > 0 else { return [] }

        var grouped: [UUID: Decimal] = [:]
        for tx in expenses {
            grouped[tx.tagId, default: 0] += tx.amount
        }

        return grouped.compactMap { tagId, amount -> CategorySpend? in
            guard let tag = tag(for: tagId) else { return nil }
            let pct = MoneyFormat.ratio(amount, of: total) * 100
            return CategorySpend(id: tagId, tag: tag, amount: amount, percentage: pct)
        }
        .sorted { MoneyFormat.decimalValue($0.amount) > MoneyFormat.decimalValue($1.amount) }
    }

    func topExpenseCategory(in interval: DateInterval) -> CategorySpend? {
        categoryBreakdown(in: interval).first
    }

    func weekOverWeekInsight(for date: Date, calendar: Calendar = .current) -> String? {
        guard settings.weeklyInsightsEnabled else { return nil }
        guard let current = weekInterval(containing: date, calendar: calendar),
              let previousStart = calendar.date(byAdding: .weekOfYear, value: -1, to: current.start),
              let previous = weekInterval(containing: previousStart, calendar: calendar) else {
            return nil
        }

        let currentTop = topExpenseCategory(in: current)
        let previousTop = topExpenseCategory(in: previous)
        guard let currentTop, let previousTop, currentTop.tag.id == previousTop.tag.id else {
            if let currentTop {
                return "\(currentTop.tag.name) is your top spend this week"
            }
            return nil
        }

        let prevAmt = MoneyFormat.decimalValue(previousTop.amount)
        let currAmt = MoneyFormat.decimalValue(currentTop.amount)
        guard prevAmt > 0 else { return nil }
        let change = ((currAmt - prevAmt) / prevAmt) * 100
        let direction = change >= 0 ? "up" : "down"
        return "\(currentTop.tag.name) \(direction) \(Int(abs(change)))% vs last week"
    }

    func requestNotificationPermission() async -> Bool {
        await NotificationScheduler.shared.requestAuthorization()
    }

    func refreshNotificationSchedule() async {
        await NotificationScheduler.shared.scheduleBedtimeReport(
            hour: settings.eveningReportHour,
            minute: settings.eveningReportMinute,
            bedtimeLabel: settings.bedtimeTimeLabel,
            enabled: settings.notificationsEnabled
        )
    }

    func openEveningReport(for date: Date = Date()) {
        pendingEveningReportDate = date
    }

    // MARK: - Persistence

    private func loadPersistedState() {
        switch PersistenceService.shared.loadWithRecovery() {
        case .loaded(let state):
            transactions = state.transactions
            if !state.tags.isEmpty { tags = state.tags }
            settings = state.settings
            persistenceWritesEnabled = true
        case .freshInstall:
            persistenceWritesEnabled = true
        case .corruptFileOnDisk:
            #if DEBUG
            print("[ExpenseStore] Persisted file exists but could not be loaded; skipping writes to avoid data loss")
            #endif
            persistenceWritesEnabled = false
        }
    }

    private func schedulePersist() {
        guard persistenceWritesEnabled else { return }
        persistTask?.cancel()
        let snapshot = PersistenceService.PersistedState(
            transactions: transactions,
            tags: tags,
            settings: settings
        )
        persistTask = Task { [snapshot] in
            try? await Task.sleep(for: .milliseconds(350))
            guard !Task.isCancelled else { return }
            PersistenceService.shared.save(snapshot)
        }
    }

    private func scheduleNotifications() {
        notificationTask?.cancel()
        notificationTask = Task {
            try? await Task.sleep(for: .milliseconds(100))
            await refreshNotificationSchedule()
        }
    }
}
