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
import 'package:road_rescue/features/profile/notification_center.dart';
import 'package:road_rescue/features/profile/notification_prefs.dart';
import 'package:road_rescue/features/tracking/rescue_job.dart';
import 'package:shared_preferences/shared_preferences.dart';

void _submit(ProviderContainer c) => c
    .read(rescueJobProvider.notifier)
    .submit(
      service: ServiceType.battery,
      address: 'MGR Salai',
      location: const LatLng(10.79, 78.70),
    );

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
  c.read(routerProvider).go(AppRoutes.home);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  unawaited(c.read(routerProvider).push(route));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  return c;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('request progress creates unread in-app updates', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.listen(notificationCenterProvider, (_, _) {});
    _submit(c);
    c.read(rescueJobProvider.notifier).assignProvider();
    final items = c.read(notificationCenterProvider);
    expect(items.map((n) => n.title), [
      'Provider assigned',
      'Request submitted',
    ]);
    expect(c.read(unreadCountProvider), 2);

    c.read(notificationCenterProvider.notifier).markAllRead();
    expect(c.read(unreadCountProvider), 0);
    c.read(notificationCenterProvider.notifier).clear();
    expect(c.read(notificationCenterProvider), isEmpty);
    c.read(rescueJobProvider.notifier).finish();
  });

  test('turning request updates off stops new updates', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.listen(notificationCenterProvider, (_, _) {});
    await c.read(notificationPrefsProvider.notifier).setRequestUpdates(false);
    _submit(c);
    expect(c.read(notificationCenterProvider), isEmpty);
  });

  test('preferences are saved on the device', () async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    await c.read(notificationPrefsProvider.notifier).setOffers(true);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('notif_offers'), isTrue);

    // A fresh session reads them back.
    final c2 = ProviderContainer();
    addTearDown(c2.dispose);
    c2.read(notificationPrefsProvider);
    await Future<void>.delayed(Duration.zero);
    expect(c2.read(notificationPrefsProvider).offers, isTrue);
  });

  testWidgets('screen is honest that push is not set up', (tester) async {
    final c = await _open(tester, AppRoutes.notifications);
    expect(
      find.textContaining('Push notifications aren’t set up yet'),
      findsOneWidget,
    );
    expect(find.text('You’re all caught up'), findsOneWidget);

    c.read(notificationCenterProvider.notifier).add('Provider assigned', 'x');
    await tester.pump();
    expect(find.text('Provider assigned'), findsOneWidget);
    expect(find.text('Mark all read'), findsOneWidget);
    await tester.tap(find.text('Mark all read'));
    await tester.pump();
    expect(find.text('Mark all read'), findsNothing);
  });

  testWidgets('settings switches persist', (tester) async {
    final c = await _open(tester, AppRoutes.settings);
    await tester.tap(find.text('Offers & news'));
    await tester.pump();
    expect(c.read(notificationPrefsProvider).offers, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('notif_offers'), isTrue);
  });
}
