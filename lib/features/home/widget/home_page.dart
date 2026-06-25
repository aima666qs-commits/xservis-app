import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/bottom_sheets/bottom_sheets_notifier.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/diagnostics/aima_network_diagnostics.dart';
import 'package:hiddify/features/home/widget/aima_matrix_background.dart';
import 'package:hiddify/features/home/widget/connection_button.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/profile/widget/profile_tile.dart';
import 'package:hiddify/features/proxy/active/active_proxy_card.dart';
import 'package:hiddify/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = ref.watch(translationsProvider).requireValue;
    final activeProfile = ref.watch(activeProfileProvider);
    final connection = ref.watch(connectionNotifierProvider);
    final network = ref.watch(aimaNetworkDiagnosticsProvider).valueOrNull ??
        const AimaNetworkSnapshot.unsupported();

    final status = _AimaStatusViewModel.from(connection, network);

    return Scaffold(
      backgroundColor: const Color(0xFF020706),
      appBar: AppBar(
        backgroundColor: const Color(0xD9020706),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Assets.images.logo.svg(height: 24),
            const Gap(8),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'AIMA VPN',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const TextSpan(text: '  '),
                  WidgetSpan(
                    child: AppVersionLabel(),
                    alignment: PlaceholderAlignment.middle,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          _PlatformBadge(label: _platformLabel()),
          const Gap(8),
          Semantics(
            key: const ValueKey('profile_add_button'),
            label: t.pages.profiles.add,
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: Color(0xFF41F2A1)),
              onPressed: () =>
                  ref.read(bottomSheetsNotifierProvider.notifier).showAddProfile(),
            ),
          ),
          const Gap(8),
        ],
      ),
      body: AimaMatrixBackground(
        child: SafeArea(
          top: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
                    sliver: SliverList.list(
                      children: [
                        _AimaHeroStatus(status: status, network: network),
                        const Gap(14),
                        switch (activeProfile) {
                          AsyncData(value: final profile?) => ProfileTile(
                              profile: profile,
                              isMain: true,
                              margin: EdgeInsets.zero,
                              color: const Color(0xB30B1714),
                            ),
                          _ => const _NoProfileCard(),
                        },
                        const Gap(26),
                        Center(
                          child: Column(
                            children: [
                              const ConnectionButton(),
                              const Gap(10),
                              const ActiveProxyDelayIndicator(),
                              const Gap(12),
                              _NetworkFacts(network: network),
                            ],
                          ),
                        ),
                        const Gap(22),
                        const ActiveProxyFooter(),
                        const Gap(40),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: (ref.watch(hasAnyProfileProvider).value ?? false)
          ? FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xE611211C),
                foregroundColor: const Color(0xFF8BFFD0),
                side: const BorderSide(color: Color(0x6600FF9D)),
              ),
              onPressed: () => ref
                  .read(bottomSheetsNotifierProvider.notifier)
                  .showQuickSettings(),
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: const Text('Режим и маршрут'),
            )
          : null,
    );
  }

  static String _platformLabel() {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'ANDROID',
      TargetPlatform.iOS => 'iOS',
      TargetPlatform.windows => 'WINDOWS',
      TargetPlatform.macOS => 'macOS',
      TargetPlatform.linux => 'LINUX',
      _ => 'AIMA',
    };
  }
}

class _AimaHeroStatus extends StatelessWidget {
  const _AimaHeroStatus({required this.status, required this.network});

  final _AimaStatusViewModel status;
  final AimaNetworkSnapshot network;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xD90A1512),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: status.color.withValues(alpha: .55)),
        boxShadow: [
          BoxShadow(
            color: status.color.withValues(alpha: .16),
            blurRadius: 34,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status.color.withValues(alpha: .16),
                  border: Border.all(color: status.color.withValues(alpha: .65)),
                ),
                child: Icon(status.icon, color: status.color, size: 28),
              ),
              const Gap(14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: .2,
                          ),
                    ),
                    const Gap(4),
                    Text(
                      status.subtitle,
                      style: const TextStyle(
                        color: Color(0xFF9EC2B4),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Gap(16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _FactChip(
                icon: Icons.network_cell_rounded,
                text: network.supported ? network.transportLabel : 'Сеть: не проверено',
              ),
              _FactChip(
                icon: Icons.shield_outlined,
                text: status.tunnelLabel,
              ),
              _FactChip(
                icon: Icons.visibility_off_outlined,
                text: 'Телеметрия: выкл.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NetworkFacts extends StatelessWidget {
  const _NetworkFacts({required this.network});

  final AimaNetworkSnapshot network;

  @override
  Widget build(BuildContext context) {
    if (!network.supported) {
      return const Text(
        'Диагностика сети недоступна на этой платформе',
        style: TextStyle(color: Color(0xFF76998C), fontSize: 12),
      );
    }

    final message = switch ((network.hasNetwork, network.validated, network.captivePortal)) {
      (false, _, _) => 'Сигнал или интернет отсутствует',
      (true, _, true) => 'Требуется вход в сеть Wi-Fi',
      (true, false, false) => 'Сеть есть, интернет не подтверждён',
      _ when network.networkChanged => 'Сеть изменилась — проверяем туннель',
      _ => 'Интернет подтверждён системой',
    };

    return Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFF9EC2B4), fontSize: 12),
    );
  }
}

