import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/admin/widgets/admin_menu_section.dart';
import 'package:art_port/features/auth/email_verification/email_verification_pending_screen.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/mypage/data/mypage_write_providers.dart';
import 'package:art_port/features/mypage/mypage_navigation.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/mypage/widgets/email_verification_banner.dart';
import 'package:art_port/features/mypage/widgets/menu_list_item.dart';
import 'package:art_port/features/mypage/widgets/mypage_logout_button.dart';
import 'package:art_port/features/mypage/widgets/mypage_profile_section.dart';
import 'package:art_port/features/mypage/widgets/mypage_scroll_view.dart';
import 'package:art_port/features/mypage/widgets/section_card.dart';
import 'package:art_port/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClientMyPageContent extends ConsumerWidget {
  const ClientMyPageContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(clientProfileProvider);
    final liveProfile = ref.watch(myClientProfileProvider).valueOrNull;
    final actions = ref.watch(clientMyPageActionsProvider);
    final isEmailVerified = ref.watch(isEmailVerifiedProvider);

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
            name: profile.name,
            onOpenSettings: () => MyPageNavigation.openProfileSettings(context),
            subtitle: profile.email,
            subtitleStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          Visibility(
            visible: !isEmailVerified,
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: EmailVerificationBanner(
                onVerify: () => EmailVerificationPendingScreen.open(context),
              ),
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
              MenuListItem(
                label: '내 팔로워',
                icon: Icons.groups_rounded,
                iconBackgroundColor: const Color(0xFFE0E7FF),
                iconColor: const Color(0xFF4F46E5),
                onTap: () => actions.onFollowers(context),
              ),
              MenuListItem(
                label: '내가 작성한 리뷰',
                icon: Icons.star_rounded,
                iconBackgroundColor: const Color(0xFFFEF3C7),
                iconColor: const Color(0xFFF59E0B),
                onTap: () => actions.onMyReviews(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionCard(
            title: '결제 및 증빙',
            children: [
              MenuListItem(
                label: '결제 및 영수증',
                icon: Icons.receipt_long_rounded,
                iconBackgroundColor: AppColors.primaryLight,
                iconColor: AppColors.primary,
                onTap: () => actions.onPaymentsAndReceipts(context),
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
                onTap: () => actions.onInquiry(context),
              ),
            ],
          ),
          const AdminMenuSection(),
          MyPageLogoutButton(
            onTap: () => actions.confirmLogout(context),
          ),
        ],
      ),
    );
  }
}
