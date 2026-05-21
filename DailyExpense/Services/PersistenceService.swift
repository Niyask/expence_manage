import Foundation

/// Persists app state to Application Support with file protection.
final class PersistenceService {
    static let shared = PersistenceService()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.dateEncodingStrategy = .iso8601
        return e
    }()

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    private var fileURL: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("DailyExpense", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir.appendingPathComponent("state.json")
    }

    struct PersistedState: Codable {
        var transactions: [Transaction]
        var tags: [ExpenseTag]
        var settings: AppSettings
    }

    func load() -> PersistedState? {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return nil }
        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode(PersistedState.self, from: data)
        } catch {
            #if DEBUG
            print("[Persistence] load failed: \(error.localizedDescription)")
            #endif
            return nil
        }
    }

    func save(_ state: PersistedState) {
        do {
            let data = try encoder.encode(state)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            #if DEBUG
            print("[Persistence] save failed: \(error.localizedDescription)")
            #endif
        }
    }
}
