import SwiftUI

struct MorningLogScreen: View {
    @EnvironmentObject private var store: AppStore
    @State private var jawFatigue = 0.0
    @State private var masseterTension = 0.0
    @State private var toothFatigue = 0.0
    @State private var headache = 0.0
    @State private var shoulderStiffness = 0.0
    @State private var sleepQuality = 5.0
    @State private var memo = ""
    @State private var saved = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("起きた時の状態")
                                .font(.title2.bold())
                            Text("0〜10でざっくり記録します。同じ基準で続けることを優先します。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ScoreSlider(title: "顎のだるさ", value: $jawFatigue)
                    ScoreSlider(title: "エラの張り感", value: $masseterTension)
                    ScoreSlider(title: "歯の疲れ", value: $toothFatigue)
                    ScoreSlider(title: "頭痛", value: $headache)
                    ScoreSlider(title: "肩こり", value: $shoulderStiffness)
                    ScoreSlider(title: "睡眠の質", value: $sleepQuality)

                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("自由メモ")
                                .font(.headline)
                            TextEditor(text: $memo)
                                .frame(minHeight: 110)
                                .padding(8)
                                .background(Color(.secondarySystemGroupedBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    Button("朝ログを保存する") {
                        save()
                    }
                    .buttonStyle(PrimaryActionButtonStyle())

                    if saved {
                        Text("今日の朝ログを保存しました。")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.teal)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .background(Color.teal.opacity(0.12))
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("朝ログ")
            .onAppear(perform: loadToday)
        }
    }

    private func loadToday() {
        guard let log = store.todayMorningLog else { return }
        jawFatigue = Double(log.jawFatigue)
        masseterTension = Double(log.masseterTension)
        toothFatigue = Double(log.toothFatigue)
        headache = Double(log.headache)
        shoulderStiffness = Double(log.shoulderStiffness)
        sleepQuality = Double(log.sleepQuality)
        memo = log.memo
    }

    private func save() {
        let log = MorningLog(
            id: store.todayMorningLog?.id ?? UUID(),
            date: Date(),
            jawFatigue: Int(jawFatigue),
            masseterTension: Int(masseterTension),
            toothFatigue: Int(toothFatigue),
            headache: Int(headache),
            shoulderStiffness: Int(shoulderStiffness),
            sleepQuality: Int(sleepQuality),
            memo: memo
        )
        store.saveMorningLog(log)
        saved = true
    }
}
