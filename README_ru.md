# XFreedom

XFreedom — нативный мультиплатформенный клиент сервиса XFreedom. Клиент сохраняет существующий tunnel-runtime на базе libbox/sing-box и добавляет продуктовую оболочку XFreedom, импорт персональной подписки, интеграцию с адаптивной маршрутизацией и переносимую premium-систему тем.

## Текущее состояние

- Android: нативный `VpnService`.
- iOS: `NetworkExtension / PacketTunnelProvider`.
- Desktop: Windows, macOS и Linux.
- Импорт: `xfreedom://import?url=...`, с сохранением совместимости со старыми ссылками upstream.
- Дизайн: 64 переносимых XFreedom-пресета.
- Версия продукта: `1.0.0+1`.
- Android application ID: `app.xservis.xfreedom`.
- Apple base bundle ID: `app.xservis.xfreedom`.

GitHub Actions собирает тестовые артефакты. Публикация production-релиза в сторах намеренно заблокирована до наличия настоящих signing credentials.

## Тестовые сборки

- Android universal APK: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/XFreedom-Android-universal.apk
- Android AAB: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/xfreedom-android-market.aab
- Windows installer: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/XFreedom-Windows-Setup-x64.exe
- Windows portable: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/XFreedom-Windows-Portable-x64.zip
- macOS DMG: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/XFreedom-MacOS.dmg
- Debian: https://github.com/aima666qs-commits/xservis-app/releases/download/draft/XFreedom-Debian-x64.deb

Draft Android-сборка может использовать непроизводственную подпись, если настоящий release keystore ещё не настроен. Для Google Play/TestFlight/App Store требуется реальная продуктовая подпись XFreedom.

## Upstream и лицензия

Этот репозиторий является публичным GitHub-fork проекта [hiddify/hiddify-app](https://github.com/hiddify/hiddify-app). Исходная атрибуция и действующий текст лицензии сохранены в [LICENSE.md](LICENSE.md).

К изменениям XFreedom относятся собственный интерфейс и бренд, app/bundle identities, схема импорта, release pipeline, 64-theme system, интеграция подписки и другие продуктовые доработки.

**Критическое условие перед коммерческой публикацией:** существующий `LICENSE.md` содержит дополнительные условия, в том числе требование атрибуции, автоматического релиза и ограничение коммерческого использования без предварительного письменного согласия upstream-правообладателя. Коммерческий/store-релиз нельзя считать юридически готовым, пока это условие не закрыто письменным разрешением либо пока ограниченные upstream-компоненты не заменены на код с подходящей лицензией.

Удалять upstream copyright/license notices только ради ребрендинга нельзя.

## Граница безопасности

Работа над приложением и UI не должна менять production-конфигурацию VPN-серверов. Маршруты, UUID, REALITY key material, SNI, порты и текущие VPN-сервисы управляются отдельным проверяемым контуром.

## Поддержка

Telegram: [@xfreedommBot](https://t.me/xfreedommBot)
