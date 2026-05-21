import Foundation
import UserNotifications

@MainActor
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    private let center = UNUserNotificationCenter.current()
    private let eveningIdentifier = "com.dailyexpense.evening-report"

    enum AuthorizationStatus {
        case notDetermined
        case denied
        case authorized
    }

    func authorizationStatus() async -> AuthorizationStatus {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .authorized
        case .denied:
            return .denied
        default:
            return .notDetermined
        }
    }

    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    func scheduleEveningReport(hour: Int, minute: Int, enabled: Bool) async {
        center.removePendingNotificationRequests(withIdentifiers: [eveningIdentifier])
        guard enabled else { return }

        let status = await authorizationStatus()
        guard status == .authorized else { return }

        var date = DateComponents()
        date.hour = min(23, max(0, hour))
        date.minute = min(59, max(0, minute))

        let content = UNMutableNotificationContent()
        content.title = "Evening Report"
        content.body = "Tap to review today's income, expenses, and savings."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: eveningIdentifier, content: content, trigger: trigger)
        try? await center.add(request)
    }
}
