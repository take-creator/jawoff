import SwiftUI

struct CheckScreen: View {
    @EnvironmentObject private var store: AppStore
    @State private var teethTouching = false
    @State private var jawTension = false
    @State private var tonguePosition = true
    @State private var shoulderTension = false
    @State private var stress = false
    @State private var savedAt: Date?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("今の状態をチェック")
                                .font(.title2.bold())
                            Text("通知が来た時、作業の区切り、気づいた時に記録します。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ToggleRow(title: "今、上下の歯が触れていた", subtitle: "軽く触れているだけでもオン", isOn: $teethTouching)
                    ToggleRow(title: "顎に力が入っていた", subtitle: "噛む力やこわばり", isOn: $jawTension)
                    ToggleRow(title: "舌は上顎についていた", subtitle: "リラックスした置き場所", isOn: $tonguePosition)
                    ToggleRow(title: "肩・首に力が入っていた", subtitle: "姿勢や緊張も一緒に確認", isOn: $shoulderTension)
                    ToggleRow(title: "ストレスを感じていた", subtitle: "集中・焦り・考えごと", isOn: $stress)

                    Button("現在時刻で記録する") {
                        save()
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    if let savedAt {
                        AppCard(tint: Color.teal.opacity(0.12)) {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("\(savedAt.formatted(date: .omitted, time: .shortened)) に記録しました")
                                    .font(.headline)
                                    .foregroundStyle(.teal)
                                Text("唇は閉じる、歯は離す、舌は上顎")
                                Text("深呼吸3回")
                                Text("顎・肩の力を抜く")
                            }
                            .font(.subheadline)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 104)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("チェック")
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
        teethTouching = false
        jawTension = false
        tonguePosition = true
        shoulderTension = false
        stress = false
    }
}
