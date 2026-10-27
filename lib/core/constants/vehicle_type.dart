enum VehicleType {
  car(label: 'Car'),
  bike(label: 'Bike'),
  ev(label: 'EV'),
  other(label: 'Other');

  const VehicleType({required this.label});

  final String label;

  /// Types offered in the emergency request flow (no free-form "Other").
  static const requestTypes = [car, bike, ev];
}
