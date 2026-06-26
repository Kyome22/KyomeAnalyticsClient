/// A transport that sends analytics events to a server.
public protocol AnalyticsTransport: Sendable {
    /// Sends an activity event using the supplied configuration.
    ///
    /// - Parameters:
    ///   - event: The event payload to send.
    ///   - configuration: The endpoint and app key used for the request.
    func send(event: ActiveAppEvent, configuration: KyomeAnalyticsConfiguration) async throws
}
