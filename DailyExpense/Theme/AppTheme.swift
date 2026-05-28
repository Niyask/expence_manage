import SwiftUI

/// Brand colors (shared across light and dark).
enum AppTheme {
    static let primary = Color(red: 0.051, green: 0.58, blue: 0.533)
    static let primaryLight = Color(red: 0.204, green: 0.827, blue: 0.6)
    static let secondary = Color(red: 0.388, green: 0.4, blue: 0.945)
    static let income = Color(red: 0.063, green: 0.725, blue: 0.506)
    static let expense = Color(red: 0.937, green: 0.267, blue: 0.267)
    static let accentOrange = Color(red: 0.976, green: 0.451, blue: 0.086)

    static let summaryGradient = LinearGradient(
        colors: [primary, secondary],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let incomeGradient = LinearGradient(
        colors: [income, primaryLight],
        startPoint: .leading,
        endPoint: .trailing
    )

    static let eveningHeaderGradient = LinearGradient(
        colors: [
            Color(red: 0.118, green: 0.106, blue: 0.294),
            Color(red: 0.231, green: 0.51, blue: 0.965)
        ],
        startPoint: .bottomLeading,
        endPoint: .topTrailing
    )

}

extension Font {
    static func appTitle() -> Font { .system(size: 28, weight: .bold) }
    static func appHeadline() -> Font { .system(size: 17, weight: .bold) }
    static func appSubheadline() -> Font { .system(size: 15, weight: .semibold) }
    static func appBody() -> Font { .system(size: 14, weight: .medium) }
    static func appCaption() -> Font { .system(size: 12, weight: .medium) }
    static func appSmall() -> Font { .system(size: 11, weight: .regular) }
}

struct ThemedScreenModifier: ViewModifier {
    @EnvironmentObject private var themeContext: ThemeContext

    func body(content: Content) -> some View {
        content
            .environment(\.themePalette, themeContext.palette)
    }
}

extension View {
    func themedScreen() -> some View {
        modifier(ThemedScreenModifier())
    }

    func appCardSurface(cornerRadius: CGFloat = 14) -> some View {
        modifier(AppCardSurfaceModifier(cornerRadius: cornerRadius))
    }

    func appTextFieldSurface(cornerRadius: CGFloat = 14) -> some View {
        modifier(AppTextFieldSurfaceModifier(cornerRadius: cornerRadius))
    }

    func appThemedRoot(appearance: AppAppearancePreference) -> some View {
        preferredColorScheme(appearance.colorScheme)
            .tint(AppTheme.primary)
    }
}

private struct AppCardSurfaceModifier: ViewModifier {
    @Environment(\.themePalette) private var palette
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content.background(palette.cardBackground, in: RoundedRectangle(cornerRadius: cornerRadius))
    }
}

private struct AppTextFieldSurfaceModifier: ViewModifier {
    @Environment(\.themePalette) private var palette
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content
            .foregroundStyle(palette.textPrimary)
            .padding()
            .background(palette.fieldBackground, in: RoundedRectangle(cornerRadius: cornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(palette.cardStroke, lineWidth: 1)
            )
    }
}
