import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import '../../emergency_request/request_confirmation_screen/estimates.dart';
import '../rescue_job.dart';
import '../widgets/no_active_rescue.dart';
import '../widgets/rescue_cards.dart';
import '../widgets/rescue_scaffold.dart';
import '../widgets/status_hero.dart';

/// 15. Shown right after "Request Assistance".
class RequestSubmittedScreen extends ConsumerWidget {
  const RequestSubmittedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(rescueJobProvider);
    void home() => context.go(AppRoutes.home);
    if (job == null) return const NoActiveRescue();

    return RescueScaffold(
      onBack: home,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GradientButton(
            label: 'View Progress',
            onPressed: () => context.go(AppRoutes.rescueFinding),
          ),
          Gap.v8,
          TextButton(
            onPressed: home,
            style: TextButton.styleFrom(foregroundColor: AppColors.brandCyan),
            child: const Text('Go to Home'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Gap.v16,
          const StatusHero(
            title: 'Request Submitted',
            subtitle:
                'Your request has been submitted successfully.\n'
                'We’re finding the best service provider for you.',
          ),
          Gap.v32,
          InfoRowsCard(
            rows: [
              (AppIcons.vehicles, 'Request ID', '#${job.requestId}'),
              (
                AppIcons.service(job.service, selected: true),
                'Service Type',
                job.service.label,
              ),
              (
                Icons.timer_outlined,
                'Estimated Time',
                Estimates.arrival(job.service),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
