import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../../shared/widgets/empty_state.dart';
import '../garage_provider.dart';
import '../widgets/delete_vehicle.dart';
import 'widgets/saved_vehicle_card.dart';

/// 25. Vehicles tab: saved vehicles and Add Vehicle.
class MyVehiclesScreen extends ConsumerWidget {
  const MyVehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final garage = ref.watch(garageProvider);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.overlayStyle,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.screenGutter,
              0,
              AppSpacing.screenGutter,
              bottomInset + AppSpacing.s24,
            ),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go(AppRoutes.home),
                    tooltip: 'Back to Home',
                    padding: EdgeInsets.zero,
                    alignment: Alignment.centerLeft,
                    icon: Icon(AppIcons.back, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => context.go(AppRoutes.profile),
                    tooltip: 'Profile',
                    icon: Icon(
                      Icons.manage_accounts_outlined,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Semantics(
                header: true,
                child: Text(
                  'My Vehicles',
                  style: AppTypography.headingLarge.copyWith(fontSize: 26),
                ),
              ),
              Gap.v8,
              Text(
                'Manage your vehicles for faster service requests.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Gap.v20,
              GradientButton(
                label: 'Add Vehicle',
                icon: Icons.add_circle,
                onPressed: () => context.push(AppRoutes.addVehicle),
              ),
              Gap.v20,
              if (garage.vehicles.isEmpty)
                const EmptyState(
                  compact: true,
                  icon: AppIcons.vehicles,
                  title: 'No vehicles yet',
                  message: 'Add your car or bike to request help faster.',
                )
              else
                for (final v in garage.vehicles) ...[
                  SavedVehicleCard(
                    vehicle: v,
                    isDefault: garage.isDefault(v),
                    onTap: () => context.push(AppRoutes.vehicleDetails(v.id)),
                    onMenu: (action) => switch (action) {
                      VehicleMenuAction.edit => context.push(
                        AppRoutes.editVehicle(v.id),
                      ),
                      VehicleMenuAction.makeDefault =>
                        ref.read(garageProvider.notifier).setDefault(v.id),
                      VehicleMenuAction.delete => confirmDeleteVehicle(
                        context,
                        ref,
                        v,
                      ),
                    },
                  ),
                  Gap.v12,
                ],
              if (garage.vehicles.length > 1) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push(AppRoutes.defaultVehicle),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.brandCyan,
                    ),
                    child: const Text('Change default vehicle'),
                  ),
                ),
                Gap.v8,
              ],
              const _InfoNote(),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  const _InfoNote();

  @override
  Widget build(BuildContext context) {
    return Container(
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandGradientEnd,
            ),
            child: Icon(Icons.question_mark, color: AppColors.onPrimary),
          ),
          Gap.h16,
          Expanded(
            child: Text(
              'Adding your vehicle details helps us find the right service '
              'provider for you.',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
