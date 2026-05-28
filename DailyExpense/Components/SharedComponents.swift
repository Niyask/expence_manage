import SwiftUI

struct SummaryCard: View {
    let greeting: String
    let netBalance: Decimal
    let income: Decimal
    let expenses: Decimal
    let currencySymbol: String
    var currencyLocaleIdentifier: String = "en_US"
    /// Shown under total expenses — week-based spend only.
    var weeklyExpenses: Decimal?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(greeting)
                .font(.appBody())
                .foregroundStyle(.white.opacity(0.95))

            Text("Net Balance")
                .font(.appSmall())
                .foregroundStyle(.white.opacity(0.85))

            Text(MoneyFormat.string(netBalance, symbol: currencySymbol, localeIdentifier: currencyLocaleIdentifier, signed: true))
                .font(.system(size: 34, weight: .bold))
                .foregroundStyle(.white)

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Income")
                        .font(.appSmall())
                        .foregroundStyle(.white.opacity(0.85))
                    Text(MoneyFormat.string(income, symbol: currencySymbol, localeIdentifier: currencyLocaleIdentifier))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(red: 0.75, green: 1, blue: 0.88))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle()
                    .fill(.white.opacity(0.35))
                    .frame(width: 1, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Total Expenses")
                        .font(.appSmall())
                        .foregroundStyle(.white.opacity(0.85))
                    Text(MoneyFormat.string(expenses, symbol: currencySymbol, localeIdentifier: currencyLocaleIdentifier))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(Color(red: 1, green: 0.82, blue: 0.82))
                    if let weeklyExpenses {
                        Text("This week: \(MoneyFormat.string(weeklyExpenses, symbol: currencySymbol, localeIdentifier: currencyLocaleIdentifier))")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundStyle(.white.opacity(0.75))
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color.black.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.summaryGradient, in: RoundedRectangle(cornerRadius: 24))
        .shadow(color: AppTheme.primary.opacity(0.3), radius: 16, y: 8)
        .colorScheme(.dark)
    }
}

struct BannerRow: View {
    @Environment(\.themePalette) private var palette
    let icon: String
    let title: String
    var subtitle: String? = nil
    let tint: Color

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            if subtitle == nil {
                Text(icon)
                    .font(.system(size: 14))
            } else {
                Text(icon)
                    .font(.system(size: 22))
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(subtitle == nil ? .appCaption() : .appBody())
                    .fontWeight(subtitle == nil ? .medium : .semibold)
                    .foregroundStyle(tint)
                if let subtitle {
                    Text(subtitle)
                        .font(.appSmall())
                        .foregroundStyle(palette.textSecondary)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, subtitle == nil ? 12 : 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(tint.opacity(0.25), lineWidth: 1)
        )
    }
}

struct QuickActionButton: View {
    @Environment(\.themePalette) private var palette
    let emoji: String
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(emoji)
                    .font(.system(size: 22))
                Text(title)
                    .font(.appSmall())
                    .foregroundStyle(palette.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .appCardSurface()
            .shadow(color: .black.opacity(palette.shadowOpacity), radius: 6, y: 2)
        }
        .scalePressStyle()
    }
}

struct TransactionRow: View {
    @Environment(\.themePalette) private var palette
    let tag: ExpenseTag
    let title: String
    let subtitle: String
    let amount: Decimal
    let currencySymbol: String
    var currencyLocaleIdentifier: String = "en_US"
    let isIncome: Bool

    var body: some View {
        HStack(spacing: 12) {
            Text(tag.emoji)
                .font(.system(size: 18))
                .frame(width: 40, height: 40)
                .background(tag.color.opacity(0.15), in: RoundedRectangle(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.appBody())
                    .foregroundStyle(palette.textPrimary)
                Text(subtitle)
                    .font(.appSmall())
                    .foregroundStyle(palette.textSecondary)
            }

            Spacer()

            Text(
                isIncome
                    ? MoneyFormat.string(amount, symbol: currencySymbol, localeIdentifier: currencyLocaleIdentifier, signed: true)
                    : "-\(MoneyFormat.string(amount, symbol: currencySymbol, localeIdentifier: currencyLocaleIdentifier))"
            )
                .font(.system(size: 15, weight: .bold))
                .foregroundStyle(isIncome ? AppTheme.income : AppTheme.expense)
        }
        .padding(14)
        .appCardSurface()
        .shadow(color: .black.opacity(palette.shadowOpacity), radius: 6, y: 2)
    }
}

struct TagChip: View {
    @Environment(\.themePalette) private var palette
    let tag: ExpenseTag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(tag.emoji)
                    .font(.system(size: 14))
                Text(tag.name)
                    .font(.appCaption())
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? .white : palette.textPrimary)
            .background(
                isSelected ? AnyShapeStyle(tag.color) : AnyShapeStyle(tag.color.opacity(0.14)),
                in: Capsule()
            )
            .overlay(
                Capsule()
                    .stroke(tag.color.opacity(isSelected ? 0 : 0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scalePressStyle()
        .animation(AppAnimations.tagSpring, value: isSelected)
    }
}

struct PrimaryButton: View {
    let title: String
    var gradient: LinearGradient = AppTheme.incomeGradient
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.appSubheadline())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(gradient, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: AppTheme.primary.opacity(0.3), radius: 12, y: 6)
        }
        .scalePressStyle()
        .accessibilityLabel(title)
        .accessibilityAddTraits(.isButton)
    }
}

struct FlowTagLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var positions: [CGPoint] = []

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
