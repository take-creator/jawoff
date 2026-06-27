import SwiftUI

struct TrendsScreen: View {
    @EnvironmentObject private var store: AppStore
    @State private var startDate = Calendar.current.startOfDay(for: Date())
    @State private var endDate = Calendar.current.startOfDay(for: Date())
    @State private var didSetInitialRange = false
    @State private var selectedRecordKind: RecordKind = .checks

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    recordKindTabs
                    if selectedRecordKind.usesPeriod {
                        periodSelector
                    }

                    switch selectedRecordKind {
                    case .checks:
                        checkRecordsCard
                    case .morning:
                        morningRecordsCard
                    case .photo:
                        monthlyPhotoGuideCard
                    }
                }
                .padding()
                .padding(.bottom, 104)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("記録")
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

    private var recordKindTabs: some View {
        Picker("記録の種類", selection: $selectedRecordKind) {
            ForEach(RecordKind.allCases) { kind in
                Text(kind.title).tag(kind)
            }
        }
        .pickerStyle(.segmented)
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
            }
        }
    }

    private var chartBuckets: [TrendBucket] {
        makeDailyBuckets(from: startDate, through: endDate, logs: store.checkLogs)
    }

    private var morningBuckets: [MorningTrendBucket] {
        makeDailyMorningBuckets(from: startDate, through: endDate, logs: store.morningLogs)
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

    private var checkRecordsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("日別の記録")
                            .font(.title3.bold())
                        Text("歯の状態")
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
                    emptyText("この期間の記録はまだありません")
                } else {
                    summaryRow
                }
            }
        }
    }

    private var morningRecordsCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("朝ログの記録")
                            .font(.title3.bold())
                        Text("起床時の噛み締め感")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("合計 \(morningRecordedCount)日")
                        .font(.caption.weight(.semibold).monospacedDigit())
                        .foregroundStyle(TrendPalette.main)
                }

                HStack(spacing: 14) {
                    LegendItem(title: "はい", color: TrendPalette.touching)
                    LegendItem(title: "いいえ", color: TrendPalette.separated)
                }

                MorningDetectionHistory(buckets: morningBuckets)

                if morningRecordedCount == 0 {
                    emptyText("この期間の朝ログはまだありません")
                } else {
                    morningSummaryRow
                }
            }
        }
    }

    private var monthlyPhotoGuideCard: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("月1写真記録ガイド")
                        .font(.title3.bold())
                    Text("画像保存はMVPでは未実装です。毎月同じ条件で撮るためのガイドです。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Text("同じ照明・同じ距離・無表情で撮影します。")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(TrendPalette.main)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(TrendPalette.main.opacity(0.10))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

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
    }

    private var morningRecordedBuckets: [MorningTrendBucket] {
        morningBuckets.filter(\.hasRecord)
    }

    private var morningRecordedCount: Int {
        morningRecordedBuckets.count
    }

    private var weeklyMorningCounts: MorningDetectionCounts {
        morningCounts(in: .weekOfYear)
    }

    private var monthlyMorningCounts: MorningDetectionCounts {
        morningCounts(in: .month)
    }

    private var monthlyNoRate: Int {
        guard monthlyMorningCounts.total > 0 else { return 0 }
        return Int((Double(monthlyMorningCounts.noCount) / Double(monthlyMorningCounts.total) * 100).rounded())
    }

    private var morningSummaryRow: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 14) {
                MorningCountPill(title: "今週", counts: weeklyMorningCounts)
                MorningCountPill(title: "今月", counts: monthlyMorningCounts)
            }

            Text("今月は\(monthlyNoRate)%の日で朝の噛み締め感がありませんでした")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(TrendPalette.main)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(TrendPalette.main.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var appStartDate: Date {
        let calendar = Calendar.current
        let firstCheck = store.checkLogs.map(\.timestamp).min()
        let firstMorning = store.morningLogs.map(\.date).min()
        let firstRecord = [firstCheck, firstMorning].compactMap { $0 }.min()
        return calendar.startOfDay(for: firstRecord ?? Date())
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

    private func makeDailyMorningBuckets(from start: Date, through end: Date, logs: [MorningLog]) -> [MorningTrendBucket] {
        let calendar = Calendar.current
        let normalizedStart = calendar.startOfDay(for: min(start, end))
        let normalizedEnd = calendar.startOfDay(for: max(start, end))
        let dayCount = calendar.dateComponents([.day], from: normalizedStart, to: normalizedEnd).day ?? 0

        return (0...dayCount).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: offset, to: normalizedStart) else {
                return nil
            }
            let log = logs.first { $0.date.dayKey == date.dayKey }
            return MorningTrendBucket(
                id: date.dayKey,
                label: Self.shortDateFormatter.string(from: date),
                log: log
            )
        }
    }

    private func morningCounts(in component: Calendar.Component) -> MorningDetectionCounts {
        let calendar = Calendar.current
        guard let interval = calendar.dateInterval(of: component, for: Date()) else {
            return MorningDetectionCounts(yesCount: 0, noCount: 0)
        }
        let logs = store.morningLogs.filter { interval.contains($0.date) }
        return MorningDetectionCounts(
            yesCount: logs.filter(\.morningClenchingDetected).count,
            noCount: logs.filter { !$0.morningClenchingDetected }.count
        )
    }

    private func emptyText(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    private static let shortDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "M/d"
        return formatter
    }()
}

