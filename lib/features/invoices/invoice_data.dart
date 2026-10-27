import '../../core/constants/service_type.dart';
import '../tracking/request_history.dart';
import '../tracking/rescue_job.dart';

/// Everything printed on an invoice, from either the live job or a past
/// request.
class InvoiceData {
  const InvoiceData({
    required this.requestId,
    required this.issuedAt,
    required this.service,
    required this.vehicle,
    required this.address,
    required this.serviceCharge,
    required this.convenienceFee,
    required this.paid,
    this.providerName,
    this.providerVehicle,
    this.customerName,
  });

  final String requestId;
  final DateTime issuedAt;
  final ServiceType service;
  final String vehicle;
  final String address;
  final int serviceCharge;
  final int convenienceFee;
  final bool paid;
  final String? providerName;
  final String? providerVehicle;
  final String? customerName;

  int get total => serviceCharge + convenienceFee;

  /// Every invoice is generated from local sample/simulated data until the
  /// billing backend exists, so this is always true for now and printed on
  /// the PDF.
  bool get isDemo => true;

  String get fileName => 'RoadRescue-Invoice-$requestId.pdf';

  factory InvoiceData.fromJob(RescueJob job, {String? customerName}) =>
      InvoiceData(
        requestId: job.requestId,
        issuedAt: job.completedAt ?? DateTime.now(),
        service: job.service,
        vehicle: [
          job.vehicleName,
          job.vehicleRegistration,
        ].where((s) => s.isNotEmpty).join(' • '),
        address: job.address,
        serviceCharge: job.serviceCharge,
        convenienceFee: job.convenienceFee,
        paid: job.stage == RescueStage.paid,
        providerName: job.provider?.name,
        providerVehicle: job.provider?.vehicleLine,
        customerName: customerName,
      );

  factory InvoiceData.fromPast(PastRequest r, {String? customerName}) =>
      InvoiceData(
        requestId: r.id,
        issuedAt: r.timeline.isEmpty ? r.at : r.timeline.last.$2,
        service: r.service,
        vehicle: '${r.vehicleName} • ${r.vehicleRegistration}',
        address: r.address,
        serviceCharge: r.serviceCharge,
        convenienceFee: r.convenienceFee,
        paid: r.isCompleted,
        providerName: r.provider?.name,
        providerVehicle: r.provider?.vehicleLine,
        customerName: customerName,
      );
}
