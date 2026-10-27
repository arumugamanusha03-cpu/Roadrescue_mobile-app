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
import 'package:road_rescue/features/customer/home_screen/home_screen.dart';
import 'package:road_rescue/features/invoices/invoice_payment_screen/invoice_payment_screen.dart';
import 'package:road_rescue/features/tracking/finding_providers_screen/finding_providers_screen.dart';
import 'package:road_rescue/features/tracking/live_tracking_screen/route_simulation.dart';
import 'package:road_rescue/features/tracking/provider_arrived_screen/provider_arrived_screen.dart';
import 'package:road_rescue/features/tracking/provider_assigned_screen/provider_assigned_screen.dart';
import 'package:road_rescue/features/tracking/rate_review_screen/rate_review_screen.dart';
import 'package:road_rescue/features/tracking/rescue_format.dart';
import 'package:road_rescue/features/tracking/rescue_job.dart';
import 'package:road_rescue/features/tracking/service_completed_screen/service_completed_screen.dart';
import 'package:road_rescue/features/tracking/service_in_progress_screen/service_in_progress_screen.dart';

/// The map retries tile downloads forever in tests, so pump fixed time
/// instead of settling.
Future<void> _settle(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final f = find.text(text).last;
  await tester.ensureVisible(f);
  await tester.tap(f);
  await _settle(tester);
}

void main() {
  testWidgets('a rescue runs end to end, from submission to review', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(412 * 3, 915 * 3)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(sessionProvider.notifier)
      ..completeOnboarding()
      ..signIn(UserRole.customer)
      ..markLocationPromptHandled();
    c
        .read(rescueJobProvider.notifier)
        .submit(
          service: ServiceType.flatTyre,
          address: '123, MGR Salai, Trichy, Tamil Nadu',
          location: const LatLng(10.79, 78.70),
        );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const RoadRescueApp()),
    );
    c.read(routerProvider).go(AppRoutes.rescueSubmitted);
    await _settle(tester);
    expect(find.text('Request Submitted'), findsOneWidget);
    expect(find.text('Flat Tyre'), findsOneWidget);

    // 16 → 17: matching ticks through the checklist, then assigns.
    await _tapText(tester, 'View Progress');
    expect(find.byType(FindingProvidersScreen), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await tester.pump(FindingProvidersScreen.stepInterval);
    }
    await _settle(tester);
    expect(find.byType(ProviderAssignedScreen), findsOneWidget);
    expect(find.text('Rajesh Kumar'), findsOneWidget);
    // The simulated drive starts as soon as the provider is assigned.
    expect(
      c.read(activeRequestProvider)?.status,
      isIn([RequestStatus.accepted, RequestStatus.onTheWay]),
    );

    // 18: details.
    await _tapText(tester, 'View Provider Details');
    expect(find.text('TN 09 AB 5678'), findsOneWidget);
    expect(find.text('1,200+'), findsOneWidget);

    // 19 → 20: the van drives to the customer.
    await _tapText(tester, 'Live Tracking');
    expect(find.text('Live Tracking'), findsWidgets);
    await tester.pump(const Duration(seconds: 3));
    expect(c.read(rescueJobProvider)?.stage, RescueStage.onTheWay);
    await tester.pump(RouteSimulation.duration);
    await _settle(tester);
    expect(find.byType(ProviderArrivedScreen), findsOneWidget);

    // 21 → 22: service runs, then completes.
    await _tapText(tester, 'Start Service');
    expect(find.byType(ServiceInProgressScreen), findsOneWidget);
    expect(find.text('Service Started'), findsOneWidget);
    await tester.pump(ServiceInProgressScreen.demoDuration);
    await _settle(tester);
    expect(find.byType(ServiceCompletedScreen), findsOneWidget);

    // 23: invoice totals and payment.
    await _tapText(tester, 'View Invoice');
    expect(find.byType(InvoicePaymentScreen), findsOneWidget);
    expect(find.text('₹650.00'), findsOneWidget);
    await _tapText(tester, 'Pay ₹650.00');
    await tester.pump(const Duration(seconds: 1));
    await _settle(tester);

    // 24: rating needs a star, then the journey ends on Home.
    expect(find.byType(RateReviewScreen), findsOneWidget);
    // The payment snackbar floats over the buttons; let it go first.
    await tester.pump(const Duration(seconds: 5));
    await _settle(tester);
    await _tapText(tester, 'Submit Review');
    expect(find.text('Tap a star to rate your provider.'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel('4 stars'));
    await tester.pump(const Duration(seconds: 5));
    await _settle(tester);
    await _tapText(tester, 'Submit Review');
    expect(c.read(rescueJobProvider), isNull);
    expect(c.read(activeRequestProvider), isNull);
    expect(find.byType(HomeScreen), findsOneWidget);
    // Let snackbars finish.
    await tester.pump(const Duration(seconds: 5));
  });

  test('time and money formatting', () {
    expect(RescueFormat.time(DateTime(2024, 9, 12, 10, 5)), '10:05 AM');
    expect(
      RescueFormat.dateTime(DateTime(2024, 9, 12, 23, 10)),
      'Sep 12, 2024 • 11:10 PM',
    );
    expect(RescueFormat.duration(const Duration(seconds: 20)), '1 minute');
    expect(RescueFormat.rupees(650), '₹650.00');
  });

  test('simulated route starts at the provider and ends at the customer', () {
    const from = LatLng(10.80, 78.71);
    const to = LatLng(10.79, 78.70);
    final sim = RouteSimulation(from: from, to: to);
    expect(sim.at(0), from);
    expect(sim.at(1), to);
    expect(RouteSimulation.etaFor(0), 12);
    expect(RouteSimulation.etaFor(1), 0);
  });
}
