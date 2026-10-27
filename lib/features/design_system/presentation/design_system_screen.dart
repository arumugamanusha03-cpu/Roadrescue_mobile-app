import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/shared.dart';
import 'widgets/ds_components.dart';
import 'widgets/ds_foundations.dart';

/// Debug-only catalogue of tokens and components. The reference point for
/// every new screen: if something isn't here, it doesn't exist yet.
class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppHeader(
          title: 'Design System',
          showBack: false,
          actions: [
            TextButton(
              onPressed: () => context.go(AppRoutes.onboarding),
              child: const Text('Open app'),
            ),
          ],
        ),
        body: Column(
          children: [
            ResponsiveBody(
              child: TabBar(
                tabs: [
                  const Tab(text: 'Foundations'),
                  const Tab(text: 'Components'),
                ],
                labelStyle: AppTypography.buttonSmall,
                labelColor: AppColors.textPrimary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.label,
                dividerColor: AppColors.divider,
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _scroll(const DsFoundations()),
                  _scroll(const DsComponents()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _scroll(Widget child) => SafeArea(
    top: false,
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(top: AppSpacing.s24),
      child: ResponsiveBody(child: child),
    ),
  );
}
