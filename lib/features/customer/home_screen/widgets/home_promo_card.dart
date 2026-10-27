import 'package:flutter/material.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/theme.dart';

/// Feature card in the promo slot of the design: text + small outlined
/// button on the left, photo fading in from the right.
class HomePromoCard extends StatelessWidget {
  const HomePromoCard({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(
          color: AppColors.textPrimary.withValues(alpha: 0.08),
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: FractionallySizedBox(
              widthFactor: 0.55,
              heightFactor: 1,
              alignment: Alignment.centerRight,
              child: ShaderMask(
                blendMode: BlendMode.dstIn,
                shaderCallback: (rect) => const LinearGradient(
                  colors: [Colors.transparent, Colors.black],
                  stops: [0, 0.45],
                ).createShader(rect),
                child: Image.asset(
                  AppAssets.homePromo,
                  fit: BoxFit.cover,
                  alignment: const Alignment(0.6, 0.55),
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.s20),
            child: FractionallySizedBox(
              widthFactor: 0.6,
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Add your vehicle',
                    style: AppTypography.cardTitle.copyWith(fontSize: 18),
                  ),
                  Gap.v8,
                  Text(
                    'Save your car details for faster help next time.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Gap.v16,
                  OutlinedButton(
                    onPressed: onPressed,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      backgroundColor: AppColors.background.withValues(
                        alpha: 0.4,
                      ),
                      side: BorderSide(
                        color: AppColors.textPrimary.withValues(alpha: 0.2),
                      ),
                      shape: const RoundedRectangleBorder(
                        borderRadius: AppRadius.mdAll,
                      ),
                      textStyle: AppTypography.buttonSmall,
                      minimumSize: const Size(0, AppSizes.buttonSmall),
                    ),
                    child: const Text('Add Vehicle'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
