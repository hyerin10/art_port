/// 커미션 타입 샘플 이미지
class CommissionSampleImage {
  const CommissionSampleImage({
    required this.id,
    this.localPath,
    this.networkUrl,
  });

  final String id;
  final String? localPath;
  final String? networkUrl;

  String? get displaySource => localPath ?? networkUrl;

  CommissionSampleImage copyWith({
    String? id,
    String? localPath,
    String? networkUrl,
    bool clearLocalPath = false,
    bool clearNetworkUrl = false,
  }) {
    return CommissionSampleImage(
      id: id ?? this.id,
      localPath: clearLocalPath ? null : (localPath ?? this.localPath),
      networkUrl: clearNetworkUrl ? null : (networkUrl ?? this.networkUrl),
    );
  }
}

/// 아티스트 커미션 타입
class ArtistCommissionType {
  const ArtistCommissionType({
    required this.id,
    required this.name,
    required this.startingPriceWon,
    required this.workPeriod,
    required this.totalSlots,
    required this.openSlots,
    required this.description,
    required this.sampleImages,
    this.thumbnailNetworkUrl,
    this.thumbnailLocalPath,
    this.isActive = true,
  });

  final String id;
  final String name;
  final int startingPriceWon;
  final String workPeriod;
  final int totalSlots;
  final int openSlots;
  final String description;
  final List<CommissionSampleImage> sampleImages;
  final String? thumbnailNetworkUrl;
  final String? thumbnailLocalPath;
  final bool isActive;

  static const int maxSampleImages = 3;

  String? get thumbnailSource =>
      thumbnailLocalPath ??
      thumbnailNetworkUrl ??
      (sampleImages.isNotEmpty ? sampleImages.first.displaySource : null);

  bool get isSlotsClosed => openSlots <= 0;

  String get slotStatusLabel {
    if (isSlotsClosed) return '슬롯 마감';
    return '$openSlots/$totalSlots 슬롯 오픈';
  }

  String get formattedPrice => '${formatWon(startingPriceWon)}~';

