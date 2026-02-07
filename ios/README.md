# ti.macos.panels iOS Module Project

This folder contains the native iOS module project for `ti.macos.panels`.

## Main docs

- Full module documentation: [`../README.md`](../README.md)
- Packaged module docs source: [`../documentation/index.md`](../documentation/index.md)

## Build

```bash
cd ios
ti build -p ios --build-only --sdk 13.2.0
```

Generated package:

- `dist/ti.macos.panels-iphone-1.0.0.zip`

## Notes

- Module id: `ti.macos.panels`
- Platform: `iphone`
- Minimum Titanium SDK: `13.2.0`
- Catalyst support is enabled via `mac: true` in `manifest`.
