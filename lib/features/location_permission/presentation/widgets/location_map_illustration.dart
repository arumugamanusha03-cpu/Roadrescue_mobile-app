import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Decorative map, drawn locally without a map SDK or external imagery.
class LocationMapIllustration extends StatelessWidget {
  const LocationMapIllustration({super.key});

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: CustomPaint(painter: _LocationMapPainter(), size: Size.infinite),
  );
}

class _LocationMapPainter extends CustomPainter {
  const _LocationMapPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // A fixed drawing coordinate system keeps the pin and perspective map
    // balanced when the available width or screen height changes.
    final scale = (size.width / 360).clamp(0.0, size.height / 300);
    canvas
      ..translate(
        (size.width - 360 * scale) / 2,
        (size.height - 300 * scale) / 2,
      )
      ..scale(scale);

    const glowBounds = Rect.fromLTWH(50, 5, 260, 260);
    canvas.drawOval(
      glowBounds,
      Paint()
        ..shader = RadialGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.24),
            AppColors.primary.withValues(alpha: 0),
          ],
        ).createShader(glowBounds),
    );

    final map = Path()
      ..moveTo(22, 184)
      ..quadraticBezierTo(8, 169, 27, 157)
      ..lineTo(171, 104)
      ..quadraticBezierTo(184, 99, 200, 109)
      ..lineTo(338, 199)
      ..quadraticBezierTo(355, 212, 333, 226)
      ..lineTo(199, 286)
      ..quadraticBezierTo(182, 293, 164, 282)
      ..close();
    const mapBounds = Rect.fromLTWH(10, 100, 340, 195);
    canvas.drawPath(
      map,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.surface, AppColors.backgroundSecondary],
        ).createShader(mapBounds),
    );
    canvas.save();
    canvas.clipPath(map);

    // Two intersecting families of streets form the perspective grid.
    final street = Paint()
      ..color = AppColors.primarySecondary.withValues(alpha: 0.20)
      ..strokeWidth = 2;
    for (var i = -4; i < 10; i++) {
      canvas.drawLine(
        Offset(i * 42.0, 96),
        Offset(i * 42.0 + 238, 302),
        street,
      );
      canvas.drawLine(
        Offset(-35, i * 24.0 + 130),
        Offset(380, i * 24.0 - 28),
        street,
      );
    }
    final route = Path()
      ..moveTo(42, 230)
      ..lineTo(86, 206)
      ..quadraticBezierTo(97, 202, 112, 210)
      ..lineTo(187, 257)
      ..lineTo(252, 220)
      ..quadraticBezierTo(266, 213, 281, 221)
      ..lineTo(321, 246);
    canvas.drawPath(
      route,
      Paint()
        ..shader = LinearGradient(
          colors: [
            AppColors.iceBlue,
            AppColors.authGradientEnd,
            AppColors.brandCyan,
          ],
        ).createShader(mapBounds)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
    canvas.drawPath(
      map,
      Paint()
        ..color = AppColors.primarySecondary.withValues(alpha: 0.30)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    const focus = Offset(183, 199);
    for (final radius in [65.0, 44.0, 24.0]) {
      canvas.drawOval(
        Rect.fromCenter(
          center: focus,
          width: radius * 2,
          height: radius * 0.64,
        ),
        Paint()
          ..color = AppColors.brandCyan.withValues(alpha: 0.65)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );
    }
    canvas.drawOval(
      Rect.fromCenter(center: focus, width: 27, height: 9),
      Paint()
        ..color = AppColors.brandCyan
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawOval(
      Rect.fromCenter(center: focus, width: 13, height: 4),
      Paint()..color = AppColors.textPrimary,
    );

    for (final point in [
      const Offset(84, 164),
      const Offset(112, 210),
      const Offset(187, 257),
      const Offset(287, 189),
      const Offset(276, 263),
    ]) {
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = AppColors.brandCyan.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      canvas.drawCircle(point, 2.5, Paint()..color = AppColors.brandCyan);
    }

    final pin = Path()
      ..moveTo(183, 187)
      ..cubicTo(176, 178, 134, 120, 134, 85)
      ..cubicTo(134, 18, 232, 18, 232, 85)
      ..cubicTo(232, 120, 190, 178, 183, 187)
      ..close();
    const pinBounds = Rect.fromLTWH(134, 34, 98, 153);
    canvas.drawShadow(pin, AppColors.primary, 18, false);
    canvas.drawPath(
      pin,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.authGradientStart,
            AppColors.authGradientEnd,
            AppColors.primary,
          ],
        ).createShader(pinBounds),
    );
    canvas.drawPath(
      pin,
      Paint()
        ..color = AppColors.iceBlue
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );
    canvas.drawCircle(
      const Offset(183, 84),
      20,
      Paint()..color = AppColors.textPrimary,
    );
  }

  @override
  bool shouldRepaint(_LocationMapPainter oldDelegate) => false;
}
