import SwiftUI
import UIKit

enum AppAppearance {
    @MainActor
    static func apply(_ preference: AppAppearancePreference) {
        let palette = ThemePalette.palette(for: preference)
        let style: UIUserInterfaceStyle = preference == .dark ? .dark : .light

        for scene in UIApplication.shared.connectedScenes {
            guard let windowScene = scene as? UIWindowScene else { continue }
            for window in windowScene.windows {
                window.overrideUserInterfaceStyle = style
            }
        }

        let textPrimary = UIColor(palette.textPrimary)
        let background = UIColor(palette.background)
        let card = UIColor(palette.cardBackground)

        UITextField.appearance().textColor = textPrimary
        UITextView.appearance().textColor = textPrimary
        UITextField.appearance().backgroundColor = UIColor(palette.fieldBackground)
        UIDatePicker.appearance().tintColor = UIColor(AppTheme.primary)

        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = background
        nav.titleTextAttributes = [.foregroundColor: textPrimary]
        nav.largeTitleTextAttributes = [.foregroundColor: textPrimary]
        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(AppTheme.primary)

        let tab = UITabBarAppearance()
        tab.configureWithOpaqueBackground()
        tab.backgroundColor = card
        UITabBar.appearance().standardAppearance = tab
        UITabBar.appearance().scrollEdgeAppearance = tab
        UITabBar.appearance().tintColor = UIColor(AppTheme.primary)
        UITabBar.appearance().unselectedItemTintColor = UIColor(palette.textSecondary)

        UITableView.appearance().backgroundColor = background
        UICollectionView.appearance().backgroundColor = background
    }
}
