import 'package:flutter/material.dart';

import 'app_colors.dart';

/// The type scale for one palette. Inter is bundled in assets/fonts.
///
/// Weight discipline: 700 for display/headings only, 600 for titles and
/// buttons, 500 for emphasis inside body copy, 400 for everything else.
class TypeScale {
  const TypeScale(this.p);

  final AppPalette p;

  static const String fontFamily = 'Inter';

  /// 34 / 700 — onboarding headlines, invoice total.
  TextStyle get display => TextStyle(
    fontFamily: fontFamily,
    fontSize: 34,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
    color: p.textPrimary,
  );

  /// 28 / 700 — screen titles, home hero headline.
  TextStyle get headingLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    color: p.textPrimary,
  );

  /// 20 / 600 — section headings.
  TextStyle get headingSection => TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: p.textPrimary,
  );

  /// 16 / 600 — card titles, list item titles.
  TextStyle get cardTitle => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.35,
    fontWeight: FontWeight.w600,
    color: p.textPrimary,
  );

  /// 16 / 400 — lead/supporting copy under headlines.
  TextStyle get bodyLarge => TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: p.textSecondary,
  );

  /// 14 / 400 — default body copy.
  TextStyle get body => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w400,
    color: p.textSecondary,
  );

  /// 14 / 500 — emphasised values inside body (ETA, price, plate number).
  TextStyle get bodyStrong => TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w500,
    color: p.textPrimary,
  );

  /// 12 / 400 — metadata, timestamps, helper text.
  TextStyle get caption => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.4,
    fontWeight: FontWeight.w400,
    color: p.textMuted,
  );

  /// 12 / 500 — field labels, chip labels, nav labels.
  TextStyle get label => TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    color: p.textSecondary,
  );

  /// 16 / 600 — large and medium buttons.
  TextStyle get button => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// 14 / 600 — small buttons and text links.
  TextStyle get buttonSmall => const TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  /// Material [TextTheme] mapping so stock widgets pick up the scale.
  TextTheme get textTheme => TextTheme(
    displayLarge: display,
    displayMedium: display,
    displaySmall: display,
    headlineLarge: headingLarge,
    headlineMedium: headingLarge,
    headlineSmall: headingSection,
    titleLarge: headingSection,
    titleMedium: cardTitle,
    titleSmall: bodyStrong,
    bodyLarge: bodyLarge,
    bodyMedium: body,
    bodySmall: caption,
    labelLarge: button,
    labelMedium: label,
    labelSmall: caption,
  );
}

/// Type scale of the active theme.
abstract final class AppTypography {
  static const String fontFamily = TypeScale.fontFamily;
  static TypeScale get _t => TypeScale(AppColors.current);

  static TextStyle get display => _t.display;
  static TextStyle get headingLarge => _t.headingLarge;
  static TextStyle get headingSection => _t.headingSection;
  static TextStyle get cardTitle => _t.cardTitle;
  static TextStyle get bodyLarge => _t.bodyLarge;
  static TextStyle get body => _t.body;
  static TextStyle get bodyStrong => _t.bodyStrong;
  static TextStyle get caption => _t.caption;
  static TextStyle get label => _t.label;
  static TextStyle get button => _t.button;
  static TextStyle get buttonSmall => _t.buttonSmall;
  static TextTheme get textTheme => _t.textTheme;
}

/// Fixed dark type scale for screens over photography.
abstract final class AppTypographyDark {
  static const _t = TypeScale(AppPalette.dark);

  static TextStyle get display => _t.display;
  static TextStyle get headingLarge => _t.headingLarge;
  static TextStyle get headingSection => _t.headingSection;
  static TextStyle get cardTitle => _t.cardTitle;
  static TextStyle get bodyLarge => _t.bodyLarge;
  static TextStyle get body => _t.body;
  static TextStyle get bodyStrong => _t.bodyStrong;
  static TextStyle get caption => _t.caption;
  static TextStyle get label => _t.label;
  static TextStyle get button => _t.button;
  static TextStyle get buttonSmall => _t.buttonSmall;
}
