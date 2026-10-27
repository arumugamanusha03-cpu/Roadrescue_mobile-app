import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/services/theme_controller.dart';
import 'core/theme/theme.dart';

class RoadRescueApp extends ConsumerStatefulWidget {
  const RoadRescueApp({super.key});

  @override
  ConsumerState<RoadRescueApp> createState() => _RoadRescueAppState();
}

class _RoadRescueAppState extends ConsumerState<RoadRescueApp>
    with WidgetsBindingObserver {
  /// Element under MaterialApp, used to refresh every widget on a theme
  /// switch (colours are read from [AppColors], not inherited).
  BuildContext? _appContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// "System" follows the phone's dark-mode switch while the app is open.
  @override
  void didChangePlatformBrightness() {
    if (ref.read(themeModeProvider) == ThemeMode.system) setState(() {});
  }

  AppPalette _paletteFor(ThemeMode mode) {
    final brightness = switch (mode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system =>
        WidgetsBinding.instance.platformDispatcher.platformBrightness,
    };
    return brightness == Brightness.light ? AppPalette.light : AppPalette.dark;
  }

  void _rebuildEverything() {
    final root = _appContext;
    if (root == null || !root.mounted) return;
    void mark(Element e) {
      e.markNeedsBuild();
      e.visitChildren(mark);
    }

    (root as Element).visitChildren(mark);
  }

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(ref.watch(themeModeProvider));
    if (!identical(palette, AppColors.current)) {
      AppColors.current = palette;
      // Many widgets are const and don't depend on Theme; refresh them all
      // once the new theme is in place. State (forms, scroll, routes) is kept.
      WidgetsBinding.instance.addPostFrameCallback((_) => _rebuildEverything());
    }
    final theme = AppTheme.current;

    return MaterialApp.router(
      title: 'RoadRescue',
      debugShowCheckedModeBanner: false,
      theme: theme,
      darkTheme: theme,
      themeMode: palette.isDark ? ThemeMode.dark : ThemeMode.light,
      routerConfig: ref.watch(routerProvider),
      builder: (context, child) {
        _appContext = context;
        // Respect the user's font size, but cap extreme scales where fixed
        // chrome (bottom bar, chips) would stop being usable.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(maxScaleFactor: 1.6),
          ),
          child: child!,
        );
      },
    );
  }
}
