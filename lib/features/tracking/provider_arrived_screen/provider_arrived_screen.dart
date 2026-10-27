import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../rescue_job.dart';
import '../widgets/no_active_rescue.dart';
import '../widgets/rescue_cards.dart';
import '../widgets/rescue_scaffold.dart';
import '../widgets/status_hero.dart';

/// 20. The provider is at the vehicle.
class ProviderArrivedScreen extends ConsumerWidget {
  const ProviderArrivedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(rescueJobProvider);
    final p = job?.provider;
    if (job == null || p == null) return const NoActiveRescue();

    return RescueScaffold(
      onBack: () => context.go(AppRoutes.home),
      bottom: GradientButton(
        label: 'Start Service',
        onPressed: () {
          ref.read(rescueJobProvider.notifier).startService();
          context.go(AppRoutes.rescueInProgress);
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.v8,
          const StatusHero(
            title: 'Provider Arrived',
            subtitle: 'Your service provider has arrived at your location.',
          ),
          Gap.v24,
          RescueCard(
            child: RescueProviderRow(
              provider: p,
              showVehicle: true,
              showContact: true,
            ),
          ),
          Gap.v12,
          RescueCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  AppIcons.locationSelected,
                  size: 30,
                  color: AppColors.brandCyan,
                ),
                Gap.h16,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Location', style: AppTypography.caption),
                      Gap.v4,
                      Text(
                        job.address,
                        style: AppTypography.bodyStrong.copyWith(fontSize: 15),
                      ),
                      Gap.v12,
                      OutlinedButton.icon(
                        onPressed: () => context.push(AppRoutes.liveTracking),
                        icon: const Icon(
                          Icons.map_outlined,
                          size: AppSizes.iconSm,
                        ),
                        label: const Text('View on Map'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.brandCyan,
                          backgroundColor: AppColors.surfaceElevated,
                          side: BorderSide.none,
                          minimumSize: const Size.fromHeight(44),
                          shape: const RoundedRectangleBorder(
                            borderRadius: AppRadius.mdAll,
                          ),
                        ),
                      ),
                    ],
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
