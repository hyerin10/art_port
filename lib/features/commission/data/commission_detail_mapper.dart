import 'package:art_port/features/commission/data/commission_detail_defaults.dart';
import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:art_port/features/explore/models/commission_sample.dart';
import 'package:art_port/features/search/models/search_commission.dart';

/// 탐색·검색 등 소스 모델 → [CommissionDetail] 변환
abstract final class CommissionDetailMapper {
  static CommissionDetail fromExploreSample(CommissionSample sample) {
    return _build(
      id: sample.id,
      title: _titleFromTags(
        sample.tags,
        fallback: '${sample.artistName} 커미션',
      ),
      primaryImageUrl: sample.imageUrl,
      hasSlotOpen: true,
      artistName: sample.artistName,
      artistAvatarUrl: sample.artistAvatarUrl,
      tags: sample.tags,
      startPriceWon: sample.startPriceWon,
      rating: 4.7 + (sample.id.hashCode % 3) * 0.1,
      reviewCount: 40 + sample.likeCount ~/ 3,
      estimatedDays: 7 + sample.id.hashCode % 14,
      completedCount: 50 + sample.likeCount ~/ 2,
      responseRatePercent: 92 + sample.id.hashCode % 8,
    );
  }

  static CommissionDetail fromLiveSlot(LiveSlotSample slot) {
    final tags = slot.categoryTag
        .split('/')
        .map((part) => '#${part.trim()}')
        .toList();

    return _build(
      id: slot.commissionId,
      title: _titleFromLiveSlot(slot),
      primaryImageUrl: slot.artworkUrl,
      hasSlotOpen: slot.slotsLeft > 0,
      artistName: slot.artistName,
      artistAvatarUrl: slot.avatarUrl,
      tags: tags,
      startPriceWon: slot.priceWon,
      rating: 4.6 + (slot.commissionId.hashCode % 4) * 0.1,
      reviewCount: 60 + slot.priceWon ~/ 1000,
      estimatedDays: 10 + slot.commissionId.hashCode % 10,
      completedCount: 100 + slot.priceWon ~/ 500,
      responseRatePercent: 88 + slot.commissionId.hashCode % 12,
    );
  }

  static CommissionDetail fromSearchItem(SearchCommissionItem item) {
    return _build(
      id: item.id,
      title: item.title,
      primaryImageUrl: item.imageUrl,
      hasSlotOpen: item.hasSlot,
      artistName: item.artistName,
      artistAvatarUrl: item.artistAvatarUrl,
      tags: item.tags,
      startPriceWon: item.startPriceWon,
      rating: 4.6 + (item.id.hashCode % 4) * 0.1,
      reviewCount: 30 + item.likeCount ~/ 4,
      estimatedDays: item.daysUntilDeadline > 0 ? item.daysUntilDeadline : 14,
      completedCount: 80 + item.likeCount ~/ 3,
      responseRatePercent: 90 + item.id.hashCode % 10,
    );
  }

  static CommissionDetail _build({
    required String id,
    required String title,
    required String primaryImageUrl,
    required bool hasSlotOpen,
    required String artistName,
    required String artistAvatarUrl,
    required List<String> tags,
    required int startPriceWon,
    required double rating,
    required int reviewCount,
    required int estimatedDays,
    required int completedCount,
    required int responseRatePercent,
    List<CommissionPriceOption>? priceOptions,
  }) {
    return CommissionDetail(
      id: id,
      title: title,
      imageUrls: [
        primaryImageUrl,
        CommissionDetailDefaults.alternateImage(id, 1),
        CommissionDetailDefaults.alternateImage(id, 2),
      ],
      hasSlotOpen: hasSlotOpen,
      artistName: artistName,
      artistAvatarUrl: artistAvatarUrl,
      rating: rating,
      reviewCount: reviewCount,
      tags: tags,
      estimatedDays: estimatedDays,
      completedCount: completedCount,
      responseRatePercent: responseRatePercent,
      priceOptions: priceOptions ?? CommissionDetailDefaults.priceOptions(startPriceWon),
      introText: CommissionDetailDefaults.introText(artistName),
      workScopeItems: CommissionDetailDefaults.workScopeItems,
      revisionPolicyItems: CommissionDetailDefaults.revisionPolicyItems,
      noticeText: CommissionDetailDefaults.noticeText,
    );
  }

  static String _titleFromTags(List<String> tags, {required String fallback}) {
    if (tags.isEmpty) return fallback;
    final cleaned = tags.map((t) => t.replaceAll('#', '')).join(' ');
    return '$cleaned 커미션';
  }

  static String _titleFromLiveSlot(LiveSlotSample slot) {
    final parts = slot.categoryTag.split('/');
    if (parts.length >= 2) {
      return '${parts[0].trim()} ${parts[1].trim()} 커미션';
    }
    return '${slot.artistName} ${slot.categoryTag} 커미션';
  }
}
