import SwiftUI

struct EveningReportView: View {
    @Environment(\.themePalette) private var palette
    @EnvironmentObject private var store: ExpenseStore
    let date: Date

    private var dayTransactions: [Transaction] {
        store.transactions(on: date, sortedByPrice: true)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 14) {
                header
                summaryRow
                transactionsSection
                categoryCard
            }
            .padding(.bottom, 24)
        }
        .background(palette.background)
        .navigationTitle("Bedtime Summary")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("🌙")
                .font(.system(size: 36))
            Text("Today's Summary")
                .font(.appTitle())
                .foregroundStyle(.white)
            Text(date, style: .date)
                .font(.appCaption())
                .foregroundStyle(.white.opacity(0.7))
            Text("Reminder at \(store.settings.bedtimeTimeLabel)")
                .font(.appSmall())
                .foregroundStyle(.white.opacity(0.65))
            Text(store.settings.formatMoney(store.netBalance(on: date), signed: true))
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.white)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.eveningHeaderGradient)
        .colorScheme(.dark)
    }

    private var summaryRow: some View {
        HStack {
            summaryCell("↑ Income", value: store.total(for: .income, on: date), color: AppTheme.income)
            summaryCell("↓ Expenses", value: store.total(for: .expense, on: date), color: AppTheme.expense)
            summaryCell("💰 Net", value: store.netBalance(on: date), color: AppTheme.secondary)
        }
        .padding(16)
        .appCardSurface(cornerRadius: 16)
        .padding(.horizontal, 24)
        .offset(y: -20)
    }

    private func summaryCell(_ title: String, value: Decimal, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.appSmall())
                .foregroundStyle(palette.textSecondary)
            Text(store.settings.formatMoney(value, signed: title.contains("Net")))
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("All transactions")
                    .font(.appHeadline())
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                Text("Sorted by price")
                    .font(.appSmall())
                    .foregroundStyle(palette.textSecondary)
            }
            .padding(.horizontal, 24)

            if dayTransactions.isEmpty {
                Text("No transactions today")
                    .font(.appCaption())
                    .foregroundStyle(palette.textSecondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .appCardSurface()
                    .padding(.horizontal, 24)
            } else {
                ForEach(dayTransactions) { tx in
                    if let tag = store.tag(for: tx.tagId) {
                        TransactionRow(
                            tag: tag,
                            title: tx.note.isEmpty ? tag.name : tx.note,
                            subtitle: MoneyFormat.time(tx.date),
                            amount: tx.amount,
                            currencySymbol: store.settings.currencyAmountPrefix,
                            currencyLocaleIdentifier: store.settings.currencyLocaleIdentifier,
                            currencyCode: store.settings.currencyCode,
                            isIncome: tx.type == .income
                        )
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
    }

    private var categoryCard: some View {
        let breakdown = store.categoryBreakdown(in: dayInterval)
        return Group {
            if !breakdown.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Expenses by category")
                        .font(.appSubheadline())
                        .foregroundStyle(palette.textPrimary)
                    ForEach(breakdown) { item in
                        HStack {
                            Text(item.tag.name)
                                .font(.appCaption())
                                .foregroundStyle(palette.textPrimary)
                            Spacer()
                            Text("\(Int(item.percentage))%")
                                .font(.appCaption())
                                .foregroundStyle(palette.textSecondary)
                        }
                        AnimatedProgressBar(
                            progress: CGFloat(item.percentage / 100),
                            color: item.tag.color
                        )
                    }
                }
                .padding(16)
                .appCardSurface(cornerRadius: 18)
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
