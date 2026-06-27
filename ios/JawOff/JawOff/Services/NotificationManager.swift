import Foundation
import UserNotifications

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @MainActor
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()
    private let hourlyReminderIdentifier = "jawoff.hourlyReminder"

    override init() {
        super.init()
        center.delegate = self
    }

    @MainActor
    func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    @MainActor
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            await refreshAuthorizationStatus()
            return false
        }
    }

    @MainActor
    func scheduleHourlyReminder() async {
        center.removePendingNotificationRequests(withIdentifiers: [hourlyReminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "歯、触れていませんか？"
        content.body = "アプリを開いて、今の噛み締め状態を確認しましょう。"
        content.sound = .default
        content.userInfo = ["screen": "check"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 60 * 60, repeats: true)
        let request = UNNotificationRequest(
            identifier: hourlyReminderIdentifier,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            assertionFailure("Failed to schedule notification: \(error.localizedDescription)")
        }
    }

    func cancelReminder() {
        center.removePendingNotificationRequests(withIdentifiers: [hourlyReminderIdentifier])
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
        guard response.notification.request.identifier == hourlyReminderIdentifier else { return }
        NotificationCenter.default.post(name: .jawOffReminderOpened, object: nil)
    }
}

extension Notification.Name {
    static let jawOffReminderOpened = Notification.Name("jawOffReminderOpened")
}
