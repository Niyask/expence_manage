import SwiftUI

enum AppAppearancePreference: String, Codable, CaseIterable, Identifiable {
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme {
        self == .dark ? .dark : .light
    }
}

struct ThemePalette {
    let background: Color
    let cardBackground: Color
    let cardStroke: Color
    let fieldBackground: Color
    let textPrimary: Color
    let textSecondary: Color
    let toggleTrack: Color
    let chevron: Color
    let shadowOpacity: Double

    static let light = ThemePalette(
        background: Color(red: 0.973, green: 0.98, blue: 0.988),
        cardBackground: .white,
        cardStroke: Color(red: 0.9, green: 0.91, blue: 0.92),
        fieldBackground: Color(red: 0.98, green: 0.99, blue: 1.0),
        textPrimary: Color(red: 0.059, green: 0.09, blue: 0.165),
        textSecondary: Color(red: 0.392, green: 0.455, blue: 0.545),
        toggleTrack: Color(red: 0.94, green: 0.95, blue: 0.96),
        chevron: Color(red: 0.8, green: 0.82, blue: 0.84),
        shadowOpacity: 0.05
    )

    static let dark = ThemePalette(
        background: Color(red: 0.07, green: 0.09, blue: 0.12),
        cardBackground: Color(red: 0.12, green: 0.14, blue: 0.18),
        cardStroke: Color(red: 0.22, green: 0.24, blue: 0.3),
        fieldBackground: Color(red: 0.15, green: 0.17, blue: 0.22),
        textPrimary: Color(red: 0.95, green: 0.96, blue: 0.98),
        textSecondary: Color(red: 0.62, green: 0.66, blue: 0.72),
        toggleTrack: Color(red: 0.18, green: 0.2, blue: 0.26),
        chevron: Color(red: 0.45, green: 0.48, blue: 0.54),
        shadowOpacity: 0.35
    )

    static func palette(for preference: AppAppearancePreference) -> ThemePalette {
        preference == .dark ? .dark : .light
    }
}

@MainActor
final class ThemeContext: ObservableObject {
    @Published private(set) var palette: ThemePalette = .light
    @Published private(set) var revision: Int = 0

    func apply(_ preference: AppAppearancePreference) {
        palette = ThemePalette.palette(for: preference)
        revision += 1
        AppAppearance.apply(preference)
    }
}

private struct ThemePaletteKey: EnvironmentKey {
    static let defaultValue: ThemePalette = .light
}

extension EnvironmentValues {
    var themePalette: ThemePalette {
        get { self[ThemePaletteKey.self] }
        set { self[ThemePaletteKey.self] = newValue }
    }
}
