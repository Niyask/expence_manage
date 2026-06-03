import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var store: ExpenseStore
    @EnvironmentObject private var themeContext: ThemeContext
    var initialTab: Int = 0
    var presentAddExpenseOnAppear: Bool = false
    var openAllTransactionsOnAppear: Bool = false
    @State private var selectedTab = 0
    @State private var showAddExpense = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            TabView(selection: $selectedTab) {
                HomeView(
                    showAddExpense: $showAddExpense,
                    selectedTab: $selectedTab,
                    openAllTransactionsOnAppear: openAllTransactionsOnAppear
                )
                    .tabItem { Label("Home", systemImage: "house.fill") }
                    .tag(0)

                FinancialReportView()
                    .tabItem { Label("Report", systemImage: "chart.bar.fill") }
                    .tag(1)

                SettingsView()
                    .tabItem { Label("Settings", systemImage: "gearshape.fill") }
                    .tag(2)
            }
            .tint(AppTheme.primary)
            .animation(AppAnimations.tabEase, value: selectedTab)

            FloatingAddButton {
                withAnimation(AppAnimations.sheetSpring) {
                    showAddExpense = true
                }
            }
            .padding(.trailing, 20)
            .padding(.bottom, 56)
        }
        .themedScreen(themeContext: themeContext)
        .onAppear {
            selectedTab = initialTab
            if presentAddExpenseOnAppear {
                showAddExpense = true
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseView()
                .environmentObject(store)
                .environmentObject(themeContext)
                .themedScreen(themeContext: themeContext)
                .appThemedRoot(appearance: store.settings.appearance)
        }
    }
}

struct FloatingAddButton: View {
    let action: () -> Void
    @State private var scale: CGFloat = 1
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Button(action: action) {
            Text("+")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(AppTheme.summaryGradient, in: Circle())
                .shadow(color: AppTheme.primary.opacity(0.35), radius: 12, y: 6)
                .scaleEffect(scale)
        }
        .scalePressStyle()
        .frame(maxWidth: .infinity, alignment: .trailing)
        .accessibilityLabel("Add expense")
        .accessibilityHint("Opens the expense entry form")
        .onAppear {
            guard !reduceMotion else { return }
            withAnimation(AppAnimations.fabPulse) {
                scale = 1.06
            }
        }
    }
}
