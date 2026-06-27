import SwiftUI

struct MorningLogScreen: View {
    @EnvironmentObject private var store: AppStore
    @State private var morningClenchingDetected: Bool?
    @State private var saved = false

    var body: some View {
        ScreenContainer(
            title: "朝ログ",
            subtitle: "起きた直後の感覚だけを、はい・いいえで残します。"
        ) {
            InfoCard(
                icon: "sun.max.fill",
                title: "朝の状態をシンプルに記録",
                subtitle: "夜間の噛み締めは自分で制御しにくいため、まずは変化を見返せるようにします。"
            )

            AppCard {
                VStack(alignment: .leading, spacing: 20) {
                    SectionHeader(
                        icon: "bed.double.fill",
                        title: "起床時の噛み締め感",
                        subtitle: "朝起きた時、噛み締めていた感覚はありましたか？"
                    )

                    HStack(spacing: 12) {
                        MorningChoiceButton(
                            title: "はい",
                            subtitle: "感覚あり",
                            icon: "exclamationmark.circle.fill",
                            tint: AppDesign.Color.warning,
                            isSelected: morningClenchingDetected == true
                        ) {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.84)) {
                                morningClenchingDetected = true
                                saved = false
                            }
                        }

                        MorningChoiceButton(
                            title: "いいえ",
                            subtitle: "感覚なし",
                            icon: "checkmark.circle.fill",
                            tint: AppDesign.Color.success,
                            isSelected: morningClenchingDetected == false
                        ) {
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.84)) {
                                morningClenchingDetected = false
                                saved = false
                            }
                        }
                    }
                }
            }

            Button("朝ログを保存する") {
                save()
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .disabled(morningClenchingDetected == nil)
            .opacity(morningClenchingDetected == nil ? 0.45 : 1)
            .animation(.easeInOut(duration: 0.2), value: morningClenchingDetected)

            if saved {
                InfoCard(
                    icon: "checkmark.seal.fill",
                    title: "今日の朝ログを保存しました",
                    subtitle: "記録画面の朝ログから、今週・今月の状態を見返せます。",
                    tint: AppDesign.Color.success
                )
            }

            DisclaimerView()
        }
        .onAppear(perform: loadToday)
    }

    private func loadToday() {
        guard let log = store.todayMorningLog else { return }
        morningClenchingDetected = log.morningClenchingDetected
    }

    private func save() {
        guard let morningClenchingDetected else { return }
        let log = MorningLog(
            id: store.todayMorningLog?.id ?? UUID(),
            date: Date(),
            morningClenchingDetected: morningClenchingDetected
        )
        store.saveMorningLog(log)
        withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
            saved = true
        }
    }
}

private struct MorningChoiceButton: View {
    var title: String
    var subtitle: String
    var icon: String
    var tint: Color
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title2.weight(.bold))
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.bold))
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .opacity(0.82)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(isSelected ? tint : AppDesign.Color.secondarySurface)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control, style: .continuous))
            .scaleEffect(isSelected ? 1 : 0.99)
            .animation(.spring(response: 0.28, dampingFraction: 0.84), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}
