import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/artist_application/artist_application_screen.dart';
import 'package:art_port/providers/artist_status_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 오픈 슬롯 / 워크룸 탭 진입 화면 — 미승인 작가에게 표시
enum ArtistApplicationEntryTab {
  openSlot,
  workroom,
  mypage,
}

class ArtistApplicationEntryView extends ConsumerWidget {
  const ArtistApplicationEntryView({
    super.key,
    required this.tab,
  });

  final ArtistApplicationEntryTab tab;

  static const _gradientStart = Color(0xFF7C4DFF);
  static const _gradientEnd = Color(0xFFEC4899);
  static const _cardBg = Color(0xFFF3F0FF);

  String get _titleKo => switch (tab) {
        ArtistApplicationEntryTab.openSlot => '오픈 슬롯',
        ArtistApplicationEntryTab.workroom => '작업실',
        ArtistApplicationEntryTab.mypage => '작가 마이페이지',
      };

  String get _titleEn => switch (tab) {
        ArtistApplicationEntryTab.openSlot => 'Open Slot',
        ArtistApplicationEntryTab.workroom => 'Workroom',
        ArtistApplicationEntryTab.mypage => 'Artist My Page',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(artistApprovalStatusProvider);

    if (status == ArtistApprovalStatus.pending) {
      return _PendingReviewView(tab: tab);
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _titleKo,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _titleEn,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '작가로 활동하세요',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'ArtPort에서 커미션을 열고 전 세계 팬들과 만나보세요.\n'
                  '당신의 재능을 세상에 알릴 기회입니다.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 28),
                _ApplyButton(
                  onTap: () => ArtistApplicationScreen.open(context),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Apply to Become an Artist',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
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

class _ApplyButton extends StatelessWidget {
  const _ApplyButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                ArtistApplicationEntryView._gradientStart,
                ArtistApplicationEntryView._gradientEnd,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: ArtistApplicationEntryView._gradientEnd
                    .withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  '작가 활동 신청하기',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingReviewView extends StatelessWidget {
  const _PendingReviewView({required this.tab});

  final ArtistApplicationEntryTab tab;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.hourglass_top_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '심사 진행 중',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '제출하신 신청서는 관리자 심사를 거쳐\n'
              '1~3영업일 이내에 승인 여부가 결정됩니다.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
