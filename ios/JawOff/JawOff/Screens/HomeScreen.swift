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
                        MetricCard(title: "今日のスコア", value: scoreText(store.todayAwarenessScore), caption: "Jaw Awareness")
                        MetricCard(title: "チェック", value: "\(store.todayChecks.count)", caption: "今日の回数")
                        MetricCard(title: "触れていた", value: "\(store.todayTouchingCount)", caption: "気づけた回数")
                        MetricCard(title: "離れていた", value: "\(store.todaySeparatedCount)", caption: "保てていた回数")
                        MetricCard(title: "前日比", value: changeText(store.awarenessScoreChangeFromYesterday), caption: "昨日との差")
                        MetricCard(title: "7日平均", value: scoreText(store.sevenDayAverageAwarenessScore), caption: "平均スコア")
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
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 120)
            }
            .background(Color(.systemGroupedBackground))
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var heroCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("小さな確認を積み重ねる")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.teal)
                Text("唇は閉じる、歯は離す、舌は上顎")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                Text("通知が来たらワンタップで今の状態を記録します。触れていた時も、気づけたことが改善の一歩です。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("今チェックする") {
                    selectedTab = .check
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
        }
    }

    private func scoreText(_ score: Int?) -> String {
        guard let score else { return "-" }
        return "\(score)"
    }

    private func changeText(_ change: Int?) -> String {
        guard let change else { return "-" }
        if change > 0 { return "+\(change)" }
        return "\(change)"
    }
}
