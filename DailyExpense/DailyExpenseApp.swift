import SwiftUI

@main
struct DailyExpenseApp: App {
    @StateObject private var store = ExpenseStore()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(store)
                .task {
                    if store.settings.notificationsEnabled {
                        _ = await store.requestNotificationPermission()
                        await store.refreshNotificationSchedule()
                    }
                }
        }
    }
}
