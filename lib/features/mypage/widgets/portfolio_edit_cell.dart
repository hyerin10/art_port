import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/local_or_network_image.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:flutter/material.dart';

/// 포트폴리오 그리드 셀 — 드래그 정렬, 대표작, 삭제 오버레이
class PortfolioEditCell extends StatelessWidget {
  const PortfolioEditCell({
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
                    LocalOrNetworkImage(source: item.displaySource),
                    if (isFeatured)
                      const Positioned(
                        top: 6,
                        left: 6,
                        child: _FeaturedBadge(),
                      ),
                    if (isActive)
                      _PortfolioCellOverlay(
                        size: size,
                        source: item.displaySource,
                        index: index,
                        onSetFeatured: onSetFeatured,
                        onRemove: onRemove,
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

class _PortfolioCellOverlay extends StatelessWidget {
  const _PortfolioCellOverlay({
    required this.size,
    required this.source,
    required this.index,
    required this.onSetFeatured,
    required this.onRemove,
  });

  final double size;
  final String? source;
  final int index;
  final VoidCallback onSetFeatured;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    child: LocalOrNetworkImage(source: source),
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
