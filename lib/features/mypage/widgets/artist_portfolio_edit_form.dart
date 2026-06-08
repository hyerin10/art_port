import 'package:art_port/features/mypage/artist_portfolio_edit_controllers.dart';
import 'package:art_port/features/mypage/artist_portfolio_edit_providers.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:art_port/features/mypage/widgets/artist_portfolio_basic_info_section.dart';
import 'package:art_port/features/mypage/widgets/artist_portfolio_grid_section.dart';
import 'package:art_port/features/mypage/widgets/artist_portfolio_intro_section.dart';
import 'package:art_port/features/mypage/widgets/artist_portfolio_sns_section.dart';
import 'package:art_port/features/mypage/widgets/artist_portfolio_style_tool_section.dart';
import 'package:art_port/features/mypage/widgets/portfolio_profile_banner.dart';
import 'package:flutter/material.dart';

/// 프로필/포트폴리오 편집 폼 본문
class ArtistPortfolioEditForm extends StatelessWidget {
  const ArtistPortfolioEditForm({
    super.key,
    required this.form,
    required this.controllers,
    required this.notifier,
    required this.onBackgroundTap,
    required this.onAvatarTap,
    required this.onAddPortfolioImages,
  });

  final ArtistPortfolioEditState form;
  final ArtistPortfolioEditControllers controllers;
  final ArtistPortfolioEditNotifier notifier;
  final VoidCallback onBackgroundTap;
  final VoidCallback onAvatarTap;
  final VoidCallback onAddPortfolioImages;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: notifier.clearActivePortfolioIndex,
      behavior: HitTestBehavior.translucent,
      child: SingleChildScrollView(
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
                  ArtistPortfolioBasicInfoSection(
                    form: form,
                    controllers: controllers,
                    onNicknameChanged: notifier.updateNickname,
                    onOneLineIntroChanged: notifier.updateOneLineIntro,
                  ),
                  const SizedBox(height: 28),
                  ArtistPortfolioGridSection(
                    form: form,
                    onAddPortfolioImages: onAddPortfolioImages,
                    onPortfolioItemTap: notifier.setActivePortfolioIndex,
                    onSetFeatured: notifier.setAsFeatured,
                    onRemovePortfolioImage: notifier.removePortfolioImage,
                    onReorderPortfolio: notifier.reorderPortfolio,
                  ),
                  const SizedBox(height: 28),
                  ArtistPortfolioStyleToolSection(
                    form: form,
                    onStyleToggle: notifier.toggleStyle,
                    onToolToggle: notifier.toggleTool,
                  ),
                  const SizedBox(height: 28),
                  ArtistPortfolioIntroSection(
                    form: form,
                    controllers: controllers,
                    onDetailedIntroChanged: notifier.updateDetailedIntro,
                    onWorkNoticeChanged: notifier.updateWorkNotice,
                  ),
                  const SizedBox(height: 28),
                  ArtistPortfolioSnsSection(
                    controllers: controllers,
                    onTwitterChanged: notifier.updateTwitterHandle,
                    onInstagramChanged: notifier.updateInstagramHandle,
                    onWebsiteChanged: notifier.updateWebsiteUrl,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
