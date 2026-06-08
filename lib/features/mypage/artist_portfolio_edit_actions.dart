import 'package:art_port/features/mypage/artist_portfolio_edit_providers.dart';
import 'package:art_port/features/mypage/services/profile_image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 프로필/포트폴리오 편집 화면 액션 헬퍼
abstract final class ArtistPortfolioEditActions {
  static Future<void> pickBackground(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final path = await showImageSourceBottomSheet(context);
    if (path != null && context.mounted) {
      ref.read(artistPortfolioEditProvider.notifier).setBackgroundImage(path);
    }
  }

  static Future<void> pickAvatar(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final path = await showImageSourceBottomSheet(context);
    if (path != null && context.mounted) {
      ref.read(artistPortfolioEditProvider.notifier).setAvatarImage(path);
    }
  }

  static Future<void> pickPortfolioImages(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final paths = await showPortfolioGalleryBottomSheet(context);
    if (paths.isNotEmpty && context.mounted) {
      ref.read(artistPortfolioEditProvider.notifier).addPortfolioImages(paths);
    }
  }

  static Future<void> save(BuildContext context, WidgetRef ref) async {
    FocusScope.of(context).unfocus();
    ref.read(artistPortfolioEditProvider.notifier).clearActivePortfolioIndex();

    final success =
        await ref.read(artistPortfolioEditProvider.notifier).save();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('프로필/포트폴리오가 저장되었습니다.')),
      );
    }
  }
}
