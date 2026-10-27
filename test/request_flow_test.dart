import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:road_rescue/app.dart';
import 'package:road_rescue/core/constants/request_status.dart';
import 'package:road_rescue/core/constants/service_type.dart';
import 'package:road_rescue/core/constants/user_role.dart';
import 'package:road_rescue/core/routing/app_router.dart';
import 'package:road_rescue/core/routing/app_routes.dart';
import 'package:road_rescue/core/services/session_controller.dart';
import 'package:road_rescue/features/customer/home_screen/home_providers.dart';
import 'package:road_rescue/features/emergency_request/location_screen/location_screen.dart';
import 'package:road_rescue/features/emergency_request/request_confirmation_screen/estimates.dart';
import 'package:road_rescue/features/emergency_request/request_draft.dart';
import 'package:road_rescue/features/emergency_request/vehicle_details_screen/vehicle_details_screen.dart';
import 'package:road_rescue/features/tracking/request_submitted_screen/request_submitted_screen.dart';
import 'package:road_rescue/features/vehicles/garage_provider.dart';
import 'package:road_rescue/shared/buttons/gradient_button.dart';

Future<ProviderContainer> _open(
  WidgetTester tester,
  String route, {
  void Function(ProviderContainer)? setup,
}) async {
  tester.view
    ..physicalSize = const Size(412 * 3, 915 * 3)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  container.read(sessionProvider.notifier)
    ..completeOnboarding()
    ..signIn(UserRole.customer)
    ..markLocationPromptHandled();
  setup?.call(container);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const RoadRescueApp(),
    ),
  );
  container.read(routerProvider).go(AppRoutes.home);
  await tester.pumpAndSettle();
  // push() completes only when the route pops, so don't await it.
  unawaited(container.read(routerProvider).push(route));
  await _settle(tester);
  return container;
}

/// The map keeps retrying tile downloads (no network in tests), so it never
/// "settles"; pump past transitions with fixed time instead.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

void main() {
  testWidgets('picking a service stores it and opens vehicle details', (
    tester,
  ) async {
    final c = await _open(tester, AppRoutes.requestService);
    expect(find.text('Select Service Type'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('Dead Battery'));
    await tester.pumpAndSettle();
    expect(c.read(requestDraftProvider).service, ServiceType.battery);
    expect(find.byType(VehicleDetailsScreen), findsOneWidget);
  });

  testWidgets('vehicle step starts from the default saved vehicle', (
    tester,
  ) async {
    final c = await _open(tester, AppRoutes.requestVehicle);
    final draft = c.read(requestDraftProvider);
    expect(draft.brand, 'Toyota');
    expect(draft.model, 'Innova Crysta');
    expect(draft.registration, 'TN 45 AB 1234');
    expect(find.text('TN 45 AB 1234'), findsWidgets);
  });

  testWidgets('vehicle details explains what is missing', (tester) async {
    // No saved vehicles, so nothing is pre-filled.
    await _open(
      tester,
      AppRoutes.requestVehicle,
      setup: (c) {
        final garage = c.read(garageProvider.notifier);
        for (final v in [...c.read(garageProvider).vehicles]) {
          garage.remove(v.id);
        }
      },
    );
    await tester.tap(find.bySemanticsLabel('Next'));
    await tester.pumpAndSettle();
    expect(find.text('Select the brand.'), findsOneWidget);
    expect(find.text('Enter the registration number.'), findsOneWidget);
  });

  testWidgets('location step saves the pinned point and moves on', (
    tester,
  ) async {
    final c = await _open(tester, AppRoutes.requestLocation);
    expect(find.byType(LocationScreen), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Near Chathiram bus stand');
    await tester.tap(find.bySemanticsLabel('Use This Location'));
    await _settle(tester);
    final draft = c.read(requestDraftProvider);
    expect(draft.address, 'Near Chathiram bus stand');
    expect(draft.location, isNotNull);
    expect(find.text('Additional Information'), findsOneWidget);
  });

  testWidgets('confirming sends the request and shows it on Home', (
    tester,
  ) async {
    final c = await _open(tester, AppRoutes.history);
    c.read(requestDraftProvider.notifier)
      ..selectService(ServiceType.battery)
      ..setBrand('Toyota')
      ..setModel('Innova Crysta')
      ..setRegistration('TN 45 AB 1234')
      ..setFuelType('Diesel')
      ..setLocation(const LatLng(10.79, 78.70), 'Trichy, Tamil Nadu');
    unawaited(c.read(routerProvider).push(AppRoutes.requestConfirm));
    await _settle(tester);

    expect(find.text('Dead Battery'), findsOneWidget);
    expect(find.text('Toyota Innova Crysta\nTN 45 AB 1234'), findsOneWidget);
    expect(find.text('₹600 - ₹900'), findsOneWidget);
    expect(find.text('10 - 15 minutes'), findsOneWidget);

    await tester.tap(find.byType(GradientButton));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    final active = c.read(activeRequestProvider);
    expect(active?.status, RequestStatus.searching);
    expect(active?.serviceType, ServiceType.battery);
    expect(c.read(requestDraftProvider).service, isNull);
    expect(find.byType(RequestSubmittedScreen), findsOneWidget);
    expect(find.text('Request Submitted'), findsOneWidget);
  });

  test('estimates use Indian digit grouping', () {
    expect(Estimates.charge(ServiceType.accident), '₹1,500 - ₹4,000');
  });
}
