import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:art_port/features/mypage/widgets/portfolio_add_cell.dart';
import 'package:art_port/features/mypage/widgets/portfolio_edit_cell.dart';
import 'package:flutter/material.dart';

/// 포트폴리오 3열 그리드 — 드래그 정렬, 대표작, 삭제 지원
class PortfolioEditGrid extends StatelessWidget {
  const PortfolioEditGrid({
    super.key,
    required this.images,
    required this.maxCount,
    required this.activeIndex,
    required this.onItemTap,
    required this.onSetFeatured,
    required this.onRemove,
    required this.onReorder,
    required this.onAddTap,
  });

  final List<PortfolioImageItem> images;
  final int maxCount;
  final int? activeIndex;
  final ValueChanged<int> onItemTap;
  final ValueChanged<int> onSetFeatured;
  final ValueChanged<String> onRemove;
  final void Function(int from, int to) onReorder;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final canAdd = images.length < maxCount;
    final itemCount = images.length + (canAdd ? 1 : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        const columns = 3;
        final cellSize =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (var i = 0; i < itemCount; i++)
              if (i < images.length)
                PortfolioEditCell(
                  key: ValueKey(images[i].id),
                  item: images[i],
                  index: i,
                  size: cellSize,
                  isFeatured: i == 0,
                  isActive: activeIndex == i,
                  onTap: () => onItemTap(i),
                  onSetFeatured: () => onSetFeatured(i),
                  onRemove: () => onRemove(images[i].id),
                  onReorder: onReorder,
                )
              else
                PortfolioAddCell(
                  size: cellSize,
                  onTap: onAddTap,
                ),
          ],
        );
      },
    );
  }
}
