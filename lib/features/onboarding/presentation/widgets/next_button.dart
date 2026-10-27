import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

final _gradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [AppColorsDark.brandGradientStart, AppColorsDark.brandGradientEnd],
);

List<BoxShadow> get _glow => [
  BoxShadow(
    color: AppColorsDark.brandGradientEnd.withValues(alpha: 0.5),
    blurRadius: 28,
    offset: const Offset(0, 8),
  ),
];

/// Round gradient arrow button for pages 1–3.
class OnboardingNextButton extends StatelessWidget {
  const OnboardingNextButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  static const double size = 72;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Next page',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: _gradient,
          boxShadow: _glow,
        ),
        child: Material(
          type: MaterialType.transparency,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: SizedBox.square(
              dimension: size,
              child: Icon(
                Icons.arrow_forward,
                size: AppSizes.iconXl,
                color: AppColorsDark.onPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Full-width "Get Started →" button on the final page.
class OnboardingGetStartedButton extends StatelessWidget {
  const OnboardingGetStartedButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Get Started',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          gradient: _gradient,
          boxShadow: _glow,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.lgAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.buttonLarge,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Get Started',
                    style: AppTypographyDark.button.copyWith(
                      fontSize: 17,
                      color: AppColorsDark.onPrimary,
                    ),
                  ),
                  Gap.h12,
                  Icon(
                    Icons.arrow_forward,
                    size: AppSizes.iconLg,
                    color: AppColorsDark.onPrimary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
