import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:road_rescue/app.dart';
import 'package:road_rescue/core/constants/user_role.dart';
import 'package:road_rescue/core/routing/app_router.dart';
import 'package:road_rescue/core/routing/app_routes.dart';
import 'package:road_rescue/core/services/session_controller.dart';
import 'package:road_rescue/features/auth/domain/auth_validators.dart';
import 'package:road_rescue/features/auth/presentation/login/login_screen.dart';
import 'package:road_rescue/features/onboarding/presentation/onboarding_screen.dart';
import 'package:road_rescue/features/splash/presentation/splash_screen.dart';

void main() {
  group('redirectFor', () {
    const fresh = Session();
    const onboarded = Session(hasSeenOnboarding: true);
    const customerNoPrompt = Session(
      hasSeenOnboarding: true,
      role: UserRole.customer,
    );
    const customer = Session(
      hasSeenOnboarding: true,
      hasHandledLocationPrompt: true,
      role: UserRole.customer,
    );
    const provider = Session(hasSeenOnboarding: true, role: UserRole.provider);
    const admin = Session(hasSeenOnboarding: true, role: UserRole.admin);

    test('first launch goes to onboarding', () {
      expect(redirectFor(fresh, AppRoutes.home), AppRoutes.onboarding);
      expect(redirectFor(fresh, AppRoutes.onboarding), isNull);
    });

    test('signed out users are held in auth', () {
      expect(redirectFor(onboarded, AppRoutes.home), AppRoutes.login);
      expect(redirectFor(onboarded, AppRoutes.signup), isNull);
    });

    test('customers answer the location prompt before home', () {
      expect(
        redirectFor(customerNoPrompt, AppRoutes.home),
        AppRoutes.locationPermission,
      );
      expect(
        redirectFor(customer, AppRoutes.locationPermission),
        AppRoutes.home,
      );
    });

    test('signed-in users leave entry routes', () {
      expect(redirectFor(customer, AppRoutes.login), AppRoutes.home);
      expect(
        redirectFor(provider, AppRoutes.onboarding),
        AppRoutes.providerDashboard,
      );
    });

    test('each role stays inside its own area', () {
      expect(redirectFor(customer, AppRoutes.adminDashboard), AppRoutes.home);
      expect(
        redirectFor(provider, AppRoutes.home),
        AppRoutes.providerDashboard,
      );
      expect(
        redirectFor(admin, AppRoutes.providerJobs),
        AppRoutes.adminDashboard,
      );
      expect(redirectFor(admin, AppRoutes.adminReports), isNull);
      expect(redirectFor(provider, AppRoutes.providerJob('42')), isNull);
    });

    test('design system is always reachable', () {
      expect(redirectFor(fresh, AppRoutes.designSystem), isNull);
    });
  });

  testWidgets('design system renders without layout errors on a small phone', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(360 * 3, 640 * 3)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await _openDesignSystem(tester);
    expect(find.text('Design System'), findsOneWidget);

    await tester.tap(find.text('Components'));
    // Loaders animate indefinitely, so pump past the tab transition instead
    // of settling.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    // The page is a non-lazy scroll view, so every component has been laid
    // out by now and any overflow would already have been reported.
    expect(find.text('Need help on the road?').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('components survive the maximum supported font scale', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320 * 3, 640 * 3)
      ..devicePixelRatio = 3;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _openDesignSystem(tester);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Components'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });

  testWidgets('splash shows the brand artwork, then hands off to onboarding', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: RoadRescueApp()));
    await tester.pump();
    expect(find.byType(SplashScreen), findsOneWidget);

    await tester.pump(SplashScreen.hold);
    await tester.pumpAndSettle();
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });

  testWidgets('onboarding pages through and finishes into sign-in', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: RoadRescueApp()));
    await tester.pump(SplashScreen.hold);
    await tester.pumpAndSettle();

    for (var i = 0; i < 3; i++) {
      await tester.tap(find.bySemanticsLabel('Next page'));
      await tester.pumpAndSettle();
    }
    expect(find.text('Get Started'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Get Started'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('sign in validates, then signs the customer in', (tester) async {
    tester.view
      ..physicalSize = const Size(412 * 3, 1400 * 3)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final container = ProviderContainer();
    addTearDown(container.dispose);
    container.read(sessionProvider.notifier).completeOnboarding();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const RoadRescueApp(),
      ),
    );
    container.read(routerProvider).go(AppRoutes.login);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Enter your email address.'), findsOneWidget);
    expect(container.read(sessionProvider).isSignedIn, isFalse);

    await tester.enterText(find.byType(TextFormField).first, 'a@b.co');
    await tester.enterText(find.byType(TextFormField).last, 'secret');
    await tester.tap(find.bySemanticsLabel('Sign In'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(container.read(sessionProvider).role, UserRole.customer);
  });

  test('sign-up validators explain how to fix the input', () {
    expect(AuthValidators.email('nope'), isNotNull);
    expect(AuthValidators.newPassword('short1'), 'Use at least 8 characters.');
    expect(AuthValidators.newPassword('longenough1'), isNull);
    expect(AuthValidators.confirmPassword(() => 'abc')('abd'), isNotNull);
  });
}

Future<void> _openDesignSystem(WidgetTester tester) async {
  final container = ProviderContainer();
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const RoadRescueApp(),
    ),
  );
  container.read(routerProvider).go(AppRoutes.designSystem);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}
