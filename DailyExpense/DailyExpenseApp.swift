import SwiftUI

@main
struct DailyExpenseApp: App {
    @StateObject private var store = ExpenseStore()
    @StateObject private var themeContext = ThemeContext()
    private let notificationHandler = AppNotificationHandler()

    private var screenshotScreen: AppScreenshotScreen? {
        AppScreenshotScreen.fromProcessArguments()
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if let screen = screenshotScreen {
                    ScreenshotCaptureHost(screen: screen)
                } else {
                    RootView()
                }
            }
            .environmentObject(store)
            .environmentObject(themeContext)
            .themedScreen(themeContext: themeContext)
            .appThemedRoot(appearance: store.settings.appearance)
            .id(themeContext.revision)
            .onAppear {
                notificationHandler.configure(store: store)
                applyTheme(store.settings.appearance)
            }
            .onChange(of: store.settings.appearance) { newValue in
                applyTheme(newValue)
            }
            .task {
                guard screenshotScreen == nil else { return }
                if store.settings.hasCompletedOnboarding,
                   store.settings.notificationsEnabled {
                    _ = await store.requestNotificationPermission()
                    await store.refreshNotificationSchedule()
                }
            }
        }
    }

    @MainActor
    private func applyTheme(_ appearance: AppAppearancePreference) {
        themeContext.apply(appearance)
    }
}
