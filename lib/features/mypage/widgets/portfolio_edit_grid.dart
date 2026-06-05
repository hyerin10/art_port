import 'dart:io';

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 포트폴리오 3열 그리드 — 드래그 정렬, 대표작, 삭제 지원
class PortfolioEditGrid extends StatelessWidget {
  const PortfolioEditGrid({
    super.key,
    required this.images,
    required this.activeIndex,
    required this.onItemTap,
    required this.onSetFeatured,
    required this.onRemove,
    required this.onReorder,
    required this.onAddTap,
  });

  final List<PortfolioImageItem> images;
  final int? activeIndex;
  final ValueChanged<int> onItemTap;
  final ValueChanged<int> onSetFeatured;
  final ValueChanged<String> onRemove;
  final void Function(int from, int to) onReorder;
  final VoidCallback onAddTap;

  @override
  Widget build(BuildContext context) {
    final canAdd = images.length < ArtistPortfolioEditState.maxPortfolioCount;
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
                _PortfolioCell(
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
                _AddPortfolioCell(
                  size: cellSize,
                  onTap: onAddTap,
                ),
          ],
        );
      },
    );
  }
}

class _PortfolioCell extends StatelessWidget {
  const _PortfolioCell({
    super.key,
    required this.item,
    required this.index,
    required this.size,
    required this.isFeatured,
    required this.isActive,
    required this.onTap,
    required this.onSetFeatured,
    required this.onRemove,
    required this.onReorder,
  });

  final PortfolioImageItem item;
  final int index;
  final double size;
  final bool isFeatured;
  final bool isActive;
  final VoidCallback onTap;
  final VoidCallback onSetFeatured;
  final VoidCallback onRemove;
  final void Function(int from, int to) onReorder;

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (details) => details.data != index,
      onAcceptWithDetails: (details) => onReorder(details.data, index),
      builder: (context, candidate, rejected) {
        final isDropTarget = candidate.isNotEmpty;

        return SizedBox(
          width: size,
          height: size,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isFeatured || isDropTarget
                      ? AppColors.primary
                      : Colors.transparent,
                  width: isFeatured || isDropTarget ? 2 : 0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _PortfolioImage(source: item.displaySource),
                    if (isFeatured)
                      const Positioned(
                        top: 6,
                        left: 6,
                        child: _FeaturedBadge(),
                      ),
                    if (isActive)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _OverlayActionButton(
                                size: 32,
                                icon: Icons.star_border_rounded,
                                iconColor: const Color(0xFF3B82F6),
                                onTap: onSetFeatured,
                              ),
                              const SizedBox(width: 6),
                              _OverlayActionButton(
                                size: 32,
                                icon: Icons.close_rounded,
                                iconColor: const Color(0xFFEF4444),
                                onTap: onRemove,
                              ),
                              const SizedBox(width: 6),
                              Draggable<int>(
                                data: index,
                                feedback: Material(
                                  color: Colors.transparent,
                                  child: SizedBox(
                                    width: size * 0.85,
                                    height: size * 0.85,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: _PortfolioImage(
                                        source: item.displaySource,
                                      ),
                                    ),
                                  ),
                                ),
                                childWhenDragging: Opacity(
                                  opacity: 0.35,
                                  child: _OverlayActionButton(
                                    size: 32,
                                    icon: Icons.drag_indicator_rounded,
                                    iconColor: AppColors.textSecondary,
                                    onTap: () {},
                                  ),
                                ),
                                child: _OverlayActionButton(
                                  size: 32,
                                  icon: Icons.drag_indicator_rounded,
                                  iconColor: AppColors.textSecondary,
                                  onTap: () {},
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FeaturedBadge extends StatelessWidget {
  const _FeaturedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 12, color: Colors.white),
          SizedBox(width: 2),
          Text(
            '대표작',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _OverlayActionButton extends StatelessWidget {
  const _OverlayActionButton({
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.size = 32,
  });

  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      elevation: 2,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.55, color: iconColor),
        ),
      ),
    );
  }
}

class _AddPortfolioCell extends StatelessWidget {
  const _AddPortfolioCell({
    required this.size,
    required this.onTap,
  });

  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.primary.withValues(alpha: 0.55),
          radius: 14,
          strokeWidth: 1.5,
          dashWidth: 6,
          dashGap: 4,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                size: 28,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 4),
              Text(
                '추가',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PortfolioImage extends StatelessWidget {
  const _PortfolioImage({required this.source});

  final String? source;

  @override
  Widget build(BuildContext context) {
    if (source == null || source!.isEmpty) {
      return const ColoredBox(
        color: AppColors.chipBackground,
        child: Icon(Icons.image_outlined, color: AppColors.textMuted),
      );
    }

    final isNetwork = source!.startsWith('http');
    if (isNetwork) {
      return Image.network(
        source!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: AppColors.chipBackground,
          child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
        ),
      );
    }

    if (!kIsWeb) {
      return Image.file(
        File(source!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => const ColoredBox(
          color: AppColors.chipBackground,
          child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
        ),
      );
    }

    return const ColoredBox(
      color: AppColors.chipBackground,
      child: Icon(Icons.image_outlined, color: AppColors.textMuted),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
  });

  final Color color;
  final double radius;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        final extractPath = metric.extractPath(
          distance,
          next.clamp(0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance = next + dashGap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color ||
        radius != oldDelegate.radius ||
        strokeWidth != oldDelegate.strokeWidth;
  }
}
