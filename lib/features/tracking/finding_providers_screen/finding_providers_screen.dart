import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../rescue_job.dart';
import '../widgets/no_active_rescue.dart';
import '../widgets/rescue_cards.dart';
import '../widgets/rescue_scaffold.dart';
import 'widgets/radar_visual.dart';

/// 16. Radar + checklist while a provider is matched.
///
/// TEMPORARY: the checklist ticks on a timer and a sample provider is
/// assigned at the end. With a backend this screen just listens for the
/// "assigned" event.
class FindingProvidersScreen extends ConsumerStatefulWidget {
  const FindingProvidersScreen({super.key});

  static const stepInterval = Duration(milliseconds: 1200);

  @override
  ConsumerState<FindingProvidersScreen> createState() =>
      _FindingProvidersScreenState();
}

class _FindingProvidersScreenState
    extends ConsumerState<FindingProvidersScreen> {
  static const _steps = [
    'Searching nearby providers',
    'Checking availability',
    'Finding the best match',
    'This may take a few moments...',
  ];

  Timer? _timer;
  int _done = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final job = ref.read(rescueJobProvider);
      if (job == null) return;
      // Re-entering after assignment just shows the result.
      if (job.stage.index >= RescueStage.assigned.index) {
        return context.go(AppRoutes.rescueAssigned);
      }
      ref.read(rescueJobProvider.notifier).startSearching();
      _timer = Timer.periodic(FindingProvidersScreen.stepInterval, (t) {
        if (_done < _steps.length) {
          setState(() => _done++);
          return;
        }
        t.cancel();
        ref.read(rescueJobProvider.notifier).assignProvider();
        context.go(AppRoutes.rescueAssigned);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(rescueJobProvider) == null) return const NoActiveRescue();

    return RescueScaffold(
      onBack: () => context.go(AppRoutes.home),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const RadarVisual(),
          Gap.v24,
          Semantics(
            header: true,
            child: Text(
              'Finding Nearby Providers',
              textAlign: TextAlign.center,
              style: AppTypography.headingLarge.copyWith(fontSize: 26),
            ),
          ),
          Gap.v12,
          Text(
            'We’re locating the nearest verified service providers for you.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          Gap.v24,
          RescueCard(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s20,
              vertical: AppSpacing.s8,
            ),
            child: Column(
              children: [
                for (final (i, step) in _steps.indexed)
                  _StepRow(label: step, done: i < _done),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label, ${done ? 'done' : 'pending'}',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: AppMotion.standard,
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done ? AppColors.brandGradientEnd : Colors.transparent,
                border: done
                    ? null
                    : Border.all(color: AppColors.textMuted, width: 1.5),
              ),
              child: done
                  ? Icon(Icons.check, size: 16, color: AppColors.onPrimary)
                  : null,
            ),
            Gap.h16,
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: AppMotion.standard,
                style: AppTypography.body.copyWith(
                  color: done ? AppColors.textPrimary : AppColors.textSecondary,
                ),
                child: Text(label),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
