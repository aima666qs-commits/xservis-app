import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/xf_theme_pack.dart';

class XfThemeBackground extends StatefulWidget {
  const XfThemeBackground({
    super.key,
    required this.child,
    this.preset,
  });

  final Widget child;
  final XfThemePreset? preset;

  @override
  State<XfThemeBackground> createState() => _XfThemeBackgroundState();
}

class _XfThemeBackgroundState extends State<XfThemeBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 18),
  )..repeat(reverse: true);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    if (reduce) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final preset = widget.preset;
    final tokens = preset?.tokens;
    final bg = tokens?.backgroundColor ?? const Color(0xFF02070B);
    final a = tokens?.accentA ?? const Color(0xFF00DDEB);
    final b = tokens?.accentB ?? const Color(0xFF4C69FF);
    final c = tokens?.accentC ?? const Color(0xFFFF4FC3);
    final effect = preset?.background ?? 'grid-bloom';

    return ColoredBox(
      color: bg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, __) => _BackgroundLayer(
                effect: effect,
                progress: _controller.value,
                background: bg,
                a: a,
                b: b,
                c: c,
              ),
            ),
          ),
          IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    bg.withValues(alpha: .08),
                    bg.withValues(alpha: .78),
                  ],
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}

class _BackgroundLayer extends StatelessWidget {
  const _BackgroundLayer({
    required this.effect,
    required this.progress,
    required this.background,
    required this.a,
    required this.b,
    required this.c,
  });

  final String effect;
  final double progress;
  final Color background;
  final Color a;
  final Color b;
  final Color c;

  @override
  Widget build(BuildContext context) {
    return switch (effect) {
      'particle-field' => CustomPaint(
          painter: _ParticleFieldPainter(progress: progress, a: a, b: b),
        ),
      'constellation' => CustomPaint(
          painter: _ParticleFieldPainter(
            progress: progress,
            a: a,
            b: b,
            drawLinks: true,
            count: 42,
          ),
        ),
      'grid-bloom' => Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0, -.25 + progress * .12),
                  radius: 1.15,
                  colors: [
                    a.withValues(alpha: .22),
                    b.withValues(alpha: .08),
                    background,
                  ],
                ),
              ),
            ),
            CustomPaint(painter: _GridPainter(color: b.withValues(alpha: .09))),
          ],
        ),
      'aurora' => _SoftGradientScene(
          progress: progress,
          background: background,
          colors: [a, b, c],
          mode: _GradientMode.aurora,
        ),
      'liquid' => _SoftGradientScene(
          progress: progress,
          background: background,
          colors: [a, b, c],
          mode: _GradientMode.liquid,
        ),
      'orbs' => _SoftGradientScene(
          progress: progress,
          background: background,
          colors: [a, b, c],
          mode: _GradientMode.orbs,
        ),
      'nebula' => _SoftGradientScene(
          progress: progress,
          background: background,
          colors: [a, b, c],
          mode: _GradientMode.nebula,
        ),
      _ => DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, .6),
              radius: 1.2,
              colors: [a.withValues(alpha: .18), background],
            ),
          ),
        ),
    };
  }
}

enum _GradientMode { aurora, liquid, orbs, nebula }

class _SoftGradientScene extends StatelessWidget {
  const _SoftGradientScene({
    required this.progress,
    required this.background,
    required this.colors,
    required this.mode,
  });

  final double progress;
  final Color background;
  final List<Color> colors;
  final _GradientMode mode;

  @override
  Widget build(BuildContext context) {
    final swing = math.sin(progress * math.pi * 2) * .16;
    final alignments = switch (mode) {
      _GradientMode.aurora => [
          Alignment(-.78 + swing, -.62),
          Alignment(.78 - swing, -.2),
          Alignment(.15, .85 - swing),
        ],
      _GradientMode.liquid => [
          Alignment(-.55 + swing, -.3),
          Alignment(.45, -.15 - swing),
          Alignment(.72 - swing, .72),
        ],
      _GradientMode.orbs => [
          Alignment(-.65 + swing, -.55 + swing),
          Alignment(.72 - swing, -.4),
          Alignment(.15 + swing, .7 - swing),
        ],
      _GradientMode.nebula => [
          Alignment(-.8 + swing, -.7),
          Alignment(.82, .22 - swing),
          Alignment(-.05, .86),
        ],
    };

    return Stack(
      fit: StackFit.expand,
      children: [
        ColoredBox(color: background),
        for (var i = 0; i < colors.length; i++)
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: alignments[i],
                radius: mode == _GradientMode.nebula ? .9 : .7,
                colors: [
                  colors[i].withValues(alpha: mode == _GradientMode.liquid ? .24 : .20),
                  Colors.transparent,
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = .6;
    const spacing = 48.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _GridPainter oldDelegate) => oldDelegate.color != color;
}

class _ParticleFieldPainter extends CustomPainter {
  const _ParticleFieldPainter({
    required this.progress,
    required this.a,
    required this.b,
    this.drawLinks = true,
    this.count = 60,
  });

  final double progress;
  final Color a;
  final Color b;
  final bool drawLinks;
  final int count;

  Offset _point(int index, Size size) {
    final seedX = ((index * 73) % 997) / 997;
    final seedY = ((index * 191) % 991) / 991;
    final phase = index * .73;
    final dx = math.sin(progress * math.pi * 2 + phase) * 10;
    final dy = math.cos(progress * math.pi * 2 * .7 + phase) * 8;
    return Offset(seedX * size.width + dx, seedY * size.height + dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final points = List<Offset>.generate(count, (index) => _point(index, size));
    final dot = Paint()..style = PaintingStyle.fill;
    final line = Paint()
      ..strokeWidth = .55
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length; i++) {
      final color = Color.lerp(a, b, (math.sin(i * .9) + 1) / 2) ?? a;
      dot.color = color.withValues(alpha: .52);
      canvas.drawCircle(points[i], 1 + (i % 3) * .35, dot);

      if (!drawLinks) continue;
      for (var j = i + 1; j < points.length; j++) {
        final distance = (points[i] - points[j]).distance;
        if (distance > 94) continue;
        line.color = color.withValues(alpha: (1 - distance / 94) * .12);
        canvas.drawLine(points[i], points[j], line);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleFieldPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.a != a || oldDelegate.b != b;
}
