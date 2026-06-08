import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:art_port/features/mypage/widgets/form_section_title.dart';
import 'package:art_port/features/mypage/widgets/selectable_option_chips.dart';
import 'package:flutter/material.dart';

/// 주요 스타일 / 사용 툴 선택 섹션
class ArtistPortfolioStyleToolSection extends StatelessWidget {
  const ArtistPortfolioStyleToolSection({
    super.key,
    required this.form,
    required this.onStyleToggle,
    required this.onToolToggle,
  });

  final ArtistPortfolioEditState form;
  final ValueChanged<String> onStyleToggle;
  final ValueChanged<String> onToolToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormSectionTitle('주요 스타일'),
        const SizedBox(height: 12),
        SelectableOptionChips(
          options: ArtistPortfolioEditState.styleOptions,
          selected: form.selectedStyles,
          onToggle: onStyleToggle,
        ),
        const SizedBox(height: 28),
        const FormSectionTitle('사용 툴'),
        const SizedBox(height: 12),
        SelectableOptionChips(
          options: ArtistPortfolioEditState.toolOptions,
          selected: form.selectedTools,
          onToggle: onToolToggle,
        ),
      ],
    );
  }
}
