# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-06

### Added
- Initial release of `ti.macos.panels` Titanium module
- Mac Catalyst-only native file dialogs using `NSOpenPanel` and `NSSavePanel`
- Six public APIs: `pickFolder()`, `pickFile()`, `pickFiles()`, `openDocument()`, `openDocuments()`, `saveFile()`
- Unified result contract across all methods with standardized error codes
- Option validation with detailed error messages
- File filtering via extensions and UTType identifiers
- Support for both callback and synchronous return patterns
- Comprehensive documentation and usage examples
- Full error catalog: `ERR_NO_SELECTION`, `ERR_USER_CANCELLED`, `ERR_INVALID_OPTIONS`, `ERR_PANEL_UNAVAILABLE`, `ERR_NOT_SUPPORTED_PLATFORM`, `ERR_INVALID_START_DIRECTORY`

### Security
- Requires Mac Catalyst entitlements for user-selected file access
- Sandbox-aware design for macOS App Store compatibility

[1.0.0]: https://github.com/cesarestrada/ti.macos.panels/releases/tag/v1.0.0
