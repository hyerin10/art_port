import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/mypage/data/dto/support_inquiry_dto.dart';

class SupportRepository {
  SupportRepository(this._client);

  final ApiClient _client;

  Future<List<SupportInquiryDto>> getMy() async {
    final json = await _client.getList('/support/my');
    return json.map(SupportInquiryDto.fromJson).toList();
  }

  Future<List<SupportInquiryDto>> getAllForAdmin({String? status}) async {
    final json = await _client.getList(
      '/support/inquiries',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return json.map(SupportInquiryDto.fromJson).toList();
  }

  Future<SupportInquiryDto> updateStatus({
    required String inquiryId,
    required String status,
  }) async {
    final json = await _client.patch(
      '/support/inquiries/$inquiryId/status',
      body: {'status': status},
    );
    return SupportInquiryDto.fromJson(json);
  }

  Future<SupportInquiryDto> getById(String inquiryId) async {
    final json = await _client.get('/support/inquiries/$inquiryId');
    return SupportInquiryDto.fromJson(json);
  }

  Future<SupportInquiryDto> create({
    required String category,
    String? title,
    required String content,
  }) async {
    final json = await _client.post(
      '/support/inquiries',
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
    required String content,
  }) async {
    final json = await _client.post(
      '/support/inquiries/$inquiryId/messages',
      body: {'content': content},
    );
    return SupportMessageDto.fromJson(json);
  }
}
