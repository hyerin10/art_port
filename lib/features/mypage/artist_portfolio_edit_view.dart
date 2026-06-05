import 'dart:io';

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/features/mypage/artist_portfolio_edit_providers.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/mypage/services/profile_image_picker.dart';
import 'package:art_port/features/mypage/widgets/artist_portfolio_edit_header.dart';
import 'package:art_port/features/mypage/widgets/portfolio_edit_grid.dart';
import 'package:art_port/features/mypage/widgets/settings_text_field.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtistPortfolioEditView extends ConsumerStatefulWidget {
  const ArtistPortfolioEditView({super.key});

  @override
  ConsumerState<ArtistPortfolioEditView> createState() =>
      _ArtistPortfolioEditViewState();
}

class _ArtistPortfolioEditViewState
    extends ConsumerState<ArtistPortfolioEditView> {
  final _nicknameController = TextEditingController();
  final _oneLineIntroController = TextEditingController();
  final _detailedIntroController = TextEditingController();
  final _workNoticeController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _websiteController = TextEditingController();
  var _initialized = false;

  @override
  void dispose() {
    _nicknameController.dispose();
    _oneLineIntroController.dispose();
    _detailedIntroController.dispose();
    _workNoticeController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _websiteController.dispose();
    super.dispose();
  }

  void _syncControllers(ArtistPortfolioEditState form) {
    if (!_initialized) {
      _nicknameController.text = form.nickname;
      _oneLineIntroController.text = form.oneLineIntro;
      _detailedIntroController.text = form.detailedIntro;
      _workNoticeController.text = form.workNotice;
      _twitterController.text = form.twitterHandle;
      _instagramController.text = form.instagramHandle;
      _websiteController.text = form.websiteUrl;
      _initialized = true;
    }
  }

  Future<void> _pickBackgroundImage() async {
    final path = await showImageSourceBottomSheet(context);
    if (path != null && mounted) {
      ref.read(artistPortfolioEditProvider.notifier).setBackgroundImage(path);
    }
  }

  Future<void> _pickAvatarImage() async {
    final path = await showImageSourceBottomSheet(context);
    if (path != null && mounted) {
      ref.read(artistPortfolioEditProvider.notifier).setAvatarImage(path);
    }
  }

  Future<void> _pickPortfolioImages() async {
    final paths = await showPortfolioGalleryBottomSheet(context);
    if (paths.isNotEmpty && mounted) {
      ref.read(artistPortfolioEditProvider.notifier).addPortfolioImages(paths);
    }
  }

  Future<void> _onSave() async {
    FocusScope.of(context).unfocus();
    ref.read(artistPortfolioEditProvider.notifier).clearActivePortfolioIndex();

    final success =
        await ref.read(artistPortfolioEditProvider.notifier).save();

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필/포트폴리오가 저장되었습니다.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(artistPortfolioEditProvider);
    final notifier = ref.read(artistPortfolioEditProvider.notifier);
    _syncControllers(form);

    return GestureDetector(
      onTap: notifier.clearActivePortfolioIndex,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            ArtistPortfolioEditHeader(
              onBack: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _ProfileBannerSection(
                      backgroundLocalPath: form.backgroundLocalPath,
                      backgroundNetworkUrl: form.backgroundNetworkUrl,
                      avatarLocalPath: form.avatarLocalPath,
                      avatarNetworkUrl: form.avatarNetworkUrl,
                      onBackgroundTap: _pickBackgroundImage,
                      onAvatarTap: _pickAvatarImage,
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 52),
                          const _SectionTitle('기본 정보'),
                          const SizedBox(height: 16),
                          SettingsTextField(
                            controller: _nicknameController,
                            label: '작가 닉네임',
                            onChanged: notifier.updateNickname,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: 20),
                          SettingsTextField(
                            controller: _oneLineIntroController,
                            label: '한 줄 소개',
                            onChanged: notifier.updateOneLineIntro,
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
                              const Expanded(
                                child: _SectionTitle('포트폴리오'),
                              ),
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
                            onItemTap: notifier.setActivePortfolioIndex,
                            onSetFeatured: notifier.setAsFeatured,
                            onRemove: notifier.removePortfolioImage,
                            onReorder: notifier.reorderPortfolio,
                            onAddTap: _pickPortfolioImages,
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
                          const _SectionTitle('주요 스타일'),
                          const SizedBox(height: 12),
                          _SelectableChips(
                            options: ArtistPortfolioEditState.styleOptions,
                            selected: form.selectedStyles,
                            onToggle: notifier.toggleStyle,
                          ),
                          const SizedBox(height: 28),
                          const _SectionTitle('사용 툴'),
                          const SizedBox(height: 12),
                          _SelectableChips(
                            options: ArtistPortfolioEditState.toolOptions,
                            selected: form.selectedTools,
                            onToggle: notifier.toggleTool,
                          ),
                          const SizedBox(height: 28),
                          const _SectionTitle('상세 소개글'),
                          const SizedBox(height: 12),
                          _MultilineTextField(
                            controller: _detailedIntroController,
                            maxLength: ArtistPortfolioEditState.maxDetailedIntro,
                            currentLength: form.detailedIntro.length,
                            onChanged: notifier.updateDetailedIntro,
                          ),
                          const SizedBox(height: 28),
                          const _SectionTitle('작업 공지사항'),
                          const SizedBox(height: 12),
                          _MultilineTextField(
                            controller: _workNoticeController,
                            maxLength: ArtistPortfolioEditState.maxWorkNotice,
                            currentLength: form.workNotice.length,
                            onChanged: notifier.updateWorkNotice,
                            minLines: 5,
                          ),
                          const SizedBox(height: 28),
                          const _SectionTitle('SNS 연동'),
                          const SizedBox(height: 12),
                          _SnsTextField(
                            controller: _twitterController,
                            icon: Icons.close_rounded,
                            iconBackground: const Color(0xFF1DA1F2),
                            hintText: '@username',
                            onChanged: notifier.updateTwitterHandle,
                          ),
                          const SizedBox(height: 10),
                          _SnsTextField(
                            controller: _instagramController,
                            icon: Icons.camera_alt_rounded,
                            iconBackground: const Color(0xFFE1306C),
                            hintText: 'username',
                            onChanged: notifier.updateInstagramHandle,
                          ),
                          const SizedBox(height: 10),
                          _SnsTextField(
                            controller: _websiteController,
                            icon: Icons.language_rounded,
                            iconBackground: AppColors.primary,
                            hintText: 'https://',
                            onChanged: notifier.updateWebsiteUrl,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: form.isSaving ? null : _onSave,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: form.isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            '저장하기',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: ArtPortBottomNav(
          onTabSelected: (index) {
            ref.read(showMyPageProvider.notifier).close();
            ref.read(currentTabProvider.notifier).selectTab(index);
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
    );
  }
}

class _ProfileBannerSection extends StatelessWidget {
  const _ProfileBannerSection({
    required this.backgroundLocalPath,
    required this.backgroundNetworkUrl,
    required this.avatarLocalPath,
    required this.avatarNetworkUrl,
    required this.onBackgroundTap,
    required this.onAvatarTap,
  });

  final String? backgroundLocalPath;
  final String? backgroundNetworkUrl;
  final String? avatarLocalPath;
  final String? avatarNetworkUrl;
  final VoidCallback onBackgroundTap;
  final VoidCallback onAvatarTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onBackgroundTap,
              child: _ProfileImage(
                localPath: backgroundLocalPath,
                networkUrl: backgroundNetworkUrl,
                fit: BoxFit.cover,
                placeholder: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE9E4FF),
                        Color(0xFFD4CBFF),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.photo_camera_outlined,
                          size: 20,
                          color: AppColors.primary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '배경 이미지 변경',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 20,
            bottom: -36,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: _ProfileImage(
                      localPath: avatarLocalPath,
                      networkUrl: avatarNetworkUrl,
                      fit: BoxFit.cover,
                      placeholder: const ColoredBox(
                        color: AppColors.chipBackground,
                        child: Icon(
                          Icons.person_rounded,
                          size: 40,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Material(
                    color: AppColors.primary,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onAvatarTap,
                      child: const SizedBox(
                        width: 32,
                        height: 32,
                        child: Icon(
                          Icons.photo_camera_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileImage extends StatelessWidget {
  const _ProfileImage({
    required this.localPath,
    required this.networkUrl,
    required this.fit,
    required this.placeholder,
  });

  final String? localPath;
  final String? networkUrl;
  final BoxFit fit;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    final source = localPath ?? networkUrl;
    if (source == null || source.isEmpty) return placeholder;

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    if (!kIsWeb) {
      return Image.file(
        File(source),
        fit: fit,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    return placeholder;
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
      ),
    );
  }
}

class _SelectableChips extends StatelessWidget {
  const _SelectableChips({
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  final List<String> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          FilterChip(
            label: Text(option),
            selected: selected.contains(option),
            onSelected: (_) => onToggle(option),
            showCheckmark: false,
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected.contains(option)
                  ? Colors.white
                  : AppColors.textPrimary,
            ),
            backgroundColor: AppColors.background,
            selectedColor: AppColors.primary,
            side: BorderSide(
              color: selected.contains(option)
                  ? AppColors.primary
                  : AppColors.borderLight,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          ),
      ],
    );
  }
}

class _MultilineTextField extends StatelessWidget {
  const _MultilineTextField({
    required this.controller,
    required this.maxLength,
    required this.currentLength,
    required this.onChanged,
    this.minLines = 4,
  });

  final TextEditingController controller;
  final int maxLength;
  final int currentLength;
  final ValueChanged<String> onChanged;
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          onChanged: onChanged,
          minLines: minLines,
          maxLines: null,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
            height: 1.5,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.chipBackground,
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '$currentLength/$maxLength',
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

class _SnsTextField extends StatelessWidget {
  const _SnsTextField({
    required this.controller,
    required this.icon,
    required this.iconBackground,
    required this.hintText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final IconData icon;
  final Color iconBackground;
  final String hintText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: 12, right: 8),
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: Colors.white),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 52, minHeight: 32),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }
}
