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
                        HomeCountCard(title: "触れていた", value: "\(store.todayTouchingCount)", caption: "食いしばりに気づけた回数")
                        HomeCountCard(title: "離れていた", value: "\(store.todaySeparatedCount)", caption: "歯を離せていた回数")
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

private struct HomeCountCard: View {
    var title: String
    var value: String
    var caption: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.title3.bold())
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(value)
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .monospacedDigit()

            Text(caption)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.white.opacity(0.86))
                .lineLimit(2)
                .minimumScaleFactor(0.78)
        }
        .frame(maxWidth: .infinity, minHeight: 124, alignment: .leading)
        .padding()
        .background(Color.teal)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.teal.opacity(0.24), radius: 14, x: 0, y: 8)
    }
}
