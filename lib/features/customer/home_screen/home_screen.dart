import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_header.dart';
import '../../profile/notification_center.dart';
import '../../tracking/rescue_job.dart';
import '../../tracking/rescue_routes.dart';
import 'home_providers.dart';
import 'widgets/active_request_tile.dart';
import 'widgets/home_hero.dart';
import 'widgets/home_promo_card.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/quick_action_tile.dart';

/// Customer home: photo hero with greeting and Get Help, four shortcuts,
/// the live request, and the add-vehicle card.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const double _heroImageHeight = 420;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(activeRequestProvider);
    final unread = ref.watch(unreadCountProvider);
    // Bar height (incl. raised button) is passed in as bottom padding
    // because the shell extends the body behind the bar.
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: AppColors.overlayStyle,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: bottomInset + AppSpacing.s24),
          child: Stack(
            children: [
              const _HeroBackdrop(height: _heroImageHeight),
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.screenGutter,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      HomeTopBar(
                        unreadCount: unread,
                        onProfile: () => context.go(AppRoutes.profile),
                        onNotifications: () =>
                            context.push(AppRoutes.notifications),
                      ),
                      Gap.v24,
                      HomeHero(
                        greeting: greetingFor(DateTime.now()),
                        onGetHelp: () => context.push(AppRoutes.requestService),
                      ),
                      Gap.v32,
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (final (i, tile) in [
                              QuickActionTile(
                                icon: AppIcons.emergencyAction,
                                label: 'Emergency',
                                onTap: () =>
                                    context.push(AppRoutes.requestService),
                              ),
                              QuickActionTile(
                                icon: AppIcons.vehicles,
                                label: 'My Vehicles',
                                onTap: () => context.go(AppRoutes.vehicles),
                              ),
                              QuickActionTile(
                                icon: AppIcons.trackRequest,
                                label: 'Track Request',
                                badgeCount: active == null ? 0 : 1,
                                onTap: () => context.go(AppRoutes.tracking),
                              ),
                              QuickActionTile(
                                icon: AppIcons.history,
                                label: 'History',
                                onTap: () => context.go(AppRoutes.trackHistory),
                              ),
                            ].indexed) ...[
                              if (i > 0) Gap.h12,
                              Expanded(child: tile),
                            ],
                          ],
                        ),
                      ),
                      Gap.v32,
                      SectionHeader(
                        title: 'Active Request',
                        subtitle: active == null
                            ? null
                            : 'Your rescue is on the way',
                        actionLabel: 'View All',
                        onAction: () => context.go(AppRoutes.trackHistory),
                      ),
                      Gap.v12,
                      if (active != null)
                        ActiveRequestTile(
                          request: active,
                          onTap: () {
                            final job = ref.read(rescueJobProvider);
                            if (job == null) {
                              context.go(AppRoutes.tracking);
                            } else {
                              context.push(rescueRouteFor(job.stage));
                            }
                          },
                        )
                      else
                        const EmptyState(
                          compact: true,
                          icon: AppIcons.success,
                          title: 'No active assistance',
                          message: 'Tap Get Help Now if you need a provider.',
                        ),
                      Gap.v24,
                      HomePromoCard(
                        onPressed: () => context.push(AppRoutes.addVehicle),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Photo anchored top-right, darkened from the left (behind the text) and
/// faded into the page colour at the bottom.
class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height + MediaQuery.paddingOf(context).top,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            AppAssets.homeHero,
            fit: BoxFit.cover,
            alignment: const Alignment(0.2, 0.15),
            excludeFromSemantics: true,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xE607131F),
                  Color(0x6607131F),
                  Color(0x2207131F),
                ],
                stops: [0, 0.55, 1],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0x8007131F),
                  const Color(0x0007131F),
                  AppColors.background,
                ],
                stops: [0, 0.35, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
