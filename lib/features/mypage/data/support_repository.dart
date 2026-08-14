import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/mypage/data/dto/support_inquiry_dto.dart';

class SupportRepository {
  SupportRepository(this._client);

  final ApiClient _client;

  Future<List<SupportInquiryDto>> getMy(String userId) async {
    final json = await _client.getList(
      '/support/my',
      queryParameters: {'userId': userId},
    );
    return json.map(SupportInquiryDto.fromJson).toList();
  }

  Future<List<SupportInquiryDto>> getAllForAdmin({
    required String adminUserId,
    String? status,
  }) async {
    final json = await _client.getList(
      '/support/inquiries',
      queryParameters: {
        'adminUserId': adminUserId,
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return json.map(SupportInquiryDto.fromJson).toList();
  }

  Future<SupportInquiryDto> updateStatus({
    required String inquiryId,
    required String adminUserId,
    required String status,
  }) async {
    final json = await _client.patch(
      '/support/inquiries/$inquiryId/status',
      queryParameters: {'adminUserId': adminUserId},
      body: {'status': status},
    );
    return SupportInquiryDto.fromJson(json);
  }

  Future<SupportInquiryDto> getById({
    required String inquiryId,
    required String userId,
  }) async {
    final json = await _client.get(
      '/support/inquiries/$inquiryId',
      queryParameters: {'userId': userId},
    );
    return SupportInquiryDto.fromJson(json);
  }

  Future<SupportInquiryDto> create({
    required String userId,
    required String category,
    String? title,
    required String content,
  }) async {
    final json = await _client.post(
      '/support/inquiries',
      queryParameters: {'userId': userId},
      body: {
        'category': category,
        'title': ?title,
        'content': content,
      },
    );
    return SupportInquiryDto.fromJson(json);
  }

  Future<SupportMessageDto> addMessage({
    required String inquiryId,
    required String userId,
    required String content,
  }) async {
    final json = await _client.post(
      '/support/inquiries/$inquiryId/messages',
      queryParameters: {'userId': userId},
      body: {'content': content},
    );
    return SupportMessageDto.fromJson(json);
  }
}
