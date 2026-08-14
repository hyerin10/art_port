import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/artist_application/data/dto/artist_application_dto.dart';

class ArtistApplicationRepository {
  ArtistApplicationRepository(this._client);

  final ApiClient _client;

  Future<ArtistApplicationDto> getMyApplication(String userId) async {
    final json = await _client.get(
      '/artist-applications/my',
      queryParameters: {'userId': userId},
    );
    return ArtistApplicationDto.fromJson(json);
  }

  Future<ArtistApplicationDto> apply({
    required String userId,
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
        'userId': userId,
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
}
