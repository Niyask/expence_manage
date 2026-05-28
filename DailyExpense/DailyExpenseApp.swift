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
                .themedScreen()
                .appThemedRoot(appearance: store.settings.appearance)
                .id(themeContext.revision)
                .onAppear {
                    notificationHandler.configure(store: store)
                    themeContext.apply(store.settings.appearance)
                }
                .onChange(of: store.settings.appearance) { newValue in
                    themeContext.apply(newValue)
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
}
