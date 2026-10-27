import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/vehicle_type.dart';
import 'saved_vehicle.dart';

/// The customer's saved vehicles and which one is the default.
class Garage {
  const Garage({this.vehicles = const [], this.defaultId});

  final List<SavedVehicle> vehicles;
  final String? defaultId;

  SavedVehicle? byId(String id) {
    for (final v in vehicles) {
      if (v.id == id) return v;
    }
    return null;
  }

  SavedVehicle? get defaultVehicle =>
      defaultId == null ? null : byId(defaultId!);

  bool isDefault(SavedVehicle v) => v.id == defaultId;
}

/// TEMPORARY in-memory garage seeded with the vehicles from the approved
/// design. Swap for a vehicles repository when the API exists.
class GarageController extends Notifier<Garage> {
  @override
  Garage build() => Garage(
    defaultId: 'v1',
    vehicles: [
      SavedVehicle(
        id: 'v1',
        type: VehicleType.car,
        brand: 'Toyota',
        model: 'Innova Crysta',
        registration: 'TN 45 AB 1234',
        fuelType: 'Diesel',
        year: 2022,
        color: 'White',
        engine: '2.4 L',
        chassisNumber: 'MBJ8EV3DXN1234567',
        insuranceValidTill: DateTime(2026, 3, 12),
        pucValidTill: DateTime(2026, 1, 15),
      ),
      const SavedVehicle(
        id: 'v2',
        type: VehicleType.car,
        brand: 'Hyundai',
        model: 'i20',
        registration: 'TN 10 CD 5678',
        fuelType: 'Petrol',
        year: 2021,
        color: 'Blue',
        engine: '1.2 L',
      ),
      const SavedVehicle(
        id: 'v3',
        type: VehicleType.bike,
        brand: 'Yamaha',
        model: 'R15',
        registration: 'TN 10 EF 9012',
        fuelType: 'Petrol',
        year: 2023,
        color: 'Red',
        engine: '155 cc',
      ),
    ],
  );

  /// Adds a vehicle; the first one saved becomes the default.
  void add(SavedVehicle vehicle) => state = Garage(
    vehicles: [...state.vehicles, vehicle],
    defaultId: state.defaultId ?? vehicle.id,
  );

  void update(SavedVehicle vehicle) => state = Garage(
    vehicles: [
      for (final v in state.vehicles) v.id == vehicle.id ? vehicle : v,
    ],
    defaultId: state.defaultId,
  );

  /// Removing the default hands the role to the next vehicle, if any.
  void remove(String id) {
    final rest = [
      for (final v in state.vehicles)
        if (v.id != id) v,
    ];
    state = Garage(
      vehicles: rest,
      defaultId: state.defaultId == id
          ? (rest.isEmpty ? null : rest.first.id)
          : state.defaultId,
    );
  }

  void setDefault(String id) =>
      state = Garage(vehicles: state.vehicles, defaultId: id);

  static String newId() => 'v${DateTime.now().microsecondsSinceEpoch}';
}

final garageProvider = NotifierProvider<GarageController, Garage>(
  GarageController.new,
);
