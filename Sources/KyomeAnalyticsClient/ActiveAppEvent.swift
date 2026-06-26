import Foundation

/// The JSON payload sent for an app activity event.
public struct ActiveAppEvent: Codable, Sendable {
    /// The event name. This is currently always `app_active`.
    public let event: String

    /// The stable client-generated install identifier.
    public let installID: String

    /// The app version reported by the client.
    public let appVersion: String?

    /// The app build number reported by the client.
    public let build: String?

    /// The operating system name reported by the client.
    public let os: String

    /// The operating system version reported by the client.
    public let osVersion: String

    /// The CPU architecture reported by the client.
    public let arch: String

    /// The current locale identifier reported by the client.
    public let locale: String

    /// The current time zone identifier reported by the client.
    public let timezone: String

    /// The timestamp when the event was created.
    public let sentAt: Date

    init(
        installID: String,
        appVersion: String?,
        build: String?,
        sentAt: Date,
        systemInfo: any SystemInfoProvider = CurrentSystemInfo()
    ) throws {
        event = "app_active"
        self.installID = installID
        self.appVersion = appVersion
        self.build = build
        os = systemInfo.osName
        osVersion = systemInfo.osVersion
        arch = systemInfo.architecture
        locale = systemInfo.localeIdentifier
        timezone = systemInfo.timezoneIdentifier
        self.sentAt = sentAt
    }

    enum CodingKeys: String, CodingKey {
        case event
        case installID = "install_id"
        case appVersion = "app_version"
        case build
        case os
        case osVersion = "os_version"
        case arch
        case locale
        case timezone
        case sentAt = "sent_at"
    }
}
