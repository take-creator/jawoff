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
                            Text("1時間ごとの通知")
                                .font(.title2.bold())
                            Text("通知文言は「歯、触れていませんか？」です。通知をタップしたらチェック画面を開いて記録します。")
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

                            Toggle("1時間ごとの通知を使う", isOn: notificationToggle)
                                .font(.headline)
                                .disabled(notifications.authorizationStatus != .authorized)
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("通知間隔")
                                .font(.headline)
                            Text("iPhone版MVPでは、目的に合わせて1時間固定にしています。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Text("現在: \(store.settings.reminderIntervalMinutes)分ごと")
                                .font(.subheadline.weight(.semibold))
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
                        await notifications.scheduleHourlyReminder()
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
            await notifications.scheduleHourlyReminder()
        }
    }
}
