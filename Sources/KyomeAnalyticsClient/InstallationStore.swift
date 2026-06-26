import Foundation

/// A persistence layer for the install ID and daily send state.
public protocol InstallationStore: Sendable {
    /// Returns the stable install ID, creating one if necessary.
    func installID() throws -> String

    /// Returns the UTC day for the last successful activity event send.
    func lastSentDay() throws -> Date?

    /// Stores the UTC day for the last successful activity event send.
    ///
    /// - Parameter date: The start of the day used for the send check.
    func setLastSentDay(_ date: Date) throws
}
