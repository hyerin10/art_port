import 'package:art_port/features/explore/models/commission_sample.dart';
import 'package:art_port/features/search/models/search_commission.dart';

/// 작가 최근 작품 썸네일
class ArtistRecentWork {
  const ArtistRecentWork({
    required this.commissionId,
    required this.imageUrl,
  });

  final String commissionId;
  final String imageUrl;
}

/// 팔로우한 작가 목록 카드용 프로필 모델
class FollowedArtistProfile {
  const FollowedArtistProfile({
    required this.id,
    required this.name,
    required this.displayName,
    required this.avatarUrl,
    required this.specialtiesLabel,
    required this.recentWorks,
  });

  final String id;
  final String name;
  final String displayName;
  final String avatarUrl;
  final String specialtiesLabel;
  final List<ArtistRecentWork> recentWorks;
}

/// 작가 프로필 카탈로그 — 더미 데이터 기반 (추후 API 교체)
abstract final class ArtistCatalog {
  static const _displayNameOverrides = {
    '초코쌤': 'ChocoArt',
    '미유_Miyu': 'MikaArt',
    '네오네오': 'NeoNeo',
    '하늘픽셀': 'SkyPixel',
    '루나린': 'LunaLin',
    '루나픽셀': 'LunaPixel',
    '별하늘님': 'StarSky',
    '하늘조각': 'SkyPiece',
    '소라드로우': 'SoraDraw',
    '민트캣': 'MintCat',
    '사쿠라펜': 'SakuraPen',
    '모모캔': 'MomoCan',
    '별빛작가': 'Starlight',
    'PixelDreams': 'PixelDreams',
  };

  static const _idOverrides = {
    '초코쌤': 'choco-art',
    '미유_Miyu': 'mika-art',
    '네오네오': 'neoneo',
    '하늘픽셀': 'sky-pixel',
    '루나린': 'luna-lin',
    '루나픽셀': 'luna-pixel',
    '별하늘님': 'star-sky',
    '하늘조각': 'sky-piece',
    '소라드로우': 'sora-draw',
    '민트캣': 'mint-cat',
    '사쿠라펜': 'sakura-pen',
    '모모캔': 'momo-can',
    '별빛작가': 'starlight',
    'PixelDreams': 'pixel-dreams',
  };

  static final Map<String, FollowedArtistProfile> _profiles = _buildProfiles();

  static Map<String, FollowedArtistProfile> _buildProfiles() {
    final grouped = <String, _ArtistAccumulator>{};

    void addCommission({
      required String artistName,
      required String artistAvatarUrl,
      required String commissionId,
      required String imageUrl,
      required List<String> tags,
    }) {
      final id = idForName(artistName);
      grouped.putIfAbsent(
        id,
        () => _ArtistAccumulator(
          id: id,
          name: artistName,
          avatarUrl: artistAvatarUrl,
        ),
      );
      final acc = grouped[id]!;
      acc.avatarUrl ??= artistAvatarUrl;
      for (final tag in tags) {
        acc.tags.add(tag.replaceAll('#', ''));
      }
      if (acc.works.length < 3) {
        acc.works.add(ArtistRecentWork(
          commissionId: commissionId,
          imageUrl: imageUrl,
        ));
      }
    }

    for (final item in SearchDummyData.commissions) {
      addCommission(
        artistName: item.artistName,
        artistAvatarUrl: item.artistAvatarUrl,
        commissionId: item.id,
        imageUrl: item.imageUrl,
        tags: item.tags,
      );
    }

    for (final sample in ExploreDummyData.gallerySamples) {
      addCommission(
        artistName: sample.artistName,
        artistAvatarUrl: sample.artistAvatarUrl,
        commissionId: sample.id,
        imageUrl: sample.imageUrl,
        tags: sample.tags,
      );
    }

    return {
      for (final acc in grouped.values)
        acc.id: FollowedArtistProfile(
          id: acc.id,
          name: acc.name,
          displayName: _displayNameOverrides[acc.name] ?? acc.name,
          avatarUrl: acc.avatarUrl!,
          specialtiesLabel: _formatSpecialties(acc.tags),
          recentWorks: acc.works,
        ),
    };
  }

  static String idForName(String artistName) =>
      _idOverrides[artistName] ??
      artistName.toLowerCase().replaceAll(RegExp(r'\s+'), '-');

  static FollowedArtistProfile? forId(String id) => _profiles[id];

  static FollowedArtistProfile? forName(String artistName) =>
      _profiles[idForName(artistName)];

  static List<FollowedArtistProfile> get allProfiles =>
      _profiles.values.toList();

  static String _formatSpecialties(Set<String> tags) {
    final list = tags.take(3).toList();
    if (list.isEmpty) return 'Illustration, Character';
    return list.join(', ');
  }
}

class _ArtistAccumulator {
  _ArtistAccumulator({
    required this.id,
    required this.name,
    required this.avatarUrl,
  });

  final String id;
  final String name;
  String? avatarUrl;
  final Set<String> tags = {};
  final List<ArtistRecentWork> works = [];
}
