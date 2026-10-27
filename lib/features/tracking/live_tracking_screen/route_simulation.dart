import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// TEMPORARY stand-in for the provider's GPS feed: a fixed road-like path
/// from the provider's start to the customer, walked over [duration].
class RouteSimulation {
  RouteSimulation({required LatLng from, required LatLng to})
    : points = [
        from,
        LatLng(
          from.latitude,
          to.longitude + (from.longitude - to.longitude) * 0.35,
        ),
        LatLng(
          to.latitude + (from.latitude - to.latitude) * 0.3,
          to.longitude + (from.longitude - to.longitude) * 0.35,
        ),
        to,
      ];

  /// Rebuilds a simulation over an existing route.
  RouteSimulation.fromPoints(this.points);

  final List<LatLng> points;

  static const duration = Duration(seconds: 24);
  static const startEtaMinutes = 12;

  static const _distance = Distance();

  late final List<double> _legs = [
    for (var i = 1; i < points.length; i++)
      _distance.as(LengthUnit.Meter, points[i - 1], points[i]),
  ];
  late final double _total = _legs.fold(0, (a, b) => a + b);

  /// Position after [t] (0 → 1) of the trip.
  LatLng at(double t) {
    var remaining = _total * t.clamp(0, 1);
    for (var i = 0; i < _legs.length; i++) {
      if (remaining <= _legs[i] || i == _legs.length - 1) {
        final f = _legs[i] == 0 ? 1.0 : (remaining / _legs[i]).clamp(0.0, 1.0);
        final a = points[i], b = points[i + 1];
        return LatLng(
          a.latitude + (b.latitude - a.latitude) * f,
          a.longitude + (b.longitude - a.longitude) * f,
        );
      }
      remaining -= _legs[i];
    }
    return points.last;
  }

  /// Rest of the route from [t], for drawing what's left.
  List<LatLng> remainingFrom(double t) {
    final here = at(t);
    var walked = _total * t.clamp(0, 1);
    var i = 0;
    while (i < _legs.length && walked > _legs[i]) {
      walked -= _legs[i];
      i++;
    }
    return [here, ...points.sublist(math.min(i + 1, points.length))];
  }

  static int etaFor(double t) => (startEtaMinutes * (1 - t)).ceil();
}
