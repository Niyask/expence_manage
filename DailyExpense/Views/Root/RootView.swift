import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: ExpenseStore

    var body: some View {
        ZStack {
            if store.settings.hasCompletedOnboarding {
                MainTabView()
                    .transition(AppAnimations.screenSwap)
                    .zIndex(1)
            } else {
                OnboardingView()
                    .transition(AppAnimations.screenSwap)
                    .zIndex(0)
            }
        }
        .animation(AppAnimations.cardSpring, value: store.settings.hasCompletedOnboarding)
        .sheet(
            isPresented: Binding(
                get: { store.pendingEveningReportDate != nil },
                set: { if !$0 { store.pendingEveningReportDate = nil } }
            )
        ) {
            if let date = store.pendingEveningReportDate {
                NavigationStack {
                    EveningReportView(date: date)
                        .toolbar {
                            ToolbarItem(placement: .confirmationAction) {
                                Button("Done") { store.pendingEveningReportDate = nil }
                            }
                        }
                }
                .environmentObject(store)
            }
        }
    }
}
