/// Errors raised by Kyome Analytics client operations.
public enum KyomeAnalyticsError: Error, Equatable {
    /// The server response was missing, non-HTTP, or outside the 2xx range.
    case unacceptableResponse
}
