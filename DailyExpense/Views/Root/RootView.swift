import SwiftUI

struct RootView: View {
    @EnvironmentObject private var store: ExpenseStore

    var body: some View {
        Group {
            if store.settings.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView()
            }
        }
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
