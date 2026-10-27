import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/forgot_password/forgot_password_screen.dart';
import '../../features/auth/presentation/login/login_screen.dart';
import '../../features/auth/presentation/signup/signup_screen.dart';
import '../../features/customer/home_screen/home_screen.dart';
import '../../features/design_system/presentation/design_system_screen.dart';
import '../../features/emergency_request/additional_info_screen/additional_info_screen.dart';
import '../../features/emergency_request/location_screen/location_screen.dart';
import '../../features/emergency_request/request_confirmation_screen/request_confirmation_screen.dart';
import '../../features/emergency_request/service_type_screen/service_type_screen.dart';
import '../../features/emergency_request/vehicle_details_screen/vehicle_details_screen.dart';
import '../../features/invoices/invoice_payment_screen/invoice_payment_screen.dart';
import '../../features/invoices/invoice_pdf_screen/invoice_pdf_screen.dart';
import '../../features/location_permission/presentation/location_permission_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/about_screen/about_screen.dart';
import '../../features/profile/edit_profile_screen/edit_profile_screen.dart';
import '../../features/profile/help_support_screen/help_support_screen.dart';
import '../../features/profile/notifications_screen/notifications_screen.dart';
import '../../features/profile/profile_screen/profile_screen.dart';
import '../../features/profile/settings_screen/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/tracking/finding_providers_screen/finding_providers_screen.dart';
import '../../features/tracking/live_tracking_screen/live_tracking_screen.dart';
import '../../features/tracking/provider_arrived_screen/provider_arrived_screen.dart';
import '../../features/tracking/provider_assigned_screen/provider_assigned_screen.dart';
import '../../features/tracking/provider_details_screen/provider_details_screen.dart';
import '../../features/tracking/rate_review_screen/rate_review_screen.dart';
import '../../features/tracking/request_details_screen/request_details_screen.dart';
import '../../features/tracking/request_submitted_screen/request_submitted_screen.dart';
import '../../features/tracking/service_completed_screen/service_completed_screen.dart';
import '../../features/tracking/service_in_progress_screen/service_in_progress_screen.dart';
import '../../features/tracking/track_service_screen/track_service_screen.dart';
import '../../features/vehicles/add_vehicle_screen/add_vehicle_screen.dart';
import '../../features/vehicles/edit_vehicle_screen/edit_vehicle_screen.dart';
import '../../features/vehicles/my_vehicles_screen/my_vehicles_screen.dart';
import '../../features/vehicles/set_default_vehicle_screen/set_default_vehicle_screen.dart';
import '../../features/vehicles/vehicle_details_screen/vehicle_details_screen.dart';
import '../constants/user_role.dart';
import '../services/session_controller.dart';
import 'app_routes.dart';
import 'placeholder_screen.dart';
import 'role_shell.dart';

