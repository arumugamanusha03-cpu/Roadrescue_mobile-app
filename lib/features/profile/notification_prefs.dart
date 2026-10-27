import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the customer wants to be told about. Saved on the device, the same
/// way as the theme choice. Push delivery isn't set up yet; these control
/// in-app updates now and will drive push once it exists.
class NotificationPrefs {
  const NotificationPrefs({this.requestUpdates = true, this.offers = false});

  final bool requestUpdates;
  final bool offers;

  NotificationPrefs copyWith({bool? requestUpdates, bool? offers}) =>
      NotificationPrefs(
        requestUpdates: requestUpdates ?? this.requestUpdates,
        offers: offers ?? this.offers,
      );
}

class NotificationPrefsController extends Notifier<NotificationPrefs> {
  static const _requestKey = 'notif_request_updates';
  static const _offersKey = 'notif_offers';

  @override
  NotificationPrefs build() {
    _load();
    return const NotificationPrefs();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = NotificationPrefs(
        requestUpdates: p.getBool(_requestKey) ?? true,
        offers: p.getBool(_offersKey) ?? false,
      );
    } catch (_) {
      // Storage unavailable (tests, private browsing): keep defaults.
    }
  }

  Future<void> setRequestUpdates(bool on) async {
    state = state.copyWith(requestUpdates: on);
    await _save(_requestKey, on);
  }

  Future<void> setOffers(bool on) async {
    state = state.copyWith(offers: on);
    await _save(_offersKey, on);
  }

  Future<void> _save(String key, bool value) async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setBool(key, value);
    } catch (_) {}
  }
}

final notificationPrefsProvider =
    NotifierProvider<NotificationPrefsController, NotificationPrefs>(
      NotificationPrefsController.new,
    );
