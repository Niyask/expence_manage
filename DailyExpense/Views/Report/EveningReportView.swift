import SwiftUI

struct EveningReportView: View {
    @EnvironmentObject private var store: ExpenseStore
    let date: Date

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                header
                summaryRow
                categoryCard
                breakdownList
            }
            .padding(.bottom, 24)
        }
        .background(AppTheme.background)
        .navigationTitle("Evening Report")
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🌙")
                .font(.system(size: 36))
            Text("Evening Report")
                .font(.appTitle())
                .foregroundStyle(.white)
            Text(date, style: .date)
                .font(.appCaption())
                .foregroundStyle(.white.opacity(0.7))
            Text(MoneyFormat.string(store.netBalance(on: date), symbol: store.settings.currencySymbol, signed: true))
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.eveningHeaderGradient)
    }

    private var summaryRow: some View {
        HStack {
            summaryCell("↑ Income", value: store.total(for: .income, on: date), color: AppTheme.income)
            summaryCell("↓ Expenses", value: store.total(for: .expense, on: date), color: AppTheme.expense)
            summaryCell("💰 Saved", value: store.netBalance(on: date), color: AppTheme.secondary)
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal, 24)
        .offset(y: -20)
    }

    private func summaryCell(_ title: String, value: Decimal, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.appSmall())
                .foregroundStyle(AppTheme.textSecondary)
            Text(MoneyFormat.string(value, symbol: store.settings.currencySymbol, signed: title.contains("Saved")))
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var categoryCard: some View {
        let breakdown = store.categoryBreakdown(in: dayInterval)
        return VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.appSubheadline())
            ForEach(breakdown) { item in
                HStack {
                    Text(item.tag.name)
                        .font(.appCaption())
                    Spacer()
                    Text("\(Int(item.percentage))%")
                        .font(.appCaption())
                        .foregroundStyle(AppTheme.textSecondary)
                }
                AnimatedProgressBar(
                    progress: CGFloat(item.percentage / 100),
                    color: item.tag.color
                )
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 18))
        .padding(.horizontal, 24)
    }

    private var breakdownList: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Breakdown")
                .font(.appHeadline())
                .padding(.horizontal, 24)
            ForEach(store.categoryBreakdown(in: dayInterval)) { item in
                TransactionRow(
                    tag: item.tag,
                    title: item.tag.name,
                    subtitle: "\(Int(item.percentage))% of today",
                    amount: item.amount,
                    currencySymbol: store.settings.currencySymbol,
                    isIncome: false
                )
                .padding(.horizontal, 24)
            }
        }
    }

    private var dayInterval: DateInterval {
        let cal = Calendar.current
        let start = cal.startOfDay(for: date)
        return DateInterval(start: start, end: cal.date(byAdding: .day, value: 1, to: start) ?? date)
    }
}
