import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/request_status.dart';
import '../../core/constants/service_type.dart';
import '../../core/constants/vehicle_type.dart';
import '../customer/home_screen/active_request.dart';
import '../customer/home_screen/home_providers.dart';
import 'live_tracking_screen/route_simulation.dart';
import 'request_history.dart';

/// Where the customer's rescue is, end to end.
enum RescueStage {
  submitted,
  searching,
  assigned,
  onTheWay,
  arrived,
  inProgress,
  completed,
  paid,
}

class ProviderInfo {
  const ProviderInfo({
    required this.name,
    required this.rating,
    required this.reviews,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.experience,
    required this.totalServices,
    required this.phone,
  });

  final String name;
  final double rating;
  final int reviews;
  final String vehicleType;
  final String vehicleNumber;
  final String experience;
  final String totalServices;
  final String phone;

  String get vehicleLine => '$vehicleType • $vehicleNumber';
}

/// One rescue job as the customer sees it.
class RescueJob {
  const RescueJob({
    required this.requestId,
    required this.service,
    required this.address,
    required this.customerLocation,
    required this.stage,
    required this.createdAt,
    this.vehicleType = VehicleType.car,
    this.vehicleName = '',
    this.vehicleRegistration = '',
    this.notes = '',
    this.photoCount = 0,
    this.voiceNotePath,
    this.provider,
    this.providerLocation,
    this.route = const [],
    this.progress = 0,
    this.etaMinutes,
    this.assignedAt,
    this.arrivedAt,
    this.startedAt,
    this.completedAt,
    this.serviceCharge = 600,
    this.convenienceFee = 50,
  });

  final String requestId;
  final ServiceType service;
  final String address;
  final LatLng customerLocation;
  final RescueStage stage;
  final DateTime createdAt;
  final VehicleType vehicleType;
  final String vehicleName;
  final String vehicleRegistration;
  final String notes;
  final int photoCount;

  /// Local recording only; uploaded once Storage is connected.
  final String? voiceNotePath;
  final ProviderInfo? provider;
  final LatLng? providerLocation;

  /// The provider's whole planned route; [progress] (0 → 1) is how far along.
  final List<LatLng> route;
  final double progress;
  final int? etaMinutes;
  final DateTime? assignedAt;
  final DateTime? arrivedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final int serviceCharge;
  final int convenienceFee;

  int get total => serviceCharge + convenienceFee;

  bool get providerMoving =>
      stage == RescueStage.assigned || stage == RescueStage.onTheWay;

  Duration? get serviceDuration => startedAt == null || completedAt == null
      ? null
      : completedAt!.difference(startedAt!);

  /// What's left of the route, for drawing.
  List<LatLng> get remainingRoute {
    if (route.length < 2 || !providerMoving) return const [];
    return RouteSimulation.fromPoints(route).remainingFrom(progress);
  }

  RescueJob copyWith({
    RescueStage? stage,
    ProviderInfo? provider,
    LatLng? providerLocation,
    List<LatLng>? route,
    double? progress,
    int? etaMinutes,
    DateTime? assignedAt,
    DateTime? arrivedAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) => RescueJob(
    requestId: requestId,
    service: service,
    address: address,
    customerLocation: customerLocation,
    createdAt: createdAt,
    vehicleType: vehicleType,
    vehicleName: vehicleName,
    vehicleRegistration: vehicleRegistration,
    notes: notes,
    photoCount: photoCount,
    voiceNotePath: voiceNotePath,
    stage: stage ?? this.stage,
    provider: provider ?? this.provider,
    providerLocation: providerLocation ?? this.providerLocation,
    route: route ?? this.route,
    progress: progress ?? this.progress,
    etaMinutes: etaMinutes ?? this.etaMinutes,
    assignedAt: assignedAt ?? this.assignedAt,
    arrivedAt: arrivedAt ?? this.arrivedAt,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    serviceCharge: serviceCharge,
    convenienceFee: convenienceFee,
  );
}

/// Drives the rescue journey.
///
/// TEMPORARY: there is no backend yet, so provider matching, the drive
/// (a timer walking [RouteSimulation]) and the service are simulated.
/// When the API lands, these become reactions to server events; screens
/// keep the same calls.
class RescueJobController extends Notifier<RescueJob?> {
  /// Sample provider shown until matching comes from the server.
  static const sampleProvider = ProviderInfo(
    name: 'Rajesh Kumar',
    rating: 4.8,
    reviews: 325,
    vehicleType: 'Towing Van',
    vehicleNumber: 'TN 09 AB 5678',
    experience: '5+ Years',
    totalServices: '1,200+',
    phone: '+919876543210',
  );

  static const tick = Duration(seconds: 1);

  Timer? _drive;

  @override
  RescueJob? build() {
    ref.onDispose(() => _drive?.cancel());
    return null;
  }

  void submit({
    required ServiceType service,
    required String address,
    required LatLng location,
    VehicleType vehicleType = VehicleType.car,
    String vehicleName = '',
    String vehicleRegistration = '',
    String notes = '',
    int photoCount = 0,
    String? voiceNotePath,
  }) {
    _drive?.cancel();
    final now = DateTime.now();
    final id =
        'RR${now.year}${_two(now.month)}${_two(now.day)}${_two(now.second)}';
    state = RescueJob(
      requestId: id,
      service: service,
      address: address,
      customerLocation: location,
      stage: RescueStage.submitted,
      createdAt: now,
      vehicleType: vehicleType,
      vehicleName: vehicleName,
      vehicleRegistration: vehicleRegistration,
      notes: notes,
      photoCount: photoCount,
      voiceNotePath: voiceNotePath,
    );
    _syncHome();
  }

