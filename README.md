# ti.macos.panels

Titanium native module for Mac Catalyst file panels.

## Description

`ti.macos.panels` wraps Apple native panels and exposes them through a JavaScript API:

- `NSOpenPanel` for open/select actions
- `NSSavePanel` for save destination actions

The module only runs on Mac Catalyst and all methods share the same result contract, including consistent `ERR_*` codes.

## Features

- Select one folder, one file, or many files
- Document-named variants (`openDocument`, `openDocuments`)
- Save destination picker (`saveFile`)
- Same callback result shape for every API
- Standard `ERR_*` error catalog
- Option validation (including invalid path/type checks)
- File filters with extensions and UTType identifiers

## Compatibility

- Minimum Titanium SDK: `13.2.0.GA` (official SDK; `minsdk: 13.2.0`)
- Module platform: `iphone`
- Runtime target: `macOS` via Mac Catalyst (`-T macos`)
- `ios/manifest` must keep `mac: true`

If you call it outside Mac Catalyst runtime, methods return `ERR_NOT_SUPPORTED_PLATFORM`.

### SDK and Xcode compatibility

The official `13.2.0.GA` SDK includes the Catalyst module fixes from [tidev/titanium-sdk#14391](https://github.com/tidev/titanium-sdk/pull/14391). Use that release or a newer SDK.

`ios/titanium.xcconfig` defaults to `TITANIUM_SDK_VERSION = 13.2.0.GA`. This must match the installed SDK directory, including its suffix. `manifest` uses `minsdk: 13.2.0` as the minimum supported Titanium version.

For Xcode 27.2, use `node scripts/build.cjs` from the repository root. The build hook selects an explicit destination for each archive and uses the selected SDK for headers and frameworks. It does not change the globally selected SDK or patch SDK source. The build script also removes Finder metadata from the ZIP. The native deployment target is iOS 15.0 (including its Catalyst equivalent), separate from the Titanium minimum version.

To select another installed SDK, run `node scripts/build.cjs 14.0.0.fixes`. The host app must also support the lifecycle required by its Apple SDK. See [verification results](QA-CHECKLIST.md#verified-2026-11-09-module-101) for the build and runtime versions tested.

## Entitlements

`ti.macos.panels` opens dialogs and returns paths. Configure file access entitlements in the host app's `tiapp.xml`, according to the locations it needs to read or write.

Add the host app's entitlements here:

```xml
<!-- tiapp.xml of your app -->
<ios>
  <entitlements>
    <dict>
      <!-- add entries here -->
    </dict>
  </entitlements>
</ios>
```

### Access via panel (user-selected paths)

When the user selects a file or folder through `ti.macos.panels`, the module returns its path. A sandboxed app needs this entitlement to read and write the selection:

```xml
<key>com.apple.security.files.user-selected.read-write</key>
<true/>
```

The panel can return a path even when the sandbox prevents `Ti.Filesystem` from reading or writing it. See Apple's [user-selected file access entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.files.user-selected.read-write).

### Programmatic access to ~/Downloads/ (no panel required)

If your app needs to write to `~/Downloads/` directly, without using any panel, add:

```xml
<key>com.apple.security.files.downloads.read-write</key>
<true/>
```

This entitlement permits a sandboxed app to read and write `~/Downloads/` without opening a panel. See Apple's [Downloads access entitlement](https://developer.apple.com/documentation/bundleresources/entitlements/com.apple.security.files.downloads.read-write).

### Programmatic access to ~/Documents/ (no panel required)

There is no first-class entitlement for `~/Documents/` equivalent to the Downloads one. Use the temporary exception entitlement:

```xml
<key>com.apple.security.temporary-exception.files.home-relative-path.read-write</key>
<array>
  <string>/Documents/</string>
</array>
```

This grants read-write access to `~/Documents/` (or a subdirectory) without user interaction. Scope it as narrowly as possible (e.g. `/Documents/MyApp/` instead of `/Documents/`). Apple requires justification for this entitlement on App Store submissions. See [file access temporary exceptions](https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/EntitlementKeyReference/Chapters/AppSandboxTemporaryExceptionEntitlements.html#//apple_ref/doc/uid/TP40011195-CH5-SW7).

### Summary table

| Goal                                     | Entitlement needed                | Needs panel? |
| ---------------------------------------- | --------------------------------- | ------------ |
| Read/write a file the user picked        | `user-selected.read-write`        | Yes          |
| Read/write any path the user picked      | `user-selected.read-write`        | Yes          |
| Write to `~/Downloads/` programmatically | `downloads.read-write`            | No           |
| Write to `~/Documents/` programmatically | `temporary-exception` (see above) | No           |

## Installation

### 1. Build the module

```bash
node scripts/build.cjs
```

Generated package:

- `ios/dist/ti.macos.panels-iphone-1.0.1.zip`

### 2. Install module in your Titanium app

Add this to your app `tiapp.xml`:

```xml
<modules>
  <module platform="iphone" version="1.0.1">ti.macos.panels</module>
</modules>
```

Install or unpack the built module zip into your Titanium modules path (or your app-local `modules/iphone/...` layout).

### 3. Add entitlements in app `tiapp.xml`

At minimum, add `user-selected.read-write` so panel-returned paths are usable:

```xml
<ios>
  <entitlements>
    <dict>
      <key>com.apple.security.files.user-selected.read-write</key>
      <true/>
    </dict>
  </entitlements>
</ios>
```

See [Entitlements](#entitlements) for a full breakdown of which entitlements to add depending on what directories your app accesses.

## Usage

```js
const macPanel = require('ti.macos.panels')

macPanel.pickFolder({ title: 'Choose a folder' }, function (result) {
  if (!result.success) {
    Ti.API.warn(result.code + ': ' + result.message)
    return
  }
  Ti.API.info('Folder: ' + result.path)
})

macPanel.openDocuments({
  title: 'Open documents',
  allowedExtensions: ['txt', 'json']
}, function (result) {
  if (!result.success) {
    Ti.API.warn(result.code + ': ' + result.message)
    return
  }
  Ti.API.info(JSON.stringify(result.paths))
})

macPanel.saveFile({
  title: 'Save file',
  defaultName: 'export',
  defaultExtension: 'txt'
}, function (result) {
  if (!result.success) {
    Ti.API.warn(result.code + ': ' + result.message)
    return
  }

  // saveFile only picks a destination; your app writes the content.
  Ti.Filesystem.getFile(result.path).write('Generated by ti.macos.panels')
})
```

## Screenshots

GitHub will display light or dark screenshots automatically based on your theme.

### `pickFolder`

![pickFolder (Light)](documentation/images/light-mode/pickFolder.png#gh-light-mode-only)
![pickFolder (Dark)](documentation/images/dark-mode/pickFolder.png#gh-dark-mode-only)

### `pickFile`

![pickFile (Light)](documentation/images/light-mode/pickFile.png#gh-light-mode-only)
![pickFile (Dark)](documentation/images/dark-mode/pickFile.png#gh-dark-mode-only)

### `pickFiles`

![pickFiles (Light)](documentation/images/light-mode/pickFiles.png#gh-light-mode-only)
![pickFiles (Dark)](documentation/images/dark-mode/pickFiles.png#gh-dark-mode-only)

### `openDocument`

![openDocument (Light)](documentation/images/light-mode/openDocument.png#gh-light-mode-only)
![openDocument (Dark)](documentation/images/dark-mode/openDocument.png#gh-dark-mode-only)

### `openDocuments`

![openDocuments (Light)](documentation/images/light-mode/openDocuments.png#gh-light-mode-only)
![openDocuments (Dark)](documentation/images/dark-mode/openDocuments.png#gh-dark-mode-only)

### `saveFile`

![saveFile (Light)](documentation/images/light-mode/saveFile.png#gh-light-mode-only)
![saveFile (Dark)](documentation/images/dark-mode/saveFile.png#gh-dark-mode-only)

## Read selected files with Ti.Filesystem

`ti.macos.panels` returns paths. File I/O is handled with Titanium `Ti.Filesystem`.

Single file:

```js
macPanel.pickFile({ title: 'Choose one file' }, function (result) {
  if (!result.success || !result.path) { return }

  const file = Ti.Filesystem.getFile(result.path)
  const blob = file.read()
  Ti.API.info(blob ? blob.text : '')
})
```

Multiple files:

```js
macPanel.pickFiles({ title: 'Choose files' }, function (result) {
  if (!result.success || !Array.isArray(result.paths)) { return }

  result.paths.forEach(function (selectedPath) {
    const file = Ti.Filesystem.getFile(selectedPath)
    const blob = file.read()
    Ti.API.info(selectedPath + ' -> ' + (blob ? blob.length : 0) + ' bytes')
  })
})
```

## API reference

### `pickFolder(options?, callback?)`

Selects one folder (`NSOpenPanel`).

### `pickFile(options?, callback?)`

Selects one file (`NSOpenPanel`).

### `pickFiles(options?, callback?)`

Selects multiple files (`NSOpenPanel`), controlled by `allowMultiple` (default `true`).

### `openDocument(options?, callback?)`

Same behavior as `pickFile`, with `selectionType: "document"` in the result.

### `openDocuments(options?, callback?)`

Same behavior as `pickFiles`, but always with multi-selection enabled and `selectionType: "documents"`.

### `saveFile(options?, callback?)`

Selects save destination (`NSSavePanel`).

### Alias behavior

`pickFile` and `openDocument` use the same `NSOpenPanel` flow, options, and validation. The same applies to `pickFiles` and `openDocuments`. The names and the `selectionType` value distinguish the intent:

- `pickFile` returns `selectionType: "file"`, while `openDocument` returns `selectionType: "document"`.
- `pickFiles` returns `selectionType: "files"`, while `openDocuments` returns `selectionType: "documents"`.
- `openDocuments` always enables multi-selection.
- `pickFiles` can enable or disable multi-selection with `allowMultiple`.


## Options

Common options:

- `title: String`
- `prompt: String`
- `directoryURL: String` (must be an existing directory)
- `showHiddenFiles: Boolean`
- `canCreateDirectories: Boolean`

Open panel options:

- `resolvesAliases: Boolean` (default `true`)
- `allowedExtensions: String | String[]`
- `allowedContentTypes: String | String[]` (UTType identifiers, priority over extensions)
- `allowMultiple: Boolean` (`pickFiles` only)

Save panel options:

- `defaultName: String`
- `defaultExtension: String`

## Unified result contract

All methods use this result shape for synchronous returns and callback arguments:

```js
{
  paths: String[],
  success: Boolean,
  canceled: Boolean,
  cancelled: Boolean,
  path: String | null,
  code: String | null,
  message: String | null,
  panel: 'open' | 'save',
  fileName: String | null,
  extension: String | null,
  selectionType: 'folder' | 'file' | 'files' | 'document' | 'documents' | 'save'
}
```

## Error codes

- `ERR_NO_SELECTION`
- `ERR_USER_CANCELLED`
- `ERR_INVALID_OPTIONS`
- `ERR_PANEL_UNAVAILABLE`
- `ERR_NOT_SUPPORTED_PLATFORM`
- `ERR_INVALID_START_DIRECTORY`

## Build and test

Build module package:

```bash
node scripts/build.cjs
```

To run the example, install the ZIP in a Classic Titanium host app and copy `example/app.js` and `example/validation-tests.js` into its `Resources` directory. Configure its file access entitlements, then run from the host app directory:

```bash
ti build -p ios -T macos --sdk 14.0.0.fixes
```

For the automated native assertions, call `require('validation-tests').run(require('ti.macos.panels'), result => Ti.API.info(JSON.stringify(result)))` in that Catalyst host.

If you need to validate native slices directly with Xcode:

```bash
cd ios
xcodebuild -project ti.macos.panels.xcodeproj -scheme ti.macos.panels -configuration Release -archivePath build/iphoneos.xcarchive -destination 'generic/platform=iOS' archive
xcodebuild -project ti.macos.panels.xcodeproj -scheme ti.macos.panels -configuration Release -archivePath build/iphonesimulator.xcarchive -destination 'generic/platform=iOS Simulator' archive
xcodebuild -project ti.macos.panels.xcodeproj -scheme ti.macos.panels -configuration Release -archivePath build/macosx.xcarchive -destination 'generic/platform=macOS,variant=Mac Catalyst' archive
```

## Troubleshooting

### `Could not find a valid Titanium module ... ti.macos.panels`

- Confirm `tiapp.xml` includes module id/version/platform.
- Confirm the built zip is installed in your Titanium modules path or app-local modules directory.

### Panel always cancels or no usable path is returned

- Check that `com.apple.security.files.user-selected.read-write` is in `tiapp.xml`.
- Check that the app is built with `-T macos` (Mac Catalyst runtime).

### Ti.Filesystem can't read/write a path outside the sandbox

The module returns the path. If access is blocked, it is a sandbox entitlement issue in the app. Add the entitlement for the target directory. See the [Entitlements summary table](#summary-table).

### `ERR_INVALID_OPTIONS`

- Make sure option types match the contract (string/boolean/string-array).
- An invalid `directoryURL` returns `ERR_INVALID_START_DIRECTORY`; check that the directory exists.

### Titanium CLI build fails before compile

- With Xcode 27.2, use `node scripts/build.cjs` so each archive has an explicit destination.
- Run `node --test tests/build-hook.test.cjs` to check the build hook.
- Run `example/validation-tests.js` inside a Catalyst host to check synchronous errors and exactly-once callbacks for all six APIs.

## Contributing

- Open an issue with reproducible steps for bugs.
- Propose API/behavior changes before large refactors.
- Submit focused PRs with tests/checklist updates (`QA-CHECKLIST.md`) when behavior changes.

## License

MIT. See [`LICENSE`](LICENSE).

## Credits and acknowledgments

- Built with Titanium SDK and TiDev toolchain.
- Uses Apple native panel APIs (`NSOpenPanel`, `NSSavePanel`).

## Project notes

- [Requirements](docs/project/requirements.md): API and compatibility contract.
- [Context](docs/project/context.md): code layout, build workflow, and documentation map.
- [Decisions](docs/project/decisions.md): choices and their reasons.
- [Status](docs/project/status.md): current work and release state. Read this when resuming work; keep it out of startup imports.
