# XFreedom 1.0 — чек-лист до публичного релиза

Дата подготовки: 2026-09-29.

## Уже проверено

- [x] XFreedom product identity в Android/iOS/macOS/Windows/Linux.
- [x] Android application ID: `app.xservis.xfreedom`.
- [x] Apple base bundle ID: `app.xservis.xfreedom`.
- [x] XFreedom deep link: `xfreedom://import?url=...`.
- [x] Android APK build.
- [x] Android AAB build.
- [x] Windows build.
- [x] Linux build.
- [x] macOS DMG/PKG build.
- [x] iOS release compile без code signing.
- [x] XFreedom AppIcon catalog generated in CI.
- [x] 64-theme portable design system.
- [x] CI no longer publishes artifacts into the upstream Hiddify release repository.

## Обязательные внешние данные для production signing

### Android / Google Play

GitHub Actions secrets:

- `ANDROID_SIGNING_KEY` — base64 release keystore.
- `ANDROID_SIGNING_STORE_PASSWORD`.
- `ANDROID_SIGNING_KEY_PASSWORD`.
- `ANDROID_SIGNING_KEY_ALIAS`.
- `GOOGLE_PLAY_SERVICE_ACCOUNT_JSON` — service account with permission to upload the XFreedom application.

Production release workflow must fail closed if the release signing key is absent.

### iOS / TestFlight / App Store

GitHub Actions secrets:

- `APPLE_CERTIFICATE_P12`.
- `APPLE_CERTIFICATE_P12_PASSWORD`.
- `APPLE_MOBILE_PROVISIONING_PROFILES_TARGZ_BASE64`.
- `APPSTORE_ISSUER_ID`.
- `APPSTORE_API_KEY_ID`.
- `APPSTORE_API_PRIVATE_KEY`.

Required app identifiers:

- main app: `app.xservis.xfreedom`;
- packet-tunnel extension: `app.xservis.xfreedom.PacketTunnel`.

The signed profile must include the Network Extension entitlement required by the packet tunnel.

## Store metadata

Product name: **XFreedom**

Category: network / utility client.

Support: `https://t.me/xfreedommBot`.

Privacy policy target: `https://xservis.app/legal/privacy.html`.

Terms target: `https://xservis.app/legal/terms.html`.

Do not submit those public URLs until the XFreedom production web deployment is confirmed reachable.

## Licensing gate

This repository is a fork of `hiddify/hiddify-app` and keeps the inherited `LICENSE.md`.

The current license text contains additional conditions including a non-commercial-use restriction without prior written consent. Therefore one of these must be completed before a commercial/store launch tied to paid XFreedom service:

1. documented written commercial permission from the relevant upstream rights holder; or
2. replacement of restricted inherited client material with a codebase whose license permits the intended commercial distribution.

Do not mark this item complete based on assumption.

- [ ] Commercial distribution permission / replacement path confirmed.

## Production infrastructure gate

The app build does not authorize changes to working XFreedom VPN servers.

Before customer launch separately verify:

- [ ] XFreedom web/API production deployment.
- [ ] Owner Control `/owner/` production canary.
- [ ] Payment providers actually configured with real merchant credentials.
- [ ] Payment fulfillment reaches the authoritative subscription/account service.
- [ ] Seven-node runtime inventory is collected read-only.
- [ ] Existing VPN routes continue working after product-layer deployment.
- [ ] Android signed production APK/AAB verified by signing certificate fingerprint.
- [ ] iOS signed IPA / TestFlight upload verified.
- [ ] Store account ownership/agreements/tax/payment requirements completed.

## Definition of public launch

A public launch is considered complete only after the production web/API is reachable, the native release is signed with XFreedom-owned credentials, payment/subscription activation is verified end-to-end, required licensing permission is documented, and the intended distribution channel has accepted or published the build.

A GitHub draft artifact alone is a test distribution, not a production-store release.