  void startSearching() => _set(RescueStage.searching);

  /// Assigns the sample provider and starts the simulated drive.
  void assignProvider() {
    final job = state;
    if (job == null) return;
    // Start about 2 km north-east of the customer.
    final start = LatLng(
      job.customerLocation.latitude + 0.014,
      job.customerLocation.longitude + 0.012,
    );
    final sim = RouteSimulation(from: start, to: job.customerLocation);
    state = job.copyWith(
      stage: RescueStage.assigned,
      provider: sampleProvider,
      etaMinutes: RouteSimulation.startEtaMinutes,
      providerLocation: start,
      route: sim.points,
      progress: 0,
      assignedAt: DateTime.now(),
    );
    _syncHome();

    _drive?.cancel();
    final steps = RouteSimulation.duration.inMilliseconds / tick.inMilliseconds;
    _drive = Timer.periodic(tick, (t) {
      final current = state;
      if (current == null || !current.providerMoving) return t.cancel();
      final progress = (current.progress + 1 / steps).clamp(0.0, 1.0);
      if (progress >= 1) {
        t.cancel();
        return markArrived();
      }
      state = current.copyWith(
        stage: RescueStage.onTheWay,
        progress: progress,
        providerLocation: sim.at(progress),
        etaMinutes: RouteSimulation.etaFor(progress),
      );
      _syncHome();
    });
  }

  void markArrived() {
    final job = state;
    if (job == null) return;
    _drive?.cancel();
    state = job.copyWith(
      stage: RescueStage.arrived,
      providerLocation: job.customerLocation,
      progress: 1,
      etaMinutes: 0,
      arrivedAt: DateTime.now(),
    );
    _syncHome();
  }

  void startService() {
    final job = state;
    if (job == null) return;
    state = job.copyWith(
      stage: RescueStage.inProgress,
      startedAt: DateTime.now(),
    );
    _syncHome();
  }

  void completeService() {
    final job = state;
    if (job == null) return;
    state = job.copyWith(
      stage: RescueStage.completed,
      completedAt: DateTime.now(),
    );
    _syncHome();
  }

  void markPaid() => _set(RescueStage.paid);

  /// Rating submitted or skipped: the journey is over and goes to history.
  void finish({int? rating, String? feedback}) {
    final job = state;
    if (job != null) {
      ref
          .read(requestHistoryProvider.notifier)
          .add(
            PastRequest(
              id: job.requestId,
              service: job.service,
              status: PastStatus.completed,
              at: job.createdAt,
              vehicleType: job.vehicleType,
              vehicleName: job.vehicleName,
              vehicleRegistration: job.vehicleRegistration,
              address: job.address,
              provider: job.provider,
              notes: job.notes.isEmpty ? null : job.notes,
              photoCount: job.photoCount,
              serviceCharge: job.serviceCharge,
              convenienceFee: job.convenienceFee,
              timeline: [
                ('Request Submitted', job.createdAt),
                if (job.assignedAt != null)
                  ('Provider Assigned', job.assignedAt!),
                if (job.arrivedAt != null) ('Provider Arrived', job.arrivedAt!),
                if (job.startedAt != null) ('Service Started', job.startedAt!),
                if (job.completedAt != null)
                  ('Service Completed', job.completedAt!),
              ],
              rating: rating,
              feedback: feedback == null || feedback.trim().isEmpty
                  ? null
                  : feedback.trim(),
            ),
          );
    }
    _drive?.cancel();
    state = null;
    ref.read(activeRequestProvider.notifier).clear();
  }

  void _set(RescueStage stage) {
    final job = state;
    if (job == null) return;
    state = job.copyWith(stage: stage);
    _syncHome();
  }

  /// Keeps the home screen's active request card in step.
  void _syncHome() {
    final job = state;
    if (job == null) return;
    final home = ref.read(activeRequestProvider.notifier);
    if (job.stage == RescueStage.paid) return home.clear();
    home.start(
      ActiveRequest(
        id: job.requestId,
        serviceType: job.service,
        status: statusFor(job.stage),
        providerName: job.provider?.name,
        providerRating: job.provider?.rating,
        providerReviews: job.provider?.reviews,
        etaMinutes: job.stage == RescueStage.onTheWay ? job.etaMinutes : null,
      ),
    );
  }

  static RequestStatus statusFor(RescueStage stage) => switch (stage) {
    RescueStage.submitted || RescueStage.searching => RequestStatus.searching,
    RescueStage.assigned => RequestStatus.accepted,
    RescueStage.onTheWay => RequestStatus.onTheWay,
    RescueStage.arrived => RequestStatus.arrived,
    RescueStage.inProgress => RequestStatus.inProgress,
    RescueStage.completed || RescueStage.paid => RequestStatus.completed,
  };

  static String _two(int v) => v.toString().padLeft(2, '0');
}

final rescueJobProvider = NotifierProvider<RescueJobController, RescueJob?>(
  RescueJobController.new,
);
