import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:road_rescue/app.dart';
import 'package:road_rescue/core/constants/service_type.dart';
import 'package:road_rescue/core/constants/user_role.dart';
import 'package:road_rescue/core/routing/app_router.dart';
import 'package:road_rescue/core/routing/app_routes.dart';
import 'package:road_rescue/core/services/session_controller.dart';
import 'package:road_rescue/core/services/theme_controller.dart';
import 'package:road_rescue/core/theme/theme.dart';
import 'package:road_rescue/features/auth/presentation/login/login_screen.dart';
import 'package:road_rescue/features/profile/profile_screen/profile_screen.dart';
import 'package:road_rescue/features/profile/user_profile.dart';
import 'package:road_rescue/features/tracking/request_details_screen/request_details_screen.dart';
import 'package:road_rescue/features/tracking/request_history.dart';
import 'package:road_rescue/features/tracking/rescue_job.dart';
import 'package:road_rescue/features/tracking/track_service_screen/track_service_screen.dart';

Future<ProviderContainer> _open(
  WidgetTester tester,
  String route, {
  Size size = const Size(412, 1000),
}) async {
  tester.view
    ..physicalSize = size * 3
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final c = ProviderContainer();
  addTearDown(c.dispose);
  c.read(sessionProvider.notifier)
    ..completeOnboarding()
    ..signIn(UserRole.customer)
    ..markLocationPromptHandled();
  await tester.pumpWidget(
    UncontrolledProviderScope(container: c, child: const RoadRescueApp()),
  );
  c.read(routerProvider).go(AppRoutes.home);
  await _settle(tester);
  if (route.startsWith('/tracking') && !route.contains('/request/') ||
      route == AppRoutes.profile) {
    c.read(routerProvider).go(route);
  } else if (route != AppRoutes.home) {
    unawaited(c.read(routerProvider).push(route));
  }
  await _settle(tester);
  return c;
}

/// Maps never "settle" in tests (tile retries), so pump fixed time.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.tap(f);
  await _settle(tester);
}

void main() {
  tearDown(() => AppColors.current = AppPalette.dark);

  testWidgets('Track tab: empty Active, History list, Completed filter', (
    tester,
  ) async {
    await _open(tester, AppRoutes.tracking);
    expect(find.byType(TrackServiceScreen), findsOneWidget);
    expect(find.text('No active request'), findsOneWidget);

    await _tap(tester, find.bySemanticsLabel('History tab'));
    expect(find.text('Recent Requests'), findsOneWidget);
    expect(find.text('Towing Service'), findsOneWidget);
    expect(find.text('Cancelled'), findsOneWidget);

    await _tap(tester, find.bySemanticsLabel('Completed tab'));
    expect(find.text('Towing Service'), findsNothing);
    expect(find.text('Out of Fuel'), findsOneWidget);
  });

  testWidgets('home History link opens the History tab', (tester) async {
    final c = await _open(tester, AppRoutes.trackHistory);
    expect(find.text('Recent Requests'), findsOneWidget);
    expect(
      c.read(routerProvider).routeInformationProvider.value.uri.path,
      AppRoutes.tracking,
    );
  });

  testWidgets('request details tabs show details, timeline, bill, rating', (
    tester,
  ) async {
    await _open(tester, AppRoutes.pastRequest('RR20240905'));
    expect(find.byType(RequestDetailsScreen), findsOneWidget);
    expect(find.text('Tata Nexon EV\nTN 22 XY 7890'), findsOneWidget);
    expect(
      find.text('Fuel delivered and vehicle started successfully.'),
      findsOneWidget,
    );
    expect(find.text('+2'), findsOneWidget);

    await _tap(tester, find.bySemanticsLabel('Timeline tab'));
    expect(find.text('Service Completed'), findsOneWidget);
    await _tap(tester, find.bySemanticsLabel('Invoice tab'));
    expect(find.text('₹450.00'), findsOneWidget);
    await _tap(tester, find.bySemanticsLabel('Feedback tab'));
    expect(find.bySemanticsLabel('Rated 5 out of 5'), findsOneWidget);
  });

  testWidgets('active request shows on the Track tab with its timeline', (
    tester,
  ) async {
    final c = await _open(tester, AppRoutes.home);
    c.read(rescueJobProvider.notifier)
      ..submit(
        service: ServiceType.flatTyre,
        address: '123, MGR Salai',
        location: const LatLng(10.79, 78.70),
      )
      ..assignProvider();
    c.read(routerProvider).go(AppRoutes.tracking);
    await _settle(tester);
    expect(find.text('On the Way'), findsOneWidget);
    expect(find.text('Request Submitted'), findsOneWidget);
    expect(find.text('View Provider Details'), findsOneWidget);
    // Finish the simulated drive so no timers outlive the test.
    c.read(rescueJobProvider.notifier).finish();
    await _settle(tester);
    expect(c.read(requestHistoryProvider).first.service, ServiceType.flatTyre);
  });

  testWidgets('profile shows the customer and logs out to sign-in', (
    tester,
  ) async {
    final c = await _open(tester, AppRoutes.profile);
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Anusha A'), findsOneWidget);
    expect(find.text('Aug 2024'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);

    await _tap(tester, find.text('Logout'));
    await _tap(tester, find.text('Logout').last);
    expect(c.read(sessionProvider).isSignedIn, isFalse);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('edit profile saves the new name', (tester) async {
    final c = await _open(tester, AppRoutes.editProfile);
    await tester.enterText(find.byType(TextFormField).first, 'Priya S');
    await _tap(tester, find.text('Save Changes'));
    expect(c.read(userProfileProvider).name, 'Priya S');
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('Settings → Theme switches the whole app to light and back', (
    tester,
  ) async {
    final c = await _open(tester, AppRoutes.settings);
    expect(find.text('Theme'), findsOneWidget);

    await _tap(tester, find.text('Light'));
    expect(c.read(themeModeProvider), ThemeMode.light);
    expect(AppColors.isDark, isFalse);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).last);
    expect(scaffold.backgroundColor, AppPalette.light.background);

    await _tap(tester, find.text('Dark'));
    expect(AppColors.isDark, isTrue);
  });

  for (final route in [
    AppRoutes.home,
    AppRoutes.vehicles,
    AppRoutes.tracking,
    AppRoutes.profile,
    AppRoutes.settings,
    AppRoutes.pastRequest('RR20240905'),
    AppRoutes.requestService,
  ]) {
    testWidgets('light theme renders $route on a small phone', (tester) async {
      ThemeController.initial = ThemeMode.light;
      addTearDown(() => ThemeController.initial = ThemeMode.dark);
      await _open(tester, route, size: const Size(320, 640));
      expect(AppColors.isDark, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
