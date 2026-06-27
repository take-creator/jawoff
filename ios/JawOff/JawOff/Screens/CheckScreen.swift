import SwiftUI

struct CheckScreen: View {
    @EnvironmentObject private var store: AppStore
    @State private var currentStep = 0
    @State private var teethTouching = false
    @State private var jawTension = false
    @State private var tonguePosition = true
    @State private var shoulderTension = false
    @State private var stress = false
    @State private var savedAt: Date?

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Spacer(minLength: 24)

                if let savedAt {
                    savedView(savedAt: savedAt)
                } else {
                    Text("\(currentStep + 1) / 7")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.teal)

                    VStack(spacing: 18) {
                        Text(stepTitle)
                            .font(.largeTitle.bold())
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.72)
                            .lineLimit(3)
                            .frame(maxWidth: .infinity)

                        if let caption = stepCaption {
                            Text(caption)
                                .font(.body)
                                .foregroundStyle(.secondary)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }

                        stepControls
                            .padding(.top, 12)
                    }
                    .padding(.horizontal, 24)

                    Spacer(minLength: 24)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 104)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("チェック")
        }
    }

    @ViewBuilder
    private var stepControls: some View {
        if currentStep == 0 {
            Button("チェックを始める") {
                withAnimation(.easeInOut) {
                    currentStep = 1
                }
            }
            .buttonStyle(PrimaryActionButtonStyle())
        } else if currentStep == 6 {
            Button("記録する") {
                save()
            }
            .buttonStyle(PrimaryActionButtonStyle())

            Button("戻る") {
                withAnimation(.easeInOut) {
                    currentStep = 5
                }
            }
            .buttonStyle(SecondaryActionButtonStyle())
        } else {
            HStack(spacing: 14) {
                Button("いいえ") {
                    answer(false)
                }
                .buttonStyle(SecondaryActionButtonStyle())

                Button("はい") {
                    answer(true)
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }

            Button("戻る") {
                withAnimation(.easeInOut) {
                    currentStep = max(0, currentStep - 1)
                }
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
            .padding(.top, 4)
        }
    }

    private var stepTitle: String {
        switch currentStep {
        case 0:
            return "今の状態をチェック"
        case 1:
            return "今、上下の歯が触れていた"
        case 2:
            return "顎に力が入っていた"
        case 3:
            return "舌は上顎についていた"
        case 4:
            return "肩、首に力が入っていた"
        case 5:
            return "ストレスを感じていた"
        default:
            return "記録する"
        }
    }

    private var stepCaption: String? {
        switch currentStep {
        case 0:
            return "通知が来た時、作業の区切り、気づいた時に短く確認します。"
        case 6:
            return "ここまでの回答を現在時刻で保存します。"
        default:
            return nil
        }
    }

    private func answer(_ value: Bool) {
        switch currentStep {
        case 1:
            teethTouching = value
        case 2:
            jawTension = value
        case 3:
            tonguePosition = value
        case 4:
            shoulderTension = value
        case 5:
            stress = value
        default:
            break
        }

        withAnimation(.easeInOut) {
            currentStep = min(6, currentStep + 1)
        }
    }

    private func save() {
        let now = Date()
        let log = CheckLog(
            id: UUID(),
            timestamp: now,
            teethTouching: teethTouching,
            jawTension: jawTension,
            tonguePosition: tonguePosition,
            shoulderTension: shoulderTension,
            stress: stress
        )
        store.addCheckLog(log)
        savedAt = now
        currentStep = 0
        teethTouching = false
        jawTension = false
        tonguePosition = true
        shoulderTension = false
        stress = false
    }

    private func savedView(savedAt: Date) -> some View {
        VStack(spacing: 18) {
            Text("\(savedAt.formatted(date: .omitted, time: .shortened)) に記録しました")
                .font(.title2.bold())
                .foregroundStyle(.teal)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                Text("唇は閉じる、歯は離す、舌は上顎")
                Text("深呼吸3回")
                Text("顎・肩の力を抜く")
            }
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Button("もう一度チェックする") {
                withAnimation(.easeInOut) {
                    self.savedAt = nil
                    currentStep = 0
                }
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .padding(.top, 12)
        }
        .padding(.horizontal, 8)
    }
}
