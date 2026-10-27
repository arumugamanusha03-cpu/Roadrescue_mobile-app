import 'package:flutter/material.dart';

import '../../../../core/theme/theme.dart';
import '../../data/onboarding_content.dart';

/// Full-bleed photo with a navy scrim rising from the bottom, headline and
/// description anchored above the controls.
class OnboardingPage extends StatelessWidget {
  const OnboardingPage({
    super.key,
    required this.content,
    required this.bottomInset,
  });

  final OnboardingContent content;

  /// Space reserved at the bottom for the indicator and next button.
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (content.image != null)
          Image.asset(
            content.image!,
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            excludeFromSemantics: true,
          )
        else
          ColoredBox(color: AppColorsDark.backgroundSecondary),
        // Light at the top for the status bar and Skip, heavy at the bottom
        // where the copy sits.
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0, 0.18, 0.5, 0.72, 1],
              colors: [
                Color(0x99010B17),
                Color(0x00010B17),
                Color(0x00010B17),
                Color(0xD9010B17),
                Color(0xFF010B17),
              ],
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.s32,
              0,
              AppSpacing.s32,
              bottomInset,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text.rich(
                    TextSpan(
                      text: content.highlight.isEmpty
                          ? content.headline
                          : '${content.headline}\n',
                      children: [
                        if (content.highlight.isNotEmpty)
                          TextSpan(
                            text: content.highlight,
                            style: TextStyle(color: AppColorsDark.brandCyan),
                          ),
                      ],
                    ),
                    style: AppTypographyDark.display.copyWith(
                      fontSize: 38,
                      height: 1.12,
                    ),
                  ),
                ),
                Gap.v20,
                Text(
                  content.description,
                  style: AppTypographyDark.bodyLarge.copyWith(
                    fontSize: 17,
                    color: AppColorsDark.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
