import 'package:flutter/material.dart';

/// Kept under the existing class name for backward compatibility.
/// The old animated green "matrix" effect was replaced with a restrained,
/// resolution-independent XFreedom cyan grid so the same surface remains crisp
/// on phones, tablets, desktop and high-density/4K-class displays.
class AimaMatrixBackground extends StatelessWidget {
  const AimaMatrixBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xFF02070B),
      child: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, -0.5),
                radius: 1.15,
                colors: [
                  Color(0x2600DDEB),
                  Color(0x1200AFC4),
                  Color(0xFF02070B),
                ],
                stops: [0, .42, 1],
              ),
            ),
          ),
          const CustomPaint(painter: _XFreedomGridPainter()),
          const IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0x0002070B),
                    Color(0x0800DDEB),
                    Color(0xD902070B),
                  ],
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _XFreedomGridPainter extends CustomPainter {
  const _XFreedomGridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0x1000DDEB)
      ..strokeWidth = .5;

    const spacing = 48.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _XFreedomGridPainter oldDelegate) => false;
}
