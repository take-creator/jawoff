import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selectedTab: AppTab
    @Binding var isCheckPresented: Bool

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
                                Text("起床時の噛み締め感を残すと、変化を見返しやすくなります。")
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
                    .foregroundStyle(HomePalette.main)
                Text("食いしばりは気づく回数を増やすことが大切です")
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
                    .fixedSize(horizontal: false, vertical: true)
                Text("通知が来たら、今の歯の状態をワンタップで記録します。")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button("今チェックする") {
                    isCheckPresented = true
                }
                .buttonStyle(HomePrimaryButtonStyle())
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
                    color: HomePalette.separated
                )

                ProgressBarRow(
                    title: "触れていた",
                    count: touchingCount,
                    ratio: touchingRatio,
                    color: HomePalette.touching
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
                        .foregroundStyle(.primary)
                }

                Spacer()

                Text(percentText)
                    .font(.title3.bold().monospacedDigit())
                    .foregroundStyle(color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(HomePalette.progressBackground)
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

private enum HomePalette {
    static let main = Color(red: 24 / 255, green: 195 / 255, blue: 207 / 255)
    static let separated = Color(red: 45 / 255, green: 190 / 255, blue: 127 / 255)
    static let touching = Color(red: 244 / 255, green: 162 / 255, blue: 97 / 255)
    static let progressBackground = Color(red: 232 / 255, green: 234 / 255, blue: 240 / 255)
}

private struct HomePrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(HomePalette.main)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
