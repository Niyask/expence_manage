import SwiftUI

struct AddIncomeView: View {
    @EnvironmentObject private var store: ExpenseStore
    @Environment(\.dismiss) private var dismiss

    @State private var amountText = ""
    @State private var selectedTag: ExpenseTag?
    @State private var note = ""

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount Received")
                            .font(.appCaption())
                            .foregroundStyle(AppTheme.textSecondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(store.settings.currencySymbol)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(AppTheme.income)
                            TextField("0", text: $amountText)
                                .font(.system(size: 48, weight: .bold))
                                .keyboardType(.decimalPad)
                                .foregroundStyle(AppTheme.income)
                        }
                        Rectangle()
                            .fill(AppTheme.incomeGradient)
                            .frame(height: 3)
                            .cornerRadius(2)
                    }

                    Text("Income Source")
                        .font(.appSubheadline())

                    FlowTagLayout(spacing: 10) {
                        ForEach(store.tags(for: .income)) { tag in
                            TagChip(tag: tag, isSelected: selectedTag?.id == tag.id) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    selectedTag = tag
                                }
                            }
                        }
                    }

                    TextField("e.g. May salary from Company", text: $note)
                        .padding()
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(24)
            }
            .background(AppTheme.background)
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Add Income") { save() }
                    .padding()
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
            }
            .onAppear {
                selectedTag = store.tags(for: .income).first(where: { $0.name == "Salary" }) ?? store.tags(for: .income).first
            }
        }
    }

    private var canSave: Bool {
        selectedTag != nil && InputValidator.parseAmount(from: amountText) != nil
    }

    private func save() {
        guard let tag = selectedTag,
              let amount = InputValidator.parseAmount(from: amountText) else { return }
        guard store.addTransaction(
            amount: amount,
            tag: tag,
            note: note,
            date: Date(),
            type: .income
        ) else { return }
        dismiss()
    }
}
