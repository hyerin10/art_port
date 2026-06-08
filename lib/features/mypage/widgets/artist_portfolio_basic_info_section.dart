import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/artist_portfolio_edit_controllers.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:art_port/features/mypage/widgets/form_section_title.dart';
import 'package:art_port/features/mypage/widgets/settings_text_field.dart';
import 'package:flutter/material.dart';

/// 기본 정보 섹션 — 닉네임, 한 줄 소개
class ArtistPortfolioBasicInfoSection extends StatelessWidget {
  const ArtistPortfolioBasicInfoSection({
    super.key,
    required this.form,
    required this.controllers,
    required this.onNicknameChanged,
    required this.onOneLineIntroChanged,
  });

  final ArtistPortfolioEditState form;
  final ArtistPortfolioEditControllers controllers;
  final ValueChanged<String> onNicknameChanged;
  final ValueChanged<String> onOneLineIntroChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormSectionTitle('기본 정보'),
        const SizedBox(height: 16),
        SettingsTextField(
          controller: controllers.nickname,
          label: '작가 닉네임',
          onChanged: onNicknameChanged,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 20),
        SettingsTextField(
          controller: controllers.oneLineIntro,
          label: '한 줄 소개',
          onChanged: onOneLineIntroChanged,
          textInputAction: TextInputAction.next,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${form.oneLineIntro.length}/${ArtistPortfolioEditState.maxOneLineIntro}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
