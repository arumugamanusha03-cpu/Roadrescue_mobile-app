import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Pulsing radar over a faint street grid, the customer's pin in the middle
/// and nearby providers around it.
class RadarVisual extends StatefulWidget {
  const RadarVisual({super.key});

  @override
  State<RadarVisual> createState() => _RadarVisualState();
}

class _RadarVisualState extends State<RadarVisual>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: SizedBox(
        height: 240,
        child: LayoutBuilder(
          builder: (context, c) {
            final w = c.maxWidth;
            Widget providerPin(double dx, double dy) => Positioned(
              left: w / 2 + dx - 18,
              top: 120 + dy - 40,
              child: const _ProviderPin(),
            );
            return Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _pulse,
                    builder: (context, _) => CustomPaint(
                      painter: _RadarPainter(reduceMotion ? 0.5 : _pulse.value),
                    ),
                  ),
                ),
                providerPin(-90, -40),
                providerPin(55, -75),
                providerPin(60, 50),
                Center(
                  child: Icon(
                    Icons.location_on,
                    size: 72,
                    color: AppColors.brandCyan,
                    shadows: [
                      const Shadow(color: Color(0xAA00C2FF), blurRadius: 24),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Icon(
                      Icons.directions_car_filled,
                      size: 26,
                      color: AppColors.background,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ProviderPin extends StatelessWidget {
  const _ProviderPin();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        const Icon(Icons.location_on, size: 40, color: Color(0xFF6F8FFF)),
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: AppColors.textPrimary,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.local_shipping, size: 13, color: AppColors.warning),
        ),
      ],
    );
  }
}

class _RadarPainter extends CustomPainter {
  _RadarPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final grid = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.12)
      ..strokeWidth = 1;
    // Faint "streets".
    final rnd = math.Random(7);
    for (var i = 0; i < 14; i++) {
      final a = Offset(rnd.nextDouble() * size.width, 0);
      final b = Offset(rnd.nextDouble() * size.width, size.height);
      canvas.drawLine(a, b, grid);
    }
    for (var i = 0; i < 6; i++) {
      final y = rnd.nextDouble() * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y + 30), grid);
    }

    final maxR = size.shortestSide * 0.62;
    for (final f in [0.35, 0.65, 1.0]) {
      canvas.drawCircle(
        c,
        maxR * f,
        Paint()
          ..style = PaintingStyle.stroke
          ..color = AppColors.brandCyan.withValues(alpha: 0.18),
      );
    }
    // Expanding pulse.
    canvas.drawCircle(
      c,
      maxR * t,
      Paint()..color = AppColors.brandCyan.withValues(alpha: 0.16 * (1 - t)),
    );
    canvas.drawCircle(
      c,
      30,
      Paint()..color = AppColors.brandCyan.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(_RadarPainter old) => old.t != t;
}
