import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_rescue/app.dart';
import 'package:road_rescue/core/constants/user_role.dart';
import 'package:road_rescue/core/routing/app_router.dart';
import 'package:road_rescue/core/routing/app_routes.dart';
import 'package:road_rescue/core/services/session_controller.dart';
import 'package:road_rescue/features/invoices/invoice_data.dart';
import 'package:road_rescue/features/invoices/invoice_pdf_screen/invoice_pdf.dart';
import 'package:road_rescue/features/tracking/request_history.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('invoice data from a past request carries totals and demo flag', () {
    final past = RequestHistoryController().build().first;
    final d = InvoiceData.fromPast(past, customerName: 'Anusha A');
    expect(d.requestId, 'RR20240905');
    expect(d.total, 450);
    expect(d.paid, isTrue);
    expect(d.isDemo, isTrue);
    expect(d.fileName, 'RoadRescue-Invoice-RR20240905.pdf');
  });

  test('builds a valid PDF document', () async {
    final past = RequestHistoryController().build().first;
    final bytes = await buildInvoicePdf(InvoiceData.fromPast(past));
    expect(bytes.length, greaterThan(1000));
    expect(ascii.decode(bytes.sublist(0, 5)), '%PDF-');
  });

  testWidgets('invoice screen labels the PDF as demo and offers actions', (
    tester,
  ) async {
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
    unawaited(c.read(routerProvider).push(AppRoutes.invoice('RR20240905')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.textContaining('Demo invoice from sample data'),
      findsOneWidget,
    );
    expect(find.text('Share'), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Print'), findsOneWidget);
  });

  testWidgets('cancelled requests have no invoice', (tester) async {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    c.read(sessionProvider.notifier)
      ..completeOnboarding()
      ..signIn(UserRole.customer)
      ..markLocationPromptHandled();
    await tester.pumpWidget(
      UncontrolledProviderScope(container: c, child: const RoadRescueApp()),
    );
    c.read(routerProvider).go(AppRoutes.invoice('RR20240828'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('No invoice for this request'), findsOneWidget);
  });
}
