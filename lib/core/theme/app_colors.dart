import 'package:flutter/services.dart';

/// One complete set of RoadRescue colours. [dark] is the original locked
/// palette; [light] follows the approved light-theme reference.
///
/// Usage rules (both palettes):
/// - Blue is the only brand/action colour.
/// - [success] is reserved for completed/positive outcomes.
/// - [error] is reserved for emergency, destructive and error states.
/// - [warning] is a status colour only, never a brand accent.
class AppPalette {
  const AppPalette({
    required this.brightness,
    required this.background,
    required this.backgroundSecondary,
    required this.surface,
    required this.surfaceElevated,
    required this.primary,
    required this.primarySecondary,
    required this.iceBlue,
    required this.interactionBlue,
    required this.brandCyan,
    required this.brandGradientStart,
    required this.brandGradientEnd,
    required this.authGradientStart,
    required this.authGradientEnd,
    required this.onAuthGradient,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.divider,
    required this.success,
    required this.warning,
    required this.error,
  });

  final Brightness brightness;
  final Color background;
  final Color backgroundSecondary;
  final Color surface;
  final Color surfaceElevated;
  final Color primary;
  final Color primarySecondary;
  final Color iceBlue;
  final Color interactionBlue;

  /// Accent for brand moments (highlight words, selected tabs, icons).
  final Color brandCyan;
  final Color brandGradientStart;
  final Color brandGradientEnd;
  final Color authGradientStart;
  final Color authGradientEnd;
  final Color onAuthGradient;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color divider;
  final Color success;
  final Color warning;
  final Color error;

  bool get isDark => brightness == Brightness.dark;

  static const dark = AppPalette(
    brightness: Brightness.dark,
    background: Color(0xFF07131F),
    backgroundSecondary: Color(0xFF0B1724),
    surface: Color(0xFF102231),
    surfaceElevated: Color(0xFF152A3B),
    primary: Color(0xFF536DFE),
    primarySecondary: Color(0xFF6F8FFF),
    iceBlue: Color(0xFF9BB7FF),
    interactionBlue: Color(0xFFBFD6FF),
    brandCyan: Color(0xFF00C2FF),
    brandGradientStart: Color(0xFF00B5FC),
    brandGradientEnd: Color(0xFF0073FE),
    authGradientStart: Color(0xFF4FD8FF),
    authGradientEnd: Color(0xFF0A84FF),
    onAuthGradient: Color(0xFF06121F),
    textPrimary: Color(0xFFF4F7FF),
    textSecondary: Color(0xFFC2CFDC),
    textMuted: Color(0xFF8FA6B8),
    divider: Color(0xFF233747),
    success: Color(0xFF35D0A0),
    warning: Color(0xFFF2B84B),
    error: Color(0xFFFF5C6C),
  );

  /// Light reference: cool off-white page, white cards, deep navy text and
  /// a stronger blue so accents keep contrast on white.
  static const light = AppPalette(
    brightness: Brightness.light,
    background: Color(0xFFF3F6FB),
    backgroundSecondary: Color(0xFFFFFFFF),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFEDF2FA),
    primary: Color(0xFF1E6BFF),
    primarySecondary: Color(0xFF4C8DFF),
    iceBlue: Color(0xFF1557D6),
    interactionBlue: Color(0xFF0F4FC4),
    brandCyan: Color(0xFF1667F2),
    brandGradientStart: Color(0xFF2F80FF),
    brandGradientEnd: Color(0xFF1A5FE8),
    authGradientStart: Color(0xFF2F80FF),
    authGradientEnd: Color(0xFF1A5FE8),
    onAuthGradient: Color(0xFFFFFFFF),
    textPrimary: Color(0xFF0B1B33),
    textSecondary: Color(0xFF44566C),
    textMuted: Color(0xFF6B7C91),
    divider: Color(0xFFDCE4EE),
    success: Color(0xFF12A672),
    warning: Color(0xFFC98A12),
    error: Color(0xFFE5384A),
  );
}

