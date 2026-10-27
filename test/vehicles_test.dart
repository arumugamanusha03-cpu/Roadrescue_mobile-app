import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_rescue/app.dart';
import 'package:road_rescue/core/constants/user_role.dart';
import 'package:road_rescue/core/routing/app_router.dart';
import 'package:road_rescue/core/routing/app_routes.dart';
import 'package:road_rescue/core/services/session_controller.dart';
import 'package:road_rescue/features/vehicles/garage_provider.dart';
import 'package:road_rescue/features/vehicles/my_vehicles_screen/my_vehicles_screen.dart';
import 'package:road_rescue/features/vehicles/vehicle_details_screen/vehicle_details_screen.dart';

Future<ProviderContainer> _open(WidgetTester tester, String route) async {
  tester.view
    ..physicalSize = const Size(412 * 3, 1000 * 3)
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
  c.read(routerProvider).go(AppRoutes.vehicles);
  await tester.pumpAndSettle();
  if (route != AppRoutes.vehicles) {
    unawaited(c.read(routerProvider).push(route));
    await tester.pumpAndSettle();
  }
  return c;
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('vehicles tab lists saved vehicles with the default marked', (
    tester,
  ) async {
    await _open(tester, AppRoutes.vehicles);
    expect(find.byType(MyVehiclesScreen), findsOneWidget);
    expect(find.text('Innova Crysta'), findsOneWidget);
    expect(find.text('i20'), findsOneWidget);
    expect(find.text('R15'), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);

    await _tap(tester, find.text('i20'));
    expect(find.byType(SavedVehicleDetailsScreen), findsOneWidget);
    expect(find.text('TN 10 CD 5678'), findsWidgets);
  });

  testWidgets('details show documents; set default and delete work', (
    tester,
  ) async {
    final c = await _open(tester, AppRoutes.vehicleDetails('v1'));
    expect(find.text('MBJ8EV3DXN1234567'), findsOneWidget);
    expect(find.text('Mar 12, 2026'), findsOneWidget);
    expect(find.text('Default Vehicle'), findsOneWidget);
    // Already default: no "Set as Default" button.
    expect(find.text('Set as Default Vehicle'), findsNothing);

    c.read(routerProvider).pop();
    await tester.pumpAndSettle();
    unawaited(c.read(routerProvider).push(AppRoutes.vehicleDetails('v2')));
    await tester.pumpAndSettle();
    await _tap(tester, find.text('Set as Default Vehicle'));
    expect(c.read(garageProvider).defaultId, 'v2');
    // Let the confirmation snackbar clear the bottom buttons.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    await _tap(tester, find.text('Delete Vehicle'));
    await _tap(tester, find.text('Delete Vehicle').last);
    expect(c.read(garageProvider).byId('v2'), isNull);
    // The default passes to a remaining vehicle.
    expect(c.read(garageProvider).defaultId, 'v1');
    expect(find.byType(MyVehiclesScreen), findsOneWidget);
  });

  testWidgets('add vehicle validates, then saves', (tester) async {
    final c = await _open(tester, AppRoutes.addVehicle);
    expect(find.text('Add Vehicle'), findsOneWidget);
    await _tap(tester, find.text('Save Vehicle'));
    expect(find.text('Select the brand.'), findsOneWidget);
    expect(find.text('Enter the registration number.'), findsOneWidget);

    // "Other" uses typed brand/model.
    await _tap(tester, find.bySemanticsLabel('Other'));
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Force Motors');
    await tester.enterText(fields.at(1), 'Traveller');
    await tester.enterText(fields.at(2), 'tn 33 xy 4455');
    await tester.pump();
    await _tap(tester, find.text('Select fuel type'));
    await _tap(tester, find.text('Diesel').last);
    await _tap(tester, find.text('Save Vehicle'));

    final saved = c.read(garageProvider).vehicles.last;
    expect(saved.name, 'Force Motors Traveller');
    expect(saved.registration, 'TN 33 XY 4455');
    expect(find.byType(MyVehiclesScreen), findsOneWidget);
  });

  testWidgets('set default screen changes the default', (tester) async {
    final c = await _open(tester, AppRoutes.defaultVehicle);
    expect(find.text('Set Default Vehicle'), findsOneWidget);
    await _tap(tester, find.bySemanticsLabel('Yamaha R15, TN 10 EF 9012'));
    await _tap(tester, find.text('Set as Default'));
    expect(c.read(garageProvider).defaultId, 'v3');
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('edit vehicle updates year and colour', (tester) async {
    final c = await _open(tester, AppRoutes.editVehicle('v2'));
    expect(find.text('Edit Vehicle'), findsOneWidget);
    await _tap(tester, find.text('2021'));
    await _tap(tester, find.text('2020').last);
    await _tap(tester, find.text('Update Vehicle'));
    expect(c.read(garageProvider).byId('v2')?.year, 2020);
    await tester.pump(const Duration(seconds: 5));
  });
}
