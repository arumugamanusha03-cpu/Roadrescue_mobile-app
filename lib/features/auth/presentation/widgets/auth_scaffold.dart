import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/theme.dart';

/// Shared frame for sign-in and sign-up: night photo with a navy wash,
/// centred logo, title + subtitle, then the form. Scrolls when the keyboard
/// is open or the font is large.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColorsDark.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Photo sits in the top part; the wash fades it into navy where
            // the form lives so fields stay readable.
            Image.asset(
              AppAssets.authBackground,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              excludeFromSemantics: true,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0, 0.3, 0.55, 0.75],
                  colors: [
                    Color(0x8C010B17),
                    Color(0x66010B17),
                    Color(0xD9010B17),
                    Color(0xFF010B17),
                  ],
                ),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.s24,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 440),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(
                              height: AppSizes.minTouchTarget,
                              child: onBack == null
                                  ? null
                                  : Align(
                                      alignment: Alignment.centerLeft,
                                      child: IconButton(
                                        onPressed: onBack,
                                        tooltip: 'Back',
                                        icon: Icon(
                                          AppIcons.back,
                                          size: AppSizes.iconXl,
                                          color: AppColorsDark.textPrimary,
                                        ),
                                      ),
                                    ),
                            ),
                            Center(
                              child: Image.asset(
                                AppAssets.logo,
                                height: 150,
                                semanticLabel: 'RoadRescue',
                              ),
                            ),
                            Gap.v40,
                            Semantics(
                              header: true,
                              child: Text(
                                title,
                                style: AppTypographyDark.headingLarge,
                              ),
                            ),
                            Gap.v8,
                            Text(
                              subtitle,
                              style: AppTypographyDark.bodyLarge.copyWith(
                                color: AppColorsDark.textSecondary,
                              ),
                            ),
                            Gap.v24,
                            ...children,
                            Gap.v24,
                          ],
                        ),
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
