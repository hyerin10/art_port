import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/mypage/artist_portfolio_edit_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 프로필/포트폴리오 편집 화면 액션 헬퍼
abstract final class ArtistPortfolioEditActions {
  static Future<void> pickBackground(
    BuildContext context,
    WidgetRef ref,
  ) async {
    AppToast.show(
      ScaffoldMessenger.of(context),
      message: '이미지 업로드는 아직 지원되지 않습니다.',
    );
  }

  static Future<void> pickAvatar(
    BuildContext context,
    WidgetRef ref,
  ) async {
    AppToast.show(
      ScaffoldMessenger.of(context),
      message: '이미지 업로드는 아직 지원되지 않습니다.',
    );
  }

  static Future<void> pickPortfolioImages(
    BuildContext context,
    WidgetRef ref,
  ) async {
    AppToast.show(
      ScaffoldMessenger.of(context),
      message: '이미지 업로드는 아직 지원되지 않습니다.',
    );
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
    } else {
      final error = ref.read(artistPortfolioEditProvider).saveError;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: error ?? '저장에 실패했습니다. 다시 시도해 주세요.',
      );
    }
  }
}
