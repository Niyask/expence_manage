import SwiftUI

@main
struct DailyExpenseApp: App {
    @StateObject private var store = ExpenseStore()
    @StateObject private var themeContext = ThemeContext()
    private let notificationHandler = AppNotificationHandler()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .environmentObject(themeContext)
                .environment(\.themePalette, themeContext.palette)
                .appThemedRoot(appearance: store.settings.appearance)
                .id(themeContext.revision)
                .onAppear {
                    notificationHandler.configure(store: store)
                    applyTheme(store.settings.appearance)
                }
                .onChange(of: store.settings.appearance) { newValue in
                    applyTheme(newValue)
                }
                .task {
                    if store.settings.hasCompletedOnboarding,
                       store.settings.notificationsEnabled {
                        _ = await store.requestNotificationPermission()
                        await store.refreshNotificationSchedule()
                    }
                }
        }
    }

    @MainActor
    private func applyTheme(_ appearance: AppAppearancePreference) {
        themeContext.apply(appearance)
    }
}
