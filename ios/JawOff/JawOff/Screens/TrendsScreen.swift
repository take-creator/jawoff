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
                        VStack(alignment: .leading, spacing: 16) {
                            Text("日別の記録")
                                .font(.title3.bold())

                            HStack(spacing: 14) {
                                LegendItem(title: "離れていた", color: TrendPalette.separated)
                                LegendItem(title: "触れていた", color: TrendPalette.touching)
                            }

                            ForEach(chartRows, id: \.dayKey) { row in
                                DailyStackedBarRow(row: row)
                            }
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
            let separated = checks.count - touching
            return TrendDay(
                dayKey: date.dayKey,
                label: date.formatted(.dateTime.month().day()),
                checkCount: checks.count,
                separatedCount: separated,
                touchingCount: touching
            )
        }
    }
}

private struct TrendDay {
    var dayKey: String
    var label: String
    var checkCount: Int
    var separatedCount: Int
    var touchingCount: Int

    var hasRecord: Bool {
        checkCount > 0
    }

    var separatedRatio: Double {
        guard checkCount > 0 else { return 0 }
        return Double(separatedCount) / Double(checkCount)
    }

    var touchingRatio: Double {
        guard checkCount > 0 else { return 0 }
        return Double(touchingCount) / Double(checkCount)
    }
}

private struct DailyStackedBarRow: View {
    var row: TrendDay

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .firstTextBaseline) {
                Text(row.label)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(row.hasRecord ? .primary : .secondary)
                Spacer()
                Text(row.hasRecord ? "合計 \(row.checkCount)回" : "記録なし")
                    .font(.caption.weight(.semibold).monospacedDigit())
                    .foregroundStyle(row.hasRecord ? TrendPalette.main : .secondary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(TrendPalette.progressBackground)

                    if row.hasRecord {
                        HStack(spacing: 0) {
                            Rectangle()
                                .fill(TrendPalette.separated)
                                .frame(width: geometry.size.width * CGFloat(row.separatedRatio))
                            Rectangle()
                                .fill(TrendPalette.touching)
                                .frame(width: geometry.size.width * CGFloat(row.touchingRatio))
                        }
                        .clipShape(Capsule())
                    }
                }
            }
            .frame(height: 24)

            if row.hasRecord {
                HStack(spacing: 12) {
                    Text("離れていた \(row.separatedCount)回")
                        .foregroundStyle(TrendPalette.separated)
                    Text("触れていた \(row.touchingCount)回")
                        .foregroundStyle(TrendPalette.touching)
                }
                .font(.caption.weight(.semibold).monospacedDigit())
            } else {
                Text("この日のチェックはありません")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct LegendItem: View {
    var title: String
    var color: Color

    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
        }
    }
}

private enum TrendPalette {
    static let main = Color(red: 24 / 255, green: 195 / 255, blue: 207 / 255)
    static let separated = Color(red: 45 / 255, green: 190 / 255, blue: 127 / 255)
    static let touching = Color(red: 244 / 255, green: 162 / 255, blue: 97 / 255)
    static let progressBackground = Color(red: 232 / 255, green: 234 / 255, blue: 240 / 255)
}
