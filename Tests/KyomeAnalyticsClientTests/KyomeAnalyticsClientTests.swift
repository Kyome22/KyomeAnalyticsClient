import Foundation
import Testing
@testable import KyomeAnalyticsClient

@Test func configurationUsesDefaultEndpoint() {
    let configuration = KyomeAnalyticsConfiguration(appKey: "ka_test")

    #expect(configuration.endpoint == URL(string: "https://analytics.kyome.io/api/v1/events")!)
    #expect(configuration.appKey == "ka_test")
    #expect(configuration.isEnabled == true)
}

@Test func disabledClientDoesNotTouchStoreOrTransport() async throws {
    let store = FailingInstallationStore()
    let transport = RecordingTransport()
    let client = KyomeAnalyticsClient(
        configuration: KyomeAnalyticsConfiguration(appKey: "ka_test", isEnabled: false),
        installationStore: store,
        transport: transport
    )

    let sent = try await client.trackActiveApp(now: Date(timeIntervalSince1970: 1_800_000_000))

    #expect(sent == false)
    #expect(await transport.events.isEmpty)
}

@Test func sendsOnlyOncePerDay() async throws {
    let store = MemoryInstallationStore()
    let transport = RecordingTransport()
    let client = KyomeAnalyticsClient(
        configuration: KyomeAnalyticsConfiguration(endpoint: URL(string: "https://example.com/api/v1/events")!, appKey: "ka_test"),
        installationStore: store,
        transport: transport
    )

    let first = try await client.trackActiveApp(now: Date(timeIntervalSince1970: 1_800_000_000))
    let second = try await client.trackActiveApp(now: Date(timeIntervalSince1970: 1_800_001_000))

    #expect(first == true)
    #expect(second == false)
    #expect(await transport.events.count == 1)
}

@Test func sendsAgainOnNextDay() async throws {
    let store = MemoryInstallationStore()
    let transport = RecordingTransport()
    let client = KyomeAnalyticsClient(
        configuration: KyomeAnalyticsConfiguration(endpoint: URL(string: "https://example.com/api/v1/events")!, appKey: "ka_test"),
        installationStore: store,
        transport: transport
    )

    _ = try await client.trackActiveApp(now: Date(timeIntervalSince1970: 1_800_000_000))
    let nextDay = try await client.trackActiveApp(now: Date(timeIntervalSince1970: 1_800_090_000))

    #expect(nextDay == true)
    #expect(await transport.events.count == 2)
}

final class MemoryInstallationStore: InstallationStore, @unchecked Sendable {
    private let lock = NSLock()
    private var storedInstallID = "install-id"
    private var storedLastSentDay: Date?

    func installID() throws -> String {
        lock.withLock { storedInstallID }
    }

    func lastSentDay() throws -> Date? {
        lock.withLock { storedLastSentDay }
    }

    func setLastSentDay(_ date: Date) throws {
        lock.withLock {
            storedLastSentDay = date
        }
    }
}

actor RecordingTransport: AnalyticsTransport {
    private(set) var events: [ActiveAppEvent] = []

    func send(event: ActiveAppEvent, configuration: KyomeAnalyticsConfiguration) async throws {
        events.append(event)
    }
}

struct FailingInstallationStore: InstallationStore {
    func installID() throws -> String {
        throw TestError.unexpectedStoreAccess
    }

    func lastSentDay() throws -> Date? {
        throw TestError.unexpectedStoreAccess
    }

    func setLastSentDay(_ date: Date) throws {
        throw TestError.unexpectedStoreAccess
    }
}

enum TestError: Error {
    case unexpectedStoreAccess
}
