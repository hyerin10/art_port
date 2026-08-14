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
}
