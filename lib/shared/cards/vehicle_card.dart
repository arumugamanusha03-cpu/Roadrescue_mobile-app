import 'package:flutter/material.dart';

import '../../core/constants/vehicle_type.dart';
import '../../core/theme/theme.dart';
import 'app_card.dart';

/// A saved vehicle: selection during a request, and the "My Vehicles" list.
class VehicleCard extends StatelessWidget {
  const VehicleCard({
    super.key,
    required this.type,
    required this.name,
    required this.registration,
    this.detail,
    this.photo,
    this.selected = false,
    this.onTap,
  });

  final VehicleType type;

  /// Brand and model, e.g. "Hyundai Creta".
  final String name;
  final String registration;

  /// Secondary detail, e.g. "Diesel" or "EV · 39 kWh".
  final String? detail;
  final ImageProvider? photo;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final leading = photo == null
        ? IconTile(
            icon: AppIcons.vehicle(type, selected: selected),
            selected: selected,
            size: AppSizes.avatarLg,
          )
        : ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: Image(
              image: photo!,
              width: AppSizes.avatarLg,
              height: AppSizes.avatarLg,
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          );

    return AppCard(
      onTap: onTap,
      selected: selected,
      child: Row(
        children: [
          leading,
          Gap.h16,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: AppTypography.cardTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Gap.v8,
                // Plate sits under the name so long model names keep the
                // full card width on small phones.
                Wrap(
                  spacing: AppSpacing.s8,
                  runSpacing: AppSpacing.s4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    _PlateBadge(registration: registration),
                    Text(
                      [type.label, ?detail].join(' · '),
                      style: AppTypography.caption,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlateBadge extends StatelessWidget {
  const _PlateBadge({required this.registration});

  final String registration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s8,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        registration,
        style: AppTypography.label.copyWith(
          color: AppColors.textPrimary,
          letterSpacing: 0.8,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}
