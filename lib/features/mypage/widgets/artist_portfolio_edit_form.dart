import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:art_port/features/mypage/widgets/form_section_title.dart';
import 'package:art_port/features/mypage/widgets/portfolio_edit_grid.dart';
import 'package:art_port/features/mypage/widgets/portfolio_profile_banner.dart';
import 'package:art_port/features/mypage/widgets/selectable_option_chips.dart';
import 'package:art_port/features/mypage/widgets/settings_multiline_text_field.dart';
import 'package:art_port/features/mypage/widgets/settings_text_field.dart';
import 'package:art_port/features/mypage/widgets/sns_text_field.dart';
import 'package:flutter/material.dart';

/// 프로필/포트폴리오 편집 폼 본문
class ArtistPortfolioEditForm extends StatelessWidget {
  const ArtistPortfolioEditForm({
    super.key,
    required this.form,
    required this.nicknameController,
    required this.oneLineIntroController,
    required this.detailedIntroController,
    required this.workNoticeController,
    required this.twitterController,
    required this.instagramController,
    required this.websiteController,
    required this.onBackgroundTap,
    required this.onAvatarTap,
    required this.onAddPortfolioImages,
    required this.onNicknameChanged,
    required this.onOneLineIntroChanged,
    required this.onDetailedIntroChanged,
    required this.onWorkNoticeChanged,
    required this.onTwitterChanged,
    required this.onInstagramChanged,
    required this.onWebsiteChanged,
    required this.onStyleToggle,
    required this.onToolToggle,
    required this.onPortfolioItemTap,
    required this.onSetFeatured,
    required this.onRemovePortfolioImage,
    required this.onReorderPortfolio,
  });

  final ArtistPortfolioEditState form;
  final TextEditingController nicknameController;
  final TextEditingController oneLineIntroController;
  final TextEditingController detailedIntroController;
  final TextEditingController workNoticeController;
  final TextEditingController twitterController;
  final TextEditingController instagramController;
  final TextEditingController websiteController;
  final VoidCallback onBackgroundTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onAddPortfolioImages;
  final ValueChanged<String> onNicknameChanged;
  final ValueChanged<String> onOneLineIntroChanged;
  final ValueChanged<String> onDetailedIntroChanged;
  final ValueChanged<String> onWorkNoticeChanged;
  final ValueChanged<String> onTwitterChanged;
  final ValueChanged<String> onInstagramChanged;
  final ValueChanged<String> onWebsiteChanged;
  final ValueChanged<String> onStyleToggle;
  final ValueChanged<String> onToolToggle;
  final ValueChanged<int> onPortfolioItemTap;
  final ValueChanged<int> onSetFeatured;
  final ValueChanged<String> onRemovePortfolioImage;
  final void Function(int from, int to) onReorderPortfolio;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PortfolioProfileBanner(
            backgroundLocalPath: form.backgroundLocalPath,
            backgroundNetworkUrl: form.backgroundNetworkUrl,
            avatarLocalPath: form.avatarLocalPath,
            avatarNetworkUrl: form.avatarNetworkUrl,
            onBackgroundTap: onBackgroundTap,
            onAvatarTap: onAvatarTap,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 52),
                const FormSectionTitle('기본 정보'),
                const SizedBox(height: 16),
                SettingsTextField(
                  controller: nicknameController,
                  label: '작가 닉네임',
                  onChanged: onNicknameChanged,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 20),
                SettingsTextField(
                  controller: oneLineIntroController,
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
                const SizedBox(height: 28),
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
                const SizedBox(height: 28),
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
                const SizedBox(height: 28),
                const FormSectionTitle('상세 소개글'),
                const SizedBox(height: 12),
                SettingsMultilineTextField(
                  controller: detailedIntroController,
                  maxLength: ArtistPortfolioEditState.maxDetailedIntro,
                  currentLength: form.detailedIntro.length,
                  onChanged: onDetailedIntroChanged,
                ),
                const SizedBox(height: 28),
                const FormSectionTitle('작업 공지사항'),
                const SizedBox(height: 12),
                SettingsMultilineTextField(
                  controller: workNoticeController,
                  maxLength: ArtistPortfolioEditState.maxWorkNotice,
                  currentLength: form.workNotice.length,
                  onChanged: onWorkNoticeChanged,
                  minLines: 5,
                ),
                const SizedBox(height: 28),
                const FormSectionTitle('SNS 연동'),
                const SizedBox(height: 12),
                SnsTextField(
                  controller: twitterController,
                  icon: Icons.close_rounded,
                  iconBackground: const Color(0xFF1DA1F2),
                  hintText: '@username',
                  onChanged: onTwitterChanged,
                ),
                const SizedBox(height: 10),
                SnsTextField(
                  controller: instagramController,
                  icon: Icons.camera_alt_rounded,
                  iconBackground: const Color(0xFFE1306C),
                  hintText: 'username',
                  onChanged: onInstagramChanged,
                ),
                const SizedBox(height: 10),
                SnsTextField(
                  controller: websiteController,
                  icon: Icons.language_rounded,
                  iconBackground: AppColors.primary,
                  hintText: 'https://',
                  onChanged: onWebsiteChanged,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
