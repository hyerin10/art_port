import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/mypage/profile_settings_screen.dart';
import 'package:art_port/features/mypage/widgets/menu_list_item.dart';
import 'package:art_port/features/mypage/widgets/section_card.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 마이페이지 메인 뷰 — Client / Artist 모드에 따라 UI 분기
class MyPageView extends ConsumerWidget {
  const MyPageView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArtistMode = ref.watch(appModeProvider);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: isArtistMode
          ? const _ArtistMyPageContent(key: ValueKey('artist'))
          : const _ClientMyPageContent(key: ValueKey('client')),
    );
  }

  static String formatCurrency(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return '₩ ${buffer.toString()}';
  }
}

// ─── Client Mode ────────────────────────────────────────────────────────────

class _ClientMyPageContent extends ConsumerWidget {
  const _ClientMyPageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(clientProfileProvider);
    final actions = ref.watch(clientMyPageActionsProvider);
    final profileNotifier = ref.read(clientProfileProvider.notifier);

    void openSettings() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const ProfileSettingsScreen(),
        ),
      );
    }

    return _MyPageScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileSection(
            avatarUrl: profile.avatarUrl,
            onEditPhoto: profileNotifier.onEditProfilePhoto,
            name: profile.name,
            onOpenSettings: openSettings,
            subtitle: profile.email,
            subtitleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),
          SectionCard(
            title: '나의 활동',
            children: [
              MenuListItem(
                label: '찜한 작품',
                icon: Icons.favorite_rounded,
                iconBackgroundColor: const Color(0xFFFEE2E2),
                iconColor: const Color(0xFFEF4444),
                onTap: () => actions.onLikedWorks(context),
              ),
              MenuListItem(
                label: '팔로우한 작가',
                icon: Icons.person_rounded,
                iconBackgroundColor: AppColors.primaryLight,
                iconColor: AppColors.primary,
                onTap: () => actions.onFollowedArtists(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: '결제 및 증빙',
            children: [
              MenuListItem(
                label: '영수증',
                icon: Icons.receipt_long_rounded,
                iconBackgroundColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFF97316),
                onTap: actions.onReceipts,
              ),
              MenuListItem(
                label: '결제 관리',
                icon: Icons.credit_card_rounded,
                iconBackgroundColor: const Color(0xFFDBEAFE),
                iconColor: const Color(0xFF3B82F6),
                onTap: actions.onPaymentManagement,
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: '고객 지원',
            children: [
              MenuListItem(
                label: '1:1 문의',
                icon: Icons.chat_bubble_rounded,
                iconBackgroundColor: const Color(0xFFD1FAE5),
                iconColor: const Color(0xFF10B981),
                onTap: actions.onInquiry,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Artist Mode ────────────────────────────────────────────────────────────

class _ArtistMyPageContent extends ConsumerWidget {
  const _ArtistMyPageContent({super.key});

  static const _weekdayLabels = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(artistProfileProvider);
    final earnings = ref.watch(artistEarningsProvider);
    final isRestMode = ref.watch(restModeProvider);
    final actions = ref.watch(artistMyPageActionsProvider);
    final profileNotifier = ref.read(artistProfileProvider.notifier);

    void openSettings() {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => const ProfileSettingsScreen(),
        ),
      );
    }

    return _MyPageScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _ProfileSection(
            avatarUrl: profile.avatarUrl,
            onEditPhoto: profileNotifier.onEditProfilePhoto,
            name: profile.name,
            onOpenSettings: openSettings,
            subtitle:
                '⭐ ${profile.rating} (리뷰 ${profile.reviewCount}개)',
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
                onTap: actions.onEditProfilePortfolio,
              ),
              MenuListItem(
                label: '커미션 타입 설정',
                icon: Icons.tune_rounded,
                iconBackgroundColor: AppColors.chipBackground,
                iconColor: AppColors.textSecondary,
                onTap: actions.onCommissionTypeSettings,
              ),
              MenuListItem(
                label: '공지사항 설정',
                icon: Icons.campaign_rounded,
                iconBackgroundColor: const Color(0xFFFFEDD5),
                iconColor: const Color(0xFFF97316),
                onTap: actions.onNoticeSettings,
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 10),
            child: Text(
              '수익 및 정산',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          _WithdrawableEarningsCard(
            amount: earnings.withdrawableAmount,
            onRequestWithdrawal: actions.onRequestWithdrawal,
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
              onTap: actions.onSettlementAccount,
            ),
          ),
          const SizedBox(height: 12),
          _SalesStatisticsCard(
            dailySales: earnings.dailySales,
            weeklyTotal: earnings.weeklySalesTotal,
            weekdayLabels: _weekdayLabels,
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
                  onChanged: (value) =>
                      ref.read(restModeProvider.notifier).toggle(value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared Widgets ─────────────────────────────────────────────────────────

class _MyPageScrollView extends StatelessWidget {
  const _MyPageScrollView({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const _MyPageScrollBehavior(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: child,
      ),
    );
  }
}

class _MyPageScrollBehavior extends ScrollBehavior {
  const _MyPageScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.avatarUrl,
    required this.onEditPhoto,
    required this.name,
    required this.onOpenSettings,
    required this.subtitle,
    required this.subtitleStyle,
  });

  final String avatarUrl;
  final VoidCallback onEditPhoto;
  final String name;
  final VoidCallback onOpenSettings;
  final String subtitle;
  final TextStyle subtitleStyle;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderLight, width: 3),
              ),
              child: CircleAvatar(
                radius: 52,
                backgroundColor: AppColors.chipBackground,
                backgroundImage: NetworkImage(avatarUrl),
              ),
            ),
            Positioned(
              right: 4,
              bottom: 4,
              child: GestureDetector(
                onTap: onEditPhoto,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: onOpenSettings,
              child: const Icon(
                Icons.settings_outlined,
                size: 20,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: subtitleStyle),
      ],
    );
  }
}

class _WithdrawableEarningsCard extends StatelessWidget {
  const _WithdrawableEarningsCard({
    required this.amount,
    required this.onRequestWithdrawal,
  });

  final int amount;
  final VoidCallback onRequestWithdrawal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  '출금 가능한 수익금',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Material(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
                child: InkWell(
                  onTap: onRequestWithdrawal,
                  borderRadius: BorderRadius.circular(20),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text(
                      '출금 신청',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            MyPageView.formatCurrency(amount),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SalesStatisticsCard extends StatelessWidget {
  const _SalesStatisticsCard({
    required this.dailySales,
    required this.weeklyTotal,
    required this.weekdayLabels,
  });

  final List<int> dailySales;
  final int weeklyTotal;
  final List<String> weekdayLabels;

  @override
  Widget build(BuildContext context) {
    final maxSales =
        dailySales.isEmpty ? 1 : dailySales.reduce((a, b) => a > b ? a : b);
    final highlightIndex = dailySales.isEmpty
        ? -1
        : dailySales.indexOf(maxSales);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.bar_chart_rounded,
                size: 20,
                color: AppColors.primary,
              ),
              SizedBox(width: 8),
              Text(
                '이번 달 매출 통계',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 100,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(dailySales.length, (index) {
                final sales = dailySales[index];
                final barHeight =
                    maxSales > 0 ? (sales / maxSales) * 72.0 : 0.0;
                final isHighlight = index == highlightIndex;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          height: barHeight.clamp(4.0, 72.0),
                          decoration: BoxDecoration(
                            color: isHighlight
                                ? AppColors.primary
                                : AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          weekdayLabels[index],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight:
                                isHighlight ? FontWeight.w700 : FontWeight.w500,
                            color: isHighlight
                                ? AppColors.primary
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '이번 주 총 매출',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                MyPageView.formatCurrency(weeklyTotal),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
