import 'package:art_port/features/commission/widgets/commission_grid_card.dart';
import 'package:art_port/features/common/widgets/empty_state_view.dart';
import 'package:art_port/features/mypage/mypage_navigation.dart';
import 'package:art_port/features/mypage/widgets/liked_works_header.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:art_port/providers/liked_commissions_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 찜한 작품 목록 화면
class LikedWorksView extends ConsumerWidget {
  const LikedWorksView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedItems = ref.watch(likedCommissionsProvider);

    return MyPageSubScreenScaffold(
      header: LikedWorksHeader(
        onBack: () => Navigator.of(context).pop(),
      ),
      body: likedItems.isEmpty
          ? EmptyStateView(
              icon: Icons.favorite_border_rounded,
              title: '아직 찜한 작품이 없습니다',
              subtitle: '마음에 드는 커미션을 찾아\n여기에 저장해보세요',
              actionLabel: '작품 둘러보기',
              onAction: () => MyPageNavigation.navigateToExploreTab(context, ref),
            )
          : GridView.builder(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.62,
              ),
              itemCount: likedItems.length,
              itemBuilder: (context, index) {
                final item = likedItems[index];
                return CommissionGridCard(
                  data: CommissionCardDisplayData.fromLiked(item),
                  likeButtonStyle: CommissionLikeButtonStyle.saved,
                );
              },
            ),
    );
  }
}
