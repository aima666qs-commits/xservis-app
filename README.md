# XFreedom

XFreedom is the native multi-platform client for the XFreedom network service. The current client targets Android, iOS, Windows, macOS and Linux and keeps the existing libbox/sing-box-based tunnel runtime while adding XFreedom product identity, signed subscription import, adaptive routing integration and a reusable premium theme system.

## Current product state

- Android: native `VpnService` tunnel integration.
- iOS: `NetworkExtension` packet-tunnel integration.
- Desktop: Windows, macOS and Linux builds.
- Import scheme: `xfreedom://import?url=...` with legacy upstream-link compatibility.
- Theme system: 64 portable XFreedom presets shared with Owner Control.
- Product version: `1.0.0+1`.
- Android application ID: `app.xservis.xfreedom`.
- Apple base bundle ID: `app.xservis.xfreedom`.

Unsigned/development artifacts can be produced by GitHub Actions. Production store releases are intentionally gated by platform signing credentials.

## Downloads

The CI draft release is used for test builds:

- Android universal APK: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/XFreedom-Android-universal.apk
- Android Play bundle: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/xfreedom-android-market.aab
- Windows installer: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/XFreedom-Windows-Setup-x64.exe
- Windows portable: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/XFreedom-Windows-Portable-x64.zip
- macOS DMG: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/XFreedom-MacOS.dmg
- Debian package: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/XFreedom-Debian-x64.deb

Draft Android builds may use non-production signing when release credentials are not configured. Store/TestFlight publication must use the real XFreedom signing identities.

## Build

The repository pins Flutter `3.38.5`.

Typical preparation/build targets are defined in the root `Makefile`, including:

- `make android-apk-prepare` / `make android-apk-release`
- `make android-aab-prepare` / `make android-aab-release`
- `make windows-prepare` / `make windows-release`
- `make macos-prepare` / `make macos-release`
- `make linux-prepare` / `make linux-release`
- `make ios-prepare`

iOS unsigned compile verification is performed independently by `.github/workflows/ios-verify.yml`.

## Upstream and licensing

This repository is a public GitHub fork of [hiddify/hiddify-app](https://github.com/hiddify/hiddify-app). XFreedom preserves upstream attribution and the repository's existing license terms in [LICENSE.md](LICENSE.md).

Major XFreedom changes include product branding/identities, the XFreedom dashboard, native import scheme, release pipelines, premium theme system, subscription integration and other product-specific UI/control work.

**Important distribution condition:** the inherited license in this repository includes additional terms, including attribution, automated-release requirements and a non-commercial-use restriction unless prior written consent is obtained from the upstream copyright holder. XFreedom store/commercial distribution must not be represented as cleared until that requirement is resolved or restricted upstream material is replaced with code whose licensing permits the intended distribution.

No upstream copyright or license notices should be removed merely as part of rebranding.

## Security boundary

Client UI/release work must not silently rewrite production XFreedom server runtime settings. Server routes, UUIDs, REALITY key material, SNI, ports and live VPN services are managed separately and require their own validated deployment path.

## Support

Product support: [@xfreedommBot](https://t.me/xfreedommBot)

Server-side legal/privacy pages are maintained in the XFreedom service repository.
