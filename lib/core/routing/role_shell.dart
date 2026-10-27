import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets/app_bottom_navigation.dart';
import '../theme/theme.dart';
import 'app_routes.dart';

/// Tab destinations per role. Branch order in the router must match.
abstract final class RoleDestinations {
  static const customer = [
    AppNavItem(
      label: 'Home',
      icon: AppIcons.home,
      selectedIcon: AppIcons.homeSelected,
    ),
    AppNavItem(
      label: 'Vehicles',
      icon: AppIcons.vehicles,
      selectedIcon: AppIcons.vehiclesSelected,
    ),
    AppNavItem(
      label: 'Track',
      icon: Icons.location_on_outlined,
      selectedIcon: Icons.location_on,
    ),
    AppNavItem(
      label: 'Profile',
      icon: AppIcons.profile,
      selectedIcon: AppIcons.profileSelected,
    ),
  ];

  static const provider = [
    AppNavItem(
      label: 'Dashboard',
      icon: AppIcons.dashboard,
      selectedIcon: AppIcons.dashboardSelected,
    ),
    AppNavItem(
      label: 'Jobs',
      icon: AppIcons.jobs,
      selectedIcon: AppIcons.jobsSelected,
    ),
    AppNavItem(
      label: 'Earnings',
      icon: AppIcons.earnings,
      selectedIcon: AppIcons.earningsSelected,
    ),
    AppNavItem(
      label: 'Profile',
      icon: AppIcons.profile,
      selectedIcon: AppIcons.profileSelected,
    ),
  ];

  static const admin = [
    AppNavItem(
      label: 'Dashboard',
      icon: AppIcons.dashboard,
      selectedIcon: AppIcons.dashboardSelected,
    ),
    AppNavItem(
      label: 'Requests',
      icon: AppIcons.requests,
      selectedIcon: AppIcons.requestsSelected,
    ),
    AppNavItem(
      label: 'Providers',
      icon: AppIcons.providers,
      selectedIcon: AppIcons.providersSelected,
    ),
    AppNavItem(
      label: 'Customers',
      icon: AppIcons.customers,
      selectedIcon: AppIcons.customersSelected,
    ),
    AppNavItem(
      label: 'Reports',
      icon: AppIcons.reports,
      selectedIcon: AppIcons.reportsSelected,
    ),
  ];
}

/// Scaffold + bottom navigation shared by all role shells.
class RoleShell extends StatelessWidget {
  const RoleShell({
    super.key,
    required this.navigationShell,
    required this.destinations,
    this.showGetHelp = false,
  });

  final StatefulNavigationShell navigationShell;
  final List<AppNavItem> destinations;

  /// Customer shell only: the centre "Get Help" action that opens the
  /// request flow above the tabs.
  final bool showGetHelp;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Lets content show behind the raised centre button; the body still
      // receives the bar's height as bottom padding.
      extendBody: showGetHelp,
      body: navigationShell,
      bottomNavigationBar: AppBottomNavigation(
        items: destinations,
        currentIndex: navigationShell.currentIndex,
        onSelected: (index) => navigationShell.goBranch(
          index,
          // Re-tapping the active tab returns it to its root.
          initialLocation: index == navigationShell.currentIndex,
        ),
        centerAction: showGetHelp
            ? AppNavAction(
                label: 'Get Help',
                icon: AppIcons.getHelp,
                onPressed: () => context.push(AppRoutes.requestService),
              )
            : null,
      ),
    );
  }
}
