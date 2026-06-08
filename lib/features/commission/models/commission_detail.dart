import 'package:art_port/features/explore/models/commission_sample.dart';
import 'package:art_port/features/search/models/search_commission.dart';

/// 커미션 가격 옵션
class CommissionPriceOption {
  const CommissionPriceOption({
    required this.label,
    required this.priceWon,
    this.subtitle,
    this.isPopular = false,
  });

  final String label;
  final String? subtitle;
  final int priceWon;
  final bool isPopular;

  String get priceLabel => '${CommissionDetail.formatWon(priceWon)} ~';

  String get displayLabel =>
      subtitle != null ? '$label ($subtitle)' : label;
}

/// 커미션 상세 화면 데이터 모델
class CommissionDetail {
  const CommissionDetail({
    required this.id,
    required this.title,
    required this.imageUrls,
    required this.slotStatusLabel,
    required this.hasSlotOpen,
    required this.artistName,
    required this.artistAvatarUrl,
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
    this.likeCount = 0,
    this.isLiked = false,
  });

  final String id;
  final String title;
  final List<String> imageUrls;
  final String slotStatusLabel;
  final bool hasSlotOpen;
  final String artistName;
  final String artistAvatarUrl;
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
  final int likeCount;
  final bool isLiked;

  String get ratingLabel =>
      '${rating.toStringAsFixed(1)} ($reviewCount 리뷰)';

  String get estimatedDaysLabel => '$estimatedDays일';

  String get completedCountLabel => '$completedCount건';

  String get responseRateLabel => '$responseRatePercent%';

