import 'package:flutter/material.dart';

import '../../../../core/constants/vehicle_type.dart';
import '../../../../core/theme/theme.dart';

/// Car / Bike / EV segmented choice. The selected segment is filled with
/// the cyan gradient.
class VehicleTypeSelector extends StatelessWidget {
  const VehicleTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
    this.types = VehicleType.values,
  });

  final List<VehicleType> types;
  final VehicleType selected;
  final ValueChanged<VehicleType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, type) in types.indexed) ...[
          if (i > 0) types.length > 3 ? Gap.h8 : Gap.h12,
          Expanded(
            child: _Segment(
              type: type,
              selected: type == selected,
              onTap: () => onChanged(type),
            ),
          ),
        ],
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.type,
    required this.selected,
    required this.onTap,
  });

  final VehicleType type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppColors.onAuthGradient : AppColors.textSecondary;

    return Semantics(
      button: true,
      selected: selected,
      label: type.label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.standard,
        decoration: BoxDecoration(
          borderRadius: AppRadius.mdAll,
          gradient: selected
              ? LinearGradient(
                  colors: [
                    AppColors.authGradientStart,
                    AppColors.authGradientEnd,
                  ],
                )
              : null,
          color: selected ? null : AppColors.surface,
          border: selected
              ? null
              : Border.all(
                  color: AppColors.textPrimary.withValues(alpha: 0.08),
                ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.mdAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
              child: Column(
                children: [
                  Icon(
                    AppIcons.vehicle(type, selected: selected),
                    size: AppSizes.iconLg,
                    color: fg,
                  ),
                  Gap.v4,
                  Text(
                    type.label,
                    style: AppTypography.label.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w600,
                    ),
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
