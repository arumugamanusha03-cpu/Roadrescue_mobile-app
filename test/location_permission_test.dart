import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:road_rescue/app.dart';
import 'package:road_rescue/core/constants/user_role.dart';
import 'package:road_rescue/core/routing/app_router.dart';
import 'package:road_rescue/core/routing/app_routes.dart';
import 'package:road_rescue/core/services/session_controller.dart';
import 'package:road_rescue/features/location_permission/application/location_permission_controller.dart';
import 'package:road_rescue/features/location_permission/data/location_permission_service.dart';
import 'package:road_rescue/features/location_permission/domain/location_access.dart';
import 'package:road_rescue/features/location_permission/presentation/location_permission_screen.dart';

const _previewKey = ValueKey('location-preview');

class _FakePermissionService extends LocationPermissionService {
  LocationAccess next = LocationAccess.granted;
  int requests = 0;
  int checks = 0;
  int settingsOpened = 0;
  bool canOpenSettings = true;
  bool fails = false;
  Completer<LocationAccess>? pending;

  @override
  Future<LocationAccess> request() async {
    requests++;
    if (fails) throw PlatformException(code: 'permission-failed');
    return pending == null ? next : pending!.future;
  }

  @override
  Future<LocationAccess> check() async {
    checks++;
    return next;
  }

  @override
  Future<bool> openSettings() async {
    settingsOpened++;
    return canOpenSettings;
  }
}

Future<ProviderContainer> _openScreen(
  WidgetTester tester,
  _FakePermissionService service,
) async {
  final container = ProviderContainer(
    overrides: [locationPermissionServiceProvider.overrideWithValue(service)],
  );
  addTearDown(container.dispose);
  container.read(sessionProvider.notifier)
    ..completeOnboarding()
    ..signIn(UserRole.customer);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const RepaintBoundary(key: _previewKey, child: RoadRescueApp()),
    ),
  );
  container.read(routerProvider).go(AppRoutes.locationPermission);
  await tester.pumpAndSettle();
  return container;
}

void _expectHome(ProviderContainer container) {
  expect(container.read(sessionProvider).hasHandledLocationPrompt, isTrue);
  expect(
    container.read(routerProvider).routeInformationProvider.value.uri.path,
    AppRoutes.home,
  );
  expect(find.byType(LocationPermissionScreen), findsNothing);
}

