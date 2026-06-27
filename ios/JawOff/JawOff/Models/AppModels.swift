import Foundation

struct CheckLog: Identifiable, Codable, Equatable {
    var id: UUID
    var timestamp: Date
    var teethTouching: Bool
    var jawTension: Bool
    var tonguePosition: Bool
    var shoulderTension: Bool
    var stress: Bool
}

struct MorningLog: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var jawFatigue: Int
    var masseterTension: Int
    var toothFatigue: Int
    var headache: Int
    var shoulderStiffness: Int
    var sleepQuality: Int
    var memo: String
}

struct AppSettings: Codable, Equatable {
    var reminderIntervalMinutes: Int
    var notificationEnabled: Bool

    static let `default` = AppSettings(
        reminderIntervalMinutes: 60,
        notificationEnabled: false
    )
}

struct ReminderLog: Identifiable, Codable, Equatable {
    var id: UUID
    var timestamp: Date
}

extension Date {
    var dayKey: String {
        Self.dayFormatter.string(from: self)
    }

    static var todayKey: String {
        Date().dayKey
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    static func recentDays(_ count: Int) -> [Date] {
        let calendar = Calendar.current
        let start = calendar.startOfDay(for: Date())
        return (0..<count).compactMap { offset in
            calendar.date(byAdding: .day, value: offset - count + 1, to: start)
        }
    }
}
