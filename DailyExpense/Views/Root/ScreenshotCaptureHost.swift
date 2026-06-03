import SwiftUI

/// Renders a single real app screen for App Store screenshot automation (`-ScreenshotScreen`).
struct ScreenshotCaptureHost: View {
    let screen: AppScreenshotScreen
    @EnvironmentObject private var store: ExpenseStore
    @EnvironmentObject private var themeContext: ThemeContext

    var body: some View {
        Group {
            switch screen {
            case .onboarding:
                OnboardingView()
            case .home:
                MainTabView()
            case .report:
                MainTabView(initialTab: 1)
            case .settings:
                MainTabView(initialTab: 2)
            case .addExpense:
                MainTabView(presentAddExpenseOnAppear: true)
            case .transactions:
                MainTabView(openAllTransactionsOnAppear: true)
            }
        }
        .environmentObject(store)
        .environmentObject(themeContext)
        .themedScreen(themeContext: themeContext)
        .appThemedRoot(appearance: store.settings.appearance)
    }
}
