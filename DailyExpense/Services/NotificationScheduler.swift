import Foundation
import UserNotifications

@MainActor
final class NotificationScheduler {
    static let shared = NotificationScheduler()

    /// String keys are safe to read from `nonisolated` notification delegate callbacks.
    nonisolated static let eveningDateUserInfoKey = "eveningReportDate"
    nonisolated static let eveningIdentifier = "com.dailyexpense.bedtime-report"

    private let center = UNUserNotificationCenter.current()

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

    func scheduleBedtimeReport(hour: Int, minute: Int, bedtimeLabel: String, enabled: Bool) async {
        center.removePendingNotificationRequests(withIdentifiers: [Self.eveningIdentifier])
        guard enabled else { return }

        let status = await authorizationStatus()
        guard status == .authorized else { return }

        var date = DateComponents()
        date.hour = min(23, max(0, hour))
        date.minute = min(59, max(0, minute))

        let content = UNMutableNotificationContent()
        content.title = "Bedtime summary · \(bedtimeLabel)"
        content.body = "Tap to see today's income and expenses, sorted by amount."
        content.sound = .default
        content.userInfo = [
            Self.eveningDateUserInfoKey: ISO8601DateFormatter().string(from: Date())
        ]

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let request = UNNotificationRequest(identifier: Self.eveningIdentifier, content: content, trigger: trigger)
        try? await center.add(request)
    }
}
