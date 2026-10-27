/// Every bundled image path, so screens never hard-code asset strings.
abstract final class AppAssets {
  static const splash = 'assets/images/splash.png';

  /// Transparent R mark + wordmark, cut from the splash artwork. Designed
  /// for dark backgrounds only.
  static const logo = 'assets/images/logo.png';

  /// "RoadRescue" text only, for compact headers (home top bar).
  static const logoWordmark = 'assets/images/logo_wordmark.png';

  /// Home hero and the add-vehicle card. Reusing onboarding photos until
  /// dedicated home photography is supplied (drop it in assets/images/home/).
  static const homeHero = 'assets/images/onboarding/onboarding_1.png';
  static const homePromo = 'assets/images/onboarding/onboarding_4.png';

  /// Background photo for sign-in / sign-up. Temporarily the first
  /// onboarding photo until the dedicated auth photo is supplied.
  static const authBackground = 'assets/images/onboarding/onboarding_1.png';
}
