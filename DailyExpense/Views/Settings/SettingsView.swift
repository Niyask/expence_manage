import SwiftUI
import UIKit

struct SettingsView: View {
    @Environment(\.themePalette) private var palette
    @EnvironmentObject private var store: ExpenseStore
    @Environment(\.openURL) private var openURL
    @State private var notificationStatus: String = "Checking…"
    @State private var showPermissionAlert = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Group {
                        Text("Settings")
                            .font(.appTitle())
                            .foregroundStyle(palette.textPrimary)
                            .appearOnLoad()

                        appearanceCard
                        profileCard
                        eveningReportCard
                        weeklyInsightsCard
                        currencyCard
                    }

                    Group {
                        settingsGroup("Preferences", rows: preferenceRows)
                        settingsGroup("Tags", rows: tagRows)
                        replayOnboardingButton
                        settingsGroup("Data", rows: dataRows)
                        dataRetentionCard
                        securityNote

                        Text("Daily Expense v1.0 · iOS 16+")
                            .font(.appSmall())
                            .foregroundStyle(palette.textSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 8)
                    }
                }
                .padding(24)
                .padding(.bottom, 100)
            }
            .background(palette.background)
            .task { await refreshNotificationStatus() }
            .alert("Notifications Disabled", isPresented: $showPermissionAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        openURL(url)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Enable notifications in iOS Settings to receive your bedtime summary at \(store.settings.bedtimeTimeLabel).")
            }
        }
    }

    private var appearanceBinding: Binding<AppAppearancePreference> {
        store.settingBinding(\.appearance)
    }

    private var appearanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Image(systemName: store.settings.appearance.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(AppTheme.primary)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Appearance")
                        .font(.appSubheadline())
                        .foregroundStyle(palette.textPrimary)
                    Text("Light or dark theme for the whole app")
                        .font(.appSmall())
                        .foregroundStyle(palette.textSecondary)
                }
            }
            Picker("Theme", selection: appearanceBinding) {
                ForEach(AppAppearancePreference.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .appCardSurface(cornerRadius: 16)
        .shadow(color: .black.opacity(palette.shadowOpacity), radius: 6, y: 2)
        .appearOnLoad(delay: 0)
    }

    private var profileCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your name (greeting)")
                .font(.appCaption())
                .foregroundStyle(palette.textSecondary)
            TextField("e.g. Niyas", text: store.settingBinding(\.displayName))
                .textContentType(.name)
                .autocorrectionDisabled()
                .appTextFieldSurface()
        }
        .padding(16)
        .appCardSurface(cornerRadius: 16)
        .shadow(color: .black.opacity(palette.shadowOpacity), radius: 6, y: 2)
        .appearOnLoad(delay: 0)
    }

    private var eveningReportCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("🌙")
                    .font(.system(size: 24))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Bedtime Reminder")
                        .font(.appSubheadline())
                        .foregroundStyle(palette.textPrimary)
                    Text(store.settings.hasConfiguredBedtime
                         ? "Daily summary at \(store.settings.bedtimeTimeLabel)"
                         : "Default \(store.settings.bedtimeTimeLabel) · tap to customize")
                        .font(.appSmall())
                        .foregroundStyle(palette.textSecondary)
                }
            }
            DatePicker(
                "Report time",
                selection: reportTimeBinding,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(AppTheme.primary)
            .frame(maxWidth: .infinity)
            .padding()
            .appCardSurface()
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [AppTheme.secondary.opacity(0.08), AppTheme.primary.opacity(0.08)],
                startPoint: .leading,
                endPoint: .trailing
            ),
            in: RoundedRectangle(cornerRadius: 20)
        )
    }

    private var reportTimeBinding: Binding<Date> {
        Binding(
            get: {
                var c = DateComponents()
                c.hour = store.settings.eveningReportHour
                c.minute = store.settings.eveningReportMinute
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { newDate in
                let c = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                store.withSettings { settings in
                    settings.eveningReportHour = c.hour ?? 20
                    settings.eveningReportMinute = c.minute ?? 0
                    settings.hasConfiguredBedtime = true
                }
            }
        )
    }

    private var weeklyInsightsCard: some View {
        HStack {
            Text("📊")
                .font(.system(size: 22))
            VStack(alignment: .leading, spacing: 2) {
                Text("Weekly Insights")
                    .font(.appBody())
                    .foregroundStyle(palette.textPrimary)
                Text("See top spend category each week")
                    .font(.appSmall())
                    .foregroundStyle(palette.textSecondary)
            }
            Spacer()
            Toggle("", isOn: store.settingBinding(\.weeklyInsightsEnabled))
                .labelsHidden()
                .animation(AppAnimations.tabEase, value: store.settings.weeklyInsightsEnabled)
        }
        .padding(16)
        .appCardSurface(cornerRadius: 16)
        .appearOnLoad(delay: AppAnimations.staggerDelay)
    }

    private var currencyCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Currency")
                .font(.appCaption())
                .foregroundStyle(palette.textSecondary)
            Picker("Currency", selection: store.settingBinding(\.currencyCode)) {
                ForEach(AppCurrency.all) { currency in
                    Text("\(currency.flag) \(currency.name) · \(currency.settingsLabel)")
                        .tag(currency.code)
                }
            }
            .pickerStyle(.menu)
            .tint(AppTheme.primary)
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .appCardSurface()
        }
        .padding(16)
        .appCardSurface(cornerRadius: 16)
        .shadow(color: .black.opacity(palette.shadowOpacity), radius: 6, y: 2)
        .bounceOnChange(value: store.settings.currencyCode)
        .appearOnLoad(delay: AppAnimations.staggerDelay * 2)
    }

    private var preferenceRows: [SettingsRow] {
        [
            SettingsRow(
                icon: "🔔",
                title: "Bedtime notifications",
                subtitle: notificationStatus,
                toggleBinding: notificationsBinding
            ),
        ]
    }

    private var notificationsBinding: Binding<Bool> {
        Binding(
            get: { store.settings.notificationsEnabled },
            set: { newValue in
                Task { @MainActor in
                    if newValue {
                        let granted = await store.requestNotificationPermission()
                        if granted {
                            store.withSettings { $0.notificationsEnabled = true }
                            await store.refreshNotificationSchedule()
                        } else {
                            store.withSettings { $0.notificationsEnabled = false }
                            showPermissionAlert = true
                        }
                    } else {
                        store.withSettings { $0.notificationsEnabled = false }
                        await store.refreshNotificationSchedule()
                    }
                    await refreshNotificationStatus()
                }
            }
        )
    }

    private var tagRows: [SettingsRow] {
        [
            SettingsRow(
                icon: "🏷️",
                title: "Manage Tags",
                subtitle: "\(store.expenseTagCount) expense tags  ·  \(store.incomeTagCount) income tags"
            ),
            SettingsRow(icon: "➕", title: "Add Custom Tag", value: "Coming soon"),
        ]
    }

    private var replayOnboardingButton: some View {
        Button {
            withAnimation(AppAnimations.cardSpring) {
                store.resetOnboarding()
            }
        } label: {
            HStack(spacing: 12) {
                Text("🎬")
                    .font(.system(size: 18))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Replay onboarding")
                        .font(.appBody())
                        .foregroundStyle(palette.textPrimary)
                    Text("See the welcome tour again")
                        .font(.appSmall())
                        .foregroundStyle(palette.textSecondary)
                }
                Spacer()
                Text("›")
                    .font(.system(size: 18))
                    .foregroundStyle(palette.chevron)
            }
            .padding(16)
            .appCardSurface(cornerRadius: 16)
        }
        .scalePressStyle()
    }

    private var dataRows: [SettingsRow] {
        [
            SettingsRow(
                icon: "📅",
                title: "Data retention",
                subtitle: "Last \(ExpenseStore.maxRetentionMonths) months · week-by-week"
            ),
            SettingsRow(icon: "📤", title: "Export Data", value: "Coming soon"),
            SettingsRow(icon: "☁️", title: "Backup", value: "Local only"),
        ]
    }

    private var dataRetentionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Storage policy")
                .font(.appCaption())
                .foregroundStyle(palette.textSecondary)
            Text("Transactions older than \(ExpenseStore.maxRetentionMonths) months are removed automatically. Each month is summarized week-by-week in Reports and All Transactions.")
                .font(.appSmall())
                .foregroundStyle(palette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
        .background(AppTheme.accentOrange.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private var securityNote: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Privacy & security")
                .font(.appCaption())
                .foregroundStyle(palette.textSecondary)
            Text("Data stays on your device with file protection. No account or cloud sync in v1.0.")
                .font(.appSmall())
                .foregroundStyle(palette.textSecondary)
        }
        .padding(16)
        .background(AppTheme.primary.opacity(0.06), in: RoundedRectangle(cornerRadius: 12))
    }

    private func refreshNotificationStatus() async {
        let status = await NotificationScheduler.shared.authorizationStatus()
        switch status {
        case .authorized:
            notificationStatus = store.settings.notificationsEnabled
                ? "On · \(store.settings.bedtimeTimeLabel) daily"
                : "Authorized · toggle off"
        case .denied:
            notificationStatus = "Off · enable in iOS Settings"
        case .notDetermined:
            notificationStatus = "Tap toggle to allow"
        }
    }

    private func settingsGroup(_ title: String, rows: [SettingsRow]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.appCaption())
                .foregroundStyle(palette.textSecondary)
            VStack(spacing: 0) {
                ForEach(Array(rows.enumerated()), id: \.offset) { index, row in
                    if index > 0 {
                        Divider().padding(.leading, 50)
                    }
                    SettingsRowView(row: row)
                }
            }
            .appCardSurface(cornerRadius: 16)
        }
    }
}

struct SettingsRow {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var value: String? = nil
    var toggleBinding: Binding<Bool>? = nil
}

struct SettingsRowView: View {
    @Environment(\.themePalette) private var palette
    let row: SettingsRow

    var body: some View {
        HStack(spacing: 12) {
            Text(row.icon)
                .font(.system(size: 18))
                .frame(width: 28)
            VStack(alignment: .leading, spacing: 2) {
                Text(row.title)
                    .font(.appBody())
                    .foregroundStyle(palette.textPrimary)
                if let subtitle = row.subtitle {
                    Text(subtitle)
                        .font(.appSmall())
                        .foregroundStyle(palette.textSecondary)
                }
            }
            Spacer()
            if let binding = row.toggleBinding {
                Toggle("", isOn: binding)
                    .labelsHidden()
            } else if let value = row.value {
                Text(value)
                    .font(.appCaption())
                    .foregroundStyle(palette.textSecondary)
            }
            if row.toggleBinding == nil {
                Text("›")
                    .font(.system(size: 18))
                    .foregroundStyle(palette.chevron)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, row.subtitle == nil ? 14 : 12)
    }
}
