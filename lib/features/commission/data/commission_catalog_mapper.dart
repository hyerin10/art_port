import 'package:art_port/features/artist_profile/data/dto/artist_profile_dto.dart';
import 'package:art_port/features/artist_profile/models/artist_public_profile.dart';
import 'package:art_port/features/commission/data/commission_detail_defaults.dart';
import 'package:art_port/features/commission/data/dto/commission_type_dto.dart';
import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:art_port/features/explore/models/commission_sample.dart';
import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:art_port/features/search/models/search_commission.dart';

/// API DTO → 화면 모델 변환.
abstract final class CommissionCatalogMapper {
  static const _aspectRatios = [0.72, 1.0, 0.82, 1.25, 0.88, 0.78];

  static List<String> hashedTags(List<String> tags) {
    return [
      for (final tag in tags)
        if (tag.trim().isNotEmpty) tag.startsWith('#') ? tag : '#${tag.trim()}',
    ];
  }

  static CommissionDetail toDetail(
    CommissionTypeDto type,
    ArtistProfileDto? artist,
  ) {
    final priceOptions = _priceOptions(type);
    return CommissionDetail(
      id: type.id,
      title: type.name,
      imageUrls: type.imageUrls,
      hasSlotOpen:
          type.isActive && type.openSlots > 0 && (artist?.isSlotOpen ?? true),
      artistName: artist?.displayName ?? '작가',
      artistAvatarUrl: artist?.avatarUrl ?? '',
      artistProfileId: type.artistProfileId,
      artistUserId: artist?.userId ?? '',
      rating: artist?.rating ?? 0,
      reviewCount: artist?.reviewCount ?? 0,
      tags: hashedTags(type.tags),
      estimatedDays: type.workPeriodDays,
      completedCount: type.completedCount,
      responseRatePercent: type.responseRatePercent,
      priceOptions: priceOptions,
      introText:
          type.introText ??
          type.description ??
          CommissionDetailDefaults.introText(artist?.displayName ?? '작가'),
      workScopeItems: type.workScopeItems.isNotEmpty
          ? type.workScopeItems
          : CommissionDetailDefaults.workScopeItems,
      revisionPolicyItems: type.revisionPolicyItems.isNotEmpty
          ? type.revisionPolicyItems
          : CommissionDetailDefaults.revisionPolicyItems,
      noticeText: type.noticeText ?? CommissionDetailDefaults.noticeText,
    );
  }

  static CommissionSample toGallerySample(
    CommissionTypeDto type,
    ArtistProfileDto? artist,
  ) {
    return CommissionSample(
      id: type.id,
      imageUrl: type.primaryImageUrl ?? artist?.avatarUrl ?? '',
      artistName: artist?.displayName ?? '작가',
      artistAvatarUrl: artist?.avatarUrl ?? '',
      startPriceWon: type.startingPriceWon,
      likeCount: type.completedCount,
      tags: hashedTags(type.tags),
      aspectRatio: _aspectRatios[type.id.hashCode.abs() % _aspectRatios.length],
    );
  }

  static LiveSlotSample? toLiveSlot(
    CommissionTypeDto type,
    ArtistProfileDto? artist,
  ) {
    if (!type.isActive || type.openSlots <= 0) return null;
    if (artist != null && !artist.isSlotOpen) return null;

    final imageUrl = type.primaryImageUrl;
    if (imageUrl == null || imageUrl.isEmpty) return null;

    return LiveSlotSample(
      commissionId: type.id,
      artistName: artist?.displayName ?? '작가',
      categoryTag: type.tags.isNotEmpty ? type.tags.first : type.name,
      priceWon: type.startingPriceWon,
      slotsLeft: type.openSlots,
      avatarUrl: artist?.avatarUrl ?? '',
      artworkUrl: imageUrl,
    );
  }

  static SearchCommissionItem toSearchItem(
    CommissionTypeDto type,
    ArtistProfileDto? artist, {
    required int sortOrder,
  }) {
    return SearchCommissionItem(
      id: type.id,
      imageUrl: type.primaryImageUrl ?? '',
      artistName: artist?.displayName ?? '작가',
      artistAvatarUrl: artist?.avatarUrl ?? '',
      title: type.name,
      tags: hashedTags(type.tags),
      startPriceWon: type.startingPriceWon,
      likeCount: type.completedCount,
      hasSlot: type.openSlots > 0 && (artist?.isSlotOpen ?? true),
      isAvailable: type.isActive && !(artist?.isRestMode ?? false),
      sortOrder: sortOrder,
      daysUntilDeadline: type.workPeriodDays,
      ageRating: _ageFilter(type.ageRating),
    );
  }

