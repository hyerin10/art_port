import 'package:art_port/core/network/json_parsers.dart';
import 'package:art_port/features/commission/models/commission_price_option.dart';

class CommissionTypeDto {
  const CommissionTypeDto({
    required this.id,
    required this.artistProfileId,
    required this.name,
    this.description,
    this.thumbnailUrl,
    required this.startingPriceWon,
    required this.workPeriodDays,
    required this.totalSlots,
    required this.openSlots,
    required this.ageRating,
    required this.tags,
    required this.sampleImageUrls,
    required this.priceOptions,
    this.introText,
    required this.workScopeItems,
    required this.revisionPolicyItems,
    this.noticeText,
    required this.completedCount,
    required this.responseRatePercent,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String artistProfileId;
  final String name;
  final String? description;
  final String? thumbnailUrl;
  final int startingPriceWon;
  final int workPeriodDays;
  final int totalSlots;
  final int openSlots;
  final String ageRating;
  final List<String> tags;
  final List<String> sampleImageUrls;
  final List<CommissionPriceOption> priceOptions;
  final String? introText;
  final List<String> workScopeItems;
  final List<String> revisionPolicyItems;
  final String? noticeText;
  final int completedCount;
  final int responseRatePercent;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  String? get primaryImageUrl {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) {
      return thumbnailUrl;
    }
    if (sampleImageUrls.isNotEmpty) {
      return sampleImageUrls.first;
    }
    return null;
  }

  List<String> get imageUrls {
    final urls = <String>[];
    void add(String? url) {
      if (url == null || url.isEmpty || urls.contains(url)) return;
      urls.add(url);
    }

    add(thumbnailUrl);
    for (final url in sampleImageUrls) {
      add(url);
    }
    return urls;
  }

  factory CommissionTypeDto.fromJson(Map<String, dynamic> json) {
    return CommissionTypeDto(
      id: JsonParsers.string(json['id']),
      artistProfileId: JsonParsers.string(json['artistProfileId']),
      name: JsonParsers.string(json['name']),
      description: JsonParsers.optionalString(json['description']),
      thumbnailUrl: JsonParsers.optionalString(json['thumbnailUrl']),
      startingPriceWon: JsonParsers.integer(json['startingPriceWon']),
      workPeriodDays: JsonParsers.integer(json['workPeriodDays']),
      totalSlots: JsonParsers.integer(json['totalSlots']),
      openSlots: JsonParsers.integer(json['openSlots']),
      ageRating: JsonParsers.string(json['ageRating'], 'all'),
      tags: JsonParsers.stringList(json['tags']),
      sampleImageUrls: JsonParsers.stringList(json['sampleImageUrls']),
      priceOptions: JsonParsers.objectList(
        json['priceOptions'],
      ).map(_priceOptionFromJson).toList(),
      introText: JsonParsers.optionalString(json['introText']),
      workScopeItems: JsonParsers.stringList(json['workScopeItems']),
      revisionPolicyItems: JsonParsers.stringList(json['revisionPolicyItems']),
      noticeText: JsonParsers.optionalString(json['noticeText']),
      completedCount: JsonParsers.integer(json['completedCount']),
      responseRatePercent: JsonParsers.integer(json['responseRatePercent']),
      isActive: JsonParsers.boolean(json['isActive'], true),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
      updatedAt: JsonParsers.requireDateTime(json['updatedAt']),
    );
  }

  static CommissionPriceOption _priceOptionFromJson(Map<String, dynamic> json) {
    return CommissionPriceOption(
      label: JsonParsers.string(json['label']),
      priceWon: JsonParsers.integer(json['priceWon']),
    );
  }
}
