import 'package:art_port/features/mypage/artist_portfolio_edit_providers.dart';
import 'package:art_port/features/mypage/models/artist_portfolio_data.dart';
import 'package:art_port/features/mypage/services/profile_image_picker.dart';
import 'package:art_port/features/mypage/widgets/artist_portfolio_edit_form.dart';
import 'package:art_port/features/mypage/widgets/artist_portfolio_edit_header.dart';
import 'package:art_port/features/mypage/widgets/mypage_save_footer_button.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
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
      child: MyPageSubScreenScaffold(
        header: ArtistPortfolioEditHeader(
          onBack: () => Navigator.of(context).pop(),
        ),
        body: ArtistPortfolioEditForm(
          form: form,
          nicknameController: _nicknameController,
          oneLineIntroController: _oneLineIntroController,
          detailedIntroController: _detailedIntroController,
          workNoticeController: _workNoticeController,
          twitterController: _twitterController,
          instagramController: _instagramController,
          websiteController: _websiteController,
          onBackgroundTap: _pickBackgroundImage,
          onAvatarTap: _pickAvatarImage,
          onAddPortfolioImages: _pickPortfolioImages,
          onNicknameChanged: notifier.updateNickname,
          onOneLineIntroChanged: notifier.updateOneLineIntro,
          onDetailedIntroChanged: notifier.updateDetailedIntro,
          onWorkNoticeChanged: notifier.updateWorkNotice,
          onTwitterChanged: notifier.updateTwitterHandle,
          onInstagramChanged: notifier.updateInstagramHandle,
          onWebsiteChanged: notifier.updateWebsiteUrl,
          onStyleToggle: notifier.toggleStyle,
          onToolToggle: notifier.toggleTool,
          onPortfolioItemTap: notifier.setActivePortfolioIndex,
          onSetFeatured: notifier.setAsFeatured,
          onRemovePortfolioImage: notifier.removePortfolioImage,
          onReorderPortfolio: notifier.reorderPortfolio,
        ),
        footer: MyPageSaveFooterButton(
          label: '저장하기',
          isSaving: form.isSaving,
          onPressed: _onSave,
        ),
      ),
    );
  }
}
