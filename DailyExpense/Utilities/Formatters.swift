import Foundation

enum MoneyFormat {
    private static var formatterCache: [String: NumberFormatter] = [:]

    private static func decimalFormatter(localeIdentifier: String, currencyCode: String) -> NumberFormatter {
        let cacheKey = "\(localeIdentifier)_\(currencyCode)"
        if let cached = formatterCache[cacheKey] { return cached }
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.locale = Locale(identifier: localeIdentifier)
        f.usesGroupingSeparator = true
        if currencyCode == "JPY" {
            f.minimumFractionDigits = 0
            f.maximumFractionDigits = 0
        } else {
            f.minimumFractionDigits = 0
            f.maximumFractionDigits = 2
        }
        formatterCache[cacheKey] = f
        return f
    }

    /// Unformatted amount for text fields (e.g. `68.5`, `124.30`).
    static func plainAmountString(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.usesGroupingSeparator = false
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = maxFractionDigits
        return formatter.string(from: amount as NSDecimalNumber) ?? ""
    }

    private static let maxFractionDigits = 2

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

    static func string(
        _ amount: Decimal,
        symbol: String = "$",
        localeIdentifier: String = "en_US",
        currencyCode: String = "USD",
        signed: Bool = false
    ) -> String {
        let formatter = decimalFormatter(
            localeIdentifier: localeIdentifier,
            currencyCode: currencyCode
        )
        let number = (amount as NSDecimalNumber)
        let isNegative = number.compare(NSDecimalNumber.zero) == .orderedAscending
        let body = formatter.string(from: isNegative ? number.multiplying(by: -1) : number) ?? "0"
        if signed {
            let prefix = isNegative ? "-" : "+"
            return "\(prefix)\(symbol)\(body)"
        }
        if isNegative { return "-\(symbol)\(body)" }
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
