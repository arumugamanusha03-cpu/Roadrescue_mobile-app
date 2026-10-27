import 'package:flutter/material.dart';

import '../../../../core/constants/service_type.dart';
import '../../../../core/theme/theme.dart';

/// Large icon over a label, as in the service grid design. The selected
/// tile gets a cyan border and tint.
class ServiceTypeTile extends StatelessWidget {
  const ServiceTypeTile({
    super.key,
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final ServiceType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: type.label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        decoration: BoxDecoration(
          color: selected
              ? Color.alphaBlend(
                  AppColors.brandCyan.withValues(alpha: 0.12),
                  AppColors.surface,
                )
              : AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: selected
                ? AppColors.brandCyan
                : AppColors.textPrimary.withValues(alpha: 0.08),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.lgAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.s8,
                vertical: AppSpacing.s24,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    AppIcons.service(type, selected: true),
                    size: 40,
                    color: AppColors.brandCyan,
                  ),
                  Gap.v16,
                  Text(
                    type.label,
                    style: AppTypography.bodyStrong,
                    textAlign: TextAlign.center,
                    maxLines: 2,
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
