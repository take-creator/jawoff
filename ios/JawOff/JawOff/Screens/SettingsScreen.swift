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
                            Text("30分ごとでも負担になりにくいよう、チェックはワンタップです。ランダム通知は毎回25〜55分の間で次の通知を決めます。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            VStack(spacing: 8) {
                                ForEach(ReminderFrequency.allCases) { frequency in
                                    Button {
                                        store.settings.reminderFrequency = frequency
                                        if store.settings.notificationEnabled {
                                            Task { await notifications.scheduleReminder(frequency: frequency) }
                                        }
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
                        await notifications.scheduleReminder(frequency: store.settings.reminderFrequency)
                    } else {
                        notifications.cancelReminder()
                    }
                }
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
            await notifications.scheduleReminder(frequency: store.settings.reminderFrequency)
        }
    }

    private func frequencyBackground(_ frequency: ReminderFrequency) -> Color {
        store.settings.reminderFrequency == frequency ? Color.teal.opacity(0.14) : Color(.secondarySystemGroupedBackground)
    }
}
