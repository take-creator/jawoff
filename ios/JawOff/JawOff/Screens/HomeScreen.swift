import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selectedTab: AppTab

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    heroCard

                    TodayBalanceCard(
                        touchingCount: store.todayTouchingCount,
                        separatedCount: store.todaySeparatedCount
                    )

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
                Text("通知が来たら、今の歯の状態をワンタップで記録します。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("今チェックする") {
                    selectedTab = .check
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
        }
    }

}

private struct TodayBalanceCard: View {
    var touchingCount: Int
    var separatedCount: Int

    private var totalCount: Int {
        touchingCount + separatedCount
    }

    private var touchingRatio: Double {
        ratio(for: touchingCount)
    }

    private var separatedRatio: Double {
        ratio(for: separatedCount)
    }

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 18) {
                Text("今日の歯の状態")
                    .font(.headline)

                if totalCount == 0 {
                    Text("まだ記録がありません")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                ProgressBarRow(
                    title: "離れていた",
                    count: separatedCount,
                    ratio: separatedRatio,
                    color: .green
                )

                ProgressBarRow(
                    title: "触れていた",
                    count: touchingCount,
                    ratio: touchingRatio,
                    color: .red
                )
            }
        }
    }

    private func ratio(for count: Int) -> Double {
        guard totalCount > 0 else { return 0 }
        return Double(count) / Double(totalCount)
    }
}

private struct ProgressBarRow: View {
    var title: String
    var count: Int
    var ratio: Double
    var color: Color

    private var percentText: String {
        "\(Int((ratio * 100).rounded()))%"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(color)
                        .frame(width: 11, height: 11)
                    Text(title)
                        .font(.title3.bold())
                }

                Spacer()

                Text(percentText)
                    .font(.title3.bold().monospacedDigit())
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.systemGray5))
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(ratio))
                }
            }
            .frame(height: 22)

            Text("\(count)回")
                .font(.headline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}
