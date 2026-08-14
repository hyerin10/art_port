import 'package:art_port/features/commission/models/commission_price_option.dart';

export 'commission_price_option.dart';

/// 커미션 상세 화면 데이터 모델
class CommissionDetail {
  const CommissionDetail({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.hasSlotOpen,
    required this.artistName,
    required this.artistAvatarUrl,
    required this.artistProfileId,
    required this.rating,
    required this.reviewCount,
    required this.tags,
    required this.estimatedDays,
    required this.completedCount,
    required this.responseRatePercent,
    required this.priceOptions,
    required this.introText,
    required this.workScopeItems,
    required this.revisionPolicyItems,
    required this.noticeText,
  });

  final String id;
  final String title;
  final List<String> imageUrls;
  final bool hasSlotOpen;
  final String artistName;
  final String artistAvatarUrl;
  final String artistProfileId;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final int estimatedDays;
  final int completedCount;
  final int responseRatePercent;
  final List<CommissionPriceOption> priceOptions;
  final String introText;
  final List<String> workScopeItems;
  final List<String> revisionPolicyItems;
  final String noticeText;

  String get slotStatusLabel =>
      hasSlotOpen ? '● 슬롯 오픈' : '● 슬롯 마감';

  String get ratingLabel =>
      '${rating.toStringAsFixed(1)} ($reviewCount 리뷰)';

  String get estimatedDaysLabel => '$estimatedDays일';

  String get completedCountLabel => '$completedCount건';

  String get responseRateLabel => '$responseRatePercent%';

  CommissionDetail copyWith({
    String? id,
    String? title,
  }) {
    return CommissionDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrls: imageUrls,
      hasSlotOpen: hasSlotOpen,
      artistName: artistName,
      artistAvatarUrl: artistAvatarUrl,
      artistProfileId: artistProfileId,
      rating: rating,
      reviewCount: reviewCount,
      tags: tags,
      estimatedDays: estimatedDays,
      completedCount: completedCount,
      responseRatePercent: responseRatePercent,
      priceOptions: priceOptions,
      introText: introText,
      workScopeItems: workScopeItems,
      revisionPolicyItems: revisionPolicyItems,
      noticeText: noticeText,
    );
  }
}
