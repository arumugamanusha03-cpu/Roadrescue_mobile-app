import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Applies the screen gutter and, on tablets, centres content at a readable
/// max width. Every screen body goes through this instead of hand-rolled
/// padding so gutters stay identical across the app.
class ResponsiveBody extends StatelessWidget {
  const ResponsiveBody({
    super.key,
    required this.child,
    this.maxWidth = AppSizes.contentMaxWidth,
    this.padTop = false,
  });

  final Widget child;
  final double maxWidth;
  final bool padTop;

  /// Horizontal gutter for the given available width.
  static double gutterFor(double width) => width >= AppSizes.tabletBreakpoint
      ? AppSpacing.screenGutterWide
      : AppSpacing.screenGutter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gutter = gutterFor(constraints.maxWidth);
        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth + gutter * 2),
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                gutter,
                padTop ? AppSpacing.s16 : 0,
                gutter,
                0,
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}
