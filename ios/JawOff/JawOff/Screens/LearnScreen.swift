import SwiftUI

struct LearnScreen: View {
    private let cards: [LearningCard] = [
        LearningCard(
            category: "基礎知識",
            icon: "brain.head.profile",
            title: "通常、上下の歯は離れている",
            text: "安静時は唇を軽く閉じ、上下の歯の間には少しすき間がある状態が目安です。"
        ),
        LearningCard(
            category: "基礎知識",
            icon: "face.smiling",
            title: "食いしばりは無自覚で起こりやすい",
            text: "集中、緊張、スマホ操作、作業中などに、気づかないまま歯が触れていることがあります。"
        ),
        LearningCard(
            category: "ワンポイント",
            icon: "lightbulb.fill",
            title: "TCH改善は気づく回数を増やすことが重要",
            text: "完全に防ぐよりも、触れていることに気づき、すぐ力を抜く回数を増やします。"
        ),
        LearningCard(
            category: "FAQ",
            icon: "moon.stars.fill",
            title: "夜間の食いしばりは完全制御が難しい",
            text: "睡眠中は自分でコントロールしにくいため、日中の癖から整えるのが現実的です。"
        ),
        LearningCard(
            category: "セルフケア",
            icon: "checkmark.circle.fill",
            title: "日中の歯の接触時間を減らすことが第一歩",
            text: "短いチェックを重ねることで、顎や首肩への負担を減らすきっかけを作ります。"
        ),
        LearningCard(
            category: "FAQ",
            icon: "cross.case.fill",
            title: "顎が痛い場合は歯科医に相談",
            text: "痛み、口の開けづらさ、歯の違和感が強い場合は、セルフケアだけで判断しないでください。"
        )
    ]

    var body: some View {
        ScreenContainer(
            title: "学習",
            subtitle: "食いしばりとTCHを、短いカードで少しずつ理解します。"
        ) {
            categorySummary

            ForEach(cards) { card in
                LearningInfoCard(card: card)
            }

            DisclaimerView()
        }
    }

    private var categorySummary: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    icon: "book.closed.fill",
                    title: "カテゴリ",
                    subtitle: "必要なカードだけ拾い読みできます。"
                )

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    CategoryPill(icon: "brain.head.profile", title: "基礎知識")
                    CategoryPill(icon: "lightbulb.fill", title: "ワンポイント")
                    CategoryPill(icon: "checkmark.circle.fill", title: "セルフケア")
                    CategoryPill(icon: "questionmark.circle.fill", title: "FAQ")
                }
            }
        }
    }
}

private struct LearningCard: Identifiable {
    let id = UUID()
    var category: String
    var icon: String
    var title: String
    var text: String
}

private struct LearningInfoCard: View {
    var card: LearningCard

    var body: some View {
        AppCard {
            HStack(alignment: .top, spacing: 14) {
                IconBadge(systemName: card.icon, size: 46)

                VStack(alignment: .leading, spacing: 8) {
                    Text(card.category)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppDesign.Color.brandDeep)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(AppDesign.Color.brand.opacity(0.10))
                        .clipShape(Capsule())

                    Text(card.title)
                        .font(.headline.weight(.bold))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(card.text)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

private struct CategoryPill: View {
    var icon: String
    var title: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(AppDesign.Color.brand)
            Text(title)
                .font(.caption.weight(.bold))
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppDesign.Color.secondarySurface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}