private enum RecordKind: String, CaseIterable, Identifiable {
    case checks
    case morning
    case photo

    var id: String { rawValue }

    var title: String {
        switch self {
        case .checks:
            return "歯の記録"
        case .morning:
            return "朝ログ"
        case .photo:
            return "写真"
        }
    }

    var usesPeriod: Bool {
        self != .photo
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

private struct MorningTrendBucket: Identifiable {
    var id: String
    var label: String
    var log: MorningLog?

    var hasRecord: Bool {
        log != nil
    }

    var morningClenchingDetected: Bool? {
        log?.morningClenchingDetected
    }
}

private struct MorningDetectionCounts {
    var yesCount: Int
    var noCount: Int

    var total: Int {
        yesCount + noCount
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

private struct MorningDetectionHistory: View {
    var buckets: [MorningTrendBucket]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: buckets.count > 30 ? 8 : 12) {
                ForEach(buckets) { bucket in
                    VStack(spacing: 8) { 
                        Circle()
                            .fill(circleColor(for: bucket))
                            .frame(width: buckets.count > 30 ? 16 : 22, height: buckets.count > 30 ? 16 : 22)
                            .overlay {
                                Circle()
                                    .stroke(TrendPalette.progressBackground, lineWidth: bucket.hasRecord ? 0 : 1)
                            }

                        Text(statusText(for: bucket))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(bucket.hasRecord ? .secondary : Color.secondary.opacity(0.45))

                        Text(bucket.label)
                            .font(.caption2)
                            .foregroundStyle(bucket.hasRecord ? .secondary : Color.secondary.opacity(0.45))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(width: 42, height: 18)
                    }
                    .accessibilityElement(children: .ignore)
                    .accessibilityLabel("\(bucket.label)、\(statusText(for: bucket))")
                }
            }
            .padding(.top, 8)
            .padding(.horizontal, 2)
        }
    }

    private func circleColor(for bucket: MorningTrendBucket) -> Color {
        switch bucket.morningClenchingDetected {
        case true:
            return TrendPalette.touching
        case false:
            return TrendPalette.separated
        case nil:
            return TrendPalette.progressBackground
        }
    }

    private func statusText(for bucket: MorningTrendBucket) -> String {
        switch bucket.morningClenchingDetected {
        case true:
            return "はい"
        case false:
            return "いいえ"
        case nil:
            return "未記録"
        }
    }
}

private struct MorningCountPill: View {
    var title: String
    var counts: MorningDetectionCounts

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
            Text("はい \(counts.yesCount)日")
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(TrendPalette.touching)
            Text("いいえ \(counts.noCount)日")
                .font(.subheadline.bold().monospacedDigit())
                .foregroundStyle(TrendPalette.separated)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
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
