import Foundation

@MainActor
final class AppStore: ObservableObject {
    @Published var checkLogs: [CheckLog] = [] {
        didSet { save(checkLogs, key: Keys.checkLogs) }
    }

    @Published var morningLogs: [MorningLog] = [] {
        didSet { save(morningLogs, key: Keys.morningLogs) }
    }

    @Published var reminderLogs: [ReminderLog] = [] {
        didSet { save(reminderLogs, key: Keys.reminderLogs) }
    }

    @Published var settings: AppSettings = .default {
        didSet { save(settings, key: Keys.settings) }
    }

    init() {
        checkLogs = load([CheckLog].self, key: Keys.checkLogs) ?? []
        morningLogs = load([MorningLog].self, key: Keys.morningLogs) ?? []
        reminderLogs = load([ReminderLog].self, key: Keys.reminderLogs) ?? []
        settings = load(AppSettings.self, key: Keys.settings) ?? .default
    }

    var todayChecks: [CheckLog] {
        checkLogs.filter { $0.timestamp.dayKey == Date.todayKey }
    }

    var todayMorningLog: MorningLog? {
        morningLogs.first { $0.date.dayKey == Date.todayKey }
    }

    var todayReminderLogs: [ReminderLog] {
        reminderLogs.filter { $0.timestamp.dayKey == Date.todayKey }
    }

    func addCheckLog(_ log: CheckLog) {
        checkLogs.append(log)
    }

    func saveMorningLog(_ log: MorningLog) {
        morningLogs.removeAll { $0.date.dayKey == log.date.dayKey }
        morningLogs.append(log)
        morningLogs.sort { $0.date < $1.date }
    }

    func addReminderLog() {
        reminderLogs.append(ReminderLog(id: UUID(), timestamp: Date()))
    }

    private func save<T: Encodable>(_ value: T, key: String) {
        do {
            let data = try JSONEncoder.appEncoder.encode(value)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            assertionFailure("Failed to save \(key): \(error.localizedDescription)")
        }
    }

    private func load<T: Decodable>(_ type: T.Type, key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder.appDecoder.decode(type, from: data)
    }
}

private enum Keys {
    static let checkLogs = "checkLogs"
    static let morningLogs = "morningLogs"
    static let settings = "settings"
    static let reminderLogs = "reminderLogs"
}

private extension JSONEncoder {
    static let appEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()
}

private extension JSONDecoder {
    static let appDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
