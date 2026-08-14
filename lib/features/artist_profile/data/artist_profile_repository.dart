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

  Future<List<PortfolioImageDto>> getPortfolioImages(String profileId) async {
    final json = await _client.getList(
      '/artist-profiles/$profileId/portfolio-images',
    );
    return json.map(PortfolioImageDto.fromJson).toList();
  }

  Future<List<ArtistNoticeDto>> getNotices(String profileId) async {
    final json = await _client.getList('/artist-profiles/$profileId/notices');
    return json.map(ArtistNoticeDto.fromJson).toList();
  }

  Future<List<SocialLinkDto>> getSocialLinks(String profileId) async {
    final json = await _client.getList(
      '/artist-profiles/$profileId/social-links',
    );
    return json.map(SocialLinkDto.fromJson).toList();
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
