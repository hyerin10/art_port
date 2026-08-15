import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/order/data/dto/order_dto.dart';

class OrderRepository {
  OrderRepository(this._client);

  final ApiClient _client;

  Future<OrderDto> getById(String orderId) async {
    final json = await _client.get('/orders/$orderId');
    return OrderDto.fromJson(json);
  }

  Future<List<OrderDto>> getMyClient() async {
    final json = await _client.getList('/orders/my/client');
    return json.map(OrderDto.fromJson).toList();
  }

  Future<List<OrderDto>> getMyArtist() async {
    final json = await _client.getList('/orders/my/artist');
    return json.map(OrderDto.fromJson).toList();
  }

  Future<OrderDto> submit({
    required String commissionTypeId,
    required String requestContent,
    List<String>? referenceImageUrls,
    String? usagePurpose,
    String? desiredDeadline,
    Map<String, dynamic>? selectedOption,
  }) async {
    final json = await _client.post(
      '/orders',
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

  Future<OrderDto> accept(String orderId) async {
    final json = await _client.patch('/orders/$orderId/accept');
    return OrderDto.fromJson(json);
  }

  Future<OrderDto> reject({
    required String orderId,
    required String reason,
  }) async {
    final json = await _client.patch(
      '/orders/$orderId/reject',
      body: {'reason': reason},
    );
    return OrderDto.fromJson(json);
  }

  Future<OrderDto> updateStep({
    required String orderId,
    required String newStep,
  }) async {
    final json = await _client.patch(
      '/orders/$orderId/step',
      body: {'newStep': newStep},
    );
    return OrderDto.fromJson(json);
  }

  Future<void> cancel({
    required String orderId,
    String? reason,
  }) async {
    final trimmed = reason?.trim();
    await _client.delete(
      '/orders/$orderId',
      body: (trimmed == null || trimmed.isEmpty)
          ? null
          : {'reason': trimmed},
    );
  }
}