class _NoProfileCard extends StatelessWidget {
  const _NoProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xB30B1714),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x4400FF9D)),
      ),
      child: const Row(
        children: [
          Icon(Icons.key_rounded, color: Color(0xFF41F2A1)),
          Gap(12),
          Expanded(
            child: Text(
              'Добавьте персональную подписку — после этого подключение работает одной кнопкой.',
              style: TextStyle(color: Colors.white, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlatformBadge extends StatelessWidget {
  const _PlatformBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0x2200FF9D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x5500FF9D)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF8BFFD0),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _FactChip extends StatelessWidget {
  const _FactChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0x2200FF9D),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0x3300FF9D)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF75FBBE)),
          const Gap(6),
          Text(
            text,
            style: const TextStyle(
              color: Color(0xFFC7F9E6),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AimaStatusViewModel {
  const _AimaStatusViewModel({
    required this.title,
    required this.subtitle,
    required this.tunnelLabel,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String tunnelLabel;
  final IconData icon;
  final Color color;

  factory _AimaStatusViewModel.from(
    AsyncValue<ConnectionStatus> connection,
    AimaNetworkSnapshot network,
  ) {
    if (network.supported && !network.hasNetwork) {
      return const _AimaStatusViewModel(
        title: 'Нет сети',
        subtitle: 'VPN подключится после восстановления Wi-Fi или мобильного интернета.',
        tunnelLabel: 'Туннель ожидает сеть',
        icon: Icons.signal_cellular_connected_no_internet_0_bar_rounded,
        color: Color(0xFFFFB85C),
      );
    }

    if (network.captivePortal) {
      return const _AimaStatusViewModel(
        title: 'Требуется вход в Wi-Fi',
        subtitle: 'Откройте страницу авторизации сети. После входа AIMA продолжит подключение.',
        tunnelLabel: 'Туннель приостановлен',
        icon: Icons.wifi_password_rounded,
        color: Color(0xFFFFB85C),
      );
    }

    return switch (connection) {
      AsyncData(value: Connected()) => _AimaStatusViewModel(
          title: network.networkChanged ? 'Соединение восстановлено' : 'Защищено',
          subtitle: network.networkChanged
              ? 'Сеть изменилась. Защищённый маршрут уже перепроверен.'
              : 'VPN-туннель активен. Сервер и маршрут выбраны автоматически.',
          tunnelLabel: 'Туннель активен',
          icon: Icons.verified_user_rounded,
          color: const Color(0xFF41F2A1),
        ),
      AsyncData(value: Connecting()) => const _AimaStatusViewModel(
          title: 'Подключаем',
          subtitle: 'Проверяем сеть, сервер и защищённый маршрут. Ничего делать не нужно.',
          tunnelLabel: 'Установка туннеля',
          icon: Icons.sync_rounded,
          color: Color(0xFF55D7FF),
        ),
      AsyncData(value: Disconnecting()) => const _AimaStatusViewModel(
          title: 'Отключаем',
          subtitle: 'Завершаем защищённое соединение без утечки маршрута.',
          tunnelLabel: 'Остановка туннеля',
          icon: Icons.power_settings_new_rounded,
          color: Color(0xFFB6C4BE),
        ),
      AsyncData(value: Disconnected(connectionFailure: final failure?)) =>
        _AimaStatusViewModel(
          title: 'Не удалось подключиться',
          subtitle: 'Причина: ${failure.toString()}. Выберите повторное подключение.',
          tunnelLabel: 'Туннель не активен',
          icon: Icons.gpp_bad_rounded,
          color: const Color(0xFFFF6B77),
        ),
      AsyncData(value: Disconnected()) => const _AimaStatusViewModel(
          title: 'Готово к подключению',
          subtitle: 'Нажмите большую кнопку. AIMA сама выберет рабочий сервер и маршрут.',
          tunnelLabel: 'Туннель выключен',
          icon: Icons.shield_outlined,
          color: Color(0xFF8BFFD0),
        ),
      AsyncError() => const _AimaStatusViewModel(
          title: 'Ошибка состояния',
          subtitle: 'Состояние VPN не удалось прочитать. Повторите подключение.',
          tunnelLabel: 'Статус не подтверждён',
          icon: Icons.error_outline_rounded,
          color: Color(0xFFFF6B77),
        ),
      _ => const _AimaStatusViewModel(
          title: 'Проверяем систему',
          subtitle: 'Читаем состояние сети и VPN-модуля.',
          tunnelLabel: 'Проверка',
          icon: Icons.radar_rounded,
          color: Color(0xFF55D7FF),
        ),
    };
  }
}

class AppVersionLabel extends HookConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider).requireValue;
    final version = ref.watch(appInfoProvider).requireValue.presentVersion;
    if (version.isBlank) return const SizedBox();

    return Semantics(
      label: t.common.version,
      button: false,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0x2200FF9D),
          borderRadius: BorderRadius.circular(6),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        child: Text(
          version,
          textDirection: TextDirection.ltr,
          style: const TextStyle(color: Color(0xFF8BFFD0), fontSize: 10),
        ),
      ),
    );
  }
}
