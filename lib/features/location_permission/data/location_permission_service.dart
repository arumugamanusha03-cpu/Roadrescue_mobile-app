import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../domain/location_access.dart';

/// Foreground permission only: no GPS lookup, background access or tracking.
class LocationPermissionService {
  const LocationPermissionService();

  bool get _supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  Future<LocationAccess> request() async {
    if (!_supported) return LocationAccess.unavailable;
    // Request results distinguish permanent denial on Android. A status
    // check alone cannot reliably make that distinction.
    return _accessFor(await Permission.locationWhenInUse.request());
  }

  Future<LocationAccess> check() async {
    if (!_supported) return LocationAccess.unavailable;
    return _accessFor(await Permission.locationWhenInUse.status);
  }

  Future<bool> openSettings() async => _supported && await openAppSettings();

  LocationAccess _accessFor(PermissionStatus status) => switch (status) {
    PermissionStatus.granted => LocationAccess.granted,
    PermissionStatus.permanentlyDenied => LocationAccess.permanentlyDenied,
    PermissionStatus.restricted => LocationAccess.restricted,
    _ => LocationAccess.denied,
  };
}

final locationPermissionServiceProvider = Provider<LocationPermissionService>(
  (_) => const LocationPermissionService(),
);
