- [x] Stop invalid-option calls before opening a panel and deliver one error callback across all six methods.
- [x] Add explicit archive destinations and an iOS 15 deployment target for Xcode 27.2.
- [x] Build with the official Titanium 13.2.0.GA SDK while retaining `minsdk: 13.2.0`.
- [x] Verify 48 native assertions and seven interactive cases in a Titanium 14.0.0.fixes Catalyst host; compile LM - Generador de Tablas with the updated module.
- [x] Update installation instructions, API documentation, and verification notes.

The ZIP includes iOS device, simulator, and Mac Catalyst variants. The simulator and Catalyst variants support arm64 and x86_64.

Titanium 13.2.0.GA was used to compile the module. Runtime tests used Titanium 14.0.0.fixes; host-app lifecycle support with Apple SDK 27.2 needs separate verification for older SDKs.
