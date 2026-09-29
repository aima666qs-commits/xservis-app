import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/theme/xf_theme_pack.dart';
import 'package:hiddify/core/theme/xf_theme_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class XfThemeGalleryPage extends HookConsumerWidget {
  const XfThemeGalleryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pack = ref.watch(xfThemePackProvider);
    final selectedId = ref.watch(xfThemePresetIdProvider);
    final query = useState('');
    final family = useState('all');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Темы и анимации'),
        actions: [
          TextButton.icon(
            onPressed: () => ref.read(xfThemePresetIdProvider.notifier).reset(),
            icon: const Icon(Icons.restart_alt_rounded),
            label: const Text('Сбросить'),
          ),
          const Gap(8),
        ],
      ),
      body: pack.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Не удалось загрузить XFreedom Theme Pack: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (presets) {
          final families = <String, String>{};
          for (final preset in presets) {
            families[preset.family] = preset.familyName;
          }
          final needle = query.value.trim().toLowerCase();
          final filtered = presets.where((preset) {
            final familyOk = family.value == 'all' || preset.family == family.value;
            final text = '${preset.name} ${preset.familyName} ${preset.background} ${preset.transition} ${preset.interaction}'
                .toLowerCase();
            return familyOk && (needle.isEmpty || text.contains(needle));
          }).toList(growable: false);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                sliver: SliverToBoxAdapter(
                  child: _IntroCard(count: presets.length),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                sliver: SliverToBoxAdapter(
                  child: TextField(
                    onChanged: (value) => query.value = value,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search_rounded),
                      hintText: 'Поиск: Particle, glass, scroll, neon...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                sliver: SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'Все',
                          selected: family.value == 'all',
                          onTap: () => family.value = 'all',
                        ),
                        for (final entry in families.entries) ...[
                          const Gap(8),
                          _FilterChip(
                            label: entry.value,
                            selected: family.value == entry.key,
                            onTap: () => family.value = entry.key,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverLayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.crossAxisExtent;
                    final columns = width >= 1100
                        ? 4
                        : width >= 760
                            ? 3
                            : width >= 480
                                ? 2
                                : 1;
                    return SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final preset = filtered[index];
                          return _ThemeCard(
                            preset: preset,
                            selected: preset.id == selectedId,
                            onSelect: () => ref
                                .read(xfThemePresetIdProvider.notifier)
                                .selectPreset(preset.id),
                          );
                        },
                        childCount: filtered.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: columns == 1 ? 1.9 : 1.25,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.auto_awesome_rounded, size: 30),
            const Gap(14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$count премиальных тем XFreedom',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                  ),
                  const Gap(6),
                  const Text(
                    'Один переносимый Theme Pack для Android, iOS и desktop. '
                    'Выбор сохраняется локально и не изменяет VPN-конфигурацию, серверы или маршруты.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.preset,
    required this.selected,
    required this.onSelect,
  });

  final XfThemePreset preset;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    final t = preset.tokens;
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: selected ? t.accentA : Theme.of(context).dividerColor,
          width: selected ? 1.5 : .7,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onSelect,
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(13),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        t.backgroundColor,
                        t.accentA.withValues(alpha: .52),
                        t.accentB.withValues(alpha: .32),
                      ],
                    ),
                    border: Border.all(color: t.accentA.withValues(alpha: .35)),
                  ),
                  child: Center(
                    child: Icon(
                      selected ? Icons.check_circle_rounded : Icons.blur_on_rounded,
                      color: selected ? t.successColor : t.textColor,
                      size: 34,
                    ),
                  ),
                ),
              ),
              const Gap(10),
              Text(
                preset.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              const Gap(3),
              Text(
                '${preset.background} · ${preset.transition}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
