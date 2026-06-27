import Foundation
import UserNotifications

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @MainActor
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center = UNUserNotificationCenter.current()
    private let reminderIdentifierPrefix = "jawoff.reminder."
    private let maxScheduledReminders = 48

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
    func scheduleReminder(settings: AppSettings) async {
        cancelReminder()

        let content = UNMutableNotificationContent()
        content.title = "歯、触れていませんか？"
        content.body = "唇は閉じる。歯は離す。舌は上顎。"
        content.sound = .default
        content.userInfo = ["screen": "check"]

        let dates = nextReminderDates(settings: settings, count: maxScheduledReminders)
        for (index, date) in dates.enumerated() {
            let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(
                identifier: "\(reminderIdentifierPrefix)\(index)",
                content: content,
                trigger: trigger
            )

            do {
                try await center.add(request)
            } catch {
                assertionFailure("Failed to schedule notification: \(error.localizedDescription)")
            }
        }
    }

    func cancelReminder() {
        let identifiers = (0..<maxScheduledReminders).map { "\(reminderIdentifierPrefix)\($0)" }
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        guard notification.request.identifier.hasPrefix(reminderIdentifierPrefix) else {
            return [.banner, .sound]
        }
        NotificationCenter.default.post(name: .jawOffReminderOpened, object: nil)
        return [.banner, .sound]
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard response.notification.request.identifier.hasPrefix(reminderIdentifierPrefix) else { return }
        NotificationCenter.default.post(name: .jawOffReminderOpened, object: nil)
    }

    private func nextReminderDates(settings: AppSettings, count: Int) -> [Date] {
        var dates: [Date] = []
        var cursor = Date()

        while dates.count < count {
            let candidate = cursor.addingTimeInterval(settings.reminderFrequency.nextIntervalSeconds)
            let nextDate = allowedDate(for: candidate, settings: settings)
            dates.append(nextDate)
            cursor = nextDate
        }

        return dates
    }

    private func allowedDate(for date: Date, settings: AppSettings) -> Date {
        if isInsideReminderWindow(date, settings: settings) {
            return date
        }
        return nextWindowStart(
            after: date,
            startMinutes: settings.reminderStartMinutes,
            endMinutes: settings.reminderEndMinutes
        )
    }

    private func isInsideReminderWindow(_ date: Date, settings: AppSettings) -> Bool {
        let minutes = minutesSinceStartOfDay(for: date)
        let start = settings.reminderStartMinutes
        let end = settings.reminderEndMinutes

        if start < end {
            return minutes >= start && minutes < end
        }
        if start > end {
            return minutes >= start || minutes < end
        }
        return true
    }

    private func nextWindowStart(after date: Date, startMinutes: Int, endMinutes: Int) -> Date {
        let calendar = Calendar.current
        let minutes = minutesSinceStartOfDay(for: date)
        let startToday = dateAt(minutes: startMinutes, on: date)

        if startMinutes < endMinutes {
            if minutes < startMinutes {
                return startToday
            }
            return calendar.date(byAdding: .day, value: 1, to: startToday) ?? startToday
        }

        if startMinutes > endMinutes, minutes >= endMinutes, minutes < startMinutes {
            return startToday
        }

        return date
    }

    private func minutesSinceStartOfDay(for date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    private func dateAt(minutes: Int, on date: Date) -> Date {
        let startOfDay = Calendar.current.startOfDay(for: date)
        return Calendar.current.date(byAdding: .minute, value: minutes, to: startOfDay) ?? date
    }
}

extension Notification.Name {
    static let jawOffReminderOpened = Notification.Name("jawOffReminderOpened")
}