  static String formatWon(int won) {
    final s = won.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()}원';
  }

  CommissionDetail copyWith({
    String? id,
    String? title,
    bool? isLiked,
  }) {
    return CommissionDetail(
      id: id ?? this.id,
      title: title ?? this.title,
      imageUrls: imageUrls,
      slotStatusLabel: slotStatusLabel,
      hasSlotOpen: hasSlotOpen,
      artistName: artistName,
      artistAvatarUrl: artistAvatarUrl,
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
      likeCount: likeCount,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  factory CommissionDetail.fromExploreSample(CommissionSample sample) {
    return CommissionDetail(
      id: sample.id,
      title: _titleFromTags(sample.tags, fallback: '${sample.artistName} 커미션'),
      imageUrls: [
        sample.imageUrl,
        _alternateImage(sample.id, 1),
        _alternateImage(sample.id, 2),
      ],
      slotStatusLabel: '● 슬롯 오픈',
      hasSlotOpen: true,
      artistName: sample.artistName,
      artistAvatarUrl: sample.artistAvatarUrl,
      rating: 4.7 + (sample.id.hashCode % 3) * 0.1,
      reviewCount: 40 + sample.likeCount ~/ 3,
      tags: sample.tags,
      estimatedDays: 7 + sample.id.hashCode % 14,
      completedCount: 50 + sample.likeCount ~/ 2,
      responseRatePercent: 92 + sample.id.hashCode % 8,
      priceOptions: _defaultPriceOptions(sample.startPriceWon),
      introText:
          '안녕하세요! ${sample.artistName}입니다. 제 스타일은 감성적이고 따뜻한 느낌의 일러스트를 지향합니다.',
      workScopeItems: _defaultWorkScope,
      revisionPolicyItems: _defaultRevisionPolicy,
      noticeText: _defaultNotice,
      likeCount: sample.likeCount,
      isLiked: sample.isLiked,
    );
  }

  factory CommissionDetail.fromLiveSlot(LiveSlotSample slot) {
    final tags = slot.categoryTag
        .split('/')
        .map((part) => '#${part.trim()}')
        .toList();

    return CommissionDetail(
      id: slot.commissionId,
      title: _titleFromLiveSlot(slot),
      imageUrls: [
        slot.artworkUrl,
        _alternateImage(slot.commissionId, 1),
        _alternateImage(slot.commissionId, 2),
      ],
      slotStatusLabel: '● 슬롯 오픈',
      hasSlotOpen: slot.slotsLeft > 0,
      artistName: slot.artistName,
      artistAvatarUrl: slot.avatarUrl,
      rating: 4.6 + (slot.commissionId.hashCode % 4) * 0.1,
      reviewCount: 60 + slot.priceWon ~/ 1000,
      tags: tags,
      estimatedDays: 10 + slot.commissionId.hashCode % 10,
      completedCount: 100 + slot.priceWon ~/ 500,
      responseRatePercent: 88 + slot.commissionId.hashCode % 12,
      priceOptions: _defaultPriceOptions(slot.priceWon),
      introText:
          '안녕하세요! ${slot.artistName}입니다. 제 스타일은 감성적이고 따뜻한 느낌의 일러스트를 지향합니다.',
      workScopeItems: _defaultWorkScope,
      revisionPolicyItems: _defaultRevisionPolicy,
      noticeText: _defaultNotice,
      likeCount: slot.priceWon ~/ 100,
    );
  }

  factory CommissionDetail.fromSearchItem(SearchCommissionItem item) {
    return CommissionDetail(
      id: item.id,
      title: item.title,
      imageUrls: [
        item.imageUrl,
        _alternateImage(item.id, 1),
        _alternateImage(item.id, 2),
      ],
      slotStatusLabel: item.hasSlot ? '● 슬롯 오픈' : '● 슬롯 마감',
      hasSlotOpen: item.hasSlot,
      artistName: item.artistName,
      artistAvatarUrl: item.artistAvatarUrl,
      rating: 4.6 + (item.id.hashCode % 4) * 0.1,
      reviewCount: 30 + item.likeCount ~/ 4,
      tags: item.tags,
      estimatedDays: item.daysUntilDeadline > 0 ? item.daysUntilDeadline : 14,
      completedCount: 80 + item.likeCount ~/ 3,
      responseRatePercent: 90 + item.id.hashCode % 10,
      priceOptions: _defaultPriceOptions(item.startPriceWon),
      introText:
          '안녕하세요! ${item.artistName}입니다. 제 스타일은 감성적이고 따뜻한 느낌의 일러스트를 지향합니다.',
      workScopeItems: _defaultWorkScope,
      revisionPolicyItems: _defaultRevisionPolicy,
      noticeText: _defaultNotice,
      likeCount: item.likeCount,
      isLiked: item.isLiked,
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

  static List<CommissionPriceOption> _defaultPriceOptions(int startPrice) {
    return [
      CommissionPriceOption(
        label: '두상',
        subtitle: 'Bust',
        priceWon: startPrice,
        isPopular: true,
      ),
      CommissionPriceOption(
        label: '흉상',
        subtitle: 'Half Body',
        priceWon: (startPrice * 1.5).round(),
      ),
      CommissionPriceOption(
        label: '전신',
        subtitle: 'Full Body',
        priceWon: startPrice * 2,
      ),
    ];
  }

  static const _defaultWorkScope = [
    '캐릭터 1인 기준 가격입니다',
    '배경은 단색 또는 간단한 효과로 제공됩니다',
    '상업용 사용 시 추가 요금이 발생합니다',
  ];

  static const _defaultRevisionPolicy = [
    '러프 단계: 무제한 수정',
    '채색 단계: 2회 수정 가능',
    '완성 후: 색감 조정만 가능',
  ];

  static const _defaultNotice =
      '커미션 신청 전 작가의 약관을 꼭 확인해주세요. 결제는 작가와 협의 후 진행됩니다.';

  static String _alternateImage(String id, int index) {
    const pool = [
      'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1635322968969-b6ec3bb19212?w=800&h=800&fit=crop',
    ];
    return pool[(id.hashCode.abs() + index) % pool.length];
  }
}

/// 커미션 상세 더미 데이터 — ID 기반 조회
abstract final class CommissionDetailData {
  static const _pixelDreams = CommissionDetail(
    id: 'pixel-dreams',
    title: '세미리얼 초상화',
    imageUrls: [
      'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1635322968969-b6ec3bb19212?w=800&h=800&fit=crop',
    ],
    slotStatusLabel: '● 슬롯 오픈',
    hasSlotOpen: true,
    artistName: 'PixelDreams',
    artistAvatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop',
    rating: 4.9,
    reviewCount: 128,
    tags: ['#MD', '#세미리얼', '#감성'],
    estimatedDays: 14,
    completedCount: 156,
    responseRatePercent: 98,
    priceOptions: [
      CommissionPriceOption(
        label: '두상',
        subtitle: 'Bust',
        priceWon: 50000,
        isPopular: true,
      ),
      CommissionPriceOption(
        label: '흉상',
        subtitle: 'Half Body',
        priceWon: 75000,
      ),
      CommissionPriceOption(
        label: '전신',
        subtitle: 'Full Body',
        priceWon: 100000,
      ),
    ],
    introText:
        '안녕하세요! PixelDreams입니다. 제 스타일은 감성적이고 따뜻한 느낌의 일러스트를 지향합니다.',
    workScopeItems: CommissionDetail._defaultWorkScope,
    revisionPolicyItems: CommissionDetail._defaultRevisionPolicy,
    noticeText: CommissionDetail._defaultNotice,
    likeCount: 190,
  );

  static const _neoNeo = CommissionDetail(
    id: 'live-slot-neoneo',
    title: '애니메이션 두상 커미션',
    imageUrls: [
      'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&h=800&fit=crop',
      'https://images.unsplash.com/photo-1635322968969-b6ec3bb19212?w=800&h=800&fit=crop',
    ],
    slotStatusLabel: '● 슬롯 오픈',
    hasSlotOpen: true,
    artistName: '네오네오',
    artistAvatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop',
    rating: 4.9,
    reviewCount: 133,
    tags: ['#두상', '#애니풍'],
    estimatedDays: 12,
    completedCount: 217,
    responseRatePercent: 91,
    priceOptions: [
      CommissionPriceOption(
        label: '두상',
        subtitle: 'Bust',
        priceWon: 45000,
        isPopular: true,
      ),
      CommissionPriceOption(
        label: '흉상',
        subtitle: 'Half Body',
        priceWon: 67500,
      ),
      CommissionPriceOption(
        label: '전신',
        subtitle: 'Full Body',
        priceWon: 90000,
      ),
    ],
    introText:
        '안녕하세요! 네오네오입니다. 제 스타일은 감성적이고 따뜻한 느낌의 일러스트를 지향합니다.',
    workScopeItems: CommissionDetail._defaultWorkScope,
    revisionPolicyItems: CommissionDetail._defaultRevisionPolicy,
    noticeText: CommissionDetail._defaultNotice,
    likeCount: 412,
  );

  static final Map<String, CommissionDetail> _overrides = {
    'pixel-dreams': _pixelDreams,
    '1': _pixelDreams.copyWith(id: '1'),
    'search-1': _pixelDreams.copyWith(id: 'search-1', title: '일러스트 한 장 타입'),
    'live-slot-neoneo': _neoNeo,
    'search-3': _neoNeo.copyWith(id: 'search-3'),
  };

  static CommissionDetail? forId(String commissionId) {
    final override = _overrides[commissionId];
    if (override != null) return override;

    for (final slot in ExploreDummyData.liveSlots) {
      if (slot.commissionId == commissionId) {
        return CommissionDetail.fromLiveSlot(slot);
      }
    }

    for (final sample in ExploreDummyData.gallerySamples) {
      if (sample.id == commissionId) {
        return CommissionDetail.fromExploreSample(sample);
      }
    }

    for (final item in SearchDummyData.commissions) {
      if (item.id == commissionId) {
        return CommissionDetail.fromSearchItem(item);
      }
    }

    return null;
  }
}
