import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/session_controller.dart';
import '../../../core/theme/theme.dart';
import '../data/onboarding_content.dart';
import 'widgets/next_button.dart';
import 'widgets/onboarding_page.dart';
import 'widgets/page_indicator.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == onboardingPages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    for (final page in onboardingPages) {
      if (page.image != null) precacheImage(AssetImage(page.image!), context);
    }
  }

  // The router's redirect moves on to sign-in once onboarding is complete.
  void _finish() => ref.read(sessionProvider.notifier).completeOnboarding();

  void _next() {
    if (_isLast) return _finish();
    _controller.nextPage(
      duration: AppMotion.emphasized,
      curve: AppMotion.emphasizedCurve,
    );
  }

  @override
  Widget build(BuildContext context) {
    const controlsHeight = 72.0;
    const bottomGap = AppSpacing.s40;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsDark.background,
        body: Stack(
          children: [
            PageView.builder(
              controller: _controller,
              itemCount: onboardingPages.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => OnboardingPage(
                content: onboardingPages[i],
                // The last page's controls are taller (dots + full button).
                bottomInset: i == onboardingPages.length - 1
                    ? 12 +
                          AppSpacing.s24 +
                          AppSizes.buttonLarge +
                          bottomGap +
                          AppSpacing.s32
                    : controlsHeight + bottomGap + AppSpacing.s40,
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: AppSpacing.s12,
                    right: AppSpacing.s20,
                  ),
                  child: TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColorsDark.textPrimary,
                      textStyle: AppTypographyDark.button.copyWith(
                        fontSize: 18,
                      ),
                    ),
                    child: const Text('Skip'),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.s32,
                    0,
                    _isLast ? AppSpacing.s32 : AppSpacing.s24,
                    bottomGap,
                  ),
                  // Pages 1–3: dots left, arrow right. Final page: dots
                  // above a full-width "Get Started".
                  child: AnimatedSwitcher(
                    duration: AppMotion.standard,
                    child: _isLast
                        ? Column(
                            key: const ValueKey('last'),
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: PageIndicator(
                                  count: onboardingPages.length,
                                  index: _index,
                                ),
                              ),
                              Gap.v24,
                              OnboardingGetStartedButton(onPressed: _finish),
                            ],
                          )
                        : SizedBox(
                            key: const ValueKey('paging'),
                            height: controlsHeight,
                            child: Row(
                              children: [
                                PageIndicator(
                                  count: onboardingPages.length,
                                  index: _index,
                                ),
                                const Spacer(),
                                OnboardingNextButton(onPressed: _next),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
