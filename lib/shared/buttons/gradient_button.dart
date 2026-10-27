import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Light cyan → blue CTA with a dark label. Used by auth and the request flow.
class GradientButton extends StatelessWidget {
  const GradientButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.showArrow = false,
    this.isLoading = false,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final bool showArrow;
  final bool isLoading;

  /// Optional leading icon (e.g. navigation arrow on "Live Tracking").
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isLoading ? '$label, loading' : label,
      excludeSemantics: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          gradient: LinearGradient(
            colors: [AppColors.authGradientStart, AppColors.authGradientEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.authGradientEnd.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: isLoading ? null : onPressed,
            borderRadius: AppRadius.lgAll,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 60),
              child: Center(
                child: isLoading
                    ? SizedBox.square(
                        dimension: AppSizes.iconLg,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.onAuthGradient,
                        ),
                      )
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (icon != null) ...[
                            Icon(icon, color: AppColors.onAuthGradient),
                            Gap.h12,
                          ],
                          Flexible(
                            child: Text(
                              label,
                              textAlign: TextAlign.center,
                              style: AppTypography.button.copyWith(
                                fontSize: 18,
                                color: AppColors.onAuthGradient,
                              ),
                            ),
                          ),
                          if (showArrow) ...[
                            Gap.h12,
                            Icon(
                              Icons.arrow_forward,
                              color: AppColors.onAuthGradient,
                            ),
                          ],
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
