import Foundation

struct CheckLog: Identifiable, Codable, Equatable {
    var id: UUID
    var timestamp: Date
    var teethTouching: Bool
    var jawTension: Bool?
    var tonguePosition: Bool?
    var shoulderTension: Bool?
    var stress: Bool?
}

struct MorningLog: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var morningClenchingDetected: Bool

    init(id: UUID, date: Date, morningClenchingDetected: Bool) {
        self.id = id
        self.date = date
        self.morningClenchingDetected = morningClenchingDetected
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        if let detected = try container.decodeIfPresent(Bool.self, forKey: .morningClenchingDetected) {
            morningClenchingDetected = detected
        } else if let level = try container.decodeIfPresent(Int.self, forKey: .morningClenchingLevel) {
            morningClenchingDetected = level > 0
        } else {
            morningClenchingDetected = (try container.decodeIfPresent(Int.self, forKey: .jawFatigue) ?? 0) > 0
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(morningClenchingDetected, forKey: .morningClenchingDetected)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case date
        case morningClenchingDetected
        case morningClenchingLevel
        case jawFatigue
    }
}

struct AppSettings: Codable, Equatable {
    var reminderFrequency: ReminderFrequency
    var notificationEnabled: Bool

    static let `default` = AppSettings(
        reminderFrequency: .minutes30,
        notificationEnabled: false
    )

    var reminderIntervalMinutes: Int {
        reminderFrequency.displayMinutes
    }

    init(reminderFrequency: ReminderFrequency, notificationEnabled: Bool) {
        self.reminderFrequency = reminderFrequency
        self.notificationEnabled = notificationEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        notificationEnabled = try container.decodeIfPresent(Bool.self, forKey: .notificationEnabled) ?? false
        if let frequency = try container.decodeIfPresent(ReminderFrequency.self, forKey: .reminderFrequency) {
            reminderFrequency = frequency
        } else {
            let oldMinutes = try container.decodeIfPresent(Int.self, forKey: .reminderIntervalMinutes) ?? 30
            reminderFrequency = ReminderFrequency.fixed(minutes: oldMinutes) ?? .minutes30
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(reminderFrequency, forKey: .reminderFrequency)
        try container.encode(notificationEnabled, forKey: .notificationEnabled)
    }

    private enum CodingKeys: String, CodingKey {
        case reminderFrequency
        case reminderIntervalMinutes
        case notificationEnabled
    }
}

enum ReminderFrequency: String, CaseIterable, Codable, Identifiable, Equatable {
    case minutes30
    case minutes45
    case minutes60
    case minutes90
    case minutes120
    case random25to55

    var id: String { rawValue }

    var title: String {
        switch self {
        case .minutes30:
            return "30分ごと"
        case .minutes45:
            return "45分ごと"
        case .minutes60:
            return "1時間ごと"
        case .minutes90:
            return "90分ごと"
        case .minutes120:
            return "2時間ごと"
        case .random25to55:
            return "ランダム通知"
        }
    }

    var detail: String {
        switch self {
        case .random25to55:
            return "25〜55分の間で毎回ランダム"
        default:
            return "\(displayMinutes)分間隔"
        }
    }

    var displayMinutes: Int {
        switch self {
        case .minutes30:
            return 30
        case .minutes45:
            return 45
        case .minutes60:
            return 60
        case .minutes90:
            return 90
        case .minutes120:
            return 120
        case .random25to55:
            return 25
        }
    }

    var nextIntervalSeconds: TimeInterval {
        switch self {
        case .random25to55:
            return TimeInterval(Int.random(in: 25...55) * 60)
        default:
            return TimeInterval(displayMinutes * 60)
        }
    }

    var repeats: Bool {
        self != .random25to55
    }

    static func fixed(minutes: Int) -> ReminderFrequency? {
        switch minutes {
        case 30:
            return .minutes30
        case 45:
            return .minutes45
        case 60:
            return .minutes60
        case 90:
            return .minutes90
        case 120:
            return .minutes120
        default:
            return nil
        }
    }
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
