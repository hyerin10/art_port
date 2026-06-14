import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/auth/email_verification/email_verification_pending_screen.dart';
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
    final actions = ref.watch(clientMyPageActionsProvider);
    final profileNotifier = ref.read(clientProfileProvider.notifier);
    final isEmailVerified = ref.watch(isEmailVerifiedProvider);

    return MyPageScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MyPageProfileSection(
            avatarUrl: profile.avatarUrl,
            onEditPhoto: profileNotifier.onEditProfilePhoto,
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
          MyPageLogoutButton(
            onTap: () => actions.confirmLogout(context),
          ),
        ],
      ),
    );
  }
}
