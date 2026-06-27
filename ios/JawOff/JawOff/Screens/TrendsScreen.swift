import SwiftUI

struct TrendsScreen: View {
    @EnvironmentObject private var store: AppStore
    @State private var period: TrendPeriod = .oneMonth

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    periodSelector

                    AppCard {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .firstTextBaseline) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("記録の推移")
                                        .font(.title3.bold())
                                    Text(period.bucketLabel)
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text("合計 \(totalCount)回")
                                    .font(.caption.weight(.semibold).monospacedDigit())
                                    .foregroundStyle(TrendPalette.main)
                            }

                            HStack(spacing: 14) {
                                LegendItem(title: "離れていた", color: TrendPalette.separated)
                                LegendItem(title: "触れていた", color: TrendPalette.touching)
                            }

                            StackedBarChart(buckets: chartBuckets)

                            if totalCount == 0 {
                                Text("この期間の記録はまだありません")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            } else {
                                summaryRow
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

    private var periodSelector: some View {
        AppCard {
            HStack {
                Text("期間")
                    .font(.headline)
                Spacer()
                Menu {
                    ForEach(TrendPeriod.allCases) { item in
                        Button(item.title) {
                            period = item
                        }
                    }
                } label: {
                    HStack(spacing: 6) {
                        Text(period.title)
                            .font(.headline)
                        Image(systemName: "chevron.down")
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(TrendPalette.main)
                }
            }
        }
    }

    private var chartBuckets: [TrendBucket] {
        period.makeBuckets(from: store.checkLogs)
    }

    private var totalSeparated: Int {
        chartBuckets.reduce(0) { $0 + $1.separatedCount }
    }

    private var totalTouching: Int {
        chartBuckets.reduce(0) { $0 + $1.touchingCount }
    }

    private var totalCount: Int {
        totalSeparated + totalTouching
    }

    private var separatedPercent: Int {
        guard totalCount > 0 else { return 0 }
        return Int((Double(totalSeparated) / Double(totalCount) * 100).rounded())
    }

    private var summaryRow: some View {
        HStack(spacing: 14) {
            SummaryPill(title: "離れていた", count: totalSeparated, percent: separatedPercent, color: TrendPalette.separated)
            SummaryPill(title: "触れていた", count: totalTouching, percent: 100 - separatedPercent, color: TrendPalette.touching)
        }
    }
}

private enum TrendPeriod: String, CaseIterable, Identifiable {
    case oneMonth
    case sixMonths
    case oneYear

    var id: String { rawValue }

    var title: String {
        switch self {
        case .oneMonth:
            return "1ヶ月"
        case .sixMonths:
            return "半年"
        case .oneYear:
            return "1年"
        }
    }

    var bucketLabel: String {
        switch self {
        case .oneMonth:
            return "日ごとの記録"
        case .sixMonths, .oneYear:
            return "週ごとの記録"
        }
    }

    func makeBuckets(from logs: [CheckLog]) -> [TrendBucket] {
        switch self {
        case .oneMonth:
            return makeDailyBuckets(days: 30, logs: logs)
        case .sixMonths:
            return makeWeeklyBuckets(weeks: 26, logs: logs)
        case .oneYear:
            return makeWeeklyBuckets(weeks: 52, logs: logs)
        }
    }

    private func makeDailyBuckets(days: Int, logs: [CheckLog]) -> [TrendBucket] {
        Date.recentDays(days).map { date in
            let dayLogs = logs.filter { $0.timestamp.dayKey == date.dayKey }
            let touching = dayLogs.filter(\.teethTouching).count
            return TrendBucket(
                id: date.dayKey,
                label: date.formatted(.dateTime.month().day()),
                separatedCount: dayLogs.count - touching,
                touchingCount: touching
            )
        }
    }

    private func makeWeeklyBuckets(weeks: Int, logs: [CheckLog]) -> [TrendBucket] {
        let calendar = Calendar.current
        let startOfThisWeek = calendar.dateInterval(of: .weekOfYear, for: Date())?.start ?? calendar.startOfDay(for: Date())

        return (0..<weeks).compactMap { offset in
            guard let start = calendar.date(byAdding: .weekOfYear, value: offset - weeks + 1, to: startOfThisWeek),
                  let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start) else {
                return nil
            }
            let weekLogs = logs.filter { $0.timestamp >= start && $0.timestamp < end }
            let touching = weekLogs.filter(\.teethTouching).count
            return TrendBucket(
                id: start.dayKey,
                label: start.formatted(.dateTime.month().day()),
                separatedCount: weekLogs.count - touching,
                touchingCount: touching
            )
        }
    }
}

private struct TrendBucket: Identifiable {
    var id: String
    var label: String
    var separatedCount: Int
    var touchingCount: Int

    var totalCount: Int {
        separatedCount + touchingCount
    }

    var hasRecord: Bool {
        totalCount > 0
    }
}

private struct StackedBarChart: View {
    var buckets: [TrendBucket]

    private var maxCount: Int {
        max(buckets.map(\.totalCount).max() ?? 0, 1)
    }

    private var barWidth: CGFloat {
        buckets.count > 30 ? 10 : 16
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .bottom, spacing: buckets.count > 30 ? 6 : 8) {
                ForEach(buckets) { bucket in
                    VStack(spacing: 8) {
                        ZStack(alignment: .bottom) {
                            Capsule()
                                .fill(TrendPalette.progressBackground)
                                .frame(width: barWidth, height: 150)

                            if bucket.hasRecord {
                                VStack(spacing: 0) {
                                    Rectangle()
                                        .fill(TrendPalette.touching)
                                        .frame(height: segmentHeight(bucket.touchingCount))
                                    Rectangle()
                                        .fill(TrendPalette.separated)
                                        .frame(height: segmentHeight(bucket.separatedCount))
                                }
                                .frame(width: barWidth)
                                .clipShape(Capsule())
                            }
                        }

                        Text(bucket.label)
                            .font(.caption2)
                            .foregroundStyle(bucket.hasRecord ? .secondary : Color.secondary.opacity(0.45))
                            .rotationEffect(.degrees(-45))
                            .frame(width: 34, height: 26)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(bucket.label)、離れていた \(bucket.separatedCount)回、触れていた \(bucket.touchingCount)回")
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 2)
        }
    }

    private func segmentHeight(_ count: Int) -> CGFloat {
        guard count > 0 else { return 0 }
        return max(4, 150 * CGFloat(count) / CGFloat(maxCount))
    }
}

private struct SummaryPill: View {
    var title: String
    var count: Int
    var percent: Int
    var color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(color)
                    .frame(width: 9, height: 9)
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
            Text("\(percent)%")
                .font(.title3.bold().monospacedDigit())
                .foregroundStyle(color)
            Text("\(count)回")
                .font(.caption.weight(.semibold).monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(color.opacity(0.10))
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
