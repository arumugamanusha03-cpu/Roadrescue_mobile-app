import '../../../core/constants/vehicle_type.dart';

/// Brands and models offered in the dropdowns, per vehicle type.
///
/// TEMPORARY static list of common Indian-market vehicles; move to the
/// backend when the vehicles API exists.
abstract final class VehicleCatalog {
  static const Map<VehicleType, Map<String, List<String>>> _models = {
    VehicleType.car: {
      'Toyota': [
        'Innova Crysta',
        'Fortuner',
        'Glanza',
        'Urban Cruiser Hyryder',
      ],
      'Hyundai': ['Creta', 'Venue', 'i20', 'Verna', 'Exter'],
      'Maruti Suzuki': ['Swift', 'Baleno', 'Brezza', 'Dzire', 'Ertiga'],
      'Tata': ['Nexon', 'Punch', 'Harrier', 'Altroz', 'Safari'],
      'Mahindra': ['XUV700', 'Scorpio-N', 'Thar', 'XUV 3XO', 'Bolero'],
      'Honda': ['City', 'Amaze', 'Elevate'],
      'Kia': ['Seltos', 'Sonet', 'Carens'],
    },
    VehicleType.bike: {
      'Hero': ['Splendor Plus', 'Glamour', 'Xtreme 160R'],
      'Honda': ['Activa', 'Shine', 'Unicorn'],
      'Bajaj': ['Pulsar 150', 'Pulsar NS200', 'Platina'],
      'TVS': ['Jupiter', 'Apache RTR 160', 'Raider'],
      'Royal Enfield': ['Classic 350', 'Bullet 350', 'Hunter 350'],
      'Yamaha': ['FZ-S', 'R15', 'MT-15'],
    },
    VehicleType.ev: {
      'Tata': ['Nexon EV', 'Punch EV', 'Tiago EV'],
      'MG': ['ZS EV', 'Comet EV', 'Windsor EV'],
      'Mahindra': ['XUV400', 'BE 6'],
      'Hyundai': ['Creta Electric', 'Ioniq 5'],
      'Ather': ['450X', 'Rizta'],
      'Ola Electric': ['S1 Pro', 'S1 Air'],
    },
  };

  /// Empty for [VehicleType.other]: brand and model are typed instead.
  static List<String> brands(VehicleType type) =>
      _models[type]?.keys.toList() ?? const [];

  static List<String> models(VehicleType type, String brand) =>
      _models[type]?[brand] ?? const [];

  static List<String> fuelTypes(VehicleType type) => switch (type) {
    VehicleType.car => const ['Petrol', 'Diesel', 'CNG', 'Hybrid'],
    VehicleType.bike => const ['Petrol'],
    VehicleType.ev => const ['Electric'],
    VehicleType.other => const ['Petrol', 'Diesel', 'CNG', 'Electric', 'Other'],
  };

  /// Loose Indian plate check: state code, district, series, number
  /// (e.g. "TN 45 AB 1234", "KA01HK7710", BH series "22 BH 1234 AA").
  static final plate = RegExp(
    r'^([A-Z]{2}\s?\d{1,2}\s?[A-Z]{0,3}\s?\d{1,4}|\d{2}\s?BH\s?\d{4}\s?[A-Z]{1,2})$',
  );

  static String? validatePlate(String? v) {
    final value = (v ?? '').trim().toUpperCase();
    if (value.isEmpty) return 'Enter the registration number.';
    if (!plate.hasMatch(value)) {
      return 'Enter it as shown on the plate, like TN 45 AB 1234.';
    }
    return null;
  }
}
