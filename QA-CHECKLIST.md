# QA Checklist - ti.macos.panels (Mac-only)

## Setup

1. Build module zip with SDK `13.2.0+`.
2. Install in a Titanium app with `mac: true` and file entitlements.
3. Run app with Mac Catalyst target.

## Structured Assertions

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

1. Trigger `pickFile('invalid-options', cb)`.
2. Assert:
- `result.success === false`
- `result.code === 'ERR_INVALID_OPTIONS'`

### H. invalid directoryURL

1. Trigger `pickFolder({ directoryURL: '/path/does/not/exist' }, cb)`.
2. Assert:
- `result.success === false`
- `result.code === 'ERR_INVALID_START_DIRECTORY'`
