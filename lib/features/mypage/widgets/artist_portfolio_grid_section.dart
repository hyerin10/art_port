import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:art_port/features/mypage/widgets/form_section_title.dart';
import 'package:art_port/features/mypage/widgets/portfolio_edit_grid.dart';
import 'package:flutter/material.dart';

/// 포트폴리오 이미지 그리드 섹션
class ArtistPortfolioGridSection extends StatelessWidget {
  const ArtistPortfolioGridSection({
    super.key,
    required this.form,
    required this.onAddPortfolioImages,
    required this.onPortfolioItemTap,
    required this.onSetFeatured,
    required this.onRemovePortfolioImage,
    required this.onReorderPortfolio,
  });

  final ArtistPortfolioEditState form;
  final VoidCallback onAddPortfolioImages;
  final ValueChanged<int> onPortfolioItemTap;
  final ValueChanged<int> onSetFeatured;
  final ValueChanged<String> onRemovePortfolioImage;
  final void Function(int from, int to) onReorderPortfolio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: FormSectionTitle('포트폴리오')),
            Text(
              '${form.portfolioImages.length}/${ArtistPortfolioEditState.maxPortfolioCount}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PortfolioEditGrid(
          images: form.portfolioImages,
          maxCount: ArtistPortfolioEditState.maxPortfolioCount,
          activeIndex: form.activePortfolioIndex,
          onItemTap: onPortfolioItemTap,
          onSetFeatured: onSetFeatured,
          onRemove: onRemovePortfolioImage,
          onReorder: onReorderPortfolio,
          onAddTap: onAddPortfolioImages,
        ),
        const SizedBox(height: 10),
        const Text(
          '첫 번째 이미지가 대표작으로 표시됩니다. 드래그하여 순서를 변경할 수 있습니다.',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
