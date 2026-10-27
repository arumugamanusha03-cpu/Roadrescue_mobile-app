import 'package:flutter/painting.dart';

import '../../core/constants/vehicle_type.dart';
import '../emergency_request/request_draft.dart';

/// A vehicle the customer has saved for faster requests.
class SavedVehicle {
  const SavedVehicle({
    required this.id,
    required this.type,
    required this.brand,
    required this.model,
    required this.registration,
    required this.fuelType,
    this.year,
    this.color,
    this.engine,
    this.chassisNumber,
    this.insuranceValidTill,
    this.pucValidTill,
    this.photo,
  });

  final String id;
  final VehicleType type;
  final String brand;
  final String model;
  final String registration;
  final String fuelType;
  final int? year;
  final String? color;

  /// e.g. "2.4 L" or "40.5 kWh".
  final String? engine;
  final String? chassisNumber;
  final DateTime? insuranceValidTill;
  final DateTime? pucValidTill;
  final PickedPhoto? photo;

  String get name => '$brand $model';

  SavedVehicle copyWith({
    VehicleType? type,
    String? brand,
    String? model,
    String? registration,
    String? fuelType,
    int? year,
    String? color,
    PickedPhoto? photo,
    bool clearPhoto = false,
  }) => SavedVehicle(
    id: id,
    type: type ?? this.type,
    brand: brand ?? this.brand,
    model: model ?? this.model,
    registration: registration ?? this.registration,
    fuelType: fuelType ?? this.fuelType,
    year: year ?? this.year,
    color: color ?? this.color,
    engine: engine,
    chassisNumber: chassisNumber,
    insuranceValidTill: insuranceValidTill,
    pucValidTill: pucValidTill,
    photo: clearPhoto ? null : photo ?? this.photo,
  );
}

/// Paint colours offered in the form, with a swatch for the dot.
abstract final class VehicleColors {
  static const Map<String, Color> swatches = {
    'White': Color(0xFFF4F7FF),
    'Black': Color(0xFF111111),
    'Silver': Color(0xFFC0C6CC),
    'Grey': Color(0xFF6B7480),
    'Red': Color(0xFFD7263D),
    'Blue': Color(0xFF2A6FDB),
    'Brown': Color(0xFF7A5230),
    'Green': Color(0xFF2E8B57),
    'Yellow': Color(0xFFF2C14E),
    'Orange': Color(0xFFF28C28),
  };

  static List<int> years() {
    final now = DateTime.now().year;
    return [for (var y = now; y > now - 30; y--) y];
  }
}
