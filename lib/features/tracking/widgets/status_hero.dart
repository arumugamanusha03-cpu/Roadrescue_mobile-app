import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';

/// Centred success badge with confetti flecks, a title and a subtitle
/// (Request Submitted, Provider Assigned, Provider Arrived, ...).
class StatusHero extends StatelessWidget {
  const StatusHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.check_rounded,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.6, end: 1),
          duration: AppMotion.emphasized,
          curve: Curves.easeOutBack,
          builder: (context, t, child) =>
              Transform.scale(scale: t, child: child),
          child: SizedBox(
            width: 160,
            height: 120,
            child: CustomPaint(
              painter: const _ConfettiPainter(),
              child: Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.brandGradientStart,
                        AppColors.brandGradientEnd,
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.textPrimary.withValues(alpha: 0.9),
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.brandGradientEnd.withValues(
                          alpha: 0.55,
                        ),
                        blurRadius: 32,
                      ),
                    ],
                  ),
                  child: Icon(icon, size: 52, color: AppColors.onPrimary),
                ),
              ),
            ),
          ),
        ),
        Gap.v16,
        Semantics(
          header: true,
          liveRegion: true,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headingLarge.copyWith(fontSize: 26),
          ),
        ),
        Gap.v12,
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: AppTypography.body.copyWith(
            fontSize: 15,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  const _ConfettiPainter();

  // (angle in degrees, distance factor, colour, is square)
  static const _flecks = [
    (200.0, 0.92, Color(0xFFF2B84B), true),
    (235.0, 0.78, Color(0xFF00C2FF), false),
    (300.0, 0.86, Color(0xFFF2B84B), false),
    (330.0, 0.95, Color(0xFFFF7AB6), true),
    (20.0, 0.9, Color(0xFF6F8FFF), true),
    (160.0, 0.88, Color(0xFFFF7AB6), false),
    (130.0, 0.8, Color(0xFF00C2FF), true),
    (55.0, 0.82, Color(0xFFF2B84B), false),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.height / 2 + 6;
    for (final (deg, f, color, square) in _flecks) {
      final a = deg * math.pi / 180;
      final p = c + Offset(math.cos(a) * r * f * 1.25, math.sin(a) * r * f);
      final paint = Paint()..color = color;
      if (square) {
        canvas
          ..save()
          ..translate(p.dx, p.dy)
          ..rotate(a)
          ..drawRect(const Rect.fromLTWH(-3, -3, 6, 6), paint)
          ..restore();
      } else {
        canvas.drawCircle(p, 3, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
