# AGENTS.md

## Repository Purpose

`KyomeAnalyticsClient` is a lightweight Swift Package client for Kyome Analytics.

It is public so open-source Kyome apps can resolve the SPM dependency, but it is not intended to be a general-purpose analytics SDK.

## Design Rules

- Keep external dependencies at zero.
- Do not add server secrets.
- Treat endpoint and app key as public identifiers.
- Keep the default endpoint as `https://analytics.kyome.io/api/v1/events`.
- Keep `endpoint:` override support for local development and staging.
- Preserve `isEnabled`; disabled clients must not create install IDs, touch state files, or send network requests.
- Public APIs should have Swift-DocC comments in English.
- Prefer small files split by responsibility.

## Main API

Expected app-side use:

```swift
let analytics = KyomeAnalyticsClient(appKey: "ka_public_app_key")
try? await analytics.trackActiveApp()
```

Debug builds should usually pass `isEnabled: false` from the app.

## Verification

Run:

```sh
env CLANG_MODULE_CACHE_PATH=.build/clang-module-cache swift test --disable-sandbox
```

Warnings about SwiftPM user cache writes are expected in this sandbox if tests otherwise pass.
