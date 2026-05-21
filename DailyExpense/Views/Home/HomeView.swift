import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: ExpenseStore
    @Binding var showAddExpense: Bool
    @Binding var selectedTab: Int
    @State private var showAddIncome = false
    @State private var showWeekly = false
    @State private var showEveningReport = false

    private var today: Date { Date() }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 12) {
                    SummaryCard(
                        greeting: greetingText,
                        netBalance: store.netBalance(on: today),
                        income: store.total(for: .income, on: today),
                        expenses: store.total(for: .expense, on: today),
                        currencySymbol: store.settings.currencySymbol
                    )
                    .appearOnLoad(delay: 0)

                    Button { showEveningReport = true } label: {
                        BannerRow(
                            icon: "🌙",
                            title: "Evening report at \(MoneyFormat.reportTime(hour: store.settings.eveningReportHour, minute: store.settings.eveningReportMinute))",
                            tint: AppTheme.secondary
                        )
                    }
                    .buttonStyle(.plain)
                    .appearOnLoad(delay: AppAnimations.staggerDelay)

                    Button { showAddIncome = true } label: {
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
                        Spacer()
                        Text("See all")
                            .font(.appCaption())
                            .foregroundStyle(AppTheme.primary)
                    }
                    .padding(.top, 4)
                    .appearOnLoad(delay: AppAnimations.staggerDelay * 5)

                    ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, tx in
                        if let tag = store.tag(for: tx.tagId) {
                            TransactionRow(
                                tag: tag,
                                title: tx.note.isEmpty ? tag.name : tx.note,
                                subtitle: MoneyFormat.daySubtitle(tx.date),
                                amount: tx.amount,
                                currencySymbol: store.settings.currencySymbol,
                                isIncome: tx.type == .income
                            )
                            .appearOnLoad(delay: AppAnimations.staggerDelay * 6 + Double(index) * 0.04)
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .background(AppTheme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddIncome) {
                AddIncomeView()
            }
            .navigationDestination(isPresented: $showWeekly) {
                WeeklyInsightsView()
            }
            .navigationDestination(isPresented: $showEveningReport) {
                EveningReportView(date: today)
            }
        }
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
