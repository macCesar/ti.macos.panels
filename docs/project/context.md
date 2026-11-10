# Project context

## Layout

`ios/Classes/TiMacosPanelsModule.m` implements the Titanium bridge and uses native `NSOpenPanel` and `NSSavePanel` dialogs on Mac Catalyst. The module has no third-party native dependencies; `ios/spm.json` has an empty dependency list.

`ios/manifest` defines the package version, module API version, and minimum Titanium version. `ios/titanium.xcconfig` selects the installed SDK directory for native headers and frameworks. Its SDK name includes the installed suffix, such as `.GA`.

## Build and verification

Run `node scripts/build.cjs` from the repository root. It defaults to the official Titanium `13.2.0.GA` SDK. An optional argument selects another installed SDK without changing the global selection.

The hook under `scripts/hooks/` adds explicit archive destinations for Xcode 27.2 and keeps the selected SDK consistent with the native header and framework paths. It is loaded through command-specific CLI configuration and is not shipped in the module ZIP. The build script removes Finder metadata from the generated ZIP.

Run `node --test tests/build-hook.test.cjs` for the hook checks. Run `example/validation-tests.js` inside a Mac Catalyst Titanium host for the native assertions. Node cannot run those native assertions.

Titanium and Apple SDK versions are separate compatibility concerns. A successful module build against Titanium 13.2 does not verify the lifecycle of a complete Titanium 13.2 app built with Apple SDK 27.2. Read the QA results before describing runtime coverage.

## Documentation map

- [README](../../README.md): installation, entitlements, API reference, examples, and troubleshooting.
- [Packaged manual](../../documentation/index.md): API and usage instructions included in the module ZIP.
- [Native project guide](../../ios/README.md): build entry point and output location.
- [QA checklist](../../QA-CHECKLIST.md): acceptance steps and results from the 2026-11-09 compatibility review.
- [Changelog](../../CHANGELOG.md): changes grouped by version.
- [Release notes](../releases/ios-1.0.1.md): body for the GitHub draft.
- [Platform resource guide](../../ios/platform/README.md): files copied into the host build directory.
- [Bundle resource guide](../../ios/Resources/README.md): files copied into the compiled host app.
- [Assets guide](../../assets/README): module assets and the JavaScript asset entry point.
- [Requirements](requirements.md): contract and acceptance criteria.
- [Decisions](decisions.md): dated technical and release choices.
- [Status](status.md): current work and release outcome. Read on demand; exclude it from startup imports.

## Assistant history

| When | Assistant | Work |
| --- | --- | --- |
| 2026-11-09 | Codex (GPT-6) | Xcode 27.2 compatibility, callback validation fix, native verification, documentation, and release preparation. |
