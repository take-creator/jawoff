import SwiftUI

struct MorningLogScreen: View {
    @EnvironmentObject private var store: AppStore
    @State private var morningClenchingDetected: Bool?
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

                    AppCard {
                        VStack(alignment: .leading, spacing: 18) {
                            Text("朝起きた時、噛み締めていた感覚はありましたか？")
                                .font(.headline)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 12) {
                                MorningChoiceButton(
                                    title: "はい",
                                    isSelected: morningClenchingDetected == true
                                ) {
                                    morningClenchingDetected = true
                                    saved = false
                                }

                                MorningChoiceButton(
                                    title: "いいえ",
                                    isSelected: morningClenchingDetected == false
                                ) {
                                    morningClenchingDetected = false
                                    saved = false
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
        saved = true
    }
}

private struct MorningChoiceButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(isSelected ? Color.teal : Color(.secondarySystemGroupedBackground))
                .foregroundStyle(isSelected ? .white : .primary)
                .overlay {
                    RoundedRectangle(cornerRadius: 18)
                        .stroke(isSelected ? Color.teal : Color(.separator), lineWidth: 1)
                }
                .clipShape(RoundedRectangle(cornerRadius: 18))
        }
        .buttonStyle(.plain)
    }
}
