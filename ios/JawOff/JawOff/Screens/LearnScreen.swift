import SwiftUI

struct LearnScreen: View {
    private let cards = [
        ("通常、上下の歯は離れている", "安静時は唇を軽く閉じ、上下の歯の間には少しすき間がある状態が目安です。"),
        ("食いしばりは無自覚で起こりやすい", "集中、緊張、スマホ操作、作業中などに、気づかないまま歯が触れていることがあります。"),
        ("TCH改善は気づく回数を増やすことが重要", "完全に防ぐよりも、触れていることに気づき、すぐ力を抜く回数を増やします。"),
        ("夜間の食いしばりは完全制御が難しい", "睡眠中は自分でコントロールしにくいため、日中の癖から整えるのが現実的です。"),
        ("日中の歯の接触時間を減らすことが第一歩", "短いチェックを重ねることで、顎や首肩への負担を減らすきっかけを作ります。"),
        ("顎が痛い場合は歯科医に相談", "痛み、口の開けづらさ、歯の違和感が強い場合は、セルフケアだけで判断しないでください。")
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(cards, id: \.0) { card in
                        AppCard {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(card.0)
                                    .font(.headline)
                                Text(card.1)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("月1写真記録ガイド")
                                .font(.headline)
                            Text("画像保存はMVPでは未実装です。同じ照明・同じ距離・無表情で、正面・左右45度・横顔を撮影します。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(["正面", "右45度", "左45度", "横顔"], id: \.self) { pose in
                                    Text(pose)
                                        .font(.subheadline.weight(.semibold))
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color(.secondarySystemGroupedBackground))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                }
                            }
                        }
                    }

                    DisclaimerView()
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("学習")
        }
    }
}
