import SwiftUI

struct AddIncomeView: View {
    @Environment(\.themePalette) private var palette
    @EnvironmentObject private var store: ExpenseStore
    @Environment(\.dismiss) private var dismiss

    @State private var amountText = ""
    @State private var selectedTag: ExpenseTag?
    @State private var note = ""
    @State private var saveFlash = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount Received")
                            .font(.appCaption())
                            .foregroundStyle(palette.textSecondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(store.settings.currencySymbol)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(AppTheme.income)
                            TextField("0.00", text: $amountText.sanitizedAmount())
                                .font(.system(size: 48, weight: .bold))
                                .keyboardType(.decimalPad)
                                .foregroundStyle(AppTheme.income)
                        }
                        Rectangle()
                            .fill(AppTheme.incomeGradient)
                            .frame(height: 3)
                            .cornerRadius(2)
                    }
                    .appearOnLoad(delay: 0)
                    .bounceOnChange(value: store.settings.currencyCode)

                    Text("Income Source")
                        .font(.appSubheadline())
                        .foregroundStyle(palette.textPrimary)

                    FlowTagLayout(spacing: 10) {
                        ForEach(Array(store.tags(for: .income).enumerated()), id: \.element.id) { index, tag in
                            TagChip(tag: tag, isSelected: selectedTag?.id == tag.id) {
                                withAnimation(AppAnimations.tagSpring) {
                                    selectedTag = tag
                                }
                            }
                            .staggeredAppear(index: index, baseDelay: AppAnimations.staggerDelay)
                        }
                    }

                    TextField("e.g. May salary from Company", text: $note)
                        .appTextFieldSurface()
                }
                .padding(24)
            }
            .background(palette.background)
            .navigationTitle("Add Income")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .safeAreaInset(edge: .bottom) {
                PrimaryButton(title: "Add Income") { save() }
                    .saveSuccessFlash(active: $saveFlash)
                    .padding()
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
                    .animation(AppAnimations.tabEase, value: canSave)
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
        withAnimation(AppAnimations.popSpring) { saveFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            dismiss()
        }
    }
}
