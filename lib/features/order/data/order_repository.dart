import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/order/data/dto/order_dto.dart';

class OrderRepository {
  OrderRepository(this._client);

  final ApiClient _client;

  Future<OrderDto> getById({
    required String orderId,
    required String userId,
  }) async {
    final json = await _client.get(
      '/orders/$orderId',
      queryParameters: {'userId': userId},
    );
    return OrderDto.fromJson(json);
  }

  Future<List<OrderDto>> getMyClient(String userId) async {
    final json = await _client.getList(
      '/orders/my/client',
      queryParameters: {'userId': userId},
    );
    return json.map(OrderDto.fromJson).toList();
  }

  Future<List<OrderDto>> getMyArtist(String userId) async {
    final json = await _client.getList(
      '/orders/my/artist',
      queryParameters: {'userId': userId},
    );
    return json.map(OrderDto.fromJson).toList();
  }

  Future<OrderDto> submit({
    required String clientId,
    required String commissionTypeId,
    required String requestContent,
    List<String>? referenceImageUrls,
    String? usagePurpose,
    String? desiredDeadline,
    Map<String, dynamic>? selectedOption,
  }) async {
    final json = await _client.post(
      '/orders',
      queryParameters: {'clientId': clientId},
      body: {
        'commissionTypeId': commissionTypeId,
        'requestContent': requestContent,
        'referenceImageUrls': ?referenceImageUrls,
        'usagePurpose': ?usagePurpose,
        'desiredDeadline': ?desiredDeadline,
        'selectedOption': ?selectedOption,
      },
    );
    return OrderDto.fromJson(json);
  }

  Future<OrderDto> accept({
    required String orderId,
    required String artistId,
  }) async {
    final json = await _client.patch(
      '/orders/$orderId/accept',
      queryParameters: {'artistId': artistId},
    );
    return OrderDto.fromJson(json);
  }

  Future<OrderDto> reject({
    required String orderId,
    required String artistId,
    required String reason,
  }) async {
    final json = await _client.patch(
      '/orders/$orderId/reject',
      queryParameters: {'artistId': artistId},
      body: {'reason': reason},
    );
    return OrderDto.fromJson(json);
  }

  Future<OrderDto> updateStep({
    required String orderId,
    required String userId,
    required String newStep,
  }) async {
    final json = await _client.patch(
      '/orders/$orderId/step',
      queryParameters: {'userId': userId},
      body: {'newStep': newStep},
    );
    return OrderDto.fromJson(json);
  }
}
