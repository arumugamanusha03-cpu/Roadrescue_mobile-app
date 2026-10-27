import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../emergency_request/widgets/request_step_scaffold.dart';
import '../garage_provider.dart';
import '../saved_vehicle.dart';
import '../widgets/vehicle_visuals.dart';

/// 29. Pick the vehicle pre-selected in new requests.
class SetDefaultVehicleScreen extends ConsumerStatefulWidget {
  const SetDefaultVehicleScreen({super.key});

  @override
  ConsumerState<SetDefaultVehicleScreen> createState() =>
      _SetDefaultVehicleScreenState();
}

class _SetDefaultVehicleScreenState
    extends ConsumerState<SetDefaultVehicleScreen> {
  late String? _selected = ref.read(garageProvider).defaultId;

  @override
  Widget build(BuildContext context) {
    final vehicles = ref.watch(garageProvider).vehicles;

    return RequestStepScaffold(
      title: 'Set Default Vehicle',
      subtitle: 'Choose a default vehicle for faster service requests.',
      bottom: GradientButton(
        label: 'Set as Default',
        onPressed: () {
          final id = _selected;
          if (id == null) return;
          ref.read(garageProvider.notifier).setDefault(id);
          final name = ref.read(garageProvider).byId(id)?.name ?? 'Vehicle';
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('$name is now your default.')));
          context.pop();
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final v in vehicles) ...[
            _Option(
              vehicle: v,
              selected: v.id == _selected,
              onTap: () => setState(() => _selected = v.id),
            ),
            Gap.v12,
          ],
          Gap.v24,
          Container(
            padding: const EdgeInsets.all(AppSpacing.s16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: AppColors.textPrimary.withValues(alpha: 0.06),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.surfaceElevated,
                  ),
                  child: Icon(Icons.star_rounded, color: AppColors.warning),
                ),
                Gap.h16,
                Expanded(
                  child: Text(
                    'Your default vehicle will be pre-selected when you '
                    'request assistance.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.vehicle,
    required this.selected,
    required this.onTap,
  });

  final SavedVehicle vehicle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: '${vehicle.name}, ${vehicle.registration}',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: selected
                ? AppColors.brandCyan
                : AppColors.textPrimary.withValues(alpha: 0.08),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.brandCyan.withValues(alpha: 0.25),
                    blurRadius: 16,
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.lgAll,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.s8),
              child: Row(
                children: [
                  VehicleThumb(vehicle: vehicle, width: 88, height: 92),
                  Gap.h16,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        BrandBadge(brand: vehicle.brand, size: 24),
                        Gap.v8,
                        Text(vehicle.brand, style: AppTypography.bodyStrong),
                        Text(vehicle.model, style: AppTypography.bodyStrong),
                        Gap.v8,
                        Text(
                          vehicle.registration,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.s8),
                    child: AnimatedContainer(
                      duration: AppMotion.fast,
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected
                            ? AppColors.brandGradientEnd
                            : Colors.transparent,
                        border: selected
                            ? null
                            : Border.all(
                                color: AppColors.textPrimary,
                                width: 1.5,
                              ),
                      ),
                      child: selected
                          ? Icon(
                              Icons.check,
                              size: 18,
                              color: AppColors.onPrimary,
                            )
                          : null,
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
