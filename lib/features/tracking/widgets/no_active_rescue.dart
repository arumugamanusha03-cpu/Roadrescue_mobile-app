import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/buttons/gradient_button.dart';
import 'rescue_scaffold.dart';

/// Shown if a rescue screen opens without a live job (e.g. after a restart).
class NoActiveRescue extends StatelessWidget {
  const NoActiveRescue({super.key});

  @override
  Widget build(BuildContext context) {
    void home() => context.go(AppRoutes.home);
    return RescueScaffold(
      onBack: home,
      bottom: GradientButton(label: 'Go to Home', onPressed: home),
      body: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.s48),
        child: Text(
          'There’s no active request right now.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyLarge,
        ),
      ),
    );
  }
}
