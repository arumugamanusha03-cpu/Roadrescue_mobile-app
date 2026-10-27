import '../../../core/constants/service_type.dart';

/// Indicative price range and arrival window per service, shown before the
/// customer commits. Final charges are set on the invoice.
///
/// TEMPORARY static figures; the pricing API will replace these.
abstract final class Estimates {
  static const Map<ServiceType, (int, int)> _charge = {
    ServiceType.battery: (600, 900),
    ServiceType.flatTyre: (300, 600),
    ServiceType.fuel: (200, 400),
    ServiceType.lockedOut: (500, 1000),
    ServiceType.engine: (800, 2000),
    ServiceType.accident: (1500, 4000),
    ServiceType.towing: (1500, 3500),
    ServiceType.other: (400, 1200),
  };

  static String charge(ServiceType type) {
    final (low, high) = _charge[type]!;
    return '₹${_rupees(low)} - ₹${_rupees(high)}';
  }

  static String arrival(ServiceType type) => switch (type) {
    ServiceType.towing || ServiceType.accident => '20 - 30 minutes',
    _ => '10 - 15 minutes',
  };

  /// Indian digit grouping: 1500 → 1,500.
  static String _rupees(int amount) {
    final s = amount.toString();
    if (s.length <= 3) return s;
    final head = s.substring(0, s.length - 3);
    final tail = s.substring(s.length - 3);
    final grouped = head.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{2})+$)'),
      (m) => '${m[1]},',
    );
    return '$grouped,$tail';
  }
}
