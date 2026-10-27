import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

enum SocialProvider { google, apple, facebook }

/// "— Or sign in with —" divider followed by Google / Apple / Facebook.
class SocialAuthSection extends StatelessWidget {
  const SocialAuthSection({
    super.key,
    required this.dividerLabel,
    required this.onSelected,
  });

  final String dividerLabel;
  final ValueChanged<SocialProvider> onSelected;

  @override
  Widget build(BuildContext context) {
    final line = Container(
      width: AppSpacing.s48,
      height: 1,
      color: AppColorsDark.textMuted.withValues(alpha: 0.6),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            line,
            Gap.h16,
            Flexible(
              child: Text(
                dividerLabel,
                style: AppTypographyDark.bodyLarge.copyWith(
                  color: AppColorsDark.textSecondary,
                ),
              ),
            ),
            Gap.h16,
            line,
          ],
        ),
        Gap.v24,
        Row(
          children: [
            for (final (i, p) in SocialProvider.values.indexed) ...[
              if (i > 0) Gap.h12,
              Expanded(
                child: _SocialButton(
                  provider: p,
                  onPressed: () => onSelected(p),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.provider, required this.onPressed});

  final SocialProvider provider;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final (label, Widget icon) = switch (provider) {
      SocialProvider.google => (
        'Continue with Google',
        const SizedBox.square(
          dimension: 30,
          child: CustomPaint(painter: _GoogleLogoPainter()),
        ),
      ),
      SocialProvider.apple => (
        'Continue with Apple',
        const Icon(Icons.apple, size: 36, color: Colors.white),
      ),
      SocialProvider.facebook => (
        'Continue with Facebook',
        const Icon(Icons.facebook, size: 34, color: Color(0xFF1877F2)),
      ),
    };

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: AppColorsDark.surface.withValues(alpha: 0.55),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(
            color: AppColorsDark.textPrimary.withValues(alpha: 0.12),
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: AppRadius.lgAll,
          child: SizedBox(height: 60, child: Center(child: icon)),
        ),
      ),
    );
  }
}

/// The four-colour Google "G", drawn so no extra package or asset is needed.
class _GoogleLogoPainter extends CustomPainter {
  const _GoogleLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = s * 0.2;
    final rect = Rect.fromCircle(
      center: Offset(s / 2, s / 2),
      radius: (s - stroke) / 2,
    );
    Paint arc(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    double deg(double d) => d * math.pi / 180;
    canvas
      ..drawArc(rect, deg(-40), deg(-95), false, arc(const Color(0xFFEA4335)))
      ..drawArc(rect, deg(-135), deg(-90), false, arc(const Color(0xFFFBBC05)))
      ..drawArc(rect, deg(135), deg(-90), false, arc(const Color(0xFF34A853)))
      ..drawArc(rect, deg(45), deg(-45), false, arc(const Color(0xFF4285F4)))
      ..drawRect(
        Rect.fromLTWH(s / 2, s / 2 - stroke / 2, s / 2 - stroke / 4, stroke),
        Paint()..color = const Color(0xFF4285F4),
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
