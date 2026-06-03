import Foundation

/// Persists app state under Application Support (survives App Store updates; only removed if the user deletes the app).
final class PersistenceService {
    static let shared = PersistenceService()
    static let currentSchemaVersion = 1

    enum LoadResult {
        case loaded(PersistedState)
        /// No saved file yet (first install).
        case freshInstall
        /// File exists but could not be read; primary file was left untouched.
        case corruptFileOnDisk
    }

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

    private var appSupportDirectory: URL {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let appDir = dir.appendingPathComponent("DailyExpense", isDirectory: true)
        try? FileManager.default.createDirectory(at: appDir, withIntermediateDirectories: true)
        return appDir
    }

    private var fileURL: URL {
        appSupportDirectory.appendingPathComponent("state.json")
    }

    private var backupURL: URL {
        appSupportDirectory.appendingPathComponent("state.json.backup")
    }

    struct PersistedState: Codable, Equatable {
        var schemaVersion: Int
        var transactions: [Transaction]
        var tags: [ExpenseTag]
        var settings: AppSettings

        init(transactions: [Transaction], tags: [ExpenseTag], settings: AppSettings) {
            schemaVersion = PersistenceService.currentSchemaVersion
            self.transactions = transactions
            self.tags = tags
            self.settings = settings
        }

        enum CodingKeys: String, CodingKey {
            case schemaVersion
            case transactions
            case tags
            case settings
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            schemaVersion = try c.decodeIfPresent(Int.self, forKey: .schemaVersion) ?? 1
            transactions = try c.decodeIfPresent([Transaction].self, forKey: .transactions) ?? []
            tags = try c.decodeIfPresent([ExpenseTag].self, forKey: .tags) ?? []
            settings = try c.decodeIfPresent(AppSettings.self, forKey: .settings) ?? AppSettings()
        }

        func encode(to encoder: Encoder) throws {
            var c = encoder.container(keyedBy: CodingKeys.self)
            try c.encode(PersistenceService.currentSchemaVersion, forKey: .schemaVersion)
            try c.encode(transactions, forKey: .transactions)
            try c.encode(tags, forKey: .tags)
            try c.encode(settings, forKey: .settings)
        }
    }

    /// Loads saved data, falling back to the last good backup if the primary file is unreadable.
    func loadWithRecovery() -> LoadResult {
        if let state = decode(from: fileURL) {
            return .loaded(state)
        }
        if FileManager.default.fileExists(atPath: fileURL.path),
           let state = decode(from: backupURL) {
            #if DEBUG
            print("[Persistence] Recovered from backup after primary read failed")
            #endif
            save(state)
            return .loaded(state)
        }
        if hasAnyPersistedFile {
            return .corruptFileOnDisk
        }
        return .freshInstall
    }

    /// Writes state atomically and keeps a backup of the previous primary file.
    func save(_ state: PersistedState) {
        do {
            let data = try encoder.encode(state)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try? FileManager.default.removeItem(at: backupURL)
                try? FileManager.default.copyItem(at: fileURL, to: backupURL)
            }
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            #if DEBUG
            print("[Persistence] save failed: \(error.localizedDescription)")
            #endif
        }
    }

    var hasPersistedDataOnDisk: Bool {
        hasAnyPersistedFile
    }

    private var hasAnyPersistedFile: Bool {
        FileManager.default.fileExists(atPath: fileURL.path)
            || FileManager.default.fileExists(atPath: backupURL.path)
    }

    private func decode(from url: URL) -> PersistedState? {
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(PersistedState.self, from: data)
        } catch {
            #if DEBUG
            print("[Persistence] decode failed (\(url.lastPathComponent)): \(error.localizedDescription)")
            #endif
            return nil
        }
    }
}
