# ti.macos.panels native project

## Documentation

- Full module documentation: [`../README.md`](../README.md)
- Packaged module docs source: [`../documentation/index.md`](../documentation/index.md)

## Build

```bash
cd ..
node scripts/build.cjs
```

The package is written to this directory, relative to `ios/`:

- `dist/ti.macos.panels-iphone-1.0.1.zip`

## Notes

- Module id: `ti.macos.panels`
- Platform: `iphone`
- Minimum Titanium SDK: `13.2.0`
- Catalyst support is enabled via `mac: true` in `manifest`.

The default build SDK is the official `13.2.0.GA`. Pass another installed SDK as an argument to the script. The hook runs during this repository's build and stays out of the module package.
