import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/service_type.dart';
import '../../core/constants/vehicle_type.dart';
import 'rescue_job.dart';

enum PastStatus { completed, cancelled }

/// A finished (or cancelled) request in the customer's history.
class PastRequest {
  const PastRequest({
    required this.id,
    required this.service,
    required this.status,
    required this.at,
    required this.vehicleType,
    required this.vehicleName,
    required this.vehicleRegistration,
    required this.address,
    this.provider,
    this.notes,
    this.photoCount = 0,
    this.serviceCharge = 0,
    this.convenienceFee = 0,
    this.timeline = const [],
    this.rating,
    this.feedback,
  });

  final String id;
  final ServiceType service;
  final PastStatus status;
  final DateTime at;
  final VehicleType vehicleType;
  final String vehicleName;
  final String vehicleRegistration;
  final String address;
  final ProviderInfo? provider;
  final String? notes;
  final int photoCount;
  final int serviceCharge;
  final int convenienceFee;

  /// (step, time) in order.
  final List<(String, DateTime)> timeline;
  final int? rating;
  final String? feedback;

  int get total => serviceCharge + convenienceFee;
  bool get isCompleted => status == PastStatus.completed;

  /// Service name as listed in history ("Towing Service" for towing).
  String get title => switch (service) {
    ServiceType.towing => 'Towing Service',
    ServiceType.battery => 'Dead Battery',
    _ => service.label,
  };
}

/// Newest first.
///
/// TEMPORARY: seeded with the requests from the approved design; replace
/// with the requests API.
class RequestHistoryController extends Notifier<List<PastRequest>> {
  @override
  List<PastRequest> build() {
    const p = RescueJobController.sampleProvider;
    DateTime t(int m, int d, int h, int min) => DateTime(2024, m, d, h, min);
    return [
      PastRequest(
        id: 'RR20240905',
        service: ServiceType.fuel,
        status: PastStatus.completed,
        at: t(9, 5, 9, 10),
        vehicleType: VehicleType.ev,
        vehicleName: 'Tata Nexon EV',
        vehicleRegistration: 'TN 22 XY 7890',
        address: '123, MGR Salai, Trichy, Tamil Nadu',
        provider: p,
        notes: 'Fuel delivered and vehicle started successfully.',
        photoCount: 4,
        serviceCharge: 400,
        convenienceFee: 50,
        timeline: [
          ('Request Submitted', t(9, 5, 9, 10)),
          ('Provider Assigned', t(9, 5, 9, 12)),
          ('Provider Arrived', t(9, 5, 9, 24)),
          ('Service Started', t(9, 5, 9, 26)),
          ('Service Completed', t(9, 5, 9, 41)),
        ],
        rating: 5,
        feedback: 'Quick and polite. Thank you!',
      ),
      PastRequest(
        id: 'RR20240901',
        service: ServiceType.engine,
        status: PastStatus.completed,
        at: t(9, 1, 18, 45),
        vehicleType: VehicleType.car,
        vehicleName: 'Hyundai i20',
        vehicleRegistration: 'TN 10 CD 5678',
        address: 'Thillai Nagar, Trichy, Tamil Nadu',
        provider: p,
        notes: 'Loose ignition coil connector fixed on the spot.',
        serviceCharge: 1200,
        convenienceFee: 50,
        timeline: [
          ('Request Submitted', t(9, 1, 18, 45)),
          ('Provider Assigned', t(9, 1, 18, 48)),
          ('Provider Arrived', t(9, 1, 19, 5)),
          ('Service Started', t(9, 1, 19, 7)),
          ('Service Completed', t(9, 1, 19, 40)),
        ],
        rating: 4,
      ),
      PastRequest(
        id: 'RR20240828',
        service: ServiceType.towing,
        status: PastStatus.cancelled,
        at: t(8, 28, 11, 20),
        vehicleType: VehicleType.car,
        vehicleName: 'Toyota Innova Crysta',
        vehicleRegistration: 'TN 45 AB 1234',
        address: 'Srirangam, Trichy, Tamil Nadu',
        timeline: [
          ('Request Submitted', t(8, 28, 11, 20)),
          ('Cancelled by customer', t(8, 28, 11, 26)),
        ],
      ),
      PastRequest(
        id: 'RR20240812',
        service: ServiceType.battery,
        status: PastStatus.completed,
        at: t(8, 12, 14, 15),
        vehicleType: VehicleType.car,
        vehicleName: 'Toyota Innova Crysta',
        vehicleRegistration: 'TN 45 AB 1234',
        address: 'Cantonment, Trichy, Tamil Nadu',
        provider: p,
        notes: 'Battery jump-started; advised replacement within a month.',
        photoCount: 2,
        serviceCharge: 600,
        convenienceFee: 50,
        timeline: [
          ('Request Submitted', t(8, 12, 14, 15)),
          ('Provider Assigned', t(8, 12, 14, 17)),
          ('Provider Arrived', t(8, 12, 14, 31)),
          ('Service Started', t(8, 12, 14, 32)),
          ('Service Completed', t(8, 12, 14, 50)),
        ],
        rating: 5,
      ),
    ];
  }

  void add(PastRequest request) => state = [request, ...state];

  PastRequest? byId(String id) {
    for (final r in state) {
      if (r.id == id) return r;
    }
    return null;
  }
}

final requestHistoryProvider =
    NotifierProvider<RequestHistoryController, List<PastRequest>>(
      RequestHistoryController.new,
    );
