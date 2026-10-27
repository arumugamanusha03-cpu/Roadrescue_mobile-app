/// Component dimensions. Heights are minimums, not fixed heights, so
/// controls grow with the system font scale instead of clipping.
abstract final class AppSizes {
  // Icons.
  static const double iconXs = 16;
  static const double iconSm = 18;
  static const double iconMd = 20;
  static const double iconLg = 24;
  static const double iconXl = 28;

  // Buttons.
  static const double buttonLarge = 56;
  static const double buttonMedium = 48;
  static const double buttonSmall = 40;

  // Inputs.
  static const double input = 56;

  /// Material minimum touch target. Every tappable element must meet it,
  /// even when its visual is smaller.
  static const double minTouchTarget = 48;

  // Avatars.
  static const double avatarSm = 32;
  static const double avatarMd = 40;
  static const double avatarLg = 56;

  // Navigation.
  static const double bottomNavHeight = 68;
  static const double bottomNavAction = 56;
  static const double appHeaderHeight = 56;

  /// Content max width on tablets so lines and forms stay readable.
  static const double contentMaxWidth = 600;

  /// Width at which layouts switch to the tablet arrangement.
  static const double tabletBreakpoint = 600;
}
