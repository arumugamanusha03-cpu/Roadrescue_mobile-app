import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/location_permission_service.dart';
import '../domain/location_access.dart';

class LocationPermissionState {
  const LocationPermissionState({
    this.access = LocationAccess.unknown,
    this.isBusy = false,
    this.skipped = false,
    this.error,
  });

  final LocationAccess access;
  final bool isBusy;
  final bool skipped;
  final String? error;

  bool get isComplete => skipped || access == LocationAccess.granted;
}

class LocationPermissionController extends Notifier<LocationPermissionState> {
  @override
  LocationPermissionState build() => const LocationPermissionState();

  Future<void> allow() async {
    if (state.isBusy || state.access == LocationAccess.granted) return;
    state = LocationPermissionState(access: state.access, isBusy: true);
    try {
      final access = await ref
          .read(locationPermissionServiceProvider)
          .request();
      state = LocationPermissionState(access: access);
    } catch (_) {
      state = const LocationPermissionState(
        error:
            'Could not request location access. Please try again or choose Not Now.',
      );
    }
  }

  void skip() {
    if (state.isBusy) return;
    // Deferring the prompt never changes the actual permission result.
    state = LocationPermissionState(access: state.access, skipped: true);
  }

  Future<bool> openSettings() async {
    if (state.isBusy) return false;
    final access = state.access;
    state = LocationPermissionState(access: access, isBusy: true);
    try {
      final opened = await ref
          .read(locationPermissionServiceProvider)
          .openSettings();
      state = LocationPermissionState(
        access: access,
        error: opened
            ? null
            : 'Could not open Settings. You can choose Not Now.',
      );
      return opened;
    } catch (_) {
      state = LocationPermissionState(
        access: access,
        error: 'Could not open Settings. You can choose Not Now.',
      );
      return false;
    }
  }

  Future<void> refreshAfterSettings() async {
    if (state.isBusy) return;
    final previous = state.access;
    state = LocationPermissionState(access: previous, isBusy: true);
    try {
      final access = await ref.read(locationPermissionServiceProvider).check();
      state = LocationPermissionState(access: access);
    } catch (_) {
      state = LocationPermissionState(
        access: previous,
        error: 'Could not check location access. Please try again.',
      );
    }
  }
}

final locationPermissionProvider =
    NotifierProvider<LocationPermissionController, LocationPermissionState>(
      LocationPermissionController.new,
    );
