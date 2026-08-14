import 'package:art_port/core/network/json_parsers.dart';

class ArtistProfileDto {
  const ArtistProfileDto({
    required this.id,
    required this.userId,
    required this.displayName,
    this.avatarUrl,
    this.backgroundUrl,
    this.oneLineIntro,
    this.detailedIntro,
    this.workingHours,
    this.averageDeliveryDays,
    this.revisionPolicy,
    this.paymentTerms,
    required this.specialties,
    required this.restrictedItems,
    required this.rating,
    required this.reviewCount,
    required this.followerCount,
    required this.completedCount,
    required this.responseRatePercent,
    required this.isRestMode,
    required this.slotStatus,
    this.statusMessage,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String displayName;
  final String? avatarUrl;
  final String? backgroundUrl;
  final String? oneLineIntro;
  final String? detailedIntro;
  final String? workingHours;
  final int? averageDeliveryDays;
  final String? revisionPolicy;
  final String? paymentTerms;
  final List<String> specialties;
  final List<String> restrictedItems;
  final double rating;
  final int reviewCount;
  final int followerCount;
  final int completedCount;
  final int responseRatePercent;
  final bool isRestMode;
  final String slotStatus;
  final String? statusMessage;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isSlotOpen => !isRestMode && slotStatus == 'open';

  factory ArtistProfileDto.fromJson(Map<String, dynamic> json) {
    final deliveryDays = json['averageDeliveryDays'];
    return ArtistProfileDto(
      id: JsonParsers.string(json['id']),
      userId: JsonParsers.string(json['userId']),
      displayName: JsonParsers.string(json['displayName']),
      avatarUrl: JsonParsers.optionalString(json['avatarUrl']),
      backgroundUrl: JsonParsers.optionalString(json['backgroundUrl']),
      oneLineIntro: JsonParsers.optionalString(json['oneLineIntro']),
      detailedIntro: JsonParsers.optionalString(json['detailedIntro']),
      workingHours: JsonParsers.optionalString(json['workingHours']),
      averageDeliveryDays:
          deliveryDays == null ? null : JsonParsers.integer(deliveryDays),
      revisionPolicy: JsonParsers.optionalString(json['revisionPolicy']),
      paymentTerms: JsonParsers.optionalString(json['paymentTerms']),
      specialties: JsonParsers.stringList(json['specialties']),
      restrictedItems: JsonParsers.stringList(json['restrictedItems']),
      rating: JsonParsers.decimal(json['rating']),
      reviewCount: JsonParsers.integer(json['reviewCount']),
      followerCount: JsonParsers.integer(json['followerCount']),
      completedCount: JsonParsers.integer(json['completedCount']),
      responseRatePercent: JsonParsers.integer(json['responseRatePercent']),
      isRestMode: JsonParsers.boolean(json['isRestMode']),
      slotStatus: JsonParsers.string(json['slotStatus'], 'closed'),
      statusMessage: JsonParsers.optionalString(json['statusMessage']),
      isVerified: JsonParsers.boolean(json['isVerified']),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
      updatedAt: JsonParsers.requireDateTime(json['updatedAt']),
    );
  }
}

class PortfolioImageDto {
  const PortfolioImageDto({
    required this.id,
    required this.artistProfileId,
    required this.imageUrl,
    required this.sortOrder,
  });

  final String id;
  final String artistProfileId;
  final String imageUrl;
  final int sortOrder;

  factory PortfolioImageDto.fromJson(Map<String, dynamic> json) {
    return PortfolioImageDto(
      id: JsonParsers.string(json['id']),
      artistProfileId: JsonParsers.string(json['artistProfileId']),
      imageUrl: JsonParsers.string(json['imageUrl']),
      sortOrder: JsonParsers.integer(json['sortOrder']),
    );
  }
}

class ArtistNoticeDto {
  const ArtistNoticeDto({
    required this.id,
    required this.artistProfileId,
    required this.type,
    required this.title,
    this.content,
    required this.bulletPoints,
    required this.isPublic,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String artistProfileId;
  final String type;
  final String title;
  final String? content;
  final List<String> bulletPoints;
  final bool isPublic;
  final bool isActive;
  final DateTime createdAt;

  bool get isPinned => type == 'pinned';

  factory ArtistNoticeDto.fromJson(Map<String, dynamic> json) {
    return ArtistNoticeDto(
      id: JsonParsers.string(json['id']),
      artistProfileId: JsonParsers.string(json['artistProfileId']),
      type: JsonParsers.string(json['type'], 'general'),
      title: JsonParsers.string(json['title']),
      content: JsonParsers.optionalString(json['content']),
      bulletPoints: JsonParsers.stringList(json['bulletPoints']),
      isPublic: JsonParsers.boolean(json['isPublic'], true),
      isActive: JsonParsers.boolean(json['isActive'], true),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
    );
  }
}

class SocialLinkDto {
  const SocialLinkDto({
    required this.id,
    required this.artistProfileId,
    required this.type,
    this.label,
    required this.url,
  });

  final String id;
  final String artistProfileId;
  final String type;
  final String? label;
  final String url;

  factory SocialLinkDto.fromJson(Map<String, dynamic> json) {
    return SocialLinkDto(
      id: JsonParsers.string(json['id']),
      artistProfileId: JsonParsers.string(json['artistProfileId']),
      type: JsonParsers.string(json['type'], 'other'),
      label: JsonParsers.optionalString(json['label']),
      url: JsonParsers.string(json['url']),
    );
  }
}
