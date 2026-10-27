import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../rescue_format.dart';
import '../rescue_job.dart';
import '../widgets/no_active_rescue.dart';
import '../widgets/rescue_cards.dart';
import '../widgets/rescue_scaffold.dart';
import '../widgets/status_hero.dart';

/// 22. Work is done.
class ServiceCompletedScreen extends ConsumerWidget {
  const ServiceCompletedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(rescueJobProvider);
    if (job == null) return const NoActiveRescue();
    final completedAt = job.completedAt ?? DateTime.now();

    return RescueScaffold(
      onBack: () => context.go(AppRoutes.home),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientButton(
            label: 'View Invoice',
            onPressed: () => context.push(AppRoutes.rescueInvoice),
          ),
          Gap.v12,
          OutlineActionButton(
            label: 'Rate Provider',
            onPressed: () => context.push(AppRoutes.rescueRate),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.v8,
          const StatusHero(
            title: 'Service Completed',
            subtitle:
                'Your vehicle has been serviced successfully.\n'
                'Thank you for choosing RoadRescue!',
          ),
          Gap.v24,
          InfoRowsCard(
            rows: [
              (AppIcons.vehicles, 'Service Type', job.service.shortLabel),
              (
                Icons.timer_outlined,
                'Service Time',
                RescueFormat.duration(job.serviceDuration ?? Duration.zero),
              ),
              (
                Icons.event_available_outlined,
                'Completed At',
                RescueFormat.dateTime(completedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
