# Status

Updated: 2026-11-09

Session by: Codex (GPT-6)

Phase: GitHub draft ready for maintainer review on `main`.

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

[Draft iOS 1.0.1](https://github.com/macCesar/ti.macos.panels/releases/tag/untagged-ebae370ed5312f527be7) is ready with `ti.macos.panels-iphone-1.0.1.zip` attached. The draft uses proposed tag `ios-1.0.1` and targets commit `12d4755b9a3e9418b111af7560f90ef588c9f0ec` on `main`.

The ZIP was rebuilt from that commit using the official Titanium `13.2.0.GA` SDK and Xcode 27.2. Its manifest, archive integrity, native architectures, packaged manual, validation fixture, and metadata exclusions passed verification. GitHub reports the same SHA-256 as the local artifact:

`376a0b7b618ef0a2cb1c8398e1179728105f8fd47d09ae22a09c0cfc94637668`

Three semantic commits contain the release changes:

- `0b9bfd4`: reject invalid options before presenting panels.
- `b0f2681`: support Xcode 27.2 with the official Titanium 13.2 SDK.
- `12d4755`: prepare version 1.0.1, documentation, and project notes.

The session-close commit records the draft outcome after the artifact build. The draft's source commit remains `12d4755`. Local verification details are in `ios/build/release-verification-1.0.1.json`; that generated file is ignored by Git.

## Next step

Review the draft and publish it when ready. The draft remains unpublished, and its proposed remote tag has not been created.
