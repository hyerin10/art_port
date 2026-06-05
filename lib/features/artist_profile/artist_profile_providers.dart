import 'package:art_port/features/artist_profile/models/artist_public_profile.dart';
import 'package:art_port/features/mypage/models/followed_artist.dart';
import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final artistPublicProfileProvider =
    Provider.family<ArtistPublicProfile?, String>((ref, artistId) {
  return ArtistPublicProfileCatalog.forId(artistId);
});

/// 작가 공개 프로필 더미 카탈로그 (추후 API 교체)
abstract final class ArtistPublicProfileCatalog {
  static final Map<String, ArtistPublicProfile> _profiles = _buildProfiles();

  static ArtistPublicProfile? forId(String id) => _profiles[id];

  static Map<String, ArtistPublicProfile> _buildProfiles() {
    final profiles = <String, ArtistPublicProfile>{};

    for (final catalog in ArtistCatalog.allProfiles) {
      profiles[catalog.id] = _profileFromCatalog(catalog);
    }

    profiles['mika-art'] = _mikaArtProfile(
      profiles['mika-art'] ?? _profileFromCatalog(ArtistCatalog.forId('mika-art')!),
    );

    return profiles;
  }

  static ArtistPublicProfile _profileFromCatalog(FollowedArtistProfile catalog) {
    final portfolioUrls = [
      for (final work in catalog.recentWorks) work.imageUrl,
      ..._extraPortfolioImages(catalog.id),
    ];

    return ArtistPublicProfile(
      id: catalog.id,
      displayName: catalog.displayName,
      avatarUrl: catalog.avatarUrl,
      oneLineIntro: '${catalog.specialtiesLabel} 전문 작가입니다.',
      rating: 4.5 + (catalog.id.hashCode % 5) * 0.1,
      reviewCount: 20 + (catalog.id.hashCode % 80),
      followerCount: 500 + (catalog.id.hashCode % 5000).abs(),
      socialLinks: const [],
      pinnedNotice: null,
      generalNotices: const [],
      detailedIntro: '${catalog.displayName}의 작업 소개입니다.',
      workingHours: '평일 10:00 ~ 22:00 (주말 휴무)',
      averageDelivery: '7-14일',
      revisionPolicy: '스케치 단계 2회, 컬러 단계 1회 수정 무료',
      paymentTerms: '작업 시작 전 50% 선입금, 최종 납품 후 50% 후불',
      specialties: catalog.specialtiesLabel.split(', '),
      restrictedItems: const ['실사풍', '19금 콘텐츠'],
      portfolioImageUrls: portfolioUrls,
      primaryCommissionId:
          catalog.recentWorks.isNotEmpty ? catalog.recentWorks.first.commissionId : null,
    );
  }

  static ArtistPublicProfile _mikaArtProfile(ArtistPublicProfile base) {
    return ArtistPublicProfile(
      id: base.id,
      displayName: 'MikaArt',
      avatarUrl: base.avatarUrl,
      oneLineIntro:
          'Anime 스타일 전문 작가입니다. 고퀄리티 작업물과 빠른 소통을 약속드립니다.',
      rating: 4.944450000051889,
      reviewCount: 64,
      followerCount: 3649,
      socialLinks: const [
        ArtistSocialLink(
          type: ArtistSocialLinkType.twitter,
          label: '@mikaart_illust',
          url: 'https://twitter.com/mikaart_illust',
        ),
        ArtistSocialLink(
          type: ArtistSocialLinkType.instagram,
          label: 'Instagram',
          url: 'https://instagram.com/mikaart_illust',
        ),
        ArtistSocialLink(
          type: ArtistSocialLinkType.website,
          label: 'Portfolio',
          url: 'https://mikaart.portfolio.com',
        ),
      ],
      pinnedNotice: PinnedNotice(
        title: '12월 커미션 오픈 안내',
        bulletPoints: const [
          '12월 커미션 슬롯이 오픈되었습니다.',
          '신청은 선착순으로 마감되며, 작업 기간은 7-14일입니다.',
          '레퍼런스와 상세 요청사항을 함께 보내주시면 더욱 정확한 작업이 가능합니다.',
        ],
        createdAt: DateTime(2024, 12, 15),
        isPublic: true,
      ),
      generalNotices: [
        GeneralNotice(
          id: 'mika-notice-1',
          title: '작업 일정 변경 안내',
          content:
              '개인 사정으로 12월 20일 ~ 12월 22일 작업이 일시 중단됩니다. 해당 기간 접수 건은 12월 23일부터 순차적으로 진행됩니다.',
          createdAt: DateTime(2024, 12, 10),
        ),
        GeneralNotice(
          id: 'mika-notice-2',
          title: '가격 정책 변경',
          content:
              '2025년 1월부터 일부 커미션 타입의 가격이 조정됩니다. 기존 신청 건은 기존 가격이 적용됩니다.',
          createdAt: DateTime(2024, 11, 28),
        ),
      ],
      detailedIntro:
          '안녕하세요, MikaArt입니다!\n\n주로 애니메이션 스타일의 캐릭터 일러스트를 전문으로 하고 있으며, 판타지와 SF 장르를 특히 좋아합니다. 고퀄리티 작업물과 빠른 소통을 약속드립니다.\n\n게임, 소설, VTuber 관련 작업 경험이 풍부하며, 수정 요청에도 적극적으로 대응합니다.',
      workingHours: '평일 10:00 ~ 22:00 (주말 휴무)',
      averageDelivery: '7-14일',
      revisionPolicy: '컬러 단계에서 2회 수정 무료, 이후 추가 수정은 건당 5,000원',
      paymentTerms: '작업 시작 전 50% 선입금, 최종 납품 후 50% 후불',
      specialties: const [
        '애니메이션 스타일',
        '판타지 캐릭터',
        '이모티콘/이미지',
        '버튜버 일러스트',
      ],
      restrictedItems: const [
        '실사풍',
        '메카/로봇',
        '19금 콘텐츠',
      ],
      portfolioImageUrls: [
        ...base.portfolioImageUrls,
        'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1618172193626-ae7fd5fab9d2?w=400&h=400&fit=crop',
        'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=400&h=400&fit=crop',
      ],
      primaryCommissionId: base.primaryCommissionId,
    );
  }

  static List<String> _extraPortfolioImages(String id) {
    return [
      'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=400&h=400&fit=crop',
      'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=400&h=400&fit=crop',
    ];
  }
}
