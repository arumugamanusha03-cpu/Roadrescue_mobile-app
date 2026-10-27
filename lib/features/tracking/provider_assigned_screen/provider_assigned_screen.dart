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

/// 17. A provider has accepted.
class ProviderAssignedScreen extends ConsumerWidget {
  const ProviderAssignedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(rescueJobProvider);
    final provider = job?.provider;
    if (job == null || provider == null) return const NoActiveRescue();

    return RescueScaffold(
      onBack: () => context.go(AppRoutes.home),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientButton(
            label: 'View Provider Details',
            onPressed: () => context.push(AppRoutes.rescueProvider),
          ),
          Gap.v12,
          OutlineActionButton(
            label: 'Live Tracking',
            icon: Icons.navigation,
            onPressed: () => context.push(AppRoutes.liveTracking),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.v8,
          const StatusHero(
            title: 'Provider Assigned',
            subtitle: 'A service provider has been assigned to your request.',
          ),
          Gap.v24,
          RescueCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.s16),
                  child: RescueProviderRow(provider: provider),
                ),
                Divider(
                  height: 1,
                  color: AppColors.textPrimary.withValues(alpha: 0.06),
                ),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      _Fact(
                        icon: AppIcons.vehicles,
                        label: 'Service Type',
                        value: job.service.shortLabel,
                      ),
                      _divider(),
                      _Fact(
                        icon: Icons.airport_shuttle_outlined,
                        label: 'Vehicle',
                        value: provider.vehicleType,
                      ),
                      _divider(),
                      _Fact(
                        icon: Icons.timer_outlined,
                        label: 'ETA',
                        value: '${job.etaMinutes ?? '—'} minutes',
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

  Widget _divider() => VerticalDivider(
    width: 1,
    color: AppColors.textPrimary.withValues(alpha: 0.06),
  );
}

class _Fact extends StatelessWidget {
  const _Fact({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: MergeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.s16,
            horizontal: AppSpacing.s4,
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.brandCyan),
              Gap.v8,
              Text(
                label,
                style: AppTypography.caption,
                textAlign: TextAlign.center,
              ),
              Gap.v4,
              Text(
                value,
                style: AppTypography.label.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
