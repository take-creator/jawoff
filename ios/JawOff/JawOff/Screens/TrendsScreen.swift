import SwiftUI

struct TrendsScreen: View {
    @EnvironmentObject private var store: AppStore
    @State private var days = 7

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Picker("期間", selection: $days) {
                        Text("7日").tag(7)
                        Text("30日").tag(30)
                    }
                    .pickerStyle(.segmented)

                    AppCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Jaw Awareness Score")
                                .font(.headline)
                            ForEach(chartRows, id: \.dayKey) { row in
                                TrendRow(row: row)
                            }
                        }
                    }

                    AppCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("直近のチェック傾向")
                                .font(.headline)
                            Text("チェック回数: \(totalChecks)回")
                                .font(.title3.bold())
                            Text("触れていた率: \(touchingRateText(totalTouchingRate))")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.teal)
                            Text("触れていた時も、気づけた記録として前向きに見返します。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .padding(.bottom, 104)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("推移")
        }
    }

    private var chartRows: [TrendDay] {
        Date.recentDays(days).map { date in
            let checks = store.checkLogs.filter { $0.timestamp.dayKey == date.dayKey }
            let touching = checks.filter(\.teethTouching).count
            return TrendDay(
                dayKey: date.dayKey,
                label: date.formatted(.dateTime.month().day()),
                score: store.awarenessScore(on: date),
                checkCount: checks.count,
                touchingRate: store.touchingRate(on: date),
                touchingCount: touching
            )
        }
    }

    private var totalChecks: Int {
        chartRows.reduce(0) { $0 + $1.checkCount }
    }

    private var totalTouchingRate: Int? {
        guard totalChecks > 0 else { return nil }
        let touching = chartRows.reduce(0) { $0 + $1.touchingCount }
        return Int((Double(touching) / Double(totalChecks) * 100).rounded())
    }
}

private struct TrendDay {
    var dayKey: String
    var label: String
    var score: Int?
    var checkCount: Int
    var touchingRate: Int?
    var touchingCount: Int
}

private struct TrendRow: View {
    var row: TrendDay

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(row.label)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("チェック \(row.checkCount)回")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
            }

            TrendBar(label: "スコア", value: row.score.map { Double($0) / 100 }, display: scoreText(row.score), color: .teal)
            TrendBar(label: "回数", value: min(Double(row.checkCount) / 12, 1), display: "\(row.checkCount)", color: .blue)
            TrendBar(label: "触れ率", value: row.touchingRate.map { Double($0) / 100 }, display: touchingRateText(row.touchingRate), color: .orange)
        }
        .padding(.vertical, 8)
    }

    private func scoreText(_ score: Int?) -> String {
        guard let score else { return "-" }
        return "\(score)"
    }
}

private struct TrendBar: View {
    var label: String
    var value: Double?
    var display: String
    var color: Color

    var body: some View {
        HStack(spacing: 8) {
            Text(label)
                .font(.caption)
                .frame(width: 32, alignment: .leading)
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(.systemGray5))
                    Capsule()
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(max(0, min(value ?? 0, 1))))
                }
            }
            .frame(height: 8)
            Text(display)
                .font(.caption.monospacedDigit())
                .frame(width: 44, alignment: .trailing)
        }
    }
}

private func touchingRateText(_ rate: Int?) -> String {
    guard let rate else { return "-" }
    return "\(rate)%"
}