  static ArtistPublicProfile toPublicProfile({
    required ArtistProfileDto profile,
    required List<PortfolioImageDto> portfolio,
    required List<ArtistNoticeDto> notices,
    required List<SocialLinkDto> socialLinks,
    List<CommissionTypeDto> commissionTypes = const [],
  }) {
    final sortedNotices = [...notices]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final pinned = sortedNotices.where((notice) => notice.isPinned).firstOrNull;
    final general = sortedNotices.where((notice) => !notice.isPinned);
    final openTypes = [
      for (final type in commissionTypes)
        if (type.isActive && type.openSlots > 0) type,
    ];
    final hasSlotOpen = profile.isSlotOpen && openTypes.isNotEmpty;
    final primaryCommissionId = hasSlotOpen
        ? openTypes.first.id
        : (commissionTypes.isEmpty ? null : commissionTypes.first.id);

    return ArtistPublicProfile(
      id: profile.id,
      userId: profile.userId,
      displayName: profile.displayName,
      avatarUrl: profile.avatarUrl ?? '',
      oneLineIntro: profile.oneLineIntro ?? '',
      rating: profile.rating,
      reviewCount: profile.reviewCount,
      followerCount: profile.followerCount,
      socialLinks: [for (final link in socialLinks) _socialLink(link)],
      pinnedNotice: pinned == null ? null : _pinnedNotice(pinned),
      generalNotices: [for (final notice in general) _generalNotice(notice)],
      detailedIntro: profile.detailedIntro ?? '',
      workingHours: profile.workingHours ?? '-',
      averageDelivery: profile.averageDeliveryDays == null
          ? '-'
          : '${profile.averageDeliveryDays}일',
      revisionPolicy: profile.revisionPolicy ?? '-',
      paymentTerms: profile.paymentTerms ?? '-',
      specialties: profile.specialties,
      restrictedItems: profile.restrictedItems,
      portfolioImageUrls: [for (final image in portfolio) image.imageUrl],
      primaryCommissionId: primaryCommissionId,
      hasSlotOpen: hasSlotOpen,
    );
  }

  static List<CommissionPriceOption> _priceOptions(CommissionTypeDto type) {
    return [
      CommissionPriceOption(
        label: '기본',
        priceWon: type.startingPriceWon,
        isPopular: true,
      ),
      ...type.priceOptions,
    ];
  }

  static SearchAgeFilter _ageFilter(String ageRating) {
    return switch (ageRating) {
      '15' => SearchAgeFilter.adultNoGore,
      '18' => SearchAgeFilter.adultWithGore,
      _ => SearchAgeFilter.allAges,
    };
  }

  static ArtistSocialLink _socialLink(SocialLinkDto link) {
    final type = switch (link.type) {
      'twitter' => ArtistSocialLinkType.twitter,
      'instagram' => ArtistSocialLinkType.instagram,
      'website' => ArtistSocialLinkType.website,
      _ => ArtistSocialLinkType.other,
    };
    return ArtistSocialLink(
      type: type,
      label: link.label ?? link.type,
      url: link.url,
    );
  }

  static PinnedNotice _pinnedNotice(ArtistNoticeDto notice) {
    return PinnedNotice(
      title: notice.title,
      bulletPoints: notice.bulletPoints.isNotEmpty
          ? notice.bulletPoints
          : [
              if (notice.content != null && notice.content!.isNotEmpty)
                notice.content!,
            ],
      createdAt: notice.createdAt,
      isPublic: notice.isPublic,
    );
  }

  static GeneralNotice _generalNotice(ArtistNoticeDto notice) {
    return GeneralNotice(
      id: notice.id,
      title: notice.title,
      content: notice.content ?? notice.bulletPoints.join('\n'),
      createdAt: notice.createdAt,
      isActive: notice.isActive,
    );
  }
}
