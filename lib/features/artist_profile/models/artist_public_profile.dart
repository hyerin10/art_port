import 'package:art_port/features/mypage/models/notice_settings_data.dart';

/// 공개 작가 프로필 SNS 링크
class ArtistSocialLink {
  const ArtistSocialLink({
    required this.type,
    required this.label,
    required this.url,
  });

  final ArtistSocialLinkType type;
  final String label;
  final String url;
}

enum ArtistSocialLinkType { twitter, instagram, website }

/// 공개 작가 프로필 (상세 페이지용)
class ArtistPublicProfile {
  const ArtistPublicProfile({
    required this.id,
    required this.displayName,
    required this.avatarUrl,
    required this.oneLineIntro,
    required this.rating,
    required this.reviewCount,
    required this.followerCount,
    required this.socialLinks,
    required this.pinnedNotice,
    required this.generalNotices,
    required this.detailedIntro,
    required this.workingHours,
    required this.averageDelivery,
    required this.revisionPolicy,
    required this.paymentTerms,
    required this.specialties,
    required this.restrictedItems,
    required this.portfolioImageUrls,
    this.primaryCommissionId,
  });

  final String id;
  final String displayName;
  final String avatarUrl;
  final String oneLineIntro;
  final double rating;
  final int reviewCount;
  final int followerCount;
  final List<ArtistSocialLink> socialLinks;
  final PinnedNotice? pinnedNotice;
  final List<GeneralNotice> generalNotices;
  final String detailedIntro;
  final String workingHours;
  final String averageDelivery;
  final String revisionPolicy;
  final String paymentTerms;
  final List<String> specialties;
  final List<String> restrictedItems;
  final List<String> portfolioImageUrls;
  final String? primaryCommissionId;

  /// 평점을 소수점 둘째 자리까지 표시 (부동소수점 버그 방지)
  String get formattedRating => rating.toStringAsFixed(2);

  String get formattedFollowerCount => _formatCount(followerCount);

  static String _formatCount(int count) {
    final s = count.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
