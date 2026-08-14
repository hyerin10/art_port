import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/mypage/data/mypage_write_providers.dart';
import 'package:art_port/features/mypage/mypage_navigation.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/mypage/widgets/menu_list_item.dart';
import 'package:art_port/features/mypage/widgets/mypage_profile_section.dart';
import 'package:art_port/features/mypage/widgets/mypage_scroll_view.dart';
import 'package:art_port/features/mypage/widgets/sales_statistics_card.dart';
import 'package:art_port/features/mypage/widgets/section_card.dart';
import 'package:art_port/features/mypage/widgets/withdrawable_earnings_card.dart';
import 'package:art_port/features/review/data/review_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtistMyPageContent extends ConsumerWidget {
  const ArtistMyPageContent({super.key});

  static const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(artistProfileProvider);
    final liveProfile = ref.watch(myArtistProfileProvider).valueOrNull;
    final earnings = ref.watch(artistEarningsProvider);
    final isRestMode = ref.watch(restModeProvider);
    final actions = ref.watch(artistMyPageActionsProvider);
    final userId = ref.watch(currentUserIdProvider);
    final reviewStats = userId == null
        ? null
        : ref.watch(artistReviewStatsProvider(userId)).valueOrNull;
    final ratingLabel = reviewStats == null
        ? null
        : '⭐ ${reviewStats.averageLabel} (리뷰 ${reviewStats.count}개)';

    ref.listen(myArtistProfileProvider, (previous, next) {
      final dto = next.value;
      if (dto == null) return;
      ref.read(restModeProvider.notifier).sync(dto.isRestMode);
    });

    return MyPageScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyPageProfileSection(
            avatarUrl: liveProfile?.avatarUrl ?? profile.avatarUrl,
            onEditPhoto: () => AppToast.show(
              ScaffoldMessenger.of(context),
              message: '이미지 업로드는 아직 지원되지 않습니다.',
            ),
            name: liveProfile?.displayName ?? profile.name,
            onOpenSettings: () => MyPageNavigation.openProfileSettings(context),
            subtitle: ratingLabel ??
                '⭐ ${profile.rating.toStringAsFixed(2)}',
            subtitleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          SectionCard(
            title: '내 커미션 관리',
            children: [
              MenuListItem(
                label: '프로필 / 포트폴리오 편집',
                icon: Icons.palette_rounded,
                iconBackgroundColor: AppColors.primaryLight,
                iconColor: AppColors.primary,
                onTap: () => actions.onEditProfilePortfolio(context),
              ),
              MenuListItem(
                label: '커미션 타입 설정',
                icon: Icons.tune_rounded,
                iconBackgroundColor: AppColors.chipBackground,
                iconColor: AppColors.textSecondary,
                onTap: () => actions.onCommissionTypeSettings(context),
              ),
              MenuListItem(
                label: '공지사항 설정',
                icon: Icons.campaign_rounded,
                iconBackgroundColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFF97316),
                onTap: () => actions.onNoticeSettings(context),
              ),
              MenuListItem(
                label: '받은 리뷰',
                icon: Icons.star_rounded,
                iconBackgroundColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                onTap: () => actions.onReceivedReviews(context),
              ),
              MenuListItem(
                label: '결제 내역 관리',
                icon: Icons.account_balance_wallet_outlined,
                iconBackgroundColor: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF10B981),
                onTap: () => actions.onPaymentsAndReceipts(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: '수익 및 정산',
            children: [
              WithdrawableEarningsCard(
                amount: earnings.withdrawableAmount,
                onRequestWithdrawal: () => actions.onRequestWithdrawal(context),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: MenuListItem(
                  label: '정산 계좌 관리',
                  icon: Icons.account_balance_rounded,
                  iconBackgroundColor: const Color(0xFFD1FAE5),
                  iconColor: const Color(0xFF10B981),
                  onTap: () => actions.onSettlementAccount(context),
                ),
              ),
              const SizedBox(height: 12),
              SalesStatisticsCard(
                dailySales: earnings.dailySales,
                weeklyTotal: earnings.weeklySalesTotal,
                weekdayLabels: _weekdayLabels,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: '상태 설정',
            children: [
              MenuListItem(
                label: '휴식 모드',
                icon: Icons.nightlight_round,
                iconBackgroundColor: AppColors.primaryLight,
                iconColor: AppColors.primary,
                onTap: null,
                trailing: Switch.adaptive(
                  value: isRestMode,
                  activeTrackColor: AppColors.primaryLight,
                  activeThumbColor: AppColors.primary,
                  onChanged: (value) async {
                    final ok = await ref
                        .read(restModeProvider.notifier)
                        .toggle(value);
                    if (!ok && context.mounted) {
                      AppToast.show(
                        ScaffoldMessenger.of(context),
                        message: '휴식 모드를 변경하지 못했습니다.',
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
