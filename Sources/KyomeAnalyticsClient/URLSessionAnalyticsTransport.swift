import Foundation

/// An analytics transport implemented with `URLSession`.
public struct URLSessionAnalyticsTransport: AnalyticsTransport {
    private let session: URLSession
    private let encoder: JSONEncoder

    /// Creates a URLSession-backed transport.
    ///
    /// - Parameter session: The URL session used to perform event requests.
    public init(session: URLSession = .shared) {
        self.session = session
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
    }

    /// Sends an activity event as JSON to the configured endpoint.
    ///
    /// The request includes the app key in the `X-App-Key` header and treats any
    /// non-2xx response as ``KyomeAnalyticsError/unacceptableResponse``.
    ///
    /// - Parameters:
    ///   - event: The event payload to send.
    ///   - configuration: The endpoint and app key used for the request.
    public func send(event: ActiveAppEvent, configuration: KyomeAnalyticsConfiguration) async throws {
        var request = URLRequest(url: configuration.endpoint)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(configuration.appKey, forHTTPHeaderField: "X-App-Key")
        request.httpBody = try encoder.encode(event)

        let (_, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode)
        else {
            throw KyomeAnalyticsError.unacceptableResponse
        }
    }
}
