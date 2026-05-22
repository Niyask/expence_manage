import SwiftUI

@main
struct DailyExpenseApp: App {
    @StateObject private var store = ExpenseStore()
    private let notificationHandler = AppNotificationHandler()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
                .onAppear {
                    notificationHandler.configure(store: store)
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
