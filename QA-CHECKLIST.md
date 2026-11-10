# QA checklist for ti.macos.panels

## Setup

1. Build module zip with `node scripts/build.cjs` (official SDK `13.2.0.GA`).
2. Install the module in a Titanium host app and declare its file access entitlements. The module manifest must retain `mac: true`.
3. Run app with Mac Catalyst target.

## API checks

### A. pickFolder success

1. Trigger `pickFolder({ title: 'Choose folder' }, cb)`.
2. Select valid folder.
3. Assert:

- `result.success === true`
- `result.selectionType === 'folder'`
- `typeof result.path === 'string'`
- `result.code === null`

### B. pickFile with filter

1. Trigger `pickFile({ allowedContentTypes: ['public.image'] }, cb)`.
2. Select image.
3. Assert:

- `result.success === true`
- `result.selectionType === 'file'`
- `result.path` exists

### C. pickFiles multiple

1. Trigger `pickFiles({ allowMultiple: true }, cb)`.
2. Select 2+ files.
3. Assert:

- `result.success === true`
- `result.selectionType === 'files'`
- `Array.isArray(result.paths) === true`
- `result.paths.length >= 2`

### D. openDocument / openDocuments

1. Trigger `openDocument(..., cb)`.
2. Assert `result.selectionType === 'document'`.
3. Trigger `openDocuments(..., cb)`.
4. Assert `result.selectionType === 'documents'`.

### E. saveFile destination + write

1. Trigger `saveFile(..., cb)`.
2. Choose destination.
3. Assert:

- `result.success === true`
- `result.selectionType === 'save'`
- `result.path` exists
4. Write content via `Ti.Filesystem.getFile(result.path).write(...)` and assert write succeeds.

### F. user cancellation

1. Trigger any method and cancel.
2. Assert:

- `result.success === false`
- `result.cancelled === true`
- `result.code === 'ERR_USER_CANCELLED'`

### G. invalid options

1. Run `example/validation-tests.js` in a Catalyst host (all six APIs, synchronous and callback forms).
2. Trigger `pickFile('invalid-options', cb)`.
3. Assert:

- `result.success === false`
- `result.code === 'ERR_INVALID_OPTIONS'`
- Callback is invoked exactly once; no panel appears, including after the callback returns.

### H. invalid directoryURL

1. Trigger `pickFolder({ directoryURL: '/path/does/not/exist' }, cb)`.
2. Assert:

- `result.success === false`
- `result.code === 'ERR_INVALID_START_DIRECTORY'`

## Verified 2026-11-09 (module 1.0.1)

- Xcode 27.2 (27B52), macOS 27.0.1, Titanium CLI 9.1.0.
- Built module using the installed official Titanium 13.2.0.GA SDK, with `node scripts/build.cjs`.
- Package contains device arm64, simulator arm64/x86_64 and Catalyst arm64/x86_64 slices. `minsdk: 13.2.0`, module API version 2.
- Four build-hook tests passed (`node --test tests/build-hook.test.cjs`). JavaScript syntax checks and Xcode project plist validation passed.
- Reproduced 1.0.0 regression in a Titanium 14.0.0.fixes Catalyst host: invalid options presented a panel; cancelling it delivered a cancellation callback after the validation error.
- The same host using the module built against 13.2.0.GA passed all 48 native assertions in `example/validation-tests.js`, with no unexpected panels.
- Seven interactive cases passed: folder, UTType-filtered image, multiple files, text document, extension-filtered multiple documents, save plus real file write, and cancellation (`ERR_USER_CANCELLED`).
- Runtime tests used Titanium 14.0.0.fixes. Titanium 13.2 was verified for module compilation. A host app using Titanium 13.2 with Apple SDK 27.2 still needs its own UIScene lifecycle check.
- Installed 1.0.1 app-locally in the LM - Generador de Tablas project; its Catalyst build passed with Titanium 14.0.0.fixes. Generated `module.xcconfig` confirms version 1.0.1.
