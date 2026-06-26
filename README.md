# KyomeAnalyticsClient

Tiny Swift client for Kyome Analytics.

This package is public so open-source Kyome apps can resolve the Swift Package
dependency. It is not a general-purpose analytics SDK, and it does not contain
server secrets.

```swift
import KyomeAnalyticsClient

let analytics = KyomeAnalyticsClient(appKey: "ka_public_app_key")

try? await analytics.trackActiveApp()
```

Disable analytics from the app when needed, for example in debug builds:

```swift
#if DEBUG
let sendsAnalytics = false
#else
let sendsAnalytics = true
#endif

let analytics = KyomeAnalyticsClient(
    appKey: "ka_public_app_key",
    isEnabled: sendsAnalytics
)
```

The package has no external dependencies. It stores a generated install ID and the
last successful send day under Application Support, then sends at most one
`app_active` event per UTC day.

The default endpoint is:

```text
https://analytics.kyome.io/api/v1/events
```

For local development or staging, pass a custom endpoint:

```swift
let analytics = KyomeAnalyticsClient(
    endpoint: URL(string: "http://127.0.0.1:8080/api/v1/events")!,
    appKey: "ka_public_app_key"
)
```
