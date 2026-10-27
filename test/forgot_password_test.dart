import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_rescue/app.dart';
import 'package:road_rescue/core/routing/app_router.dart';
import 'package:road_rescue/core/routing/app_routes.dart';
import 'package:road_rescue/core/services/session_controller.dart';
import 'package:road_rescue/features/auth/application/auth_controller.dart';
import 'package:road_rescue/features/auth/presentation/forgot_password/forgot_password_screen.dart';

/// Stands in for a connected auth backend.
class _ResultAuth extends AuthController {
  _ResultAuth(super.ref, this.result);

  final PasswordResetResult result;
  String? requestedFor;

  @override
  Future<PasswordResetResult> sendPasswordReset(String email) async {
    requestedFor = email;
    return result;
  }
}

Future<ProviderContainer> _open(
  WidgetTester tester,
  String route, {
  PasswordResetResult? backend,
}) async {
  tester.view
    ..physicalSize = const Size(412 * 3, 1100 * 3)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final c = ProviderContainer(
    overrides: [
      if (backend != null)
        authControllerProvider.overrideWith((ref) => _ResultAuth(ref, backend)),
    ],
  );
  addTearDown(c.dispose);
  c.read(sessionProvider.notifier).completeOnboarding();
  await tester.pumpWidget(
    UncontrolledProviderScope(container: c, child: const RoadRescueApp()),
  );
  c.read(routerProvider).go(route);
  await tester.pumpAndSettle();
  return c;
}

Future<void> _send(WidgetTester tester) async {
  final button = find.bySemanticsLabel(RegExp('Send Reset Link'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pump();
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('validates the email before sending', (tester) async {
    await _open(tester, AppRoutes.forgotPassword);
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    await _send(tester);
    expect(find.text('Enter your email address.'), findsOneWidget);
  });

  testWidgets('without a backend it never claims an email was sent', (
    tester,
  ) async {
    await _open(tester, AppRoutes.forgotPasswordFor('anusha@example.com'));
    // Prefilled from the login screen's email.
    expect(find.text('anusha@example.com'), findsOneWidget);
    await _send(tester);
    expect(find.text('Password reset isn’t available yet'), findsOneWidget);
    expect(find.text('Reset link sent'), findsNothing);
  });

  testWidgets('shows success only when the backend reports sent', (
    tester,
  ) async {
    final c = await _open(
      tester,
      AppRoutes.forgotPasswordFor('anusha@example.com'),
      backend: PasswordResetResult.sent,
    );
    await _send(tester);
    expect(find.text('Reset link sent'), findsOneWidget);
    expect(
      (c.read(authControllerProvider) as _ResultAuth).requestedFor,
      'anusha@example.com',
    );
  });

  testWidgets('explains a missing account', (tester) async {
    await _open(
      tester,
      AppRoutes.forgotPasswordFor('nobody@example.com'),
      backend: PasswordResetResult.userNotFound,
    );
    await _send(tester);
    expect(find.text('No account found'), findsOneWidget);
  });

  testWidgets('login passes its email to Forgot Password', (tester) async {
    await _open(tester, AppRoutes.login);
    await tester.enterText(find.byType(TextFormField).first, 'me@road.in');
    final link = find.text('Forgot Password?');
    await tester.ensureVisible(link);
    await tester.tap(link);
    await tester.pumpAndSettle();
    expect(find.byType(ForgotPasswordScreen), findsOneWidget);
    expect(find.text('me@road.in'), findsOneWidget);
  });
}
