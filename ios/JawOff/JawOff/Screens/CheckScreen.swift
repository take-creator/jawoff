import SwiftUI

struct CheckScreen: View {
    @EnvironmentObject private var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: AppTab
    @State private var result: QuickCheckResult?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.stack) {
                    ScreenHeader(
                        title: "チェック",
                        subtitle: "今の状態を1回だけ確認します。正解・不正解はありません。"
                    )

                    if let result {
                        resultView(result)
                    } else {
                        questionView
                    }
                }
                .padding(.horizontal, AppDesign.Spacing.screenHorizontal)
                .padding(.top, 18)
                .padding(.bottom, 60)
            }
            .background(AppDesign.Color.grouped)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("閉じる") {
                        dismiss()
                    }
                    .foregroundStyle(AppDesign.Color.brandDeep)
                }
            }
        }
    }

    private var questionView: some View {
        VStack(spacing: AppDesign.Spacing.stack) {
            AppCard {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(
                        icon: "face.smiling",
                        title: "今、上下の歯は触れていましたか？",
                        subtitle: "直前の感覚で選んでください。迷ったら近い方で大丈夫です。"
                    )

                    VStack(spacing: 12) {
                        Button {
                            save(teethTouching: true)
                        } label: {
                            Label("はい、触れていた", systemImage: "exclamationmark.circle.fill")
                        }
                        .buttonStyle(ChipButtonStyle(isSelected: true, tint: AppDesign.Color.warning))

                        Button {
                            save(teethTouching: false)
                        } label: {
                            Label("いいえ、離れていた", systemImage: "checkmark.circle.fill")
                        }
                        .buttonStyle(ChipButtonStyle(isSelected: true, tint: AppDesign.Color.brand))
                    }
                }
            }

            InfoCard(
                icon: "wind",
                title: "触れていたことに気づけたら十分です",
                subtitle: "記録したあと、奥歯を離してゆっくり息を吐きます。"
            )
        }
    }

    private func resultView(_ result: QuickCheckResult) -> some View {
        VStack(spacing: AppDesign.Spacing.stack) {
            AppCard {
                VStack(alignment: .leading, spacing: 18) {
                    SectionHeader(
                        icon: result.icon,
                        title: result.title,
                        subtitle: result.subtitle
                    )

                    VStack(spacing: 12) {
                        ForEach(result.messages, id: \.self) { message in
                            ResultStepRow(message: message, tint: result.tint)
                        }
                    }
                }
            }

            Button("ホームに戻る") {
                withAnimation(.easeInOut(duration: 0.25)) {
                    self.result = nil
                    selectedTab = .home
                    dismiss()
                }
            }
            .buttonStyle(PrimaryActionButtonStyle())
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func save(teethTouching: Bool) {
        let log = CheckLog(
            id: UUID(),
            timestamp: Date(),
            teethTouching: teethTouching,
            jawTension: nil,
            tonguePosition: nil,
            shoulderTension: nil,
            stress: nil
        )
        store.addCheckLog(log)
        withAnimation(.spring(response: 0.34, dampingFraction: 0.86)) {
            result = QuickCheckResult(teethTouching: teethTouching)
        }
    }
}

private struct ResultStepRow: View {
    var message: String
    var tint: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title3)
                .foregroundStyle(tint)
            Text(message)
                .font(.body.weight(.semibold))
                .foregroundStyle(.primary)
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(tint.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct QuickCheckResult: Equatable {
    var teethTouching: Bool

    var title: String {
        teethTouching ? "気づけました" : "離せていました"
    }

    var subtitle: String {
        teethTouching ? "ここで力を抜ければ十分です。短く整えましょう。" : "その調子です。離れている感覚を少しだけ覚えておきます。"
    }

    var icon: String {
        teethTouching ? "hand.raised.fill" : "checkmark.circle.fill"
    }

    var tint: Color {
        teethTouching ? AppDesign.Color.warning : AppDesign.Color.success
    }

    var messages: [String] {
        if teethTouching {
            return [
                "深呼吸を3回する",
                "奥歯をそっと離す",
                "舌を上顎に軽く置く",
                "肩と顎の力を抜く"
            ]
        }

        return [
            "歯が離れている感覚を確認する",
            "顎と肩の力を抜いたまま戻る"
        ]
    }
}
