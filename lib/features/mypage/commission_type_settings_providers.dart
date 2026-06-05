import 'dart:developer' as developer;

import 'package:art_port/features/mypage/models/commission_type_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commissionTypeSettingsProvider =
    NotifierProvider<CommissionTypeSettingsNotifier, CommissionTypeSettingsState>(
  CommissionTypeSettingsNotifier.new,
);

class CommissionTypeSettingsNotifier
    extends Notifier<CommissionTypeSettingsState> {
  static List<ArtistCommissionType> _initialTypes() {
    return const [
      ArtistCommissionType(
        id: 'type-1',
        name: 'SD/Chibi 캐릭터',
        startingPriceWon: 30000,
        workPeriod: '3-5일',
        totalSlots: 5,
        openSlots: 3,
        description: '귀여운 SD 스타일의 캐릭터 일러스트 • 투명 배경 PNG • 1인 1캐릭터 기준',
        thumbnailNetworkUrl:
            'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200&h=200&fit=crop',
        sampleImages: [
          CommissionSampleImage(
            id: 's1-1',
            networkUrl:
                'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=200&h=200&fit=crop',
          ),
          CommissionSampleImage(
            id: 's1-2',
            networkUrl:
                'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=200&h=200&fit=crop',
          ),
          CommissionSampleImage(
            id: 's1-3',
            networkUrl:
                'https://images.unsplash.com/photo-1633356122544-f134324a6cee?w=200&h=200&fit=crop',
          ),
        ],
      ),
      ArtistCommissionType(
        id: 'type-2',
        name: 'Half Body / 반신',
        startingPriceWon: 80000,
        workPeriod: '7-10일',
        totalSlots: 2,
        openSlots: 1,
        description: '허리 위 반신 일러스트 • 배경 포함 • 상세 컬러링',
        thumbnailNetworkUrl:
            'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=200&h=200&fit=crop',
        sampleImages: [
          CommissionSampleImage(
            id: 's2-1',
            networkUrl:
                'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=200&h=200&fit=crop',
          ),
          CommissionSampleImage(
            id: 's2-2',
            networkUrl:
                'https://images.unsplash.com/photo-1614850523459-c2f4c699c52e?w=200&h=200&fit=crop',
          ),
        ],
      ),
      ArtistCommissionType(
        id: 'type-3',
        name: 'Full Body / 전신',
        startingPriceWon: 150000,
        workPeriod: '14-21일',
        totalSlots: 2,
        openSlots: 0,
        description: '전신 캐릭터 일러스트 • 배경 포함 • 고해상도 PNG/JPG',
        thumbnailNetworkUrl:
            'https://images.unsplash.com/photo-1618172193626-ae7fd5fab9d2?w=200&h=200&fit=crop',
        sampleImages: [
          CommissionSampleImage(
            id: 's3-1',
            networkUrl:
                'https://images.unsplash.com/photo-1618172193626-ae7fd5fab9d2?w=200&h=200&fit=crop',
          ),
        ],
        isActive: false,
      ),
    ];
  }

  @override
  CommissionTypeSettingsState build() {
    final initial = _initialTypes();
    return CommissionTypeSettingsState(
      types: initial,
      savedSnapshot: List.from(initial),
    );
  }

  void toggleActive(String id) {
    state = state.copyWith(
      types: [
        for (final type in state.types)
          if (type.id == id) type.copyWith(isActive: !type.isActive) else type,
      ],
    );
  }

  void addType(ArtistCommissionType type) {
    state = state.copyWith(types: [...state.types, type]);
  }

  void updateType(ArtistCommissionType type) {
    state = state.copyWith(
      types: [
        for (final item in state.types)
          if (item.id == type.id) type else item,
      ],
    );
  }

  void removeType(String id) {
    state = state.copyWith(
      types: state.types.where((type) => type.id != id).toList(),
    );
  }

  ArtistCommissionType? findType(String id) {
    for (final type in state.types) {
      if (type.id == id) return type;
    }
    return null;
  }

  Future<bool> saveAll() async {
    if (state.isSaving || !state.hasChanges) return false;

    state = state.copyWith(isSaving: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    developer.log(
      'Commission types saved: ${state.types.length} items',
      name: 'CommissionTypeSettings',
    );

    state = state.copyWith(
      savedSnapshot: List.from(state.types),
      isSaving: false,
    );
    return true;
  }
}

final commissionTypeFormProvider = NotifierProvider.autoDispose
    .family<CommissionTypeFormNotifier, CommissionTypeFormState, String?>(
  CommissionTypeFormNotifier.new,
);

class CommissionTypeFormNotifier
    extends AutoDisposeFamilyNotifier<CommissionTypeFormState, String?> {
  @override
  CommissionTypeFormState build(String? editingTypeId) {
    if (editingTypeId == null) {
      return CommissionTypeFormState();
    }

    final existing =
        ref.read(commissionTypeSettingsProvider.notifier).findType(editingTypeId);
    if (existing != null) {
      return CommissionTypeFormState.fromType(existing);
    }
    return CommissionTypeFormState();
  }

  void updateName(String value) {
    state = state.copyWith(name: value);
  }

  void updateStartingPrice(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    state = state.copyWith(startingPrice: digits);
  }

  void updateWorkPeriod(String value) {
    state = state.copyWith(workPeriod: value);
  }

  void updateTotalSlots(String value) {
    final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
    state = state.copyWith(totalSlots: digits);
  }

  void updateDescription(String value) {
    state = state.copyWith(description: value);
  }

  void setSampleImage(int index, String path) {
    if (index < 0 || index >= CommissionTypeFormState.maxSampleImages) return;

    final next = List<CommissionSampleImage?>.from(state.sampleImages);
    next[index] = CommissionSampleImage(
      id: 'local-${DateTime.now().microsecondsSinceEpoch}-$index',
      localPath: path,
    );
    state = state.copyWith(sampleImages: next);
  }

  void removeSampleImage(int index) {
    if (index < 0 || index >= CommissionTypeFormState.maxSampleImages) return;

    final next = List<CommissionSampleImage?>.from(state.sampleImages);
    next[index] = null;
    state = state.copyWith(sampleImages: next);
  }

  ArtistCommissionType? buildTypeForSubmit() {
    if (!state.isValid) return null;

    final price = state.parsedStartingPrice!;
    final totalSlots = state.parsedTotalSlots;
    final samples = state.sampleImages.whereType<CommissionSampleImage>().toList();

    final thumbnail = samples.isNotEmpty ? samples.first : null;

    if (state.isEditMode) {
      final existing =
          ref.read(commissionTypeSettingsProvider.notifier).findType(state.editingTypeId!);
      if (existing == null) return null;

      return existing.copyWith(
        name: state.name.trim(),
        startingPriceWon: price,
        workPeriod: state.workPeriod.trim(),
        totalSlots: totalSlots,
        openSlots: existing.openSlots.clamp(0, totalSlots),
        description: state.description.trim(),
        sampleImages: samples,
        thumbnailLocalPath: thumbnail?.localPath,
        thumbnailNetworkUrl: thumbnail?.networkUrl,
        clearThumbnailLocalPath: thumbnail?.localPath == null,
        clearThumbnailNetworkUrl: thumbnail?.networkUrl == null,
      );
    }

    return ArtistCommissionType(
      id: 'type-${DateTime.now().microsecondsSinceEpoch}',
      name: state.name.trim(),
      startingPriceWon: price,
      workPeriod: state.workPeriod.trim().isEmpty ? '7-14일' : state.workPeriod.trim(),
      totalSlots: totalSlots,
      openSlots: totalSlots,
      description: state.description.trim(),
      sampleImages: samples,
      thumbnailLocalPath: thumbnail?.localPath,
      thumbnailNetworkUrl: thumbnail?.networkUrl,
    );
  }

  bool submit() {
    final type = buildTypeForSubmit();
    if (type == null) return false;

    final settings = ref.read(commissionTypeSettingsProvider.notifier);
    if (state.isEditMode) {
      settings.updateType(type);
    } else {
      settings.addType(type);
    }
    return true;
  }
}
