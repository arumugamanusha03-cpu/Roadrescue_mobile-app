/// The assistance categories a customer can request.
enum ServiceType {
  battery(shortLabel: 'Battery', label: 'Dead Battery'),
  flatTyre(shortLabel: 'Flat Tyre', label: 'Flat Tyre'),
  fuel(shortLabel: 'Fuel', label: 'Out of Fuel'),
  lockedOut(shortLabel: 'Locked Out', label: 'Locked Out'),
  engine(shortLabel: 'Engine', label: 'Engine Problem'),
  accident(shortLabel: 'Accident', label: 'Accident'),
  towing(shortLabel: 'Towing', label: 'Need Towing'),
  other(shortLabel: 'Other', label: 'Other');

  const ServiceType({required this.shortLabel, required this.label});

  /// Used in compact grids (home screen categories).
  final String shortLabel;

  /// Used where the customer is describing their problem.
  final String label;
}
