# Requirements

The [API reference](../../README.md#api-reference) defines the six public methods. The [QA checklist](../../QA-CHECKLIST.md) covers their acceptance checks.

## File panels

- Support folder selection, single and multiple file selection, document aliases, and a save destination on Mac Catalyst.
- Return the shared result shape and documented `ERR_*` codes in synchronous and callback calls.
- Reject invalid options before presenting a panel. A callback call must deliver one result, including validation errors and cancellation.
- Apply UTType and extension filters as documented. Read multiple selections from `paths`.
- Return the save destination so the host app can write the file.

## Compatibility

- Keep `minsdk: 13.2.0` and module API version 2. Use the official `13.2.0.GA` SDK for the baseline build.
- Build with Xcode 27.2 for iOS device, simulator, and Mac Catalyst. Include both arm64 and x86_64 in the simulator and Catalyst variants.
- Keep the native deployment target at iOS 15.0 or its Catalyst equivalent.
- Configure file entitlements in the host app. Calls outside Mac Catalyst must return `ERR_NOT_SUPPORTED_PLATFORM`.

## Release

- Build the release ZIP from the exact commit selected as the release target on `main`.
- Match the package filename and module manifest version.
- Keep build hooks scoped to this repository; exclude them from consumer packages.
- Create version 1.0.1 as a GitHub draft using tag `ios-1.0.1` and title `iOS 1.0.1`, as approved by the maintainer.
