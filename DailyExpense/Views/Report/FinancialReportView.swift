import SwiftUI

struct FinancialReportView: View {
    @EnvironmentObject private var store: ExpenseStore
    @State private var period: ReportPeriod = .week
    @State private var showWeekly = false

    enum ReportPeriod: String, CaseIterable {
        case today = "Today"
        case week = "This Week"
        case month = "This Month"
    }

    private var interval: DateInterval {
        let cal = Calendar.current
        let now = Date()
        switch period {
        case .today:
            let start = cal.startOfDay(for: now)
            return DateInterval(start: start, end: cal.date(byAdding: .day, value: 1, to: start) ?? now)
        case .week:
            return store.weekInterval(containing: now, calendar: cal) ?? DateInterval(start: now, duration: 0)
        case .month:
            return cal.dateInterval(of: .month, for: now) ?? DateInterval(start: now, duration: 0)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Financial Report")
                        .font(.appTitle())
                        .foregroundStyle(AppTheme.textPrimary)

                    periodPicker

                    quickStatsRow
                        .animation(AppAnimations.cardSpring, value: period)

                    netBalanceCard
                        .animation(AppAnimations.cardSpring, value: period)

                    HStack(spacing: 12) {
                        splitCard(title: "↑ Income", amount: incomeTotal, color: AppTheme.income)
                        splitCard(title: "↓ Expenses", amount: expenseTotal, color: AppTheme.expense)
                    }

                    spendingOverviewCard

                    incomeSection

                    expenseSection

                    if period == .month {
                        monthWeekHistoryCard
                    }

                    savingsTipCard

                    weeklyLinkButton
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .background(AppTheme.background)
            .navigationBarHidden(true)
            .navigationDestination(isPresented: $showWeekly) {
                WeeklyInsightsView()
            }
        }
    }

    // MARK: - Period tabs

