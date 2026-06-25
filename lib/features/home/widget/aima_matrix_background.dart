import 'dart:math' as math;

import 'package:flutter/material.dart';

class AimaMatrixBackground extends StatefulWidget {
  const AimaMatrixBackground({super.key, required this.child});

  final Widget child;

  @override
  State<AimaMatrixBackground> createState() => _AimaMatrixBackgroundState();
}

class _AimaMatrixBackgroundState extends State<AimaMatrixBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF020706),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.42),
                radius: 1.08,
                colors: [
                  Color(0x4D00FF9D),
                  Color(0x22008C67),
                  Color(0xFF020706),
                ],
                stops: [0, .42, 1],
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => CustomPaint(
              painter: _MatrixPainter(progress: _controller.value),
            ),
          ),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x00000000),
                    Color(0x1100FF9D),
                    Color(0xAA020706),
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

class _MatrixPainter extends CustomPainter {
  const _MatrixPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(777);
    const columnWidth = 24.0;
    final columns = (size.width / columnWidth).ceil();
    final glyphPaint = Paint()..style = PaintingStyle.fill;

    for (var column = 0; column < columns; column++) {
      final x = column * columnWidth + random.nextDouble() * 8;
      final speed = .35 + random.nextDouble() * 1.25;
      final streamLength = 4 + random.nextInt(10);
      final offset = ((progress * speed + random.nextDouble()) % 1) *
          (size.height + streamLength * 26);

      for (var row = 0; row < streamLength; row++) {
        final y = offset - row * 26 - streamLength * 26;
        if (y < -30 || y > size.height + 30) continue;

        final alpha = ((streamLength - row) / streamLength * 62).round();
        glyphPaint.color = Color.fromARGB(alpha, 0, 255, 157);
        final glyph = switch (random.nextInt(7)) {
          0 => '0',
          1 => '1',
          2 => '⌁',
          3 => '◈',
          4 => '•',
          5 => '×',
          _ => '│',
        };
        final textPainter = TextPainter(
          text: TextSpan(
            text: glyph,
            style: TextStyle(
              color: glyphPaint.color,
              fontSize: 12 + random.nextDouble() * 4,
              fontWeight: FontWeight.w600,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        textPainter.paint(canvas, Offset(x, y));
      }
    }

    final gridPaint = Paint()
      ..color = const Color(0x1200FF9D)
      ..strokeWidth = .5;
    for (double x = 0; x < size.width; x += 48) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 48) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MatrixPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
