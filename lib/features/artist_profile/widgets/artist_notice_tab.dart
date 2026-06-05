import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/artist_profile/models/artist_public_profile.dart';
import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:flutter/material.dart';

/// 공지사항 탭 — 고정 공지 + 일반 공지 리스트
class ArtistNoticeTab extends StatelessWidget {
  const ArtistNoticeTab({super.key, required this.profile});

  final ArtistPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    final pinned = profile.pinnedNotice;
    final notices = profile.generalNotices;

    if (pinned == null && notices.isEmpty) {
      return const Center(
        child: Text(
          '등록된 공지사항이 없습니다.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        if (pinned != null) ...[
          _PinnedNoticeCard(notice: pinned),
          const SizedBox(height: 12),
        ],
        for (final notice in notices) ...[
          _PublicNoticeCard(notice: notice),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PinnedNoticeCard extends StatelessWidget {
  const _PinnedNoticeCard({required this.notice});

  final PinnedNotice notice;

  @override
  Widget build(BuildContext context) {
    final preview = notice.bulletPoints.isNotEmpty
        ? notice.bulletPoints.first
        : '';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLight),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '고정',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                notice.formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            notice.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
          if (preview.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              preview,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PublicNoticeCard extends StatelessWidget {
  const _PublicNoticeCard({required this.notice});

  final GeneralNotice notice;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  notice.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    height: 1.25,
                  ),
                ),
              ),
              Text(
                notice.formattedDate,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notice.preview,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
