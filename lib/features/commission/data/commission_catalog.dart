import 'package:art_port/features/artist_profile/data/dto/artist_profile_dto.dart';
import 'package:art_port/features/commission/data/commission_catalog_mapper.dart';
import 'package:art_port/features/commission/data/dto/commission_type_dto.dart';
import 'package:art_port/features/commission/models/commission_detail.dart';
import 'package:art_port/features/explore/models/commission_sample.dart';
import 'package:art_port/features/search/models/search_commission.dart';

/// 아티스트·커미션 목록을 한 번 불러와 탐색/검색/상세에 재사용한다.
class CommissionCatalog {
  CommissionCatalog({required this.artists, required this.types})
    : artistsById = {for (final artist in artists) artist.id: artist};

  final List<ArtistProfileDto> artists;
  final List<CommissionTypeDto> types;
  final Map<String, ArtistProfileDto> artistsById;

  static const featuredBannerFallback =
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&h=400&fit=crop';

  ArtistProfileDto? artistOf(CommissionTypeDto type) =>
      artistsById[type.artistProfileId];

  List<CommissionTypeDto> get _sortedTypes {
    final sorted = [...types]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  List<CommissionSample> get gallerySamples {
    return [
      for (final type in _sortedTypes)
        CommissionCatalogMapper.toGallerySample(type, artistOf(type)),
    ];
  }

  List<LiveSlotSample> get liveSlots {
    return [
      for (final type in _sortedTypes)
        ?CommissionCatalogMapper.toLiveSlot(type, artistOf(type)),
    ];
  }

  List<SearchCommissionItem> get searchItems {
    final sorted = _sortedTypes;
    return [
      for (var i = 0; i < sorted.length; i++)
        CommissionCatalogMapper.toSearchItem(
          sorted[i],
          artistOf(sorted[i]),
          sortOrder: i,
        ),
    ];
  }

  List<String> get categoryTags {
    final seen = <String>{};
    final tags = <String>[];
    for (final type in types) {
      for (final tag in CommissionCatalogMapper.hashedTags(type.tags)) {
        if (seen.add(tag)) {
          tags.add(tag);
        }
      }
    }
    return tags;
  }

  String get featuredBannerImage {
    for (final artist in artists) {
      final url = artist.backgroundUrl;
      if (url != null && url.isNotEmpty) return url;
    }
    for (final type in types) {
      final url = type.primaryImageUrl;
      if (url != null && url.isNotEmpty) return url;
    }
    return featuredBannerFallback;
  }

  CommissionDetail? detailFor(String commissionId) {
    for (final type in types) {
      if (type.id == commissionId) {
        return CommissionCatalogMapper.toDetail(type, artistOf(type));
      }
    }
    return null;
  }
}