  static String formatWon(int amount) {
    final text = amount.toString();
    final buffer = StringBuffer('₩');
    for (var i = 0; i < text.length; i++) {
      if (i > 0 && (text.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(text[i]);
    }
    return buffer.toString();
  }

  ArtistCommissionType copyWith({
    String? id,
    String? name,
    int? startingPriceWon,
    String? workPeriod,
    int? totalSlots,
    int? openSlots,
    String? description,
    List<CommissionSampleImage>? sampleImages,
    String? thumbnailNetworkUrl,
    String? thumbnailLocalPath,
    bool? isActive,
    bool clearThumbnailLocalPath = false,
    bool clearThumbnailNetworkUrl = false,
  }) {
    return ArtistCommissionType(
      id: id ?? this.id,
      name: name ?? this.name,
      startingPriceWon: startingPriceWon ?? this.startingPriceWon,
      workPeriod: workPeriod ?? this.workPeriod,
      totalSlots: totalSlots ?? this.totalSlots,
      openSlots: openSlots ?? this.openSlots,
      description: description ?? this.description,
      sampleImages: sampleImages ?? this.sampleImages,
      thumbnailNetworkUrl: clearThumbnailNetworkUrl
          ? null
          : (thumbnailNetworkUrl ?? this.thumbnailNetworkUrl),
      thumbnailLocalPath: clearThumbnailLocalPath
          ? null
          : (thumbnailLocalPath ?? this.thumbnailLocalPath),
      isActive: isActive ?? this.isActive,
    );
  }
}

/// 커미션 타입 설정 목록 상태
class CommissionTypeSettingsState {
  const CommissionTypeSettingsState({
    required this.types,
    required this.savedSnapshot,
    this.isSaving = false,
  });

  final List<ArtistCommissionType> types;
  final List<ArtistCommissionType> savedSnapshot;
  final bool isSaving;

  bool get hasChanges => !_listsEqual(types, savedSnapshot);

  static bool _listsEqual(
    List<ArtistCommissionType> a,
    List<ArtistCommissionType> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final left = a[i];
      final right = b[i];
      if (left.id != right.id ||
          left.name != right.name ||
          left.startingPriceWon != right.startingPriceWon ||
          left.workPeriod != right.workPeriod ||
          left.totalSlots != right.totalSlots ||
          left.openSlots != right.openSlots ||
          left.description != right.description ||
          left.isActive != right.isActive ||
          left.thumbnailLocalPath != right.thumbnailLocalPath ||
          left.thumbnailNetworkUrl != right.thumbnailNetworkUrl ||
          left.sampleImages.length != right.sampleImages.length) {
        return false;
      }
      for (var j = 0; j < left.sampleImages.length; j++) {
        final ls = left.sampleImages[j];
        final rs = right.sampleImages[j];
        if (ls.localPath != rs.localPath || ls.networkUrl != rs.networkUrl) {
          return false;
        }
      }
    }
    return true;
  }

  CommissionTypeSettingsState copyWith({
    List<ArtistCommissionType>? types,
    List<ArtistCommissionType>? savedSnapshot,
    bool? isSaving,
  }) {
    return CommissionTypeSettingsState(
      types: types ?? this.types,
      savedSnapshot: savedSnapshot ?? this.savedSnapshot,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

/// 커미션 타입 추가/수정 폼 상태
class CommissionTypeFormState {
  CommissionTypeFormState({
    this.editingTypeId,
    this.name = '',
    this.startingPrice = '',
    this.workPeriod = '7-14일',
    this.totalSlots = '3',
    this.description = '',
    List<CommissionSampleImage?>? sampleImages,
  }) : sampleImages = sampleImages ??
            List<CommissionSampleImage?>.filled(maxSampleImages, null);

  final String? editingTypeId;
  final String name;
  final String startingPrice;
  final String workPeriod;
  final String totalSlots;
  final String description;
  final List<CommissionSampleImage?> sampleImages;

  static const int maxSampleImages = 3;

  bool get isEditMode => editingTypeId != null;

  int? get parsedStartingPrice => int.tryParse(startingPrice.replaceAll(',', ''));

  int get parsedTotalSlots {
    final value = int.tryParse(totalSlots);
    if (value == null || value < 1) return 1;
    return value;
  }

  bool get isValid {
    final price = parsedStartingPrice;
    return name.trim().isNotEmpty && price != null && price > 0;
  }

  CommissionTypeFormState copyWith({
    String? editingTypeId,
    String? name,
    String? startingPrice,
    String? workPeriod,
    String? totalSlots,
    String? description,
    List<CommissionSampleImage?>? sampleImages,
    bool clearEditingTypeId = false,
  }) {
    return CommissionTypeFormState(
      editingTypeId:
          clearEditingTypeId ? null : (editingTypeId ?? this.editingTypeId),
      name: name ?? this.name,
      startingPrice: startingPrice ?? this.startingPrice,
      workPeriod: workPeriod ?? this.workPeriod,
      totalSlots: totalSlots ?? this.totalSlots,
      description: description ?? this.description,
      sampleImages: sampleImages ?? this.sampleImages,
    );
  }

  factory CommissionTypeFormState.fromType(ArtistCommissionType type) {
    final samples = List<CommissionSampleImage?>.filled(maxSampleImages, null);
    for (var i = 0; i < type.sampleImages.length && i < maxSampleImages; i++) {
      samples[i] = type.sampleImages[i];
    }

    return CommissionTypeFormState(
      editingTypeId: type.id,
      name: type.name,
      startingPrice: type.startingPriceWon.toString(),
      workPeriod: type.workPeriod,
      totalSlots: type.totalSlots.toString(),
      description: type.description,
      sampleImages: samples,
    );
  }
}
