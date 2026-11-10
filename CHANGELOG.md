# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1] - 2026-11-09

### Fixed

- Reject invalid options before opening a panel and deliver one error callback across all six APIs. The synchronous result contract is unchanged.

### Changed

- Use explicit archive destinations for Xcode 27.2 and raise the native deployment target from iOS 12.0 to 15.0, including the corresponding Catalyst target.
- Build against the official Titanium `13.2.0.GA` SDK and retain `minsdk: 13.2.0` with module API version 2.
- Keep the CLI-selected SDK consistent with native header and framework paths through the repository build hook.
- Update the README, packaged manual, build instructions, resource guides, and QA checklist. Clarify file access entitlements in the host app.

### Added

- Build script and four checks for archive destination selection.
- Remove Finder metadata from generated ZIP packages.
- Native validation checks covering all six APIs in synchronous and callback forms, including exactly one callback per call.
- Project session notes and release notes reviewed with Humanizer.

### Verification

- Built device, simulator, and Mac Catalyst variants with Xcode 27.2 and the official Titanium `13.2.0.GA` SDK.
- Passed 48 native assertions and seven interactive cases in a Titanium `14.0.0.fixes` Catalyst host, including a real file write.
- Compiled LM - Generador de Tablas with module 1.0.1 and Titanium `14.0.0.fixes`.
- Runtime coverage for a complete Titanium 13.2 app with Apple SDK 27.2 remains separate from this module build verification.

## [1.0.0] - 2026-02-06

### Added

- Initial release of `ti.macos.panels` Titanium module
- Mac Catalyst-only native file dialogs using `NSOpenPanel` and `NSSavePanel`
- Six public APIs: `pickFolder()`, `pickFile()`, `pickFiles()`, `openDocument()`, `openDocuments()`, `saveFile()`
- Unified result contract across all methods with standardized error codes
- Option validation with detailed error messages
- File filtering via extensions and UTType identifiers
- Support for both callback and synchronous return patterns
- Documentation and usage examples
- Full error catalog: `ERR_NO_SELECTION`, `ERR_USER_CANCELLED`, `ERR_INVALID_OPTIONS`, `ERR_PANEL_UNAVAILABLE`, `ERR_NOT_SUPPORTED_PLATFORM`, `ERR_INVALID_START_DIRECTORY`

### Security

- Documents host-app entitlements for user-selected file access
- Sandbox-aware design for macOS App Store compatibility

[1.0.1]: https://github.com/macCesar/ti.macos.panels/releases/tag/ios-1.0.1
[1.0.0]: https://github.com/macCesar/ti.macos.panels/tree/9b84e4e605f058af4e832fb2c2a9fa1b4b33a403
