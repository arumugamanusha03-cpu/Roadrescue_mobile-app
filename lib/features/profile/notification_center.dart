import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../tracking/rescue_job.dart';
import 'notification_prefs.dart';

/// One in-app update shown on the Notifications screen.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.at,
    this.requestId,
    this.read = false,
  });

  final String id;
  final String title;
  final String body;
  final DateTime at;
  final String? requestId;
  final bool read;

  AppNotification markRead() => AppNotification(
    id: id,
    title: title,
    body: body,
    at: at,
    requestId: requestId,
    read: true,
  );
}

/// In-app updates generated on this device from the customer's request
/// progress (newest first). Kept in memory for the session.
///
/// Not push notifications: those need Firebase Cloud Messaging, which isn't
/// set up yet.
class NotificationCenter extends Notifier<List<AppNotification>> {
  @override
  List<AppNotification> build() {
    ref.listen(rescueJobProvider.select((j) => j?.stage), (prev, next) {
      final job = ref.read(rescueJobProvider);
      if (job == null || next == null || prev == next) return;
      if (!ref.read(notificationPrefsProvider).requestUpdates) return;
      final message = messageFor(job);
      if (message == null) return;
      final (title, body) = message;
      add(title, body, requestId: job.requestId);
    });
    return const [];
  }

  /// Wording per stage; null for stages that don't need an update.
  static (String, String)? messageFor(RescueJob job) => switch (job.stage) {
    RescueStage.submitted => (
      'Request submitted',
      'We’re finding a verified provider for your ${job.service.label.toLowerCase()}.',
    ),
    RescueStage.assigned => (
      'Provider assigned',
      '${job.provider?.name ?? 'A provider'} accepted your request.',
    ),
    RescueStage.arrived => (
      'Provider arrived',
      '${job.provider?.name ?? 'Your provider'} is at your location.',
    ),
    RescueStage.inProgress => (
      'Service started',
      'Work on your vehicle has begun.',
    ),
    RescueStage.completed => (
      'Service completed',
      'Your invoice is ready to view.',
    ),
    _ => null,
  };

  void add(String title, String body, {String? requestId}) {
    final now = DateTime.now();
    state = [
      AppNotification(
        id: '${now.microsecondsSinceEpoch}',
        title: title,
        body: body,
        at: now,
        requestId: requestId,
      ),
      ...state,
    ];
  }

  void markRead(String id) =>
      state = [for (final n in state) n.id == id ? n.markRead() : n];

  void markAllRead() => state = [for (final n in state) n.markRead()];

  void clear() => state = const [];
}

final notificationCenterProvider =
    NotifierProvider<NotificationCenter, List<AppNotification>>(
      NotificationCenter.new,
    );

final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(notificationCenterProvider).where((n) => !n.read).length,
);
