import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/buttons/app_button.dart';
import '../../shared/widgets/app_header.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/responsive_body.dart';
import '../constants/user_role.dart';
import '../services/session_controller.dart';
import '../theme/theme.dart';
import 'app_routes.dart';

/// TEMPORARY. Stands in for screens that are specified but not built yet, so
/// the full route map and role guards can be exercised end to end. Each
/// route swaps this for its real screen as features are implemented.
class PlaceholderScreen extends ConsumerWidget {
  const PlaceholderScreen({super.key, required this.title, this.isTab = false});

  final String title;

  /// Tab roots have no back button.
  final bool isTab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final controller = ref.read(sessionProvider.notifier);
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: AppHeader(title: title, showBack: isTab ? false : null),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: ResponsiveBody(
            padTop: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                EmptyState(
                  icon: AppIcons.info,
                  title: 'Not built yet',
                  message: location,
                ),
                if (kDebugMode) ...[
                  Gap.v8,
                  ..._devActions(context, session, controller, location),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Debug-only shortcuts for walking the route guards.
  List<Widget> _devActions(
    BuildContext context,
    Session session,
    SessionController controller,
    String location,
  ) {
    Widget action(String label, VoidCallback onPressed) => Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.s12),
      child: SecondaryButton(
        label: label,
        size: AppButtonSize.medium,
        onPressed: onPressed,
      ),
    );

    return [
      if (location == AppRoutes.onboarding)
        action('Finish onboarding', controller.completeOnboarding),
      if (location == AppRoutes.locationPermission)
        action('Handle location prompt', controller.markLocationPromptHandled),
      if (!session.isSignedIn)
        for (final role in UserRole.values)
          action('Sign in as ${role.name}', () => controller.signIn(role)),
      if (session.isSignedIn) action('Sign out', controller.signOut),
      action('Open design system', () => context.push(AppRoutes.designSystem)),
    ];
  }
}
