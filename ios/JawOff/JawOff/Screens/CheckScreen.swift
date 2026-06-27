import SwiftUI

struct CheckScreen: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selectedTab: AppTab
    @State private var result: QuickCheckResult?

    var body: some View {
        NavigationStack {
            VStack(spacing: 22) {
                Spacer(minLength: 24)

                if let result {
                    resultView(result)
                    Spacer(minLength: 24)
                } else {
                    questionView
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

    private var questionView: some View {
        VStack(spacing: 24) {
            Text("クイックチェック")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.teal)

            Text("今、上下の歯は触れていましたか？")
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .minimumScaleFactor(0.72)
                .lineLimit(3)
                .frame(maxWidth: .infinity)

            VStack(spacing: 14) {
                Button("はい、触れていた") {
                    save(teethTouching: true)
                }
                .buttonStyle(PrimaryActionButtonStyle())

                Button("いいえ、離れていた") {
                    save(teethTouching: false)
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }
            .padding(.top, 8)
        }
        .padding(.horizontal, 10)
    }

    private func resultView(_ result: QuickCheckResult) -> some View {
        VStack(spacing: 18) {
            Text(result.title)
                .font(.title2.bold())
                .foregroundStyle(.teal)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                Text("深呼吸3回")
                Text("奥歯を離す")
                Text("舌を上顎につける")
                Text("肩と顎の力を抜く")
            }
            .font(.body)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)

            Button("ホームに戻る") {
                withAnimation(.easeInOut) {
                    self.result = nil
                    selectedTab = .home
                }
            }
            .buttonStyle(PrimaryActionButtonStyle())
            .padding(.top, 12)
        }
        .padding(.horizontal, 8)
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
        withAnimation(.easeInOut) {
            result = QuickCheckResult(teethTouching: teethTouching)
        }
    }
}

private struct QuickCheckResult: Equatable {
    var teethTouching: Bool

    var title: String {
        teethTouching ? "気づけました" : "離せていました"
    }
}
