import Foundation
import SwiftUI

enum TransactionType: String, Codable, CaseIterable {
    case expense
    case income
}

struct ExpenseTag: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let emoji: String
    let colorHex: String
    let type: TransactionType

    init(id: UUID = UUID(), name: String, emoji: String, color: Color, type: TransactionType) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.colorHex = color.toHex()
        self.type = type
    }

    var color: Color { Color(hex: colorHex) ?? AppTheme.textSecondary }
}

struct Transaction: Identifiable, Codable, Hashable {
    let id: UUID
    var amount: Decimal
    var tagId: UUID
    var note: String
    var date: Date
    var type: TransactionType

    init(
        id: UUID = UUID(),
        amount: Decimal,
        tagId: UUID,
        note: String = "",
        date: Date = Date(),
        type: TransactionType
    ) {
        self.id = id
        self.amount = amount
        self.tagId = tagId
        self.note = note
        self.date = date
        self.type = type
    }
}

struct AppSettings: Codable, Equatable {
    var displayName: String = ""
    var eveningReportHour: Int = 20
    var eveningReportMinute: Int = 0
    var weeklyInsightsEnabled: Bool = true
    var notificationsEnabled: Bool = true
    var currencySymbol: String = "₹"

    var greetingName: String {
        let trimmed = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "there" : trimmed
    }
}

extension Color {
    init?(hex: String) {
        var hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        if hex.count == 6 { hex = "FF" + hex }
        guard hex.count == 8, let value = UInt64(hex, radix: 16) else { return nil }
        self.init(
            red: Double((value >> 16) & 0xFF) / 255,
            green: Double((value >> 8) & 0xFF) / 255,
            blue: Double(value & 0xFF) / 255,
            opacity: Double((value >> 24) & 0xFF) / 255
        )
    }

    func toHex() -> String {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }
}
