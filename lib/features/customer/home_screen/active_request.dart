import '../../../core/constants/request_status.dart';
import '../../../core/constants/service_type.dart';

/// What the home screen needs to show about the customer's live request.
class ActiveRequest {
  const ActiveRequest({
    required this.id,
    required this.serviceType,
    required this.status,
    this.providerName,
    this.providerRating,
    this.providerReviews,
    this.etaMinutes,
  });

  final String id;
  final ServiceType serviceType;
  final RequestStatus status;

  /// Null while [RequestStatus.searching]: no provider has accepted yet.
  final String? providerName;
  final double? providerRating;
  final int? providerReviews;
  final int? etaMinutes;

  bool get hasProvider => providerName != null;
}
