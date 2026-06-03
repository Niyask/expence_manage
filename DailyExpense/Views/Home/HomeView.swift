import SwiftUI

struct HomeView: View {
    @Environment(\.themePalette) private var palette
    @EnvironmentObject private var store: ExpenseStore
    @EnvironmentObject private var themeContext: ThemeContext
    @Binding var showAddExpense: Bool
    @Binding var selectedTab: Int
    @State private var showAddIncome = false
    @State private var showWeekly = false
    @State private var showEveningReport = false
    @State private var showAllTransactions = false
    @State private var transactionToEdit: Transaction?

    private var today: Date { Date() }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    SummaryCard(
                        greeting: greetingText,
                        netBalance: store.lifetimeNetBalance,
                        income: store.lifetimeIncome,
                        expenses: store.lifetimeExpenses,
                        currencySymbol: store.settings.currencyAmountPrefix,
                        currencyLocaleIdentifier: store.settings.currencyLocaleIdentifier,
                        weeklyExpenses: store.expenseTotalThisWeek(containing: today)
                    )
                    .appearOnLoad(delay: 0)

                    if store.transactions.isEmpty {
                        emptyStartCard
                            .appearOnLoad(delay: AppAnimations.staggerDelay)
                    }

                    Button {
                        withAnimation(AppAnimations.sheetSpring) { showEveningReport = true }
                    } label: {
                        BannerRow(
                            icon: "🌙",
                            title: "Bedtime summary at \(store.settings.bedtimeTimeLabel)",
                            subtitle: store.settings.hasConfiguredBedtime ? nil : "Default time · change in Settings",
                            tint: AppTheme.secondary
                        )
                    }
                    .buttonStyle(.plain)
                    .appearOnLoad(delay: AppAnimations.staggerDelay)

                    Button {
                        withAnimation(AppAnimations.sheetSpring) { showAddIncome = true }
                    } label: {
                        BannerRow(
                            icon: "💼",
                            title: "Add Income",
                            subtitle: "Salary, Bonus, Freelance & more",
                            tint: AppTheme.income
                        )
                    }
                    .buttonStyle(.plain)
                    .appearOnLoad(delay: AppAnimations.staggerDelay * 2)

                    if let insight = store.weekOverWeekInsight(for: today) {
                        Button { showWeekly = true } label: {
                            BannerRow(
                                icon: "📊",
                                title: "Week insight: \(insight)",
                                tint: AppTheme.accentOrange
                            )
                        }
                        .buttonStyle(.plain)
                        .appearOnLoad(delay: AppAnimations.staggerDelay * 3)
                    }

                    HStack(spacing: 12) {
                        QuickActionButton(emoji: "➕", title: "Expense") { showAddExpense = true }
                        QuickActionButton(emoji: "📊", title: "Report") { selectedTab = 1 }
                        QuickActionButton(emoji: "⚙️", title: "Settings") { selectedTab = 2 }
                    }
                    .appearOnLoad(delay: AppAnimations.staggerDelay * 4)

                    HStack {
                        Text("Recent Transactions")
                            .font(.appHeadline())
                            .foregroundStyle(palette.textPrimary)
                        Spacer()
                        Button("See all") { showAllTransactions = true }
                            .font(.appCaption())
                            .foregroundStyle(AppTheme.primary)
                    }
                    .padding(.top, 4)
                    .appearOnLoad(delay: AppAnimations.staggerDelay * 5)

                    if recentTransactions.isEmpty {
                        Text("Your list starts empty. Add income or expenses to track from zero.")
                            .font(.appCaption())
                            .foregroundStyle(palette.textSecondary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .appCardSurface()
                    } else {
                        ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, tx in
                            if let tag = store.tag(for: tx.tagId) {
                                TransactionRow(
                                    tag: tag,
                                    title: tx.note.isEmpty ? tag.name : tx.note,
                                    subtitle: MoneyFormat.daySubtitle(tx.date),
                                    amount: tx.amount,
                                    currencySymbol: store.settings.currencyAmountPrefix,
                                    currencyLocaleIdentifier: store.settings.currencyLocaleIdentifier,
                                    isIncome: tx.type == .income
                                )
                                .onTapGesture { transactionToEdit = tx }
                                .contextMenu {
                                    Button { transactionToEdit = tx } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    Button(role: .destructive) {
                                        withAnimation(AppAnimations.listSpring) {
                                            store.deleteTransaction(id: tx.id)
                                        }
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .staggeredAppear(index: index, baseDelay: AppAnimations.staggerDelay * 5)
                                .transition(AppAnimations.listInsert)
                            }
                        }
                        .animatedListBoundary(value: store.transactions.count)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .background(palette.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddIncome) {
                AddIncomeView()
                    .environmentObject(store)
                    .environmentObject(themeContext)
                    .themedScreen(themeContext: themeContext)
                    .appThemedRoot(appearance: store.settings.appearance)
            }
            .animation(AppAnimations.sheetSpring, value: showAddIncome)
            .sheet(item: $transactionToEdit) { tx in
                EditTransactionView(transaction: tx)
                    .environmentObject(store)
                    .environmentObject(themeContext)
                    .themedScreen(themeContext: themeContext)
                    .appThemedRoot(appearance: store.settings.appearance)
            }
            .animation(AppAnimations.sheetSpring, value: transactionToEdit?.id)
            .navigationDestination(isPresented: $showWeekly) {
                WeeklyInsightsView()
            }
            .navigationDestination(isPresented: $showEveningReport) {
                EveningReportView(date: today)
            }
            .navigationDestination(isPresented: $showAllTransactions) {
                TransactionListView()
            }
        }
    }

    private var emptyStartCard: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("✨")
            VStack(alignment: .leading, spacing: 4) {
                Text("Starting from 0 transactions")
                    .font(.appCaption())
                    .fontWeight(.semibold)
                    .foregroundStyle(AppTheme.primary)
                Text("Income and expenses add up from your first entry. Totals on Home are always cumulative; weekly breakdown is in Report.")
                    .font(.appSmall())
                    .foregroundStyle(palette.textSecondary)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.primary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let period: String
        switch hour {
        case 5..<12: period = "Good morning"
        case 12..<17: period = "Good afternoon"
        default: period = "Good evening"
        }
        return "\(period), \(store.settings.greetingName) 👋"
    }

    private var recentTransactions: [Transaction] {
        Array(store.transactions.sorted { $0.date > $1.date }.prefix(8))
    }
}
