import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Why a GPS fix couldn't be obtained, worded for the customer.
class LocationUnavailable implements Exception {
  const LocationUnavailable(this.message);

  final String message;
}

/// One-shot GPS fix for the location step.
abstract final class CurrentLocation {
  /// Shown until a GPS fix arrives (Tiruchirappalli city centre).
  static const fallback = LatLng(10.7905, 78.7047);

  /// [prompt] false only reads an existing grant (used on screen open);
  /// true may show the OS permission dialog (used when the customer taps
  /// the my-location button).
  static Future<LatLng> get({required bool prompt}) async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationUnavailable(
        'Turn on location services to use your current location.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && prompt) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationUnavailable(
        'Location permission is off. Move the map to set your location.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationUnavailable(
        'Location is blocked in Settings. Move the map to set your location.',
      );
    }
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    return LatLng(position.latitude, position.longitude);
  }
}
