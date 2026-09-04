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
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            const Text(
              'Xservis',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const Gap(8),
            const AppVersionLabel(),
          ],
        ),
        actions: [
          _PlatformBadge(label: _platformLabel()),
          const Gap(8),
          Semantics(
            key: const ValueKey('profile_add_button'),
            label: t.pages.profiles.add,
            child: IconButton(
              tooltip: 'Добавить подписку',
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
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
                    sliver: SliverList.list(
                      children: [
                        _AimaHeroStatus(status: status, network: network),
                        const Gap(14),
                        _SubscriptionCard(activeProfile: activeProfile),
                        const Gap(24),
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
                        _AccountActions(activeProfile: activeProfile),
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
              label: const Text('Настройки'),
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
                text: _networkLabel(network),
              ),
              _FactChip(
                icon: Icons.auto_awesome_rounded,
                text: status.accessLabel,
              ),
              const _FactChip(
                icon: Icons.tune_rounded,
                text: 'Автонастройка',
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _networkLabel(AimaNetworkSnapshot network) {
    if (!network.supported) return 'Сеть';
    return switch (network.transport) {
      'wifi' => 'Wi-Fi',
      'cellular' when network.radioGeneration != 'unknown' => network.radioGeneration,
      'cellular' => 'Мобильная сеть',
      'ethernet' => 'Ethernet',
      'none' => 'Нет сети',
      _ => 'Сеть',
    };
  }
}

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.activeProfile});

  final AsyncValue<ProfileEntity?> activeProfile;

  @override
  Widget build(BuildContext context) {
    return switch (activeProfile) {
      AsyncData(value: final profile?) => _buildProfileCard(context, profile),
      AsyncError() => _buildEmptyCard(
          context,
          title: 'Подписка недоступна',
          subtitle: 'Обновите данные или добавьте подписку ещё раз.',
          tone: const Color(0xFFFF6B77),
        ),
      _ => _buildEmptyCard(
          context,
          title: 'Персональная подписка',
          subtitle: 'Добавьте её один раз — дальше всё обновляется автоматически.',
          tone: const Color(0xFF41F2A1),
        ),
    };
  }

  Widget _buildProfileCard(BuildContext context, ProfileEntity profile) {
    final info = switch (profile) {
      RemoteProfileEntity(:final subInfo) => subInfo,
      _ => null,
    };
    final expired = info?.isExpired ?? false;
    final tone = expired ? const Color(0xFFFF6B77) : const Color(0xFF41F2A1);
    final remaining = info == null
        ? 'Активна'
        : expired
            ? 'Срок закончился'
            : _remainingLabel(info.remaining);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xD90A1512),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tone.withValues(alpha: .42)),
      ),
      child: Row(
        children: [
          Icon(Icons.workspace_premium_rounded, color: tone, size: 28),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name.isEmpty ? 'Персональная подписка' : profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const Gap(4),
                Text(
                  remaining,
                  style: TextStyle(
                    color: tone,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color tone,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xB30B1714),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: tone.withValues(alpha: .35)),
      ),
      child: Row(
        children: [
          Icon(Icons.key_rounded, color: tone),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Gap(3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Color(0xFF9EC2B4), height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _remainingLabel(Duration value) {
    if (value.inDays >= 1) return 'Осталось ${value.inDays} дн.';
    if (value.inHours >= 1) return 'Осталось ${value.inHours} ч';
    final minutes = value.inMinutes.clamp(0, 59);
    return 'Осталось $minutes мин';
  }
}

class _AccountActions extends StatelessWidget {
  const _AccountActions({required this.activeProfile});

  final AsyncValue<ProfileEntity?> activeProfile;

  @override
  Widget build(BuildContext context) {
    final profile = activeProfile.valueOrNull;
    final info = switch (profile) {
      RemoteProfileEntity(:final subInfo) => subInfo,
      _ => null,
    };
    final accountUrl = info?.webPageUrl;
    final supportUrl = info?.supportUrl;
    final shareUrl = accountUrl ?? 'https://xservis.app';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xB30B1714),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x3300FF9D)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.payments_outlined,
                  label: 'Тарифы и оплата',
                  onTap: accountUrl == null ? null : () => _open(accountUrl),
                ),
              ),
              const Gap(8),
              Expanded(
                child: _ActionButton(
                  icon: Icons.ios_share_rounded,
                  label: 'Пригласить',
                  onTap: () => Share.share('Xservis — $shareUrl'),
                ),
              ),
            ],
          ),
          if (supportUrl != null) ...[
            const Gap(8),
            SizedBox(
              width: double.infinity,
              child: _ActionButton(
                icon: Icons.support_agent_rounded,
                label: 'Поддержка',
                onTap: () => _open(supportUrl),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Future<void> _open(String raw) async {
    final uri = Uri.tryParse(raw);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonalIcon(
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, 48),
        backgroundColor: const Color(0xE611211C),
        foregroundColor: const Color(0xFFB8F8DA),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
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
        'Проверка сети недоступна на этой платформе',
        style: TextStyle(color: Color(0xFF76998C), fontSize: 12),
      );
    }

    final message = switch ((network.hasNetwork, network.validated, network.captivePortal)) {
      (false, _, _) => 'Сигнал или интернет отсутствует',
      (true, _, true) => 'Требуется вход в Wi-Fi',
      (true, false, false) => 'Сеть есть, интернет ещё не подтверждён',
      _ when network.networkChanged => 'Сеть изменилась — соединение обновляется',
      _ => 'Интернет доступен',
    };

    return Text(
      message,
      textAlign: TextAlign.center,
      style: const TextStyle(color: Color(0xFF9EC2B4), fontSize: 12),
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
    required this.accessLabel,
    required this.icon,
    required this.color,
  });

  final String title;
  final String subtitle;
  final String accessLabel;
  final IconData icon;
  final Color color;

  factory _AimaStatusViewModel.from(
    AsyncValue<ConnectionStatus> connection,
    AimaNetworkSnapshot network,
  ) {
    if (network.supported && !network.hasNetwork) {
      return const _AimaStatusViewModel(
        title: 'Нет сети',
        subtitle: 'Подключение продолжится после восстановления Wi-Fi или мобильного интернета.',
        accessLabel: 'Ожидаем сеть',
        icon: Icons.signal_cellular_connected_no_internet_0_bar_rounded,
        color: Color(0xFFFFB85C),
      );
    }

    if (network.captivePortal) {
      return const _AimaStatusViewModel(
        title: 'Требуется вход в Wi-Fi',
        subtitle: 'Откройте страницу авторизации сети. После входа Xservis продолжит автоматически.',
        accessLabel: 'Ожидаем вход',
        icon: Icons.wifi_password_rounded,
        color: Color(0xFFFFB85C),
      );
    }

    return switch (connection) {
      AsyncData(value: Connected()) => _AimaStatusViewModel(
          title: network.networkChanged ? 'Соединение восстановлено' : 'Всё готово',
          subtitle: network.networkChanged
              ? 'Сеть изменилась. Xservis уже перепроверил соединение.'
              : 'Подключение активно. Лучший доступ выбирается автоматически.',
          accessLabel: 'Активно',
          icon: Icons.verified_user_rounded,
          color: const Color(0xFF41F2A1),
        ),
      AsyncData(value: Connecting()) => const _AimaStatusViewModel(
          title: 'Подключаем',
          subtitle: 'Проверяем доступность и выбираем лучший вариант. Ничего делать не нужно.',
          accessLabel: 'Настройка',
          icon: Icons.sync_rounded,
          color: Color(0xFF55D7FF),
        ),
      AsyncData(value: Disconnecting()) => const _AimaStatusViewModel(
          title: 'Отключаем',
          subtitle: 'Завершаем соединение.',
          accessLabel: 'Отключение',
          icon: Icons.power_settings_new_rounded,
          color: Color(0xFFB6C4BE),
        ),
      AsyncData(value: Disconnected(connectionFailure: final failure?)) =>
        _AimaStatusViewModel(
          title: 'Не удалось подключиться',
          subtitle: 'Повторите подключение. Код: ${failure.toString()}.',
          accessLabel: 'Нужен повтор',
          icon: Icons.gpp_bad_rounded,
          color: const Color(0xFFFF6B77),
        ),
      AsyncData(value: Disconnected()) => const _AimaStatusViewModel(
          title: 'Готово к подключению',
          subtitle: 'Нажмите большую кнопку. Xservis всё настроит автоматически.',
          accessLabel: 'Готово',
          icon: Icons.shield_outlined,
          color: Color(0xFF8BFFD0),
        ),
      AsyncError() => const _AimaStatusViewModel(
          title: 'Ошибка состояния',
          subtitle: 'Не удалось прочитать состояние. Повторите подключение.',
          accessLabel: 'Не подтверждено',
          icon: Icons.error_outline_rounded,
          color: Color(0xFFFF6B77),
        ),
      _ => const _AimaStatusViewModel(
          title: 'Проверяем систему',
          subtitle: 'Подготавливаем соединение.',
          accessLabel: 'Проверка',
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
    if (version.trim().isEmpty) return const SizedBox();

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
