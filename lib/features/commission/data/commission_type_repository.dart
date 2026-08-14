import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/commission/data/dto/commission_type_dto.dart';

class CommissionTypeRepository {
  CommissionTypeRepository(this._client);

  final ApiClient _client;

  Future<List<CommissionTypeDto>> getAll() async {
    final json = await _client.getList('/commission-types');
    return json.map(CommissionTypeDto.fromJson).toList();
  }

  Future<CommissionTypeDto> getById(String id) async {
    final json = await _client.get('/commission-types/$id');
    return CommissionTypeDto.fromJson(json);
  }

  Future<List<CommissionTypeDto>> getByArtistProfileId(String profileId) async {
    final json = await _client.getList(
      '/artist-profiles/$profileId/commission-types',
    );
    return json.map(CommissionTypeDto.fromJson).toList();
  }

  Future<CommissionTypeDto> create({
    required String artistProfileId,
    required String name,
    String? description,
    String? thumbnailUrl,
    required int startingPriceWon,
    required int workPeriodDays,
    int? totalSlots,
    int? openSlots,
    String? ageRating,
    List<String>? tags,
    List<String>? sampleImageUrls,
    List<Map<String, Object>>? priceOptions,
    String? introText,
    List<String>? workScopeItems,
    List<String>? revisionPolicyItems,
    String? noticeText,
    bool? isActive,
  }) async {
    final json = await _client.post(
      '/commission-types',
      body: {
        'artistProfileId': artistProfileId,
        'name': name,
        'description': ?description,
        'thumbnailUrl': ?thumbnailUrl,
        'startingPriceWon': startingPriceWon,
        'workPeriodDays': workPeriodDays,
        'totalSlots': ?totalSlots,
        'openSlots': ?openSlots,
        'ageRating': ?ageRating,
        'tags': ?tags,
        'sampleImageUrls': ?sampleImageUrls,
        'priceOptions': ?priceOptions,
        'introText': ?introText,
        'workScopeItems': ?workScopeItems,
        'revisionPolicyItems': ?revisionPolicyItems,
        'noticeText': ?noticeText,
        'isActive': ?isActive,
      },
    );
    return CommissionTypeDto.fromJson(json);
  }

  Future<CommissionTypeDto> update({
    required String typeId,
    required String userId,
    String? name,
    String? description,
    String? thumbnailUrl,
    int? startingPriceWon,
    int? workPeriodDays,
    int? totalSlots,
    int? openSlots,
    String? ageRating,
    List<String>? tags,
    List<String>? sampleImageUrls,
    List<Map<String, Object>>? priceOptions,
    String? introText,
    List<String>? workScopeItems,
    List<String>? revisionPolicyItems,
    String? noticeText,
    bool? isActive,
  }) async {
    final json = await _client.patch(
      '/commission-types/$typeId',
      queryParameters: {'userId': userId},
      body: {
        'name': ?name,
        'description': ?description,
        'thumbnailUrl': ?thumbnailUrl,
        'startingPriceWon': ?startingPriceWon,
        'workPeriodDays': ?workPeriodDays,
        'totalSlots': ?totalSlots,
        'openSlots': ?openSlots,
        'ageRating': ?ageRating,
        'tags': ?tags,
        'sampleImageUrls': ?sampleImageUrls,
        'priceOptions': ?priceOptions,
        'introText': ?introText,
        'workScopeItems': ?workScopeItems,
        'revisionPolicyItems': ?revisionPolicyItems,
        'noticeText': ?noticeText,
        'isActive': ?isActive,
      },
    );
    return CommissionTypeDto.fromJson(json);
  }

  Future<void> delete({
    required String typeId,
    required String userId,
  }) async {
    await _client.delete(
      '/commission-types/$typeId',
      queryParameters: {'userId': userId},
    );
  }
}
