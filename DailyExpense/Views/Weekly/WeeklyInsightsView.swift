import SwiftUI

struct WeeklyInsightsView: View {
    @Environment(\.themePalette) private var palette
    @EnvironmentObject private var store: ExpenseStore

    @State private var selectedWeekOffset = 0

    private var calendar: Calendar { Calendar.current }
    private var anchorDate: Date {
        calendar.date(byAdding: .weekOfYear, value: -selectedWeekOffset, to: Date()) ?? Date()
    }
    private var weekInterval: DateInterval? {
        store.weekInterval(containing: anchorDate, calendar: calendar)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                weekSelectorRow
                topSpenderSection
                categoryChartSection
                weekOverWeekSection
            }
            .padding(.horizontal, 24)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(palette.background)
        .navigationTitle("Weekly Insights")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Week pills (labels inside each pill — no floating text)

    private var weekSelectorRow: some View {
        HStack(spacing: 6) {
            ForEach(0..<4, id: \.self) { index in
                let offset = 3 - index
                WeekPill(
                    label: weekLabel(weeksAgo: offset),
                    isSelected: selectedWeekOffset == offset
                ) {
                    withAnimation(AppAnimations.cardSpring) {
                        selectedWeekOffset = offset
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func weekLabel(weeksAgo: Int) -> String {
        let date = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: Date()) ?? Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "W'w' MMM"
        return formatter.string(from: date)
    }

    // MARK: - Top spender

    @ViewBuilder
    private var topSpenderSection: some View {
        if let top = topCategory {
            VStack(alignment: .leading, spacing: 8) {
                Text("🏆 TOP SPEND THIS WEEK")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(AppTheme.accentOrange)

                Text("\(top.tag.emoji) \(top.tag.name)")
                    .font(.system(size: 26, weight: .bold))
                    .foregroundStyle(palette.textPrimary)

                Text("\(store.settings.formatMoney(top.amount)) · \(Int(top.percentage))% of weekly expenses")
                    .font(.appCaption())
                    .foregroundStyle(palette.textSecondary)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppTheme.accentOrange.opacity(0.1), in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(AppTheme.accentOrange.opacity(0.35), lineWidth: 1.5)
            )
            .transition(.opacity.combined(with: .scale(scale: 0.98)))
        }
    }

    private var topCategory: ExpenseStore.CategorySpend? {
        guard let interval = weekInterval else { return nil }
        return store.topExpenseCategory(in: interval)
    }

    // MARK: - Category bars (self-contained card)

    private var categoryChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending by Category")
                .font(.appSubheadline())
                .foregroundStyle(palette.textPrimary)

            if breakdown.isEmpty {
                Text("No expenses this week")
                    .font(.appCaption())
                    .foregroundStyle(palette.textSecondary)
            } else {
                ForEach(breakdown) { item in
                    CategoryBarRow(
                        name: item.tag.name,
                        amount: store.settings.formatMoney(item.amount),
                        color: item.tag.color,
                        progress: item.percentage / 100
                    )
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardSurface(cornerRadius: 18)
        .shadow(color: .black.opacity(palette.shadowOpacity), radius: 8, y: 4)
    }

    private var breakdown: [ExpenseStore.CategorySpend] {
        guard let interval = weekInterval else { return [] }
        return store.categoryBreakdown(in: interval)
    }

    // MARK: - Week over week (stacked sections — matches Figma 35:38)

    private var weekOverWeekSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Compared to last week")
                .font(.appCaption())
                .fontWeight(.semibold)
                .foregroundStyle(palette.textPrimary)
                .padding(.bottom, 10)

            insightBox
                .padding(.bottom, 14)

            Text("Total spending by week")
                .font(.appSmall())
                .foregroundStyle(palette.textSecondary)
                .padding(.bottom, 10)

            weeklyBarChart
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCardSurface(cornerRadius: 18)
        .shadow(color: .black.opacity(palette.shadowOpacity), radius: 8, y: 4)
    }

    private var insightBox: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("💡")
                .font(.system(size: 14))
            Text(weekInsight)
                .font(.appSmall())
                .fontWeight(.medium)
                .foregroundStyle(AppTheme.secondary)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 10))
    }

    private var weeklyBarChart: some View {
        HStack(alignment: .bottom, spacing: 0) {
            ForEach(weeklyTotals, id: \.label) { week in
                VStack(spacing: 6) {
                    Spacer(minLength: 0)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppTheme.primary)
                        .frame(width: 32, height: barHeight(for: week.amount))
                    Text(week.label)
                        .font(.system(size: 10))
                        .foregroundStyle(palette.textSecondary)
                }
                .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 56)
    }

    private func barHeight(for amount: Double) -> CGFloat {
        let maxVal = weeklyTotals.map(\.amount).max() ?? 1
        guard maxVal > 0 else { return 12 }
        return max(12, CGFloat(amount / maxVal) * 44)
    }

    private var weekInsight: String {
        guard let interval = weekInterval,
              let prevStart = calendar.date(byAdding: .weekOfYear, value: -1, to: interval.start),
              let prev = store.weekInterval(containing: prevStart, calendar: calendar),
              let top = store.topExpenseCategory(in: interval),
              let prevTop = store.topExpenseCategory(in: prev),
              top.tag.id == prevTop.tag.id else {
            if let top = store.topExpenseCategory(in: weekInterval ?? DateInterval(start: Date(), duration: 0)) {
                return "\(top.tag.name) is your top spend this week"
            }
            return "Add expenses to see weekly trends"
        }
        let prevVal = MoneyFormat.decimalValue(prevTop.amount)
        let currVal = MoneyFormat.decimalValue(top.amount)
        guard prevVal > 0 else { return "\(top.tag.name) is your top category" }
        let pct = Int(((currVal - prevVal) / prevVal) * 100)
        let dir = pct >= 0 ? "up" : "down"
        return "Grocery spending \(dir) \(abs(pct))% from last week"
    }

    private var weeklyTotals: [(label: String, amount: Double)] {
        (1...3).compactMap { weeksAgo in
            guard let date = calendar.date(byAdding: .weekOfYear, value: -weeksAgo, to: Date()),
                  let interval = store.weekInterval(containing: date, calendar: calendar) else {
                return nil
            }
            let total = MoneyFormat.decimalValue(store.expenseTotal(in: interval))
            let formatter = DateFormatter()
            formatter.dateFormat = "'W'w"
            return (formatter.string(from: date), total)
        }
    }
}

// MARK: - Subviews (isolated layout — prevents overlap)

private struct WeekPill: View {
    @Environment(\.themePalette) private var palette
    let label: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                .foregroundStyle(isSelected ? .white : palette.textPrimary)
                .frame(width: 80, height: 36)
                .background(
                    isSelected ? AppTheme.primary : palette.cardBackground,
                    in: Capsule()
                )
                .overlay(
                    Capsule()
                        .stroke(palette.cardStroke, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct CategoryBarRow: View {
    @Environment(\.themePalette) private var palette
    let name: String
    let amount: String
    let color: Color
    let progress: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(name)
                    .font(.appCaption())
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                Text(amount)
                    .font(.appCaption())
                    .fontWeight(.semibold)
                    .foregroundStyle(palette.textPrimary)
            }
            AnimatedProgressBar(progress: progress, color: color)
        }
        .frame(height: 34)
    }
}
