import SwiftUI

struct AddExpenseView: View {
    @EnvironmentObject private var store: ExpenseStore
    @Environment(\.dismiss) private var dismiss

    @State private var amountText = ""
    @State private var selectedTag: ExpenseTag?
    @State private var note = ""
    @State private var date = Date()
    @State private var entryType: TransactionType = .expense

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    entryTypeToggle

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.appCaption())
                            .foregroundStyle(AppTheme.textSecondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(store.settings.currencySymbol)
                                .font(.system(size: 48, weight: .bold))
                            TextField("0", text: $amountText)
                                .font(.system(size: 48, weight: .bold))
                                .keyboardType(.decimalPad)
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                        Rectangle()
                            .fill(AppTheme.summaryGradient)
                            .frame(height: 3)
                            .cornerRadius(2)
                    }

                    Text("Category")
                        .font(.appSubheadline())

                    FlowTagLayout(spacing: 10) {
                        ForEach(store.tags(for: entryType)) { tag in
                            TagChip(tag: tag, isSelected: selectedTag?.id == tag.id) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                    selectedTag = tag
                                }
                            }
                        }
                    }

                    TextField("Add a note (optional)", text: $note)
                        .padding()
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))

                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                        .padding()
                        .background(.white, in: RoundedRectangle(cornerRadius: 14))
                }
                .padding(24)
            }
            .background(AppTheme.background)
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Save Expense", gradient: AppTheme.summaryGradient) {
                    save()
                }
                .padding()
                .disabled(!canSave)
                .opacity(canSave ? 1 : 0.5)
            }
            .onAppear {
                selectedTag = store.tags(for: .expense).first
            }
            .onChange(of: entryType) { _, newType in
                selectedTag = store.tags(for: newType).first
            }
        }
    }

    private var entryTypeToggle: some View {
        HStack(spacing: 0) {
            typeButton("Expense", type: .expense)
            typeButton("Income", type: .income)
        }
        .padding(4)
        .background(Color(red: 0.94, green: 0.95, blue: 0.96), in: RoundedRectangle(cornerRadius: 10))
    }

    private func typeButton(_ title: String, type: TransactionType) -> some View {
        Button {
            entryType = type
        } label: {
            Text(title)
                .font(.appCaption())
                .fontWeight(entryType == type ? .semibold : .regular)
                .foregroundStyle(entryType == type ? .white : AppTheme.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(entryType == type ? (type == .income ? AppTheme.income : AppTheme.primary) : .clear, in: RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
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
            date: date,
            type: entryType
        ) else { return }
        dismiss()
    }
}
