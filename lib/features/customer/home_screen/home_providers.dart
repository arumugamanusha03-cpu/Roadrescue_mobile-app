import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_request.dart';

/// The customer's live request, or null when there isn't one. Set by the
/// request confirmation screen.
///
/// TEMPORARY in-memory state; replace with a repository stream once the
/// requests API exists (that's also what will assign a provider).
class ActiveRequestController extends Notifier<ActiveRequest?> {
  @override
  ActiveRequest? build() => null;

  void start(ActiveRequest request) => state = request;

  void clear() => state = null;
}

final activeRequestProvider =
    NotifierProvider<ActiveRequestController, ActiveRequest?>(
      ActiveRequestController.new,
    );

/// "Good morning / afternoon / evening" for the given time.
String greetingFor(DateTime now) => switch (now.hour) {
  < 12 => 'Good morning',
  < 17 => 'Good afternoon',
  _ => 'Good evening',
};
