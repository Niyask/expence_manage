import Foundation

/// Validates user-entered amounts and notes before persisting.
enum InputValidator {
    static let maxAmount: Decimal = 99_999_999
    static let maxNoteLength = 500

    static func parseAmount(from text: String) -> Decimal? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        let normalized = trimmed
            .replacingOccurrences(of: ",", with: "")
            .replacingOccurrences(of: "₹", with: "")
            .replacingOccurrences(of: "$", with: "")

        guard let amount = Decimal(string: normalized, locale: Locale(identifier: "en_US_POSIX")),
              amount > 0,
              amount <= maxAmount else {
            return nil
        }
        return amount
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