/// Colours of the active theme. Screens read these; the app swaps
/// [current] when the theme changes and rebuilds the tree.
abstract final class AppColors {
  static AppPalette current = AppPalette.dark;

  static bool get isDark => current.isDark;

  static Color get background => current.background;
  static Color get backgroundSecondary => current.backgroundSecondary;
  static Color get surface => current.surface;
  static Color get surfaceElevated => current.surfaceElevated;
  static Color get primary => current.primary;
  static Color get primarySecondary => current.primarySecondary;
  static Color get iceBlue => current.iceBlue;
  static Color get interactionBlue => current.interactionBlue;
  static Color get brandCyan => current.brandCyan;
  static Color get brandGradientStart => current.brandGradientStart;
  static Color get brandGradientEnd => current.brandGradientEnd;
  static Color get authGradientStart => current.authGradientStart;
  static Color get authGradientEnd => current.authGradientEnd;
  static Color get onAuthGradient => current.onAuthGradient;
  static Color get textPrimary => current.textPrimary;
  static Color get textSecondary => current.textSecondary;
  static Color get textMuted => current.textMuted;
  static Color get divider => current.divider;
  static Color get success => current.success;
  static Color get warning => current.warning;
  static Color get error => current.error;

  /// Text/icon colour on [primary] fills.
  static Color get onPrimary => const Color(0xFFFFFFFF);

  /// Inline text links and tappable text.
  static Color get link => current.iceBlue;

  // Derived tints. Kept here so screens never invent their own alphas.
  static Color get primarySelectedFill =>
      primary.withValues(alpha: isDark ? 0.16 : 0.10);
  static Color get pressedOverlay =>
      (isDark ? interactionBlue : primary).withValues(alpha: 0.08);
  static Color get borderSubtle =>
      isDark ? divider.withValues(alpha: 0.72) : divider;
  static Color get borderGlass => textPrimary.withValues(alpha: 0.10);
  static Color get glassFill => surface.withValues(alpha: isDark ? 0.72 : 0.88);
  static Color get successFill => success.withValues(alpha: 0.14);
  static Color get warningFill => warning.withValues(alpha: 0.14);
  static Color get errorFill => error.withValues(alpha: isDark ? 0.14 : 0.10);

  /// Status bar icons that read on the page background.
  static SystemUiOverlayStyle get overlayStyle =>
      isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark;

  /// Bottom-up scrim for text set over photography (always dark).
  static List<Color> get imageScrim => const [
    Color(0x0007131F),
    Color(0x9907131F),
    Color(0xF207131F),
  ];
}

/// Fixed dark colours for screens drawn over photography (splash,
/// onboarding, sign-in) — they stay dark in both themes.
abstract final class AppColorsDark {
  static const _p = AppPalette.dark;

  static Color get background => _p.background;
  static Color get backgroundSecondary => _p.backgroundSecondary;
  static Color get surface => _p.surface;
  static Color get surfaceElevated => _p.surfaceElevated;
  static Color get primary => _p.primary;
  static Color get iceBlue => _p.iceBlue;
  static Color get brandCyan => _p.brandCyan;
  static Color get brandGradientStart => _p.brandGradientStart;
  static Color get brandGradientEnd => _p.brandGradientEnd;
  static Color get authGradientStart => _p.authGradientStart;
  static Color get authGradientEnd => _p.authGradientEnd;
  static Color get onAuthGradient => _p.onAuthGradient;
  static Color get textPrimary => _p.textPrimary;
  static Color get textSecondary => _p.textSecondary;
  static Color get textMuted => _p.textMuted;
  static Color get divider => _p.divider;
  static Color get error => _p.error;
  static Color get onPrimary => const Color(0xFFFFFFFF);
  static Color get link => _p.iceBlue;
  static Color get primarySelectedFill => _p.primary.withValues(alpha: 0.16);
}
