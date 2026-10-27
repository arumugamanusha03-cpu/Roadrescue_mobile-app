import 'package:flutter/widgets.dart';

/// 8-point spacing scale. These nine values are the only allowed gaps.
abstract final class AppSpacing {
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;
  static const double s48 = 48;

  // Semantic aliases. Prefer these in screens.

  /// Horizontal screen gutter on phones.
  static const double screenGutter = s20;

  /// Horizontal screen gutter at the tablet breakpoint.
  static const double screenGutterWide = s32;

  /// Internal padding for standard cards.
  static const double cardPadding = s16;

  /// Internal padding for hero/prominent cards.
  static const double cardPaddingLarge = s20;

  /// Gap between a section header and its content.
  static const double sectionHeaderGap = s12;

  /// Vertical gap between major sections of a screen.
  static const double sectionGap = s32;

  /// Gap between sibling items in a list or grid.
  static const double itemGap = s12;

  static const EdgeInsets cardInsets = EdgeInsets.all(cardPadding);
  static const EdgeInsets cardInsetsLarge = EdgeInsets.all(cardPaddingLarge);
}

/// Vertical and horizontal gaps as const widgets, so layouts read as rhythm
/// rather than as a scatter of SizedBox literals.
abstract final class Gap {
  static const SizedBox v4 = SizedBox(height: AppSpacing.s4);
  static const SizedBox v8 = SizedBox(height: AppSpacing.s8);
  static const SizedBox v12 = SizedBox(height: AppSpacing.s12);
  static const SizedBox v16 = SizedBox(height: AppSpacing.s16);
  static const SizedBox v20 = SizedBox(height: AppSpacing.s20);
  static const SizedBox v24 = SizedBox(height: AppSpacing.s24);
  static const SizedBox v32 = SizedBox(height: AppSpacing.s32);
  static const SizedBox v40 = SizedBox(height: AppSpacing.s40);
  static const SizedBox v48 = SizedBox(height: AppSpacing.s48);

  static const SizedBox h4 = SizedBox(width: AppSpacing.s4);
  static const SizedBox h8 = SizedBox(width: AppSpacing.s8);
  static const SizedBox h12 = SizedBox(width: AppSpacing.s12);
  static const SizedBox h16 = SizedBox(width: AppSpacing.s16);
  static const SizedBox h20 = SizedBox(width: AppSpacing.s20);
  static const SizedBox h24 = SizedBox(width: AppSpacing.s24);
}
