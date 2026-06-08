import 'package:art_port/features/mypage/artist_portfolio_edit_controllers.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:art_port/features/mypage/widgets/form_section_title.dart';
import 'package:art_port/features/mypage/widgets/settings_multiline_text_field.dart';
import 'package:flutter/material.dart';

/// 상세 소개글 / 작업 공지사항 섹션
class ArtistPortfolioIntroSection extends StatelessWidget {
  const ArtistPortfolioIntroSection({
    super.key,
    required this.form,
    required this.controllers,
    required this.onDetailedIntroChanged,
    required this.onWorkNoticeChanged,
  });

  final ArtistPortfolioEditState form;
  final ArtistPortfolioEditControllers controllers;
  final ValueChanged<String> onDetailedIntroChanged;
  final ValueChanged<String> onWorkNoticeChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormSectionTitle('상세 소개글'),
        const SizedBox(height: 12),
        SettingsMultilineTextField(
          controller: controllers.detailedIntro,
          maxLength: ArtistPortfolioEditState.maxDetailedIntro,
          currentLength: form.detailedIntro.length,
          onChanged: onDetailedIntroChanged,
        ),
        const SizedBox(height: 28),
        const FormSectionTitle('작업 공지사항'),
        const SizedBox(height: 12),
        SettingsMultilineTextField(
          controller: controllers.workNotice,
          maxLength: ArtistPortfolioEditState.maxWorkNotice,
          currentLength: form.workNotice.length,
          onChanged: onWorkNoticeChanged,
          minLines: 5,
        ),
      ],
    );
  }
}
