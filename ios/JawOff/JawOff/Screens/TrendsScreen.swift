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
                            Text("症状スコア")
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
                            Text("チェック回数: \(chartRows.reduce(0) { $0 + $1.checkCount })回")
                                .font(.title3.bold())
                            Text("回数の多さよりも、気づいて力を抜けた回数として見ます。")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("推移")
        }
    }

    private var chartRows: [TrendDay] {
        Date.recentDays(days).map { date in
            let morning = store.morningLogs.first { $0.date.dayKey == date.dayKey }
            let checks = store.checkLogs.filter { $0.timestamp.dayKey == date.dayKey }
            return TrendDay(
                dayKey: date.dayKey,
                label: date.formatted(.dateTime.month().day()),
                jawFatigue: morning?.jawFatigue,
                masseterTension: morning?.masseterTension,
                toothFatigue: morning?.toothFatigue,
                checkCount: checks.count
            )
        }
    }
}

private struct TrendDay {
    var dayKey: String
    var label: String
    var jawFatigue: Int?
    var masseterTension: Int?
    var toothFatigue: Int?
    var checkCount: Int
}

private struct TrendRow: View {
    var row: TrendDay

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(row.label)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("チェック \(row.checkCount)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.teal)
            }

            TrendBar(label: "顎", value: row.jawFatigue, color: .teal)
            TrendBar(label: "エラ", value: row.masseterTension, color: .blue)
            TrendBar(label: "歯", value: row.toothFatigue, color: .orange)
        }
        .padding(.vertical, 8)
    }
}

private struct TrendBar: View {
    var label: String
    var value: Int?
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
                        .frame(width: geometry.size.width * CGFloat(value ?? 0) / 10)
                }
            }
            .frame(height: 8)
            Text(value.map(String.init) ?? "-")
                .font(.caption.monospacedDigit())
                .frame(width: 20, alignment: .trailing)
        }
    }
}
