import Foundation

enum MoneyFormat {
    private static let decimalFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 0
        f.locale = Locale(identifier: "en_IN")
        return f
    }()

    private static let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "h:mm a"
        f.locale = Locale.current
        return f
    }()

    private static let daySubtitleFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale.current
        return f
    }()

    static func decimalValue(_ amount: Decimal) -> Double {
        (amount as NSDecimalNumber).doubleValue
    }

    static func ratio(_ part: Decimal, of total: Decimal) -> Double {
        let t = decimalValue(total)
        guard t > 0 else { return 0 }
        return decimalValue(part) / t
    }

    static func string(_ amount: Decimal, symbol: String = "₹", signed: Bool = false) -> String {
        let value = decimalValue(amount)
        let body = decimalFormatter.string(from: NSNumber(value: abs(value))) ?? "0"
        if signed {
            let prefix = value >= 0 ? "+" : "-"
            return "\(prefix)\(symbol)\(body)"
        }
        if value < 0 { return "-\(symbol)\(body)" }
        return "\(symbol)\(body)"
    }

    static func time(_ date: Date) -> String {
        timeFormatter.string(from: date)
    }

    static func daySubtitle(_ date: Date) -> String {
        let cal = Calendar.current
        let f = daySubtitleFormatter
        if cal.isDateInToday(date) {
            f.dateFormat = "'Today' · h:mm a"
        } else {
            f.dateFormat = "MMM d · h:mm a"
        }
        return f.string(from: date)
    }

    static func reportTime(hour: Int, minute: Int) -> String {
        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute
        let date = Calendar.current.date(from: comps) ?? Date()
        return timeFormatter.string(from: date)
    }
}
