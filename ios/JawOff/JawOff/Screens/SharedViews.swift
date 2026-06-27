import SwiftUI

enum AppDesign {
    enum Color {
        static let brand = SwiftUI.Color(red: 18 / 255, green: 188 / 255, blue: 204 / 255)
        static let brandDeep = SwiftUI.Color(red: 9 / 255, green: 148 / 255, blue: 168 / 255)
        static let success = SwiftUI.Color(red: 40 / 255, green: 190 / 255, blue: 130 / 255)
        static let warning = SwiftUI.Color(red: 244 / 255, green: 154 / 255, blue: 73 / 255)
        static let surface = SwiftUI.Color(.systemBackground)
        static let grouped = SwiftUI.Color(.systemGroupedBackground)
        static let secondarySurface = SwiftUI.Color(.secondarySystemGroupedBackground)
        static let softLine = SwiftUI.Color.primary.opacity(0.06)
        static let track = SwiftUI.Color(.tertiarySystemFill)
    }

    enum Spacing {
        static let screenHorizontal: CGFloat = 20
        static let stack: CGFloat = 20
        static let card: CGFloat = 20
        static let compact: CGFloat = 10
    }

    enum Radius {
        static let card: CGFloat = 26
        static let control: CGFloat = 20
        static let pill: CGFloat = 999
    }

    enum Shadow {
        static let card = SwiftUI.Color.black.opacity(0.055)
    }
}

struct ScreenContainer<Content: View>: View {
    var title: String
    var subtitle: String?
    @ViewBuilder var content: Content

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: AppDesign.Spacing.stack) {
                    ScreenHeader(title: title, subtitle: subtitle)
                    content
                }
                .padding(.horizontal, AppDesign.Spacing.screenHorizontal)
                .padding(.top, 18)
                .padding(.bottom, 112)
            }
            .background(AppDesign.Color.grouped)
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

struct ScreenHeader: View {
    var title: String
    var subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.primary)
                .tracking(0)

            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

struct AppCard<Content: View>: View {
    var tint: SwiftUI.Color = AppDesign.Color.surface
    var padding: CGFloat = AppDesign.Spacing.card
    @ViewBuilder var content: Content

    var body: some View {
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding)
            .background(tint)
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.card, style: .continuous))
            .shadow(color: AppDesign.Shadow.card, radius: 20, x: 0, y: 10)
            .transition(.scale(scale: 0.98).combined(with: .opacity))
    }
}

struct InfoCard: View {
    var icon: String
    var title: String
    var subtitle: String
    var tint: SwiftUI.Color = AppDesign.Color.brand

    var body: some View {
        AppCard {
            HStack(alignment: .top, spacing: 14) {
                IconBadge(systemName: icon, tint: tint)

                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct SectionHeader: View {
    var icon: String
    var title: String
    var subtitle: String?

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            IconBadge(systemName: icon, tint: AppDesign.Color.brand, size: 36)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.bold))
                if let subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }
}

struct IconBadge: View {
    var systemName: String
    var tint: SwiftUI.Color = AppDesign.Color.brand
    var size: CGFloat = 44

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size * 0.42, weight: .bold))
            .foregroundStyle(tint)
            .frame(width: size, height: size)
            .background(tint.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: size * 0.36, style: .continuous))
    }
}

struct MetricCard: View {
    var icon: String
    var title: String
    var value: String
    var caption: String
    var tint: SwiftUI.Color = AppDesign.Color.brand

    var body: some View {
        AppCard(padding: 16) {
            VStack(alignment: .leading, spacing: 10) {
                IconBadge(systemName: icon, tint: tint, size: 34)
                Text(value)
                    .font(.title2.weight(.bold).monospacedDigit())
                    .foregroundStyle(tint)
                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.primary)
                    Text(caption)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

struct ToggleRow: View {
    var title: String
    var subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        AppCard(tint: isOn ? AppDesign.Color.brand.opacity(0.11) : AppDesign.Color.surface) {
            Toggle(isOn: $isOn.animation(.spring(response: 0.28, dampingFraction: 0.82))) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline.weight(.bold))
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .tint(AppDesign.Color.brand)
        }
    }
}

struct DisclaimerView: View {
    var body: some View {
        InfoCard(
            icon: "cross.case",
            title: "医療判断について",
            subtitle: "このアプリはセルフケア支援を目的としたもので、診断・治療を行うものではありません。痛み、顎関節症状、歯の違和感が強い場合は歯科医師に相談してください。",
            tint: .secondary
        )
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(
                LinearGradient(
                    colors: [AppDesign.Color.brand, AppDesign.Color.brandDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control, style: .continuous))
            .shadow(color: AppDesign.Color.brand.opacity(configuration.isPressed ? 0.14 : 0.24), radius: 14, x: 0, y: 8)
            .scaleEffect(configuration.isPressed ? 0.975 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.78), value: configuration.isPressed)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(AppDesign.Color.brand.opacity(configuration.isPressed ? 0.18 : 0.12))
            .foregroundStyle(AppDesign.Color.brandDeep)
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.8), value: configuration.isPressed)
    }
}

struct ChipButtonStyle: ButtonStyle {
    var isSelected: Bool
    var tint: SwiftUI.Color = AppDesign.Color.brand

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.bold))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(isSelected ? tint : AppDesign.Color.secondarySurface)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.spring(response: 0.24, dampingFraction: 0.8), value: configuration.isPressed)
            .animation(.spring(response: 0.28, dampingFraction: 0.82), value: isSelected)
    }
}

extension View {
    func cardSectionAnimation<Value: Equatable>(_ value: Value) -> some View {
        animation(.spring(response: 0.35, dampingFraction: 0.86), value: value)
    }
}
