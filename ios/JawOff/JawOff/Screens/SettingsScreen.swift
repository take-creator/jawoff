import SwiftUI
import UserNotifications

struct SettingsScreen: View {
    @EnvironmentObject private var store: AppStore
    @EnvironmentObject private var notifications: NotificationManager

    var body: some View {
        ScreenContainer(
            title: "設定",
            subtitle: "日中の気づきを邪魔にならない頻度と時間帯に調整します。"
        ) {
            InfoCard(
                icon: "bell.badge.fill",
                title: "リマインダー",
                subtitle: "通知文言は「歯、触れていませんか？」です。通知をタップしたら、今の歯の接触だけをすぐ記録できます。"
            )

            notificationStatusCard
            frequencyCard
            timeWindowCard
            DisclaimerView()
        }
        .task {
            await notifications.refreshAuthorizationStatus()
        }
    }

    private var notificationStatusCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 18) {
                SectionHeader(
                    icon: "bell.badge.fill",
                    title: "通知状態",
                    subtitle: statusText
                )

                if notifications.authorizationStatus != .authorized {
                    Button("通知を許可する") {
                        Task { await requestNotifications() }
                    }
                    .buttonStyle(SecondaryActionButtonStyle())
                }

                Toggle(isOn: notificationToggle) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("通知を使う")
                            .font(.headline.weight(.bold))
                        Text(store.settings.notificationEnabled ? "ONになっています" : "OFFになっています")
                            .font(.subheadline)
                            .foregroundStyle(statusColor)
                    }
                }
                .tint(AppDesign.Color.brand)
                .disabled(notifications.authorizationStatus != .authorized)
                .animation(.spring(response: 0.28, dampingFraction: 0.82), value: store.settings.notificationEnabled)
            }
        }
    }

    private var frequencyCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    icon: "timer",
                    title: "通知頻度",
                    subtitle: "指定した時間帯の中だけ通知します。ランダム通知は毎回25〜55分の間で次の通知を決めます。"
                )

                VStack(spacing: 10) {
                    ForEach(ReminderFrequency.allCases) { frequency in
                        Button {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.84)) {
                                store.settings.reminderFrequency = frequency
                            }
                            scheduleIfNeeded()
                        } label: {
                            FrequencyRow(
                                frequency: frequency,
                                isSelected: store.settings.reminderFrequency == frequency
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var timeWindowCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    icon: "clock.fill",
                    title: "通知する時間帯",
                    subtitle: "この時間帯の外では通知しません。夜間通知を避けたい場合は、朝から夜までの範囲にしてください。"
                )

                VStack(spacing: 12) {
                    TimePickerRow(title: "開始", selection: reminderStartBinding)
                    TimePickerRow(title: "終了", selection: reminderEndBinding)
                }
            }
        }
    }

    private var notificationToggle: Binding<Bool> {
        Binding(
            get: { store.settings.notificationEnabled },
            set: { enabled in
                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                    store.settings.notificationEnabled = enabled
                }
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
            return "通知は許可されています。必要に応じてON/OFFできます。"
        case .denied:
            return "通知がブロックされています。iPhoneの設定から変更できます。"
        case .notDetermined:
            return "通知は未設定です。使う場合は許可してください。"
        @unknown default:
            return "通知状態を確認できません。"
        }
    }

    private var statusColor: Color {
        switch notifications.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return AppDesign.Color.brandDeep
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
}

private struct FrequencyRow: View {
    var frequency: ReminderFrequency
    var isSelected: Bool

    var body: some View {
        HStack(spacing: 12) {
            IconBadge(
                systemName: isSelected ? "checkmark.circle.fill" : "circle",
                tint: isSelected ? AppDesign.Color.brand : .secondary,
                size: 34
            )

            VStack(alignment: .leading, spacing: 3) {
                Text(frequency.title)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.primary)
                Text(frequency.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(14)
        .background(isSelected ? AppDesign.Color.brand.opacity(0.12) : AppDesign.Color.secondarySurface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .animation(.spring(response: 0.28, dampingFraction: 0.84), value: isSelected)
    }
}

private struct TimePickerRow: View {
    var title: String
    @Binding var selection: Date

    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.secondary)
            Spacer()
            DatePicker(title, selection: $selection, displayedComponents: .hourAndMinute)
                .labelsHidden()
                .datePickerStyle(.compact)
                .tint(AppDesign.Color.brand)
        }
        .padding(14)
        .background(AppDesign.Color.secondarySurface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}
