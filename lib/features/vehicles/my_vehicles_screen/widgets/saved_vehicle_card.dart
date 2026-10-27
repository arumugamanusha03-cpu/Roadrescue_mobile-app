import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../saved_vehicle.dart';
import '../../widgets/vehicle_visuals.dart';

enum VehicleMenuAction { edit, makeDefault, delete }

/// One saved vehicle: photo, brand, model, plate, fuel, overflow menu.
class SavedVehicleCard extends StatelessWidget {
  const SavedVehicleCard({
    super.key,
    required this.vehicle,
    required this.isDefault,
    required this.onTap,
    required this.onMenu,
  });

  final SavedVehicle vehicle;
  final bool isDefault;
  final VoidCallback onTap;
  final ValueChanged<VehicleMenuAction> onMenu;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: [
        vehicle.name,
        vehicle.registration,
        vehicle.fuelType,
        if (isDefault) 'default vehicle',
      ].join(', '),
      child: Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.lgAll,
          side: BorderSide(
            color: isDefault
                ? AppColors.brandGradientEnd.withValues(alpha: 0.5)
                : AppColors.textPrimary.withValues(alpha: 0.08),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.s8),
            child: Row(
              children: [
                Stack(
                  children: [
                    VehicleThumb(vehicle: vehicle),
                    if (isDefault)
                      const Positioned(top: 0, left: 0, child: DefaultTag()),
                  ],
                ),
                Gap.h16,
                Expanded(
                  child: ExcludeSemantics(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BrandBadge(brand: vehicle.brand, size: 28),
                        Gap.v8,
                        Text(
                          vehicle.brand,
                          style: AppTypography.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          vehicle.model,
                          style: AppTypography.cardTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Gap.v8,
                        Text(
                          vehicle.registration,
                          style: AppTypography.bodyStrong.copyWith(
                            fontSize: 15,
                          ),
                        ),
                        Gap.v8,
                        Row(
                          children: [
                            Icon(
                              Icons.local_gas_station_outlined,
                              size: AppSizes.iconXs,
                              color: AppColors.brandCyan,
                            ),
                            Gap.h8,
                            Text(
                              vehicle.fuelType,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    PopupMenuButton<VehicleMenuAction>(
                      tooltip: 'More options for ${vehicle.name}',
                      icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
                      color: AppColors.surfaceElevated,
                      onSelected: onMenu,
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: VehicleMenuAction.edit,
                          child: Text('Edit'),
                        ),
                        if (!isDefault)
                          const PopupMenuItem(
                            value: VehicleMenuAction.makeDefault,
                            child: Text('Set as default'),
                          ),
                        PopupMenuItem(
                          value: VehicleMenuAction.delete,
                          child: Text(
                            'Delete',
                            style: AppTypography.body.copyWith(
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Gap.v24,
                    Icon(AppIcons.chevronRight, color: AppColors.textSecondary),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
