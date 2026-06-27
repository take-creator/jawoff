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
    func scheduleReminder(frequency: ReminderFrequency) async {
        center.removePendingNotificationRequests(withIdentifiers: [hourlyReminderIdentifier])

        let content = UNMutableNotificationContent()
        content.title = "歯、触れていませんか？"
        content.body = "唇は閉じる。歯は離す。舌は上顎。"
        content.sound = .default
        content.userInfo = ["screen": "check"]

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: frequency.nextIntervalSeconds,
            repeats: frequency.repeats
        )
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
        guard notification.request.identifier == hourlyReminderIdentifier else {
            return [.banner, .sound]
        }
        NotificationCenter.default.post(name: .jawOffReminderOpened, object: nil)
        return [.banner, .sound]
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
