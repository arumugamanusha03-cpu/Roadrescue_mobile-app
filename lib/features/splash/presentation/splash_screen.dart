import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/app_routes.dart';
import '../../../core/theme/theme.dart';

/// Brand splash. Shows the approved artwork edge to edge, then hands off to
/// the router, whose redirect decides onboarding / sign-in / home.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  /// Edge colour of the artwork; also the native Android launch colour, so
  /// the hand-off from the OS splash is seamless.
  static const Color background = Color(0xFF000D20);

  static const Duration hold = Duration(milliseconds: 2200);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late final Timer _timer = Timer(
    SplashScreen.hold,
    () => context.go(AppRoutes.onboarding),
  );

  @override
  void initState() {
    super.initState();
    _timer; // start
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage(_asset), context);
  }

  static const _asset = 'assets/images/splash.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SplashScreen.background,
      body: Semantics(
        label: 'RoadRescue',
        image: true,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: AppMotion.emphasized,
          curve: AppMotion.standardCurve,
          builder: (context, t, child) => Opacity(opacity: t, child: child),
          // Cover keeps the logo centred and uncropped on every phone
          // aspect ratio; only the empty navy margins are trimmed.
          child: const SizedBox.expand(
            child: Image(
              image: AssetImage(_asset),
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }
}
