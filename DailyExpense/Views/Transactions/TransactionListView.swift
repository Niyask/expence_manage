import SwiftUI

struct TransactionListView: View {
    @Environment(\.themePalette) private var palette
    @EnvironmentObject private var store: ExpenseStore
    @EnvironmentObject private var themeContext: ThemeContext
    @State private var sortByPrice = true
    @State private var transactionToEdit: Transaction?
    @State private var showDeleteConfirm = false
    @State private var pendingDeleteId: UUID?

    private var sortedTransactions: [Transaction] {
        let list = store.transactions
        if sortByPrice {
            return list.sorted {
                MoneyFormat.decimalValue($0.amount) > MoneyFormat.decimalValue($1.amount)
            }
        }
        return list.sorted { $0.date > $1.date }
    }

    var body: some View {
        List {
            headerSection
            transactionsSection
            monthHistorySection
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .background(palette.background)
        .navigationTitle("All Transactions")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $transactionToEdit) { tx in
            EditTransactionView(transaction: tx)
                .environmentObject(store)
                .environmentObject(themeContext)
                .themedScreen(themeContext: themeContext)
                .appThemedRoot(appearance: store.settings.appearance)
        }
        .alert("Delete transaction?", isPresented: $showDeleteConfirm) {
            Button("Delete", role: .destructive) {
                if let id = pendingDeleteId {
                    store.deleteTransaction(id: id)
                }
                pendingDeleteId = nil
            }
            Button("Cancel", role: .cancel) {
                pendingDeleteId = nil
            }
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var headerSection: some View {
        Section {
            lifetimeSummaryCard
            retentionNotice
            sortToggle
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 24, bottom: 8, trailing: 24))
        .listRowSeparator(.hidden)
        .listRowBackground(Color.clear)
    }

    @ViewBuilder
    private var transactionsSection: some View {
        if sortedTransactions.isEmpty {
            Section {
                emptyState
            }
            .listRowInsets(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        } else {
            Section {
                ForEach(Array(sortedTransactions.enumerated()), id: \.element.id) { index, tx in
                    transactionRow(for: tx)
                        .staggeredAppear(index: index)
                        .transition(AppAnimations.listInsert)
                }
            }
            .animatedListBoundary(value: sortedTransactions.count)
        }
    }

    @ViewBuilder
    private func transactionRow(for tx: Transaction) -> some View {
        if let tag = store.tag(for: tx.tagId) {
            TransactionRow(
                tag: tag,
                title: tx.note.isEmpty ? tag.name : tx.note,
                subtitle: MoneyFormat.daySubtitle(tx.date),
                amount: tx.amount,
                currencySymbol: store.settings.currencyAmountPrefix,
                currencyLocaleIdentifier: store.settings.currencyLocaleIdentifier,
                currencyCode: store.settings.currencyCode,
                isIncome: tx.type == .income
            )
            .contentShape(Rectangle())
            .onTapGesture { transactionToEdit = tx }
            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                Button(role: .destructive) {
                    pendingDeleteId = tx.id
                    showDeleteConfirm = true
                } label: {
                    Label("Delete", systemImage: "trash")
                }
                Button {
                    transactionToEdit = tx
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                .tint(AppTheme.primary)
            }
            .listRowInsets(EdgeInsets(top: 4, leading: 24, bottom: 4, trailing: 24))
            .listRowSeparator(.hidden)
            .listRowBackground(Color.clear)
        }
    }

    private var lifetimeSummaryCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Since you started")
                .font(.appCaption())
                .foregroundStyle(.white.opacity(0.85))
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total income")
                        .font(.appSmall())
                        .foregroundStyle(.white.opacity(0.7))
                    Text(store.settings.formatMoney(store.lifetimeIncome))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(AppTheme.primaryLight)
                }
                Spacer()
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total expenses")
                        .font(.appSmall())
                        .foregroundStyle(.white.opacity(0.7))
                    Text(store.settings.formatMoney(store.lifetimeExpenses))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(red: 1, green: 0.85, blue: 0.85))
                }
            }
            Text("\(store.transactions.count) transactions recorded")
                .font(.appSmall())
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.summaryGradient, in: RoundedRectangle(cornerRadius: 20))
        .colorScheme(.dark)
    }

    private var retentionNotice: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("📦")
            Text("Only the last \(ExpenseStore.maxRetentionMonths) months are kept, organized week-by-week. Older entries are removed automatically.")
                .font(.appSmall())
                .foregroundStyle(palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .background(AppTheme.accentOrange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private var sortToggle: some View {
        Picker("Sort", selection: $sortByPrice) {
            Text("By price").tag(true)
            Text("By date").tag(false)
        }
        .pickerStyle(.segmented)
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Text("No transactions yet")
                .font(.appSubheadline())
                .foregroundStyle(palette.textPrimary)
            Text("Tap + on Home to add your first income or expense.")
                .font(.appCaption())
                .foregroundStyle(palette.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(32)
        .appCardSurface(cornerRadius: 16)
    }

    @ViewBuilder
    private var monthHistorySection: some View {
        let archives = store.monthArchives()
        if !archives.isEmpty {
            Section {
                ForEach(archives) { month in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(month.title)
                                .font(.appSubheadline())
                                .foregroundStyle(palette.textPrimary)
                            Spacer()
                            Text(store.settings.formatMoney(month.net, signed: true))
                                .font(.appCaption())
                                .fontWeight(.semibold)
                                .foregroundStyle(month.net >= 0 ? AppTheme.income : AppTheme.expense)
                        }

                        ForEach(month.weeks) { week in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(week.label)
                                        .font(.appCaption())
                                        .foregroundStyle(palette.textPrimary)
                                    Text("\(week.transactionCount) transactions")
                                        .font(.appSmall())
                                        .foregroundStyle(palette.textSecondary)
                                }
                                Spacer()
                                Text(store.settings.formatMoney(week.expense))
                                    .font(.appCaption())
                                    .fontWeight(.semibold)
                                    .foregroundStyle(AppTheme.expense)
                            }
                            .padding(12)
                            .background(palette.background, in: RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .padding(16)
                    .appCardSurface(cornerRadius: 16)
                    .listRowInsets(EdgeInsets(top: 6, leading: 24, bottom: 6, trailing: 24))
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
                }
            } header: {
                Text("History (last \(ExpenseStore.maxRetentionMonths) months)")
                    .font(.appHeadline())
                    .foregroundStyle(palette.textPrimary)
                    .textCase(nil)
            }
        }
    }
}
