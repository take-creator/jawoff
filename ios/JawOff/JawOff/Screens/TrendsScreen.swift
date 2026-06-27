import SwiftUI

struct TrendsScreen: View {
    @EnvironmentObject private var store: AppStore
    @State private var startDate = Calendar.current.startOfDay(for: Date())
    @State private var endDate = Calendar.current.startOfDay(for: Date())
    @State private var didSetInitialRange = false

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
                                    Text("日ごとの記録")
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
            .onAppear {
                setInitialRangeIfNeeded()
            }
            .onChange(of: startDate) { _, newValue in
                if newValue > endDate {
                    endDate = newValue
                }
            }
            .onChange(of: endDate) { _, newValue in
                if newValue < startDate {
                    startDate = newValue
                }
            }
        }
    }

    private var periodSelector: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                Text("期間")
                    .font(.headline)

                VStack(spacing: 10) {
                    HStack {
                        Text("開始")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        DatePicker(
                            "開始",
                            selection: $startDate,
                            in: appStartDate...endDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    }

                    HStack {
                        Text("終了")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Spacer()
                        DatePicker(
                            "終了",
                            selection: $endDate,
                            in: startDate...todayDate,
                            displayedComponents: .date
                        )
                        .labelsHidden()
                        .datePickerStyle(.compact)
                    }
                }

                Button("アプリ開始日から今日まで") {
                    startDate = appStartDate
                    endDate = todayDate
                }
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TrendPalette.main)
            }
        }
    }

    private var chartBuckets: [TrendBucket] {
        makeDailyBuckets(from: startDate, through: endDate, logs: store.checkLogs)
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

    private var appStartDate: Date {
        let calendar = Calendar.current
        let firstCheck = store.checkLogs.map(\.timestamp).min()
        return calendar.startOfDay(for: firstCheck ?? Date())
    }

    private var todayDate: Date {
        Calendar.current.startOfDay(for: Date())
    }

    private func setInitialRangeIfNeeded() {
        guard !didSetInitialRange else { return }
        startDate = appStartDate
        endDate = todayDate
        didSetInitialRange = true
    }

    private func makeDailyBuckets(from start: Date, through end: Date, logs: [CheckLog]) -> [TrendBucket] {
        let calendar = Calendar.current
        let normalizedStart = calendar.startOfDay(for: min(start, end))
        let normalizedEnd = calendar.startOfDay(for: max(start, end))
        let dayCount = calendar.dateComponents([.day], from: normalizedStart, to: normalizedEnd).day ?? 0

        return (0...dayCount).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: normalizedStart) else {
                return nil
            }
            let dayLogs = logs.filter { $0.timestamp.dayKey == date.dayKey }
            let touching = dayLogs.filter(\.teethTouching).count
            return TrendBucket(
                id: date.dayKey,
                label: Self.shortDateFormatter.string(from: date),
                separatedCount: dayLogs.count - touching,
                touchingCount: touching
            )
        }
    }

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "M/d"
        return formatter
    }()
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
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(width: 42, height: 18)
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
