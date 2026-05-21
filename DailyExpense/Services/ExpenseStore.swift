import Foundation
import SwiftUI

@MainActor
final class ExpenseStore: ObservableObject {
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

    private var persistTask: Task<Void, Never>?
    private var notificationTask: Task<Void, Never>?

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
        #if DEBUG
        seedDemoDataIfEmpty()
        #endif
        scheduleNotifications()
    }

    func tag(for id: UUID) -> ExpenseTag? {
        tags.first { $0.id == id }
    }

    func tags(for type: TransactionType) -> [ExpenseTag] {
        tags.filter { $0.type == type }
    }

    var expenseTagCount: Int { tags.filter { $0.type == .expense }.count }
    var incomeTagCount: Int { tags.filter { $0.type == .income }.count }

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
        return true
    }

    func transactions(on date: Date, calendar: Calendar = .current) -> [Transaction] {
        transactions.filter { calendar.isDate($0.date, inSameDayAs: date) }
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
        await NotificationScheduler.shared.scheduleEveningReport(
            hour: settings.eveningReportHour,
            minute: settings.eveningReportMinute,
            enabled: settings.notificationsEnabled
        )
    }

    // MARK: - Persistence

    private func loadPersistedState() {
        guard let state = PersistenceService.shared.load() else { return }
        transactions = state.transactions
        if !state.tags.isEmpty { tags = state.tags }
        settings = state.settings
    }

    private func schedulePersist() {
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

    #if DEBUG
    private func seedDemoDataIfEmpty() {
        guard transactions.isEmpty else { return }
        let calendar = Calendar.current
        let today = Date()
        guard
            let salary = tags.first(where: { $0.name == "Salary" }),
            let petrol = tags.first(where: { $0.name == "Petrol" }),
            let grocery = tags.first(where: { $0.name == "Grocery" })
        else { return }

        _ = addTransaction(amount: 45_000, tag: salary, note: "May salary", date: today, type: .income)
        _ = addTransaction(
            amount: 850,
            tag: petrol,
            note: "Petrol Station",
            date: calendar.date(bySettingHour: 9, minute: 30, second: 0, of: today) ?? today,
            type: .expense
        )
        _ = addTransaction(
            amount: 1_200,
            tag: grocery,
            note: "Big Bazaar",
            date: calendar.date(bySettingHour: 14, minute: 15, second: 0, of: today) ?? today,
            type: .expense
        )
    }
    #endif
}