final _rootKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Decides where a user may be, given their session. Pure so it can be unit
/// tested without a widget tree.
///
/// Order matters: onboarding → auth → location prompt → role ownership.
String? redirectFor(Session session, String location) {
  // The splash always plays; it hands off to onboarding and the rules
  // below route onward from there.
  if (location == AppRoutes.designSystem || location == AppRoutes.splash) {
    return null;
  }

  if (!session.hasSeenOnboarding) {
    return location == AppRoutes.onboarding ? null : AppRoutes.onboarding;
  }

  final role = session.role;
  if (role == null) {
    return location.startsWith('/auth/') ? null : AppRoutes.login;
  }

  // Signed in: entry routes are no longer reachable.
  if (AppRoutes.isPublic(location)) return AppRoutes.homeFor(role);

  if (role == UserRole.customer) {
    final onPrompt = location == AppRoutes.locationPermission;
    if (!session.hasHandledLocationPrompt) {
      return onPrompt ? null : AppRoutes.locationPermission;
    }
    if (onPrompt) return AppRoutes.home;
  }

  // Keep each role inside its own area.
  if (AppRoutes.roleFor(location) != role) return AppRoutes.homeFor(role);

  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  // Bridge Riverpod → Listenable so GoRouter re-runs redirects on session
  // changes without rebuilding the router itself.
  final refresh = ValueNotifier<int>(0);
  ref
    ..listen(sessionProvider, (_, _) => refresh.value++)
    ..onDispose(refresh.dispose);

  final router = GoRouter(
    navigatorKey: _rootKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) =>
        redirectFor(ref.read(sessionProvider), state.matchedLocation),
    routes: [
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.designSystem,
          builder: (_, _) => const DesignSystemScreen(),
        ),

      // Entry.
      GoRoute(path: AppRoutes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, _) => const OnboardingScreen(),
      ),
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: AppRoutes.signup, builder: (_, _) => const SignupScreen()),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (_, state) => ForgotPasswordScreen(
          initialEmail: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: AppRoutes.locationPermission,
        builder: (_, _) => const LocationPermissionScreen(),
      ),

      // Customer.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => RoleShell(
          navigationShell: shell,
          destinations: RoleDestinations.customer,
          showGetHelp: true,
        ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (_, _) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.vehicles,
                builder: (_, _) => const MyVehiclesScreen(),
                routes: [
                  // Literal segments first so they win over ':vehicleId'.
                  GoRoute(
                    path: 'add',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const AddVehicleScreen(),
                  ),
                  GoRoute(
                    path: 'default',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const SetDefaultVehicleScreen(),
                  ),
                  GoRoute(
                    path: ':vehicleId',
                    parentNavigatorKey: _rootKey,
                    builder: (_, state) => SavedVehicleDetailsScreen(
                      vehicleId: state.pathParameters['vehicleId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'edit',
                        parentNavigatorKey: _rootKey,
                        builder: (_, state) => EditVehicleScreen(
                          vehicleId: state.pathParameters['vehicleId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.tracking,
                builder: (_, state) => TrackServiceScreen(
                  initialTab: TrackServiceScreen.tabFromQuery(
                    state.uri.queryParameters['tab'],
                  ),
                ),
                routes: [
                  GoRoute(
                    path: 'live',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const LiveTrackingScreen(),
                  ),
                  GoRoute(
                    path: 'request/:requestId',
                    parentNavigatorKey: _rootKey,
                    builder: (_, state) => RequestDetailsScreen(
                      requestId: state.pathParameters['requestId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (_, _) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'edit',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'help',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const HelpSupportScreen(),
                  ),
                  GoRoute(
                    path: 'about',
                    parentNavigatorKey: _rootKey,
                    builder: (_, _) => const AboutScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      // History lives in the Track tab now.
      GoRoute(
        path: AppRoutes.history,
        redirect: (_, _) => AppRoutes.trackHistory,
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.invoicePattern,
        builder: (_, state) =>
            InvoicePdfScreen(requestId: state.pathParameters['requestId']!),
      ),

      // Request flow — full screen, above the customer shell.
      GoRoute(
        path: AppRoutes.requestService,
        builder: (_, _) => const ServiceTypeScreen(),
      ),
      GoRoute(
        path: AppRoutes.requestVehicle,
        builder: (_, _) => const VehicleDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.requestLocation,
        builder: (_, _) => const LocationScreen(),
      ),
      GoRoute(
        path: AppRoutes.requestDetails,
        builder: (_, _) => const AdditionalInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.requestConfirm,
        builder: (_, _) => const RequestConfirmationScreen(),
      ),

      // Rescue journey — full screen, above the customer shell.
      GoRoute(
        path: AppRoutes.rescueSubmitted,
        builder: (_, _) => const RequestSubmittedScreen(),
      ),
      GoRoute(
        path: AppRoutes.rescueFinding,
        builder: (_, _) => const FindingProvidersScreen(),
      ),
      GoRoute(
        path: AppRoutes.rescueAssigned,
        builder: (_, _) => const ProviderAssignedScreen(),
      ),
      GoRoute(
        path: AppRoutes.rescueProvider,
        builder: (_, _) => const ProviderDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.rescueArrived,
        builder: (_, _) => const ProviderArrivedScreen(),
      ),
      GoRoute(
        path: AppRoutes.rescueInProgress,
        builder: (_, _) => const ServiceInProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.rescueCompleted,
        builder: (_, _) => const ServiceCompletedScreen(),
      ),
      GoRoute(
        path: AppRoutes.rescueInvoice,
        builder: (_, _) => const InvoicePaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.rescueRate,
        builder: (_, _) => const RateReviewScreen(),
      ),

      // Provider.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => RoleShell(
          navigationShell: shell,
          destinations: RoleDestinations.provider,
        ),
        branches: [
          _branch(AppRoutes.providerDashboard, 'Dashboard'),
          _branch(AppRoutes.providerJobs, 'Jobs'),
          _branch(AppRoutes.providerEarnings, 'Earnings'),
          _branch(AppRoutes.providerProfile, 'Profile'),
        ],
      ),
      GoRoute(
        path: '${AppRoutes.providerRoot}/job/:jobId',
        builder: (_, _) => const PlaceholderScreen(title: 'Job Details'),
        routes: [
          GoRoute(
            path: 'complete',
            builder: (_, _) =>
                const PlaceholderScreen(title: 'Complete Service'),
          ),
        ],
      ),

      // Admin.
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => RoleShell(
          navigationShell: shell,
          destinations: RoleDestinations.admin,
        ),
        branches: [
          _branch(AppRoutes.adminDashboard, 'Dashboard'),
          _branch(AppRoutes.adminRequests, 'Requests'),
          _branch(AppRoutes.adminProviders, 'Providers'),
          _branch(AppRoutes.adminCustomers, 'Customers'),
          _branch(AppRoutes.adminReports, 'Reports'),
        ],
      ),
      _placeholder(AppRoutes.adminServices, 'Services'),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});

GoRoute _placeholder(String path, String title) => GoRoute(
  path: path,
  builder: (_, _) => PlaceholderScreen(title: title),
);

StatefulShellBranch _branch(
  String path,
  String title, {
  List<RouteBase> routes = const [],
}) => StatefulShellBranch(
  routes: [
    GoRoute(
      path: path,
      builder: (_, _) => PlaceholderScreen(title: title, isTab: true),
      routes: routes,
    ),
  ],
);
