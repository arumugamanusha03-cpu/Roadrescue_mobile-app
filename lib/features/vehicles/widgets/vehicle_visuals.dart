import 'package:flutter/material.dart';

import '../../../core/theme/theme.dart';
import '../saved_vehicle.dart';

/// Vehicle photo, or the type icon on a dark tile until one is added.
class VehicleThumb extends StatelessWidget {
  const VehicleThumb({
    super.key,
    required this.vehicle,
    this.width = 96,
    this.height = 112,
    this.iconSize = 44,
    this.radius = AppRadius.mdAll,
  });

  final SavedVehicle vehicle;
  final double width;
  final double height;
  final double iconSize;
  final BorderRadius radius;

  @override
  Widget build(BuildContext context) {
    final photo = vehicle.photo;
    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: photo != null
            ? Image.memory(
                photo.bytes,
                fit: BoxFit.cover,
                semanticLabel: 'Photo of ${vehicle.name}',
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.surfaceElevated,
                      AppColors.backgroundSecondary,
                    ],
                  ),
                ),
                child: Icon(
                  AppIcons.vehicle(vehicle.type, selected: true),
                  size: iconSize,
                  color: AppColors.textSecondary,
                ),
              ),
      ),
    );
  }
}

/// Brand mark stand-in: the brand's initial in an outlined circle.
/// (Manufacturer logos are trademarks and aren't bundled.)
class BrandBadge extends StatelessWidget {
  const BrandBadge({super.key, required this.brand, this.size = 32});

  final String brand;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.textPrimary, width: 1.5),
        ),
        child: Text(
          brand.isEmpty ? '?' : brand[0].toUpperCase(),
          style: AppTypography.cardTitle.copyWith(fontSize: size * 0.45),
        ),
      ),
    );
  }
}

/// Small blue "Default" / "Default Vehicle" tag.
class DefaultTag extends StatelessWidget {
  const DefaultTag({super.key, this.label = 'Default'});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.s12,
        vertical: AppSpacing.s4,
      ),
      decoration: BoxDecoration(
        color: AppColors.brandGradientEnd,
        borderRadius: AppRadius.smAll,
      ),
      child: Text(
        label,
        style: AppTypography.label.copyWith(color: AppColors.onPrimary),
      ),
    );
  }
}
