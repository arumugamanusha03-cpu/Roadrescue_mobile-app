import 'package:flutter/widgets.dart';

/// Radius communicates hierarchy: the more prominent the container, the
/// larger the radius. Interactive controls sit at [md].
abstract final class AppRadius {
  static const double sm = 8; // chips inside cards, thumbnails, map pins
  static const double md = 12; // buttons, inputs, small cards
  static const double lg = 16; // standard cards, list groups
  static const double xl = 20; // prominent cards (active request)
  static const double xxl = 24; // hero imagery, bottom sheets
  static const double pill = 999; // status chips, nav indicator

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));

  static const BorderRadius button = mdAll;
  static const BorderRadius input = mdAll;
  static const BorderRadius card = lgAll;
  static const BorderRadius cardProminent = xlAll;
  static const BorderRadius hero = xxlAll;
  static const BorderRadius sheet = BorderRadius.vertical(
    top: Radius.circular(xxl),
  );
}
