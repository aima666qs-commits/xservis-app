import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/xf_theme_background.dart';
import 'package:hiddify/core/theme/xf_theme_preferences.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Backward-compatible entry point for the existing HomePage.
///
/// Presentation is now driven by the portable XFreedom Theme Pack.
/// This widget never changes tunnel state, routes, server configuration, or credentials.
class AimaMatrixBackground extends ConsumerWidget {
  const AimaMatrixBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preset = ref.watch(activeXfThemePresetProvider);
    return XfThemeBackground(
      preset: preset,
      child: child,
    );
  }
}
