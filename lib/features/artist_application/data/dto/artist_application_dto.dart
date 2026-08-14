import 'package:art_port/core/network/json_parsers.dart';

class ArtistApplicationDto {
  const ArtistApplicationDto({
    required this.id,
    required this.userId,
    required this.artistName,
    required this.status,
    this.bankName = '',
    this.accountNumber = '',
    this.accountHolder = '',
    this.portfolioImageUrls = const [],
    this.verificationFileUrls = const [],
    this.styleTags = const [],
    this.maxWorkDays,
    this.roughRevisionCount,
    this.finalRevisionCount,
    this.allowNonCommercial = true,
    this.allowCommercialStreaming = false,
    this.allowCopyrightTransfer = false,
    this.rejectionReason,
    this.createdAt,
  });

  final String id;
  final String userId;
  final String artistName;
  final String status;
  final String bankName;
  final String accountNumber;
  final String accountHolder;
  final List<String> portfolioImageUrls;
  final List<String> verificationFileUrls;
  final List<String> styleTags;
  final int? maxWorkDays;
  final int? roughRevisionCount;
  final int? finalRevisionCount;
  final bool allowNonCommercial;
  final bool allowCommercialStreaming;
  final bool allowCopyrightTransfer;
  final String? rejectionReason;
  final DateTime? createdAt;

  factory ArtistApplicationDto.fromJson(Map<String, dynamic> json) {
    return ArtistApplicationDto(
      id: JsonParsers.string(json['id']),
      userId: JsonParsers.string(json['userId']),
      artistName: JsonParsers.string(json['artistName']),
      status: JsonParsers.string(json['status'], 'pending'),
      bankName: JsonParsers.string(json['bankName']),
      accountNumber: JsonParsers.string(json['accountNumber']),
      accountHolder: JsonParsers.string(json['accountHolder']),
      portfolioImageUrls: JsonParsers.stringList(json['portfolioImageUrls']),
      verificationFileUrls: JsonParsers.stringList(json['verificationFileUrls']),
      styleTags: JsonParsers.stringList(json['styleTags']),
      maxWorkDays: json['maxWorkDays'] == null
          ? null
          : JsonParsers.integer(json['maxWorkDays']),
      roughRevisionCount: json['roughRevisionCount'] == null
          ? null
          : JsonParsers.integer(json['roughRevisionCount']),
      finalRevisionCount: json['finalRevisionCount'] == null
          ? null
          : JsonParsers.integer(json['finalRevisionCount']),
      allowNonCommercial: JsonParsers.boolean(json['allowNonCommercial'], true),
      allowCommercialStreaming:
          JsonParsers.boolean(json['allowCommercialStreaming']),
      allowCopyrightTransfer:
          JsonParsers.boolean(json['allowCopyrightTransfer']),
      rejectionReason: JsonParsers.optionalString(json['rejectionReason']),
      createdAt: JsonParsers.dateTime(json['createdAt']),
    );
  }

  bool get isPending => status == 'pending';

  String get statusLabel => switch (status) {
        'approved' => '승인',
        'rejected' => '거절',
        _ => '대기',
      };
}
