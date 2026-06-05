import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 포트폴리오 탭 — 3열 정방형 이미지 그리드
class ArtistPortfolioTab extends StatelessWidget {
  const ArtistPortfolioTab({super.key, required this.imageUrls});

  final List<String> imageUrls;

  @override
  Widget build(BuildContext context) {
    if (imageUrls.isEmpty) {
      return const Center(
        child: Text(
          '등록된 포트폴리오가 없습니다.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 4.0;
        const columns = 3;
        final cellSize =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            childAspectRatio: 1,
          ),
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Image.network(
                imageUrls[index],
                width: cellSize,
                height: cellSize,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const ColoredBox(
                  color: AppColors.chipBackground,
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
