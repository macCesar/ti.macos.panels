# Status

Updated: 2026-11-09

Session by: Codex (GPT-6)

Phase: version 1.0.1 published on GitHub.

## Completed work

Version 1.0.1 fixes invalid-option calls that could open a panel and deliver a second callback. The module builds with Xcode 27.2 using the official Titanium `13.2.0.GA` SDK and retains `minsdk: 13.2.0`.

The README, packaged manual, native project guide, resource guides, QA checklist, changelog, and release notes have been reviewed with Humanizer. Session notes use the four files under `docs/project/`, linked from the README.

## Verification

- Module build passed for device arm64, simulator arm64/x86_64, and Catalyst arm64/x86_64.
- Four build-hook tests and 48 native assertions passed.
- Seven interactive cases passed, including file filters, multiple selection, cancellation, and save followed by a real write.
- Runtime tests used a Titanium `14.0.0.fixes` host. A complete Titanium 13.2 app was not runtime-tested with Apple SDK 27.2.
- Module 1.0.1 was installed in the LM - Generador de Tablas project, which compiled successfully with Titanium `14.0.0.fixes`. That integration check did not replace the app in `/Applications`.

## Release state

[iOS 1.0.1](https://github.com/macCesar/ti.macos.panels/releases/tag/ios-1.0.1) was published with maintainer approval on 2026-11-10 at 05:23:09 UTC (2026-11-09 at 23:23:09 in America/Matamoros). The release includes `ti.macos.panels-iphone-1.0.1.zip`. Remote tag `ios-1.0.1` resolves to commit `12d4755b9a3e9418b111af7560f90ef588c9f0ec` on `main`.

The ZIP was rebuilt from that commit using the official Titanium `13.2.0.GA` SDK and Xcode 27.2. Its manifest, archive integrity, native architectures, packaged manual, validation fixture, and metadata exclusions passed verification. GitHub reports the same SHA-256 as the local artifact:

`376a0b7b618ef0a2cb1c8398e1179728105f8fd47d09ae22a09c0cfc94637668`

Three semantic commits contain the release changes:

- `0b9bfd4`: reject invalid options before presenting panels.
- `b0f2681`: support Xcode 27.2 with the official Titanium 13.2 SDK.
- `12d4755`: prepare version 1.0.1, documentation, and project notes.

Follow-up documentation commits record the draft and publication outcomes after the artifact build. The release source commit remains `12d4755`. Local verification details are in `ios/build/release-verification-1.0.1.json`; that generated file is ignored by Git.

## Next step

Release preparation and publication are complete. No release actions remain for version 1.0.1.
