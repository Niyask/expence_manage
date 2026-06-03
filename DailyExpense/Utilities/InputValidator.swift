import Foundation
import SwiftUI

/// Validates user-entered amounts and notes before persisting.
enum InputValidator {
    static let maxAmount: Decimal = 99_999_999
    static let maxNoteLength = 500
    static let maxFractionDigits = 2

    /// Keeps digits and at most one decimal separator (`.`). Limits fractional digits while typing.
    static func sanitizeAmountInput(_ text: String, maxFractionDigits: Int = maxFractionDigits) -> String {
        var result = ""
        var hasSeparator = false
        var fractionDigits = 0

        for character in text {
            if character.isNumber {
                if hasSeparator {
                    guard fractionDigits < maxFractionDigits else { continue }
                    fractionDigits += 1
                }
                result.append(character)
            } else if character == "." || character == "," {
                if !hasSeparator {
                    hasSeparator = true
                    result.append(".")
                }
            }
        }
        return result
    }

    static func parseAmount(from text: String) -> Decimal? {
        let sanitized = sanitizeAmountInput(text)
        var normalized = sanitized.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else { return nil }

        if normalized.hasSuffix(".") {
            normalized.removeLast()
        }
        guard !normalized.isEmpty else { return nil }

        guard let amount = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")),
              amount > 0,
              amount <= maxAmount else {
            return nil
        }
        return amount
    }

    /// Text for amount fields when editing an existing transaction.
    static func amountEditText(for amount: Decimal) -> String {
        MoneyFormat.plainAmountString(amount)
    }

    static func sanitizeNote(_ note: String) -> String {
        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        let filtered = trimmed.unicodeScalars.filter { scalar in
            !CharacterSet.controlCharacters.contains(scalar)
        }
        let cleaned = String(String.UnicodeScalarView(filtered))
        return String(cleaned.prefix(maxNoteLength))
    }
}

extension Binding where Value == String {
    /// Use on amount `TextField` bindings so users can enter values like `12.50`.
    func sanitizedAmount(maxFractionDigits: Int = InputValidator.maxFractionDigits) -> Binding<String> {
        Binding(
            get: { wrappedValue },
            set: { wrappedValue = InputValidator.sanitizeAmountInput($0, maxFractionDigits: maxFractionDigits) }
        )
    }
}
