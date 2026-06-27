import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selectedTab: AppTab

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    heroCard

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        MetricCard(title: "今日の通知", value: "\(store.todayReminderLogs.count)", caption: "表示記録")
                        MetricCard(title: "チェック", value: "\(store.todayChecks.count)", caption: "今日の回数")
                        MetricCard(title: "顎の疲労", value: store.todayMorningLog.map { "\($0.jawFatigue)" } ?? "-", caption: "朝ログ")
                        MetricCard(title: "最後の記録", value: lastCheckTime, caption: "チェック時刻")
                    }

                    if store.todayMorningLog == nil {
                        AppCard {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("朝の症状ログが未記録です")
                                    .font(.headline)
                                Text("顎のだるさや睡眠の質を残すと、変化を見返しやすくなります。")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Button("朝ログをつける") {
                                    selectedTab = .morning
                                }
                                .buttonStyle(SecondaryActionButtonStyle())
                            }
                        }
                    }

                    DisclaimerView()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("歯を離す")
        }
    }

    private var heroCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("1時間ごとの小さな確認")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.teal)
                Text("唇は閉じる、歯は離す、舌は上顎")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                Text("通知が来たらアプリを開き、今の噛み締め状態を短く記録します。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("今チェックする") {
                    selectedTab = .check
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
        }
    }

    private var lastCheckTime: String {
        guard let latest = store.todayChecks.last else { return "-" }
        return latest.timestamp.formatted(date: .omitted, time: .shortened)
    }
}
