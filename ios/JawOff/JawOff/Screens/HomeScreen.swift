import SwiftUI

struct HomeScreen: View {
    @EnvironmentObject private var store: AppStore
    @Binding var selectedTab: AppTab
    @Binding var isCheckPresented: Bool

    var body: some View {
        ScreenContainer(
            title: "ホーム",
            subtitle: "気づく回数を増やして、歯が触れている時間を少しずつ減らします。"
        ) {
            heroCard

            TodayBalanceCard(
                touchingCount: store.todayTouchingCount,
                separatedCount: store.todaySeparatedCount
            )

            if store.todayMorningLog == nil {
                InfoCard(
                    icon: "sun.max.fill",
                    title: "朝ログが未記録です",
                    subtitle: "起床時の噛み締め感を残すと、日中の記録と合わせて変化を見返しやすくなります。"
                )

                Button("朝ログをつける") {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedTab = .morning
                    }
                }
                .buttonStyle(SecondaryActionButtonStyle())
            }

            quickTips
            DisclaimerView()
        }
    }

    private var heroCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    IconBadge(systemName: "brain.head.profile", size: 48)
                    VStack(alignment: .leading, spacing: 6) {
                        Text("気づくことが、変わる第一歩。")
                            .font(.title2.weight(.bold))
                            .fixedSize(horizontal: false, vertical: true)
                        Text("通知が来たら、今の歯の状態をワンタップで確認します。")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Button("今チェックする") {
                    withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                        isCheckPresented = true
                    }
                }
                .buttonStyle(PrimaryActionButtonStyle())
            }
        }
    }

    private var quickTips: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    icon: "sparkles",
                    title: "今日の使い方",
                    subtitle: "記録は細かくなくて大丈夫です。気づいた瞬間に残すことを優先します。"
                )

                VStack(spacing: 12) {
                    TipRow(icon: "bell.badge.fill", title: "通知で気づく", subtitle: "日中だけ、設定した間隔で確認します。")
                    TipRow(icon: "checkmark.circle.fill", title: "歯を離す", subtitle: "触れていたら、奥歯を離して肩の力を抜きます。")
                    TipRow(icon: "chart.line.uptrend.xyaxis", title: "振り返る", subtitle: "記録画面で、離れていた割合を見返します。")
                }
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
            VStack(alignment: .leading, spacing: 20) {
                SectionHeader(
                    icon: "chart.pie.fill",
                    title: "今日の歯の状態",
                    subtitle: totalCount == 0 ? "まだ記録がありません。まずは1回チェックしてみましょう。" : "今日のセルフチェック \(totalCount)回"
                )

                VStack(spacing: 18) {
                    ProgressBarRow(
                        title: "離れていた",
                        count: separatedCount,
                        ratio: separatedRatio,
                        color: AppDesign.Color.success
                    )

                    ProgressBarRow(
                        title: "触れていた",
                        count: touchingCount,
                        ratio: touchingRatio,
                        color: AppDesign.Color.warning
                    )
                }
            }
        }
        .cardSectionAnimation(totalCount)
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
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(.primary)

                Spacer()

                Text(percentText)
                    .font(.title3.weight(.bold).monospacedDigit())
                    .foregroundStyle(color)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(AppDesign.Color.track)
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(ratio))
                        .animation(.spring(response: 0.45, dampingFraction: 0.88), value: ratio)
                }
            }
            .frame(height: 16)

            Text("\(count)回")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }
}

private struct TipRow: View {
    var icon: String
    var title: String
    var subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(AppDesign.Color.brand)
                .frame(width: 28, height: 28)
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.bold))
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
