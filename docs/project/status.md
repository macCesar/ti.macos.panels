# Status

Updated: 2026-11-09

Session by: Codex (GPT-6)

Phase: release preparation on `main`.

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

The maintainer approved a GitHub draft named `iOS 1.0.1`, using proposed tag `ios-1.0.1`. Commits, a rebuild from the release target, and the draft upload are being prepared. See [release notes](../releases/ios-1.0.1.md).

## Next step

Create the draft with the rebuilt ZIP, verify its target and attachment, and record its URL and artifact checksum here. Publication remains a maintainer action after reviewing the draft.
