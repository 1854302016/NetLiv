import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// The iconic Netflix curved arc divider.
/// Features a subtle upward curve with a radiant crimson-magenta neon stroke
/// and a dark radial ambient glow underneath, matching the official Netflix landing page.
class CurvedArcDivider extends StatelessWidget {
  final double height;

  const CurvedArcDivider({
    super.key,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _CurvedArcPainter(),
      ),
    );
  }
}

class _CurvedArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Define curve path (upward arc from left to right)
    final path = Path();
    path.moveTo(0, h);
    path.quadraticBezierTo(w * 0.5, 4, w, h);

    // 1. Draw subtle ambient crimson glow under the arc
    final glowPaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, -0.8),
        radius: 1.2,
        colors: [
          AppColors.netflixRed.withOpacity(0.35),
          AppColors.netflixRedDark.withOpacity(0.12),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h * 2))
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path)
      ..lineTo(w, h * 2)
      ..lineTo(0, h * 2)
      ..close();
    canvas.drawPath(fillPath, glowPaint);

    // 2. Draw glowing neon stroke along the arc edge
    final strokePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Color(0xFFE50914),
          Color(0xFFFF3366),
          Color(0xFFE50914),
          Colors.transparent,
        ],
        stops: [0.0, 0.25, 0.5, 0.75, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, strokePaint);

    // 3. Crisp inner neon highlight
    final innerStroke = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Colors.transparent,
          Color(0xFFFF88A3),
          Color(0xFFFF88A3),
          Colors.transparent,
        ],
        stops: [0.15, 0.45, 0.55, 0.85],
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawPath(path, innerStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
