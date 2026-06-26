import Foundation

protocol SystemInfoProvider: Sendable {
    var osName: String { get }
    var osVersion: String { get }
    var architecture: String { get }
    var localeIdentifier: String { get }
    var timezoneIdentifier: String { get }
}

struct CurrentSystemInfo: SystemInfoProvider {
    var osName: String {
        #if os(macOS)
        "macOS"
        #elseif os(iOS)
        "iOS"
        #else
        "unknown"
        #endif
    }

    var osVersion: String {
        ProcessInfo.processInfo.operatingSystemVersionString
    }

    var architecture: String {
        #if arch(arm64)
        "arm64"
        #elseif arch(x86_64)
        "x86_64"
        #else
        "unknown"
        #endif
    }

    var localeIdentifier: String {
        Locale.current.identifier
    }

    var timezoneIdentifier: String {
        TimeZone.current.identifier
    }
}
