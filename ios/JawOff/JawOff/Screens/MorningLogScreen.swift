import SwiftUI

struct MorningLogScreen: View {
    @EnvironmentObject private var store: AppStore
    @State private var morningClenchingLevel = 5.0
    @State private var saved = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    AppCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("起床時の噛み締め感")
                                .font(.title2.bold())
                            Text("朝起きた瞬間の感覚で回答してください。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    ScoreSlider(
                        title: "起床時の噛み締め感",
                        subtitle: "朝起きた瞬間の感覚で回答してください。",
                        leftLabel: "",
                        rightLabel: "強い",
                        value: $morningClenchingLevel
                    )

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
                .padding(.top, 8)
                .padding(.bottom, 104)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("朝ログ")
            .onAppear(perform: loadToday)
        }
    }

    private func loadToday() {
        guard let log = store.todayMorningLog else { return }
        morningClenchingLevel = Double(log.morningClenchingLevel)
    }

    private func save() {
        let log = MorningLog(
            id: store.todayMorningLog?.id ?? UUID(),
            date: Date(),
            morningClenchingLevel: Int(morningClenchingLevel)
        )
        store.saveMorningLog(log)
        saved = true
    }
}
