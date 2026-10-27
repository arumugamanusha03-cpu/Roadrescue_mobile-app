/// Lifecycle of an assistance request, shared by customer, provider and admin.
enum RequestStatus {
  searching(label: 'Finding provider'),
  accepted(label: 'Accepted'),
  onTheWay(label: 'On the way'),
  arrived(label: 'Arrived'),
  inProgress(label: 'Service started'),
  completed(label: 'Completed'),
  cancelled(label: 'Cancelled');

  const RequestStatus({required this.label});

  final String label;

  bool get isActive => this != completed && this != cancelled;

  /// The forward path a provider moves a job through.
  static const List<RequestStatus> providerProgression = [
    accepted,
    onTheWay,
    arrived,
    inProgress,
    completed,
  ];
}
