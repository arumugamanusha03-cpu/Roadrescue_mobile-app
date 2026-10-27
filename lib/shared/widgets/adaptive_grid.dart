import 'package:flutter/material.dart';

import '../../core/theme/theme.dart';

/// Non-scrolling grid whose column count follows the available width and
/// whose rows share the height of their tallest tile. Use it inside scroll
/// views where GridView's fixed aspect ratio would clip text at large font
/// scales (service selection, quick actions, admin stat cards).
class AdaptiveGrid extends StatelessWidget {
  const AdaptiveGrid({
    super.key,
    required this.children,
    this.minTileWidth = 150,
    this.maxColumns = 4,
    this.spacing = AppSpacing.itemGap,
  });

  final List<Widget> children;
  final double minTileWidth;
  final int maxColumns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = ((width + spacing) / (minTileWidth + spacing))
            .floor()
            .clamp(1, maxColumns);

        final rows = <Widget>[];
        for (var start = 0; start < children.length; start += columns) {
          final rowChildren = <Widget>[];
          for (var i = 0; i < columns; i++) {
            if (i > 0) rowChildren.add(SizedBox(width: spacing));
            final index = start + i;
            rowChildren.add(
              Expanded(
                child: index < children.length
                    ? children[index]
                    : const SizedBox.shrink(),
              ),
            );
          }
          if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: rowChildren,
              ),
            ),
          );
        }

        return Column(mainAxisSize: MainAxisSize.min, children: rows);
      },
    );
  }
}
