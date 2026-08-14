import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/artist_profile/data/dto/artist_profile_dto.dart';

class ArtistProfileRepository {
  ArtistProfileRepository(this._client);

  final ApiClient _client;

  Future<List<ArtistProfileDto>> getAll() async {
    final json = await _client.getList('/artist-profiles');
    return json.map(ArtistProfileDto.fromJson).toList();
  }

  Future<ArtistProfileDto> getById(String id) async {
    final json = await _client.get('/artist-profiles/$id');
    return ArtistProfileDto.fromJson(json);
  }

  Future<ArtistProfileDto> update(
    String id, {
    String? displayName,
    String? avatarUrl,
    String? backgroundUrl,
    String? oneLineIntro,
    String? detailedIntro,
    String? workingHours,
    int? averageDeliveryDays,
    String? revisionPolicy,
    String? paymentTerms,
    List<String>? specialties,
    List<String>? restrictedItems,
    bool? isRestMode,
    String? slotStatus,
    String? statusMessage,
  }) async {
    final json = await _client.patch(
      '/artist-profiles/$id',
      body: {
        'displayName': ?displayName,
        'avatarUrl': ?avatarUrl,
        'backgroundUrl': ?backgroundUrl,
        'oneLineIntro': ?oneLineIntro,
        'detailedIntro': ?detailedIntro,
        'workingHours': ?workingHours,
        'averageDeliveryDays': ?averageDeliveryDays,
        'revisionPolicy': ?revisionPolicy,
        'paymentTerms': ?paymentTerms,
        'specialties': ?specialties,
        'restrictedItems': ?restrictedItems,
        'isRestMode': ?isRestMode,
        'slotStatus': ?slotStatus,
        'statusMessage': ?statusMessage,
      },
    );
    return ArtistProfileDto.fromJson(json);
  }

  Future<List<PortfolioImageDto>> getPortfolioImages(String profileId) async {
    final json = await _client.getList(
      '/artist-profiles/$profileId/portfolio-images',
    );
    return json.map(PortfolioImageDto.fromJson).toList();
  }

  Future<PortfolioImageDto> addPortfolioImage({
    required String profileId,
    required String imageUrl,
    int sortOrder = 0,
  }) async {
    final json = await _client.post(
      '/artist-profiles/$profileId/portfolio-images',
      body: {
        'imageUrl': imageUrl,
        'sortOrder': sortOrder,
      },
    );
    return PortfolioImageDto.fromJson(json);
  }

  Future<List<PortfolioImageDto>> reorderPortfolioImages({
    required String profileId,
    required String userId,
    required List<String> orderedIds,
  }) async {
    final json = await _client.patchList(
      '/artist-profiles/$profileId/portfolio-images/reorder',
      queryParameters: {'userId': userId},
      body: {'orderedIds': orderedIds},
    );
    return json.map(PortfolioImageDto.fromJson).toList();
  }

  Future<void> deletePortfolioImage({
    required String imageId,
    required String userId,
  }) async {
    await _client.delete(
      '/portfolio-images/$imageId',
      queryParameters: {'userId': userId},
    );
  }

  Future<List<ArtistNoticeDto>> getNotices(
    String profileId, {
    bool manage = false,
  }) async {
    final json = await _client.getList(
      '/artist-profiles/$profileId/notices',
      queryParameters: {
        if (manage) 'manage': 'true',
      },
    );
    return json.map(ArtistNoticeDto.fromJson).toList();
  }

  Future<ArtistNoticeDto> createNotice({
    required String profileId,
    required String type,
    required String title,
    String? content,
    List<String>? bulletPoints,
    bool? isPublic,
    bool? isActive,
  }) async {
    final json = await _client.post(
      '/artist-profiles/$profileId/notices',
      body: {
        'type': type,
        'title': title,
        'content': ?content,
        'bulletPoints': ?bulletPoints,
        'isPublic': ?isPublic,
        'isActive': ?isActive,
      },
    );
    return ArtistNoticeDto.fromJson(json);
  }

  Future<ArtistNoticeDto> updateNotice({
    required String noticeId,
    required String userId,
    String? type,
    String? title,
    String? content,
    List<String>? bulletPoints,
    bool? isPublic,
    bool? isActive,
  }) async {
    final json = await _client.patch(
      '/artist-notices/$noticeId',
      queryParameters: {'userId': userId},
      body: {
        'type': ?type,
        'title': ?title,
        'content': ?content,
        'bulletPoints': ?bulletPoints,
        'isPublic': ?isPublic,
        'isActive': ?isActive,
      },
    );
    return ArtistNoticeDto.fromJson(json);
  }

  Future<void> deleteNotice({
    required String noticeId,
    required String userId,
  }) async {
    await _client.delete(
      '/artist-notices/$noticeId',
      queryParameters: {'userId': userId},
    );
  }

  Future<List<SocialLinkDto>> getSocialLinks(String profileId) async {
    final json = await _client.getList(
      '/artist-profiles/$profileId/social-links',
    );
    return json.map(SocialLinkDto.fromJson).toList();
  }

  Future<SocialLinkDto> createSocialLink({
    required String profileId,
    required String type,
    String? label,
    required String url,
  }) async {
    final json = await _client.post(
      '/artist-profiles/$profileId/social-links',
      body: {
        'type': type,
        'label': ?label,
        'url': url,
      },
    );
    return SocialLinkDto.fromJson(json);
  }

  Future<SocialLinkDto> updateSocialLink({
    required String linkId,
    required String userId,
    String? type,
    String? label,
    String? url,
  }) async {
    final json = await _client.patch(
      '/artist-social-links/$linkId',
      queryParameters: {'userId': userId},
      body: {
        'type': ?type,
        'label': ?label,
        'url': ?url,
      },
    );
    return SocialLinkDto.fromJson(json);
  }

  Future<void> deleteSocialLink({
    required String linkId,
    required String userId,
  }) async {
    await _client.delete(
      '/artist-social-links/$linkId',
      queryParameters: {'userId': userId},
    );
  }

  Future<
      ({
        ArtistProfileDto profile,
        List<PortfolioImageDto> portfolio,
        List<ArtistNoticeDto> notices,
        List<SocialLinkDto> socialLinks,
      })> getPublicBundle(String id) async {
    final profile = await getById(id);
    final (portfolio, notices, socialLinks) = await (
      _safeList(() => getPortfolioImages(id)),
      _safeList(() => getNotices(id)),
      _safeList(() => getSocialLinks(id)),
    ).wait;

    return (
      profile: profile,
      portfolio: portfolio,
      notices: notices,
      socialLinks: socialLinks,
    );
  }

  Future<List<T>> _safeList<T>(Future<List<T>> Function() fetch) async {
    try {
      return await fetch();
    } catch (_) {
      return <T>[];
    }
  }
}
