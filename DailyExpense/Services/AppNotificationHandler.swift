import Foundation
import UserNotifications

@MainActor
final class AppNotificationHandler: NSObject, UNUserNotificationCenterDelegate {
    weak var store: ExpenseStore?

    func configure(store: ExpenseStore) {
        self.store = store
        UNUserNotificationCenter.current().delegate = self
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        let date: Date
        if let iso = userInfo[NotificationScheduler.eveningDateUserInfoKey] as? String,
           let parsed = ISO8601DateFormatter().date(from: iso) {
            date = parsed
        } else {
            date = Date()
        }
        await MainActor.run {
            store?.openEveningReport(for: date)
        }
    }
}
