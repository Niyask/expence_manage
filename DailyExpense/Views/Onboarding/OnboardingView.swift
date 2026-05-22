import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var store: ExpenseStore
    @State private var page = 0
    @State private var displayName = ""

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            emoji: "👋",
            title: "Welcome to Daily Expense",
            subtitle: "Your personal money tracker starts at zero. Add income and expenses as they happen — totals grow from your first entry.",
            gradient: AppTheme.summaryGradient
        ),
        OnboardingPage(
            emoji: "💸",
            title: "Track every transaction",
            subtitle: "Log incoming (salary, bonus, freelance) and outgoing (petrol, grocery, bills). Edit or delete any entry anytime from the transaction list.",
            gradient: AppTheme.incomeGradient
        ),
        OnboardingPage(
            emoji: "📅",
            title: "2 months · week by week",
            subtitle: "History is stored month-by-month with a weekly breakdown. After 2 months, older data is removed automatically to keep the app fast.",
            gradient: LinearGradient(
                colors: [AppTheme.secondary, AppTheme.primary],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        ),
        OnboardingPage(
            emoji: "🌙",
            title: "Bedtime summary",
            subtitle: "Get a daily reminder at your bedtime (default 8:00 PM — change in Settings). Tap the notification to see the full day, sorted by amount.",
            gradient: AppTheme.eveningHeaderGradient
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $page) {
                ForEach(Array(pages.enumerated()), id: \.offset) { index, item in
                    pageContent(item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            VStack(spacing: 12) {
                if page == pages.count - 1 {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your name (optional)")
                            .font(.appCaption())
                            .foregroundStyle(AppTheme.textSecondary)
                        TextField("e.g. Niyas", text: $displayName)
                            .textContentType(.name)
                            .autocorrectionDisabled()
                            .padding()
                            .background(.white, in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 24)
                }

                HStack(spacing: 12) {
                    if page > 0 {
                        Button("Back") {
                            withAnimation(AppAnimations.tabEase) { page -= 1 }
                        }
                        .font(.appBody())
                        .foregroundStyle(AppTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                    }

                    PrimaryButton(
                        title: page == pages.count - 1 ? "Get Started" : "Next",
                        gradient: pages[page].gradient
                    ) {
                        if page < pages.count - 1 {
                            withAnimation(AppAnimations.tabEase) { page += 1 }
                        } else {
                            finish()
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 24)

                if page < pages.count - 1 {
                    Button("Skip") { finish() }
                        .font(.appCaption())
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .padding(.bottom, 32)
            .padding(.top, 8)
        }
        .background(AppTheme.background)
    }

    private func pageContent(_ item: OnboardingPage) -> some View {
        VStack(spacing: 24) {
            Spacer(minLength: 40)

            Text(item.emoji)
                .font(.system(size: 72))
                .frame(width: 120, height: 120)
                .background(item.gradient, in: Circle())
                .shadow(color: AppTheme.primary.opacity(0.25), radius: 16, y: 8)

            Text(item.title)
                .font(.appTitle())
                .foregroundStyle(AppTheme.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text(item.subtitle)
                .font(.appBody())
                .foregroundStyle(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
                .padding(.horizontal, 32)

            retentionBadge
                .opacity(page == 2 ? 1 : 0)
                .padding(.horizontal, 24)

            Spacer()
        }
    }

    private var retentionBadge: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("ℹ️")
            Text("Transactions older than \(ExpenseStore.maxRetentionMonths) months are deleted on save and when the app opens.")
                .font(.appSmall())
                .foregroundStyle(AppTheme.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.secondary.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))
    }

    private func finish() {
        store.completeOnboarding(displayName: displayName)
        Task {
            if store.settings.notificationsEnabled {
                _ = await store.requestNotificationPermission()
                await store.refreshNotificationSchedule()
            }
        }
    }
}

private struct OnboardingPage {
    let emoji: String
    let title: String
    let subtitle: String
    let gradient: LinearGradient
}
