import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/artist_profile/models/artist_public_profile.dart';
import 'package:flutter/material.dart';

/// 프로필 탭 — 소개, 메타 정보, 정책, 태그 칩
class ArtistProfileTabContent extends StatelessWidget {
  const ArtistProfileTabContent({super.key, required this.profile});

  final ArtistPublicProfile profile;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        const _SectionTitle('소개'),
        const SizedBox(height: 8),
        Text(
          profile.detailedIntro,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _MetaInfoCard(
                icon: Icons.schedule_rounded,
                label: '작업 시간',
                value: profile.workingHours,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetaInfoCard(
                icon: Icons.check_circle_outline_rounded,
                label: '평균 납품',
                value: profile.averageDelivery,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _SectionTitle('수정 정책'),
        const SizedBox(height: 8),
        Text(
          profile.revisionPolicy,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('결제 조건'),
        const SizedBox(height: 8),
        Text(
          profile.paymentTerms,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 24),
        const _SectionTitle('전문 분야'),
        const SizedBox(height: 10),
        _TagChipWrap(
          tags: profile.specialties,
          backgroundColor: AppColors.primarySoft,
          textColor: AppColors.primary,
        ),
        const SizedBox(height: 24),
        const Row(
          children: [
            Text('⚠️', style: TextStyle(fontSize: 16)),
            SizedBox(width: 4),
            _SectionTitle('작업 불가 항목'),
          ],
        ),
        const SizedBox(height: 10),
        _TagChipWrap(
          tags: profile.restrictedItems,
          backgroundColor: const Color(0xFFFEE2E2),
          textColor: const Color(0xFFDC2626),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
    );
  }
}

class _MetaInfoCard extends StatelessWidget {
  const _MetaInfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChipWrap extends StatelessWidget {
  const _TagChipWrap({
    required this.tags,
    required this.backgroundColor,
    required this.textColor,
  });

  final List<String> tags;
  final Color backgroundColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final tag in tags)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              tag,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
      ],
    );
  }
}
