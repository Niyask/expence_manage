import Foundation

struct AppCurrency: Identifiable, Hashable, Codable {
    let code: String
    let symbol: String
    let name: String
    let flag: String
    let localeIdentifier: String

    var id: String { code }

    var settingsLabel: String { "\(code) (\(symbol))" }

    static let `default` = usd

    static let usd = AppCurrency(
        code: "USD",
        symbol: "$",
        name: "United States",
        flag: "🇺🇸",
        localeIdentifier: "en_US"
    )

    static let all: [AppCurrency] = [
        usd,
        AppCurrency(code: "INR", symbol: "₹", name: "India", flag: "🇮🇳", localeIdentifier: "en_IN"),
        AppCurrency(code: "EUR", symbol: "€", name: "Eurozone", flag: "🇪🇺", localeIdentifier: "en_IE"),
        AppCurrency(code: "GBP", symbol: "£", name: "United Kingdom", flag: "🇬🇧", localeIdentifier: "en_GB"),
        AppCurrency(code: "JPY", symbol: "¥", name: "Japan", flag: "🇯🇵", localeIdentifier: "ja_JP"),
        AppCurrency(code: "AUD", symbol: "A$", name: "Australia", flag: "🇦🇺", localeIdentifier: "en_AU"),
        AppCurrency(code: "CAD", symbol: "C$", name: "Canada", flag: "🇨🇦", localeIdentifier: "en_CA"),
        AppCurrency(code: "AED", symbol: "د.إ", name: "UAE", flag: "🇦🇪", localeIdentifier: "en_AE"),
        AppCurrency(code: "SGD", symbol: "S$", name: "Singapore", flag: "🇸🇬", localeIdentifier: "en_SG"),
        AppCurrency(code: "CHF", symbol: "CHF", name: "Switzerland", flag: "🇨🇭", localeIdentifier: "de_CH"),
    ]

    static func with(code: String) -> AppCurrency? {
        all.first { $0.code == code.uppercased() }
    }

    static func code(matchingSymbol symbol: String) -> String? {
        all.first { $0.symbol == symbol }?.code
    }
}
