# Plan Maestro: `ti.macos.panels` (Mac-Only)

## Objetivo

Construir un modulo Titanium enfocado **exclusivamente en Mac Catalyst** para dialogos nativos de archivos con contrato unificado y errores estandarizados.

## Alcance Cerrado de v1

APIs publicas:

1. `pickFolder(options, callback)`
2. `pickFile(options, callback)`
3. `pickFiles(options, callback)`
4. `openDocument(options, callback)`
5. `openDocuments(options, callback)`
6. `saveFile(options, callback)`

Fuera de alcance en este modulo:

1. `UIDocumentPickerViewController`
2. APIs legacy (`selectFolder`)
3. soporte iOS no-Catalyst

## Backends Nativos

1. `NSOpenPanel` para `pickFolder`, `pickFile`, `pickFiles`, `openDocument`, `openDocuments`
2. `NSSavePanel` para `saveFile`

## Contrato de Respuesta (unificado)

Todas las APIs devuelven este shape (sync o callback):

```js
{
  success: Boolean,
  cancelled: Boolean,
  canceled: Boolean,
  code: String | null,
  message: String | null,
  panel: 'open' | 'save',
  selectionType: 'folder' | 'file' | 'files' | 'document' | 'documents' | 'save',
  path: String | null,
  paths: String[],
  fileName: String | null,
  extension: String | null
}
```

## Catalogo de Errores

1. `ERR_NOT_SUPPORTED_PLATFORM`
2. `ERR_INVALID_OPTIONS`
3. `ERR_PANEL_UNAVAILABLE`
4. `ERR_USER_CANCELLED`
5. `ERR_NO_SELECTION`
6. `ERR_INVALID_START_DIRECTORY`

## Validaciones de Opciones

Se valida tipo/shape antes de abrir panel:

1. strings (`title`, `prompt`, `directoryURL`, `defaultName`, `defaultExtension`)
2. booleans (`showHiddenFiles`, `canCreateDirectories`, `resolvesAliases`, `allowMultiple`)
3. filtros (`allowedExtensions`, `allowedContentTypes` como string o array de strings)
4. `directoryURL` debe existir y ser directorio

## Reglas de Build

1. `manifest`: `platform: iphone`, `mac: true`
2. `project.pbxproj`: `SDKROOT = iphoneos`, `SUPPORTED_PLATFORMS = "iphoneos iphonesimulator"`, `SUPPORTS_MACCATALYST = YES`
3. app consumidora con entitlements de acceso a archivos

## QA Checklist (asserts estructurados)

### Caso A: `pickFolder` exitoso

Assert:

1. `result.success === true`
2. `result.selectionType === 'folder'`
3. `typeof result.path === 'string'`

### Caso B: `pickFile` con filtro

Assert:

1. `result.success === true`
2. `result.selectionType === 'file'`
3. `result.path` cumple filtro solicitado

### Caso C: `pickFiles` multiple

Assert:

1. `result.success === true`
2. `result.selectionType === 'files'`
3. `Array.isArray(result.paths) === true`
4. `result.paths.length > 0`

### Caso D: `openDocument/openDocuments`

Assert:

1. `openDocument -> selectionType === 'document'`
2. `openDocuments -> selectionType === 'documents'`

### Caso E: `saveFile`

Assert:

1. `result.success === true`
2. `result.selectionType === 'save'`
3. `result.path` valido para escritura

### Caso F: cancelacion de usuario

Assert:

1. `result.success === false`
2. `result.cancelled === true`
3. `result.code === 'ERR_USER_CANCELLED'`

### Caso G: opciones invalidas

Assert:

1. `result.success === false`
2. `result.code === 'ERR_INVALID_OPTIONS'`

### Caso H: `directoryURL` invalido

Assert:

1. `result.success === false`
2. `result.code === 'ERR_INVALID_START_DIRECTORY'`

## Estado

1. API Mac-only implementada
2. contrato unificado implementado
3. catalogo de errores y validaciones implementados
4. documentacion y example alineados al scope Mac-only
