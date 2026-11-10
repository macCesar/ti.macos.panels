# Decisions

## 2026-11-09: Keep Titanium 13.2 as the module minimum

Build against the installed official `13.2.0.GA` SDK and retain `minsdk: 13.2.0`. The official SDK contains the Catalyst module fixes from [Titanium SDK PR 14391](https://github.com/tidev/titanium-sdk/pull/14391), merged on February 26, 2026. The local SDK previously named `13.2.0` is not required for this build.

Use Titanium `14.0.0.fixes` for the runtime host tested with Apple SDK 27.2. Record module compilation and host runtime coverage separately.

## 2026-11-09: Scope the Xcode workaround to this repository

Xcode 27.2 rejected the module's deployment target of iOS 12 and an archive command without a destination. Raise the native deployment target to iOS 15 and select an explicit destination for each archive through the build script's hook. Keep installed SDK source and the global SDK selection unchanged.

## 2026-11-09: Return validation errors before dispatching callbacks

The validation helper returned `nil` after dispatching an error to a callback. Public methods interpreted `nil` as successful validation and scheduled a panel, which could produce a second callback. Return the validation error object to the public method and let that method dispatch it once and exit. Preserve the public API and result shape.

## 2026-11-09: Prepare a draft release

The maintainer approved `ios-1.0.1` with title `iOS 1.0.1` as a draft. The repository had no published GitHub releases. A local `v1.0.0` tag exists, but no remote tag was present during this review.

Keep the release target commit explicit and rebuild its ZIP after committing the changes. Review documentation, session notes, commit messages, and release notes with Humanizer while preserving commands and API identifiers.
