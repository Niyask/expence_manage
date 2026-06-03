import SwiftUI

struct EditTransactionView: View {
    @Environment(\.themePalette) private var palette
    @EnvironmentObject private var store: ExpenseStore
    @Environment(\.dismiss) private var dismiss

    let transaction: Transaction

    @State private var amountText: String
    @State private var selectedTag: ExpenseTag?
    @State private var note: String
    @State private var date: Date
    @State private var entryType: TransactionType
    @State private var saveFlash = false

    init(transaction: Transaction) {
        self.transaction = transaction
        _amountText = State(initialValue: InputValidator.amountEditText(for: transaction.amount))
        _note = State(initialValue: transaction.note)
        _date = State(initialValue: transaction.date)
        _entryType = State(initialValue: transaction.type)
        _selectedTag = State(initialValue: nil)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    entryTypeToggle
                        .appearOnLoad(delay: 0)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Amount")
                            .font(.appCaption())
                            .foregroundStyle(palette.textSecondary)
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text(store.settings.currencySymbol)
                                .font(.system(size: 48, weight: .bold))
                                .foregroundStyle(entryType == .income ? AppTheme.income : palette.textPrimary)
                            TextField("0.00", text: $amountText.sanitizedAmount())
                                .font(.system(size: 48, weight: .bold))
                                .keyboardType(.decimalPad)
                                .foregroundStyle(entryType == .income ? AppTheme.income : palette.textPrimary)
                        }
                        Rectangle()
                            .fill(entryType == .income ? AnyShapeStyle(AppTheme.incomeGradient) : AnyShapeStyle(AppTheme.summaryGradient))
                            .frame(height: 3)
                            .cornerRadius(2)
                    }

                    Text(entryType == .income ? "Income Source" : "Category")
                        .font(.appSubheadline())
                        .foregroundStyle(palette.textPrimary)

                    FlowTagLayout(spacing: 10) {
                        ForEach(Array(store.tags(for: entryType).enumerated()), id: \.element.id) { index, tag in
                            TagChip(tag: tag, isSelected: selectedTag?.id == tag.id) {
                                withAnimation(AppAnimations.tagSpring) {
                                    selectedTag = tag
                                }
                            }
                            .staggeredAppear(index: index)
                        }
                    }
                    .animation(AppAnimations.listSpring, value: entryType)

                    TextField("Note (optional)", text: $note)
                        .appTextFieldSurface()

                    DatePicker("Date", selection: $date, displayedComponents: [.date, .hourAndMinute])
                        .tint(AppTheme.primary)
                        .foregroundStyle(palette.textPrimary)
                        .padding()
                        .appCardSurface()
                }
                .padding(24)
            }
            .background(palette.background)
            .navigationTitle("Edit Transaction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if selectedTag == nil {
                    selectedTag = store.tag(for: transaction.tagId)
                }
            }
            .safeAreaInset(edge: .bottom) {
                VStack(spacing: 10) {
                    PrimaryButton(
                        title: "Save Changes",
                        gradient: entryType == .income ? AppTheme.incomeGradient : AppTheme.summaryGradient
                    ) {
                        save()
                    }
                    .saveSuccessFlash(active: $saveFlash)
                    .disabled(!canSave)
                    .opacity(canSave ? 1 : 0.5)
                    .animation(AppAnimations.tabEase, value: canSave)

                    Button(role: .destructive) {
                        withAnimation(AppAnimations.listSpring) {
                            store.deleteTransaction(id: transaction.id)
                        }
                        dismiss()
                    } label: {
                        Text("Delete Transaction")
                            .font(.appSubheadline())
                            .frame(maxWidth: .infinity)
                            .frame(height: 48)
                    }
                }
                .padding()
            }
        }
    }

    private var entryTypeToggle: some View {
        HStack(spacing: 0) {
            typeButton("Expense", type: .expense)
            typeButton("Income", type: .income)
        }
        .padding(4)
        .background(palette.toggleTrack, in: RoundedRectangle(cornerRadius: 10))
    }

    private func typeButton(_ title: String, type: TransactionType) -> some View {
        Button {
            withAnimation(AppAnimations.tabEase) {
                entryType = type
                if selectedTag?.type != type {
                    selectedTag = store.tags(for: type).first
                }
            }
        } label: {
            Text(title)
                .font(.appCaption())
                .fontWeight(entryType == type ? .semibold : .regular)
                .foregroundStyle(entryType == type ? .white : palette.textSecondary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(entryType == type ? (type == .income ? AppTheme.income : AppTheme.primary) : .clear, in: RoundedRectangle(cornerRadius: 8))
        }
        .scalePressStyle()
        .animation(AppAnimations.tabEase, value: entryType)
    }

    private var canSave: Bool {
        selectedTag != nil && InputValidator.parseAmount(from: amountText) != nil
    }

    private func save() {
        guard let tag = selectedTag,
              let amount = InputValidator.parseAmount(from: amountText) else { return }
        guard store.updateTransaction(
            id: transaction.id,
            amount: amount,
            tag: tag,
            note: note,
            date: date,
            type: entryType
        ) else { return }
        withAnimation(AppAnimations.popSpring) { saveFlash = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) {
            dismiss()
        }
    }
}