Future<void> _allow(WidgetTester tester) async {
  final button = find.byType(FilledButton);
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final loader = FontLoader('Inter');
    for (final weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
      loader.addFont(rootBundle.load('assets/fonts/Inter-$weight.ttf'));
    }
    await loader.load();
  });

  testWidgets('route opens without requesting permission; Not Now goes Home', (
    tester,
  ) async {
    final service = _FakePermissionService();
    final container = await _openScreen(tester, service);
    expect(find.byType(LocationPermissionScreen), findsOneWidget);
    expect(service.requests, 0);
    expect(service.checks, 0);
    await tester.ensureVisible(find.text('Not Now'));
    await tester.tap(find.text('Not Now'));
    await tester.pumpAndSettle();
    final state = container.read(locationPermissionProvider);
    expect(state.skipped, isTrue);
    expect(state.access, LocationAccess.unknown);
    expect(service.requests, 0);
    // Declining location must never block the app.
    _expectHome(container);
  });

  testWidgets('grant moves on to Home', (tester) async {
    final service = _FakePermissionService();
    final container = await _openScreen(tester, service);
    await _allow(tester);
    expect(service.requests, 1);
    expect(
      container.read(locationPermissionProvider).access,
      LocationAccess.granted,
    );
    _expectHome(container);
  });

  testWidgets('denied permission can be retried or deferred honestly', (
    tester,
  ) async {
    final service = _FakePermissionService()..next = LocationAccess.denied;
    final container = await _openScreen(tester, service);
    await _allow(tester);
    expect(container.read(locationPermissionProvider).isComplete, isFalse);
    expect(
      find.text('Location access was denied. Try again or choose Not Now.'),
      findsOneWidget,
    );
    service.next = LocationAccess.granted;
    await _allow(tester);
    expect(service.requests, 2);
    expect(
      container.read(locationPermissionProvider).access,
      LocationAccess.granted,
    );
  });

  testWidgets('permanent denial opens settings and checks on return', (
    tester,
  ) async {
    final service = _FakePermissionService()
      ..next = LocationAccess.permanentlyDenied;
    final container = await _openScreen(tester, service);
    await _allow(tester);
    expect(service.settingsOpened, 0);
    await tester.ensureVisible(find.text('Open Settings'));
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();
    expect(service.settingsOpened, 1);
    expect(
      container.read(locationPermissionProvider).access,
      LocationAccess.permanentlyDenied,
    );
    service.next = LocationAccess.granted;
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(service.checks, 1);
    expect(service.requests, 1);
    _expectHome(container);
  });

  testWidgets('settings failure remains recoverable', (tester) async {
    final service = _FakePermissionService()
      ..next = LocationAccess.permanentlyDenied
      ..canOpenSettings = false;
    final container = await _openScreen(tester, service);
    await _allow(tester);
    await tester.ensureVisible(find.text('Open Settings'));
    await tester.tap(find.text('Open Settings'));
    await tester.pumpAndSettle();
    expect(
      find.text('Could not open Settings. You can choose Not Now.'),
      findsOneWidget,
    );
    await tester.ensureVisible(find.text('Not Now'));
    await tester.tap(find.text('Not Now'));
    await tester.pumpAndSettle();
    _expectHome(container);
  });

  for (final access in [
    LocationAccess.restricted,
    LocationAccess.unavailable,
  ]) {
    testWidgets('$access can be deferred without claiming a grant', (
      tester,
    ) async {
      final service = _FakePermissionService()..next = access;
      final container = await _openScreen(tester, service);
      await _allow(tester);
      expect(find.text('Open Settings'), findsNothing);
      await tester.ensureVisible(find.text('Not Now'));
      await tester.tap(find.text('Not Now'));
      await tester.pumpAndSettle();
      expect(container.read(locationPermissionProvider).access, access);
      expect(container.read(locationPermissionProvider).skipped, isTrue);
    });
  }

  testWidgets('request errors do not grant or complete the prompt', (
    tester,
  ) async {
    final service = _FakePermissionService()..fails = true;
    final container = await _openScreen(tester, service);
    await _allow(tester);
    expect(container.read(locationPermissionProvider).isComplete, isFalse);
    expect(
      find.text(
        'Could not request location access. Please try again or choose Not Now.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('pending requests block repeat requests and skipping', (
    tester,
  ) async {
    final pending = Completer<LocationAccess>();
    final service = _FakePermissionService()..pending = pending;
    final container = await _openScreen(tester, service);
    await tester.ensureVisible(find.byType(FilledButton));
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    expect(container.read(locationPermissionProvider).isBusy, isTrue);
    expect(
      tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
      isNull,
    );
    expect(
      tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
      isNull,
    );
    expect(service.requests, 1);
    pending.complete(LocationAccess.denied);
    await tester.pumpAndSettle();
    expect(container.read(locationPermissionProvider).isBusy, isFalse);
  });

  for (final (size, textScale) in [
    (const Size(320, 568), 1.0),
    (const Size(320, 568), 1.6),
    (const Size(640, 320), 1.6),
    (const Size(393, 852), 1.0),
  ]) {
    testWidgets('layout fits $size at scale $textScale', (tester) async {
      tester.view
        ..physicalSize = size * 3
        ..devicePixelRatio = 3;
      tester.platformDispatcher.textScaleFactorTestValue = textScale;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final service = _FakePermissionService()
        ..next = LocationAccess.permanentlyDenied;
      await _openScreen(tester, service);
      expect(tester.takeException(), isNull);
      if (const bool.fromEnvironment('LOCATION_PREVIEW') && size.width == 393) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(_previewKey),
        );
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await Directory('build').create(recursive: true);
        await File(
          'build/location_permission_preview.png',
        ).writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      }
      await _allow(tester);
      await tester.ensureVisible(find.text('Open Settings'));
      expect(find.text('Open Settings').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  group('native permission adapter', () {
    const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.android);
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    });

    for (final (native, expected) in [
      (PermissionStatus.granted, LocationAccess.granted),
      (PermissionStatus.denied, LocationAccess.denied),
      (PermissionStatus.permanentlyDenied, LocationAccess.permanentlyDenied),
      (PermissionStatus.restricted, LocationAccess.restricted),
    ]) {
      test('maps $native and requests foreground location only', () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              expect(call.method, 'requestPermissions');
              expect(call.arguments, [Permission.locationWhenInUse.value]);
              // The plugin encodes statuses as their enum index
              // (denied 0, granted 1, restricted 2, limited 3,
              // permanentlyDenied 4).
              return {Permission.locationWhenInUse.value: native.index};
            });
        expect(await const LocationPermissionService().request(), expected);
      });
    }

    test('desktop returns unavailable without invoking a plugin', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(
        await const LocationPermissionService().request(),
        LocationAccess.unavailable,
      );
      expect(await const LocationPermissionService().openSettings(), isFalse);
    });
  });
}
