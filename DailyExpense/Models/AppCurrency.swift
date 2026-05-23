import Foundation

struct AppCurrency: Identifiable, Hashable, Codable {
    let code: String
    let symbol: String
    let name: String
    let flag: String
    let localeIdentifier: String

    var id: String { code }

    /// How amounts are prefixed in the UI (UAE e-commerce commonly uses `AED 99` in English).
    var amountPrefix: String {
        switch code {
        case "AED":
            return "AED "
        default:
            return symbol
        }
    }

    var settingsLabel: String {
        switch code {
        case "AED":
            return "AED · UAE Dirham"
        default:
            return "\(code) (\(symbol))"
        }
    }

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
        AppCurrency(
            code: "AED",
            symbol: "AED",
            name: "United Arab Emirates",
            flag: "🇦🇪",
            localeIdentifier: "en_AE"
        ),
        AppCurrency(code: "SGD", symbol: "S$", name: "Singapore", flag: "🇸🇬", localeIdentifier: "en_SG"),
        AppCurrency(code: "CHF", symbol: "CHF", name: "Switzerland", flag: "🇨🇭", localeIdentifier: "de_CH"),
    ]

    static func with(code: String) -> AppCurrency? {
        all.first { $0.code == code.uppercased() }
    }

    static func code(matchingSymbol symbol: String) -> String? {
        if let match = all.first(where: { $0.symbol == symbol }) {
            return match.code
        }
        switch symbol {
        case "د.إ", "Dh", "Dhs", "AED", "AED ", "\u{20C3}", "⃃":
            return "AED"
        default:
            return nil
        }
    }
}
