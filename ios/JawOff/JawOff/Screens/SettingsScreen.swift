import SwiftUI
import UserNotifications

struct SettingsScreen: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var notifications: NotificationManager

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("リマインダー")
                                .font(.title2.bold())
                            Text("通知文言は「歯、触れていませんか？」です。通知をタップしたら、今の歯の接触だけをすぐ記録できます。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("通知状態")
                                .font(.headline)
                            Text(statusText)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(statusColor)

                            if notifications.authorizationStatus != .authorized {
                                Button("通知を許可する") {
                                    Task { await requestNotifications() }
                                }
                                .buttonStyle(SecondaryActionButtonStyle())
                            }

                            Toggle("通知を使う", isOn: notificationToggle)
                                .font(.headline)
                                .disabled(notifications.authorizationStatus != .authorized)
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("通知頻度")
                                .font(.headline)
                            Text("指定した時間帯の中だけ通知します。ランダム通知は毎回25〜55分の間で次の通知を決めます。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            VStack(spacing: 8) {
                                ForEach(ReminderFrequency.allCases) { frequency in
                                    Button {
                                        store.settings.reminderFrequency = frequency
                                        scheduleIfNeeded()
                                    } label: {
                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 3) {
                                                Text(frequency.title)
                                                    .font(.subheadline.weight(.semibold))
                                                    .foregroundStyle(.primary)
                                                Text(frequency.detail)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                            if store.settings.reminderFrequency == frequency {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .font(.title3)
                                                    .foregroundStyle(.teal)
                                            }
                                        }
                                        .padding(12)
                                        .background(frequencyBackground(frequency))
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("通知する時間帯")
                                .font(.headline)
                            Text("この時間帯の外では通知しません。夜間に通知を鳴らしたくない場合は、朝から夜までの範囲にしてください。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            VStack(spacing: 10) {
                                HStack {
                                    Text("開始")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    DatePicker(
                                        "開始",
                                        selection: reminderStartBinding,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                }

                                HStack {
                                    Text("終了")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    DatePicker(
                                        "終了",
                                        selection: reminderEndBinding,
                                        displayedComponents: .hourAndMinute
                                    )
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                }
                            }
                        }
                    }

                    DisclaimerView()
                }
                .padding()
                .padding(.bottom, 104)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("設定")
            .task {
                await notifications.refreshAuthorizationStatus()
            }
        }
    }

    private var notificationToggle: Binding<Bool> {
        Binding(
            get: { store.settings.notificationEnabled },
            set: { enabled in
                store.settings.notificationEnabled = enabled
                Task {
                    if enabled {
                        await notifications.scheduleReminder(settings: store.settings)
                    } else {
                        notifications.cancelReminder()
                    }
                }
            }
        )
    }

    private var reminderStartBinding: Binding<Date> {
        Binding(
            get: { dateFromMinutes(store.settings.reminderStartMinutes) },
            set: { date in
                store.settings.reminderStartMinutes = minutesFromDate(date)
                scheduleIfNeeded()
            }
        )
    }

    private var reminderEndBinding: Binding<Date> {
        Binding(
            get: { dateFromMinutes(store.settings.reminderEndMinutes) },
            set: { date in
                store.settings.reminderEndMinutes = minutesFromDate(date)
                scheduleIfNeeded()
            }
        )
    }

    private var statusText: String {
        switch notifications.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return "通知は許可されています"
        case .denied:
            return "通知がブロックされています。iPhoneの設定から変更できます。"
        case .notDetermined:
            return "通知は未設定です"
        @unknown default:
            return "通知状態を確認できません"
        }
    }

    private var statusColor: Color {
        switch notifications.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return .teal
        case .denied:
            return .red
        default:
            return .secondary
        }
    }

    private func requestNotifications() async {
        let granted = await notifications.requestAuthorization()
        store.settings.notificationEnabled = granted
        if granted {
            await notifications.scheduleReminder(settings: store.settings)
        }
    }

    private func scheduleIfNeeded() {
        guard store.settings.notificationEnabled else { return }
        Task { await notifications.scheduleReminder(settings: store.settings) }
    }

    private func minutesFromDate(_ date: Date) -> Int {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        return (components.hour ?? 0) * 60 + (components.minute ?? 0)
    }

    private func dateFromMinutes(_ minutes: Int) -> Date {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .minute, value: minutes, to: startOfDay) ?? Date()
    }

    private func frequencyBackground(_ frequency: ReminderFrequency) -> Color {
        store.settings.reminderFrequency == frequency ? Color.teal.opacity(0.14) : Color(.secondarySystemGroupedBackground)
    }
}