    private var periodPicker: some View {
        HStack(spacing: 8) {
            ForEach(ReportPeriod.allCases, id: \.self) { p in
                Button {
                    withAnimation(AppAnimations.tabEase) { period = p }
                } label: {
                    Text(p.rawValue)
                        .font(.system(size: 12, weight: period == p ? .semibold : .regular))
                        .foregroundStyle(period == p ? .white : AppTheme.textSecondary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 9)
                        .background(
                            period == p ? AppTheme.primary : Color.white,
                            in: Capsule()
                        )
                        .overlay(
                            Capsule()
                                .stroke(Color(red: 0.9, green: 0.91, blue: 0.92), lineWidth: period == p ? 0 : 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Quick stats (fills blank after time tabs)

    private var quickStatsRow: some View {
        HStack(spacing: 0) {
            statCell(value: "\(transactionCount)", label: "Transactions")
            Divider().frame(height: 32)
            statCell(value: MoneyFormat.string(averageDailySpend, symbol: store.settings.currencySymbol), label: "Avg / day")
            Divider().frame(height: 32)
            statCell(value: "\(savingsPercent)%", label: "Saved")
        }
        .padding(.vertical, 12)
        .background(.white, in: RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private func statCell(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(AppTheme.primary)
            Text(label)
                .font(.appSmall())
                .foregroundStyle(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var transactionCount: Int {
        store.transactions(in: interval).count
    }

    private var averageDailySpend: Decimal {
        let expenses = expenseTotal
        let days: Decimal
        switch period {
        case .today: days = 1
        case .week: days = 7
        case .month: days = 30
        }
        guard days > 0 else { return 0 }
        return expenses / days
    }

    private var savingsPercent: Int {
        let income = MoneyFormat.decimalValue(incomeTotal)
        let net = MoneyFormat.decimalValue(incomeTotal - expenseTotal)
        guard income > 0 else { return 0 }
        return max(0, Int((net / income) * 100))
    }

    // MARK: - Net balance

    private var netBalanceCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Net Balance (\(period.rawValue))")
                .font(.appCaption())
                .foregroundStyle(.white.opacity(0.85))
            Text(MoneyFormat.string(incomeTotal - expenseTotal, symbol: store.settings.currencySymbol, signed: true))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)
            Text("Income \(MoneyFormat.string(incomeTotal, symbol: store.settings.currencySymbol))  −  Expenses \(MoneyFormat.string(expenseTotal, symbol: store.settings.currencySymbol))")
                .font(.appSmall())
                .foregroundStyle(.white.opacity(0.8))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.incomeGradient, in: RoundedRectangle(cornerRadius: 22))
        .shadow(color: AppTheme.primary.opacity(0.25), radius: 12, y: 6)
    }

    private var incomeTotal: Decimal {
        store.transactions(in: interval).filter { $0.type == .income }.reduce(0) { $0 + $1.amount }
    }

    private var expenseTotal: Decimal {
        store.expenseTotal(in: interval)
    }

    private func splitCard(title: String, amount: Decimal, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.appCaption())
                .foregroundStyle(color)
            Text(MoneyFormat.string(amount, symbol: store.settings.currencySymbol))
                .font(.system(size: 22, weight: .bold))
                .foregroundStyle(color)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Spending overview (fills middle gap)

    private var spendingOverviewCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Spending Overview")
                .font(.appSubheadline())
                .foregroundStyle(AppTheme.textPrimary)

            if categoryBreakdown.isEmpty {
                Text("No expenses in this period")
                    .font(.appCaption())
                    .foregroundStyle(AppTheme.textSecondary)
            } else {
                ForEach(categoryBreakdown.prefix(3)) { item in
                    HStack(spacing: 8) {
                        Text("\(item.tag.name) \(Int(item.percentage))%")
                            .font(.appSmall())
                            .foregroundStyle(AppTheme.textSecondary)
                            .frame(width: 90, alignment: .leading)
                        AnimatedProgressBar(
                            progress: CGFloat(item.percentage / 100),
                            color: item.tag.color
                        )
                        .frame(height: 5)
                    }
                    .frame(height: 18)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private var categoryBreakdown: [ExpenseStore.CategorySpend] {
        store.categoryBreakdown(in: interval)
    }

    // MARK: - Lists

    private var incomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Income Sources")
                .font(.appSubheadline())
            if incomeBreakdown.isEmpty {
                emptyRow(message: "No income recorded")
            } else {
                ForEach(incomeBreakdown, id: \.tag.id) { item in
                    reportRow(emoji: item.tag.emoji, title: item.tag.name, amount: item.amount, color: AppTheme.income)
                }
            }
        }
    }

    private var expenseSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Top Expenses \(period == .today ? "Today" : period.rawValue)")
                .font(.appSubheadline())
            if categoryBreakdown.isEmpty {
                emptyRow(message: "No expenses recorded")
            } else {
                ForEach(categoryBreakdown) { item in
                    reportRow(
                        emoji: item.tag.emoji,
                        title: "\(item.tag.name) · \(Int(item.percentage))%",
                        amount: item.amount,
                        color: AppTheme.expense
                    )
                }
            }
        }
    }

    private var incomeBreakdown: [ExpenseStore.CategorySpend] {
        let income = store.transactions(in: interval).filter { $0.type == .income }
        let total = income.reduce(Decimal(0)) { $0 + $1.amount }
        guard total > 0 else { return [] }
        var grouped: [UUID: Decimal] = [:]
        for tx in income { grouped[tx.tagId, default: 0] += tx.amount }
        return grouped.compactMap { id, amt in
            guard let tag = store.tag(for: id) else { return nil }
            let pct = MoneyFormat.ratio(amt, of: total) * 100
            return ExpenseStore.CategorySpend(id: id, tag: tag, amount: amt, percentage: pct)
        }
    }

    private func reportRow(emoji: String, title: String, amount: Decimal, color: Color) -> some View {
        HStack(spacing: 12) {
            Text(emoji)
                .font(.system(size: 18))
                .frame(width: 28)
            Text(title)
                .font(.appBody())
                .foregroundStyle(AppTheme.textPrimary)
            Spacer()
            Text(MoneyFormat.string(amount, symbol: store.settings.currencySymbol))
                .font(.appBody())
                .fontWeight(.bold)
                .foregroundStyle(color)
        }
        .padding(14)
        .background(.white, in: RoundedRectangle(cornerRadius: 12))
    }

    private func emptyRow(message: String) -> some View {
        Text(message)
            .font(.appCaption())
            .foregroundStyle(AppTheme.textSecondary)
            .frame(maxWidth: .infinity)
            .padding()
            .background(.white, in: RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Bottom cards

    private var savingsTipCard: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("💡")
            Text(savingsTipText)
                .font(.appCaption())
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private var savingsTipText: String {
        let pct = savingsPercent
        if pct >= 50 {
            return "You saved \(pct)% of income — great job!"
        }
        if expenseTotal > incomeTotal {
            return "Spending exceeded income by \(MoneyFormat.string(expenseTotal - incomeTotal, symbol: store.settings.currencySymbol))"
        }
        return "Track daily to improve your savings rate"
    }

    private var monthWeekHistoryCard: some View {
        let archives = store.monthArchives()
        return VStack(alignment: .leading, spacing: 10) {
            Text("This month · week by week")
                .font(.appSubheadline())
            if archives.isEmpty {
                Text("No data in the last \(ExpenseStore.maxRetentionMonths) months")
                    .font(.appCaption())
                    .foregroundStyle(AppTheme.textSecondary)
            } else if let current = archives.first {
                ForEach(current.weeks) { week in
                    HStack {
                        Text(week.label)
                            .font(.appCaption())
                        Spacer()
                        Text(MoneyFormat.string(week.net, symbol: store.settings.currencySymbol, signed: true))
                            .font(.appCaption())
                            .fontWeight(.semibold)
                            .foregroundStyle(week.net >= 0 ? AppTheme.income : AppTheme.expense)
                    }
                }
                Text("Data older than \(ExpenseStore.maxRetentionMonths) months is removed automatically.")
                    .font(.appSmall())
                    .foregroundStyle(AppTheme.textSecondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private var weeklyLinkButton: some View {
        Button { showWeekly = true } label: {
            Text("📊 View Weekly Breakdown →")
                .font(.appBody())
                .fontWeight(.semibold)
                .foregroundStyle(AppTheme.secondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(AppTheme.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}
