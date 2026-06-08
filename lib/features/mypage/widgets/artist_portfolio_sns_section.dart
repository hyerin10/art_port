import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/artist_portfolio_edit_controllers.dart';
import 'package:art_port/features/mypage/widgets/form_section_title.dart';
import 'package:art_port/features/mypage/widgets/sns_text_field.dart';
import 'package:flutter/material.dart';

/// SNS 연동 섹션
class ArtistPortfolioSnsSection extends StatelessWidget {
  const ArtistPortfolioSnsSection({
    super.key,
    required this.controllers,
    required this.onTwitterChanged,
    required this.onInstagramChanged,
    required this.onWebsiteChanged,
  });

  final ArtistPortfolioEditControllers controllers;
  final ValueChanged<String> onTwitterChanged;
  final ValueChanged<String> onInstagramChanged;
  final ValueChanged<String> onWebsiteChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const FormSectionTitle('SNS 연동'),
        const SizedBox(height: 12),
        SnsTextField(
          controller: controllers.twitter,
          icon: Icons.close_rounded,
          iconBackground: const Color(0xFF1DA1F2),
          hintText: '@username',
          onChanged: onTwitterChanged,
        ),
        const SizedBox(height: 10),
        SnsTextField(
          controller: controllers.instagram,
          icon: Icons.camera_alt_rounded,
          iconBackground: const Color(0xFFE1306C),
          hintText: 'username',
          onChanged: onInstagramChanged,
        ),
        const SizedBox(height: 10),
        SnsTextField(
          controller: controllers.website,
          icon: Icons.language_rounded,
          iconBackground: AppColors.primary,
          hintText: 'https://',
          onChanged: onWebsiteChanged,
        ),
      ],
    );
  }
}
