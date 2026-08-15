import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/artist_application/data/dto/artist_application_dto.dart';

class ArtistApplicationRepository {
  ArtistApplicationRepository(this._client);

  final ApiClient _client;

  Future<ArtistApplicationDto> getMyApplication() async {
    final json = await _client.get('/artist-applications/my');
    return ArtistApplicationDto.fromJson(json);
  }

  Future<ArtistApplicationDto> apply({
    required String artistName,
    required String bankName,
    required String accountNumber,
    required String accountHolder,
    List<String>? portfolioImageUrls,
    List<String>? verificationFileUrls,
    List<String>? styleTags,
    int? maxWorkDays,
    int? roughRevisionCount,
    int? finalRevisionCount,
    bool? allowNonCommercial,
    bool? allowCommercialStreaming,
    bool? allowCopyrightTransfer,
    required DateTime termsAgreedAt,
  }) async {
    final json = await _client.post(
      '/artist-applications',
      body: {
        'artistName': artistName,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolder': accountHolder,
        'portfolioImageUrls': ?portfolioImageUrls,
        'verificationFileUrls': ?verificationFileUrls,
        'styleTags': ?styleTags,
        'maxWorkDays': ?maxWorkDays,
        'roughRevisionCount': ?roughRevisionCount,
        'finalRevisionCount': ?finalRevisionCount,
        'allowNonCommercial': ?allowNonCommercial,
        'allowCommercialStreaming': ?allowCommercialStreaming,
        'allowCopyrightTransfer': ?allowCopyrightTransfer,
        'termsAgreedAt': termsAgreedAt.toUtc().toIso8601String(),
      },
    );
    return ArtistApplicationDto.fromJson(json);
  }

  Future<List<ArtistApplicationDto>> getAllForAdmin({String? status}) async {
    final json = await _client.getList(
      '/artist-applications',
      queryParameters: {
        if (status != null && status.isNotEmpty) 'status': status,
      },
    );
    return json.map(ArtistApplicationDto.fromJson).toList();
  }

  Future<ArtistApplicationDto> review({
    required String applicationId,
    required String status,
    String? rejectionReason,
  }) async {
    final json = await _client.patch(
      '/artist-applications/$applicationId/review',
      body: {
        'status': status,
        'rejectionReason': ?rejectionReason,
      },
    );
    return ArtistApplicationDto.fromJson(json);
  }
}
