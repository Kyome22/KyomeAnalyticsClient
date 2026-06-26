import Foundation

/// A file-backed installation store that saves state under Application Support.
public final class FileInstallationStore: InstallationStore, @unchecked Sendable {
    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let lock = NSLock()

    /// Creates a file-backed installation store.
    ///
    /// The store writes `state.json` under
    /// `Application Support/<applicationIdentifier>/KyomeAnalytics/`.
    ///
    /// - Parameters:
    ///   - applicationIdentifier: The identifier used to isolate state for the app.
    ///   - fileManager: The file manager used to locate and create the state directory.
    public init(applicationIdentifier: String, fileManager: FileManager = .default) {
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
        let directory = baseURL
            .appendingPathComponent(applicationIdentifier, isDirectory: true)
            .appendingPathComponent("KyomeAnalytics", isDirectory: true)
        try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        fileURL = directory.appendingPathComponent("state.json")
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    /// Returns the stable install ID, creating one if the state file does not contain one.
    public func installID() throws -> String {
        try lock.withLock {
            var state = try load()
            if let installID = state.installID {
                return installID
            }
            let installID = UUID().uuidString.lowercased()
            state.installID = installID
            try save(state)
            return installID
        }
    }

    /// Returns the UTC day for the last successful activity event send.
    public func lastSentDay() throws -> Date? {
        try lock.withLock {
            try load().lastSentDay
        }
    }

    /// Stores the UTC day for the last successful activity event send.
    ///
    /// - Parameter date: The start of the day used for the send check.
    public func setLastSentDay(_ date: Date) throws {
        try lock.withLock {
            var state = try load()
            state.lastSentDay = date
            try save(state)
        }
    }

    private func load() throws -> State {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return State()
        }
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(State.self, from: data)
    }

    private func save(_ state: State) throws {
        let data = try encoder.encode(state)
        try data.write(to: fileURL, options: [.atomic])
    }

    private struct State: Codable {
        var installID: String?
        var lastSentDay: Date?
    }
}
