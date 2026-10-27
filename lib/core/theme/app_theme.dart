import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_motion.dart';
import 'app_radius.dart';
import 'app_sizes.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

/// Built from the active [AppColors] palette (dark or light). Maps tokens onto
/// Material 3 so stock
/// widgets (dialogs, pickers, snackbars, progress) match the custom
/// components without per-screen styling.
abstract final class AppTheme {
  static ColorScheme get _colorScheme => ColorScheme(
    brightness: AppColors.current.brightness,
    primary: AppColors.primary,
    onPrimary: AppColors.onPrimary,
    primaryContainer: AppColors.surfaceElevated,
    onPrimaryContainer: AppColors.iceBlue,
    secondary: AppColors.primarySecondary,
    onSecondary: AppColors.onPrimary,
    tertiary: AppColors.iceBlue,
    onTertiary: AppColors.background,
    error: AppColors.error,
    onError: AppColors.background,
    surface: AppColors.surface,
    onSurface: AppColors.textPrimary,
    onSurfaceVariant: AppColors.textSecondary,
    surfaceContainerLowest: AppColors.background,
    surfaceContainerLow: AppColors.backgroundSecondary,
    surfaceContainer: AppColors.surface,
    surfaceContainerHigh: AppColors.surfaceElevated,
    surfaceContainerHighest: AppColors.surfaceElevated,
    outline: AppColors.divider,
    outlineVariant: AppColors.divider,
    shadow: const Color(0xFF000000),
    scrim: const Color(0xCC000000),
    inverseSurface: AppColors.textPrimary,
    onInverseSurface: AppColors.background,
    inversePrimary: AppColors.primary,
  );

  static ThemeData get current {
    final dark = AppColors.isDark;
    final iconBrightness = dark ? Brightness.light : Brightness.dark;
    final inputBorder = OutlineInputBorder(
      borderRadius: AppRadius.input,
      borderSide: BorderSide(color: AppColors.borderSubtle),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: AppColors.current.brightness,
      colorScheme: _colorScheme,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      splashFactory: InkRipple.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: AppColors.pressedOverlay,
      hoverColor: AppColors.pressedOverlay,
      focusColor: AppColors.primarySelectedFill,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      iconTheme: IconThemeData(
        color: AppColors.textSecondary,
        size: AppSizes.iconLg,
      ),
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.headingSection,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: iconBrightness,
          statusBarBrightness: dark ? Brightness.dark : Brightness.light,
          systemNavigationBarColor: AppColors.backgroundSecondary,
          systemNavigationBarIconBrightness: iconBrightness,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s16,
          vertical: AppSpacing.s16,
        ),
        hintStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
        labelStyle: AppTypography.body.copyWith(color: AppColors.textMuted),
        floatingLabelStyle: AppTypography.label.copyWith(
          color: AppColors.iceBlue,
        ),
        helperStyle: AppTypography.caption,
        errorStyle: AppTypography.caption.copyWith(color: AppColors.error),
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: inputBorder,
        enabledBorder: inputBorder,
        focusedBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: inputBorder.copyWith(
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        disabledBorder: inputBorder.copyWith(
          borderSide: BorderSide(
            color: AppColors.divider.withValues(alpha: 0.4),
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.iceBlue,
        selectionColor: AppColors.primary.withValues(alpha: 0.4),
        selectionHandleColor: AppColors.primary,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.link,
          textStyle: AppTypography.buttonSmall,
          minimumSize: const Size(
            AppSizes.minTouchTarget,
            AppSizes.minTouchTarget,
          ),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.button),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.backgroundSecondary,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: const Color(0xB3000000),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheet),
        showDragHandle: false,
        clipBehavior: Clip.antiAlias,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceElevated,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xlAll),
        titleTextStyle: AppTypography.headingSection,
        contentTextStyle: AppTypography.body,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceElevated,
        contentTextStyle: AppTypography.bodyStrong,
        actionTextColor: AppColors.link,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        insetPadding: const EdgeInsets.all(AppSpacing.s16),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.surfaceElevated,
        circularTrackColor: Colors.transparent,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.onPrimary
              : AppColors.textMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.surfaceElevated,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.divider,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(AppColors.onPrimary),
        side: BorderSide(color: AppColors.textMuted, width: 1.5),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: AppColors.divider),
        ),
        textStyle: AppTypography.label.copyWith(color: AppColors.textPrimary),
        waitDuration: AppMotion.emphasized,
      ),
    );
  }
}
