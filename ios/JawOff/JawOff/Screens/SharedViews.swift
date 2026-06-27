import SwiftUI

struct AppCard<Content: View>: View {
    var tint: Color = Color(.systemBackground)
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: Color.black.opacity(0.04), radius: 14, x: 0, y: 8)
    }
}

struct MetricCard: View {
    var title: String
    var value: String
    var caption: String

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.title.bold())
                    .foregroundStyle(.primary)
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct ToggleRow: View {
    var title: String
    var subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        AppCard(tint: isOn ? Color.teal.opacity(0.12) : Color(.systemBackground)) {
            Toggle(isOn: $isOn) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(.teal)
        }
    }
}

struct ScoreSlider: View {
    var title: String
    var subtitle: String?
    var leftLabel = "なし"
    var rightLabel = "強い"
    @Binding var value: Double

    var body: some View {
        AppCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Text("\(Int(value))")
                        .font(.headline.monospacedDigit())
                        .foregroundStyle(.teal)
                }
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Slider(value: $value, in: 0...10, step: 1)
                    .tint(.teal)
                HStack {
                    Text(leftLabel)
                    Spacer()
                    Text(rightLabel)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
        }
    }
}

struct DisclaimerView: View {
    var body: some View {
        Text("このアプリはセルフケア支援を目的としたもので、診断・治療を行うものではありません。痛み、顎関節症状、歯の違和感が強い場合は歯科医師に相談してください。")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 18))
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.teal)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.teal.opacity(0.12))
            .foregroundStyle(.teal)
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}
