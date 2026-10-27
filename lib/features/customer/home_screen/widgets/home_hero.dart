import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';

/// Greeting, headline, supporting line and the "Get Help Now" CTA. The hero
/// photo is painted behind this by the screen.
class HomeHero extends StatelessWidget {
  const HomeHero({super.key, required this.greeting, required this.onGetHelp});

  final String greeting;
  final VoidCallback onGetHelp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting 👋',
          style: AppTypographyDark.bodyLarge.copyWith(
            fontSize: 18,
            color: AppColorsDark.textSecondary,
          ),
        ),
        Gap.v8,
        Semantics(
          header: true,
          child: Text(
            'Need help\non the road?',
            style: AppTypographyDark.headingLarge.copyWith(
              fontSize: 32,
              height: 1.15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Gap.v8,
        Text(
          'Find nearby verified service providers.',
          style: AppTypographyDark.body.copyWith(
            color: AppColorsDark.textSecondary,
          ),
        ),
        Gap.v24,
        FractionallySizedBox(
          widthFactor: 0.82,
          child: _GetHelpButton(onPressed: onGetHelp),
        ),
      ],
    );
  }
}

class _GetHelpButton extends StatelessWidget {
  const _GetHelpButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Get Help Now',
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdAll,
          gradient: LinearGradient(
            colors: [
              AppColorsDark.brandGradientStart,
              AppColorsDark.brandGradientEnd,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColorsDark.brandGradientEnd.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.mdAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: AppSizes.buttonLarge,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s16),
                child: Row(
                  children: [
                    Icon(
                      Icons.support_agent_outlined,
                      size: AppSizes.iconLg,
                      color: AppColorsDark.onPrimary,
                    ),
                    Gap.h12,
                    Expanded(
                      child: Text(
                        'Get Help Now',
                        style: AppTypographyDark.button.copyWith(
                          color: AppColorsDark.onPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      AppIcons.chevronRight,
                      size: AppSizes.iconLg,
                      color: AppColorsDark.onPrimary,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
