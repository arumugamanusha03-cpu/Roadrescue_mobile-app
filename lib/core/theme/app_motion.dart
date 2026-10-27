import 'package:flutter/animation.dart';

/// Motion is short and functional. Nothing loops except loading indicators.
abstract final class AppMotion {
  /// Press feedback, colour/border changes on selection.
  static const Duration fast = Duration(milliseconds: 120);

  /// Default for state changes (chips, cards expanding, status updates).
  static const Duration standard = Duration(milliseconds: 220);

  /// Page transitions, sheets, onboarding pages.
  static const Duration emphasized = Duration(milliseconds: 320);

  /// Map marker interpolation between location updates.
  static const Duration markerMove = Duration(milliseconds: 900);

  static const Curve standardCurve = Curves.easeOutCubic;
  static const Curve emphasizedCurve = Curves.easeInOutCubicEmphasized;

  /// Scale applied to buttons and cards while pressed.
  static const double pressedScale = 0.98;
}
