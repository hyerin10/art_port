import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/resource_ids.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/commission/data/dto/commission_type_dto.dart';
import 'package:art_port/features/mypage/data/mypage_write_providers.dart';
import 'package:art_port/features/mypage/models/commission_type_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final commissionTypeSettingsProvider =
    NotifierProvider<CommissionTypeSettingsNotifier, CommissionTypeSettingsState>(
  CommissionTypeSettingsNotifier.new,
);

class CommissionTypeSettingsNotifier
    extends Notifier<CommissionTypeSettingsState> {
  final _pendingDeleteIds = <String>{};

  @override
  CommissionTypeSettingsState build() {
    Future.microtask(_load);
    return const CommissionTypeSettingsState(
      types: [],
      savedSnapshot: [],
      isLoading: true,
    );
  }

  Future<void> _load() async {
    final profileId = ref.read(currentArtistProfileIdProvider);
    if (profileId == null) {
      state = state.copyWith(isLoading: false);
      return;
    }

    try {
      final types = await ref
          .read(commissionTypeRepositoryProvider)
          .getByArtistProfileId(profileId);
      final mapped = [for (final type in types) _fromDto(type)];
      _pendingDeleteIds.clear();
      state = CommissionTypeSettingsState(
        types: mapped,
        savedSnapshot: List.from(mapped),
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        saveError: '커미션 타입을 불러오지 못했습니다.',
      );
    }
  }

  void toggleActive(String id) {
    state = state.copyWith(
      types: [
        for (final type in state.types)
          if (type.id == id) type.copyWith(isActive: !type.isActive) else type,
      ],
      clearSaveError: true,
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
    if (ResourceIds.isUuid(id)) {
      _pendingDeleteIds.add(id);
    }
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

    final profileId = ref.read(currentArtistProfileIdProvider);
    final userId = ref.read(currentUserIdProvider);
    if (profileId == null || userId == null) {
      state = state.copyWith(saveError: '로그인이 필요합니다.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      final repo = ref.read(commissionTypeRepositoryProvider);
      for (final id in [..._pendingDeleteIds]) {
        await repo.delete(id);
      }
      _pendingDeleteIds.clear();

      final next = <ArtistCommissionType>[];
      for (final type in state.types) {
        final sampleUrls = [
          for (final sample in type.sampleImages)
            if (ResourceIds.isRemoteUrl(sample.networkUrl)) sample.networkUrl!,
        ];
        final thumbnail = ResourceIds.isRemoteUrl(type.thumbnailNetworkUrl)
            ? type.thumbnailNetworkUrl
            : (sampleUrls.isEmpty ? null : sampleUrls.first);
        final workPeriodDays = _workPeriodDays(type.workPeriod);

        if (ResourceIds.isUuid(type.id)) {
          await repo.update(
            typeId: type.id,
            name: type.name,
            description: type.description,
            thumbnailUrl: thumbnail,
            startingPriceWon: type.startingPriceWon,
            workPeriodDays: workPeriodDays,
            totalSlots: type.totalSlots,
            openSlots: type.openSlots.clamp(0, type.totalSlots),
            sampleImageUrls: sampleUrls,
            isActive: type.isActive,
          );
          next.add(type);
        } else {
          final created = await repo.create(
            artistProfileId: profileId,
            name: type.name,
            description: type.description,
            thumbnailUrl: thumbnail,
            startingPriceWon: type.startingPriceWon,
            workPeriodDays: workPeriodDays,
            totalSlots: type.totalSlots,
            openSlots: type.totalSlots,
            sampleImageUrls: sampleUrls,
            isActive: type.isActive,
          );
          next.add(_fromDto(created));
        }
      }

      invalidateArtistWorkspaceQueries(ref, artistProfileId: profileId);
      state = state.copyWith(
        types: next,
        savedSnapshot: List.from(next),
        isSaving: false,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isSaving: false, saveError: e.displayMessage);
      return false;
    } catch (_) {
      state = state.copyWith(
        isSaving: false,
        saveError: '저장에 실패했습니다. 다시 시도해 주세요.',
      );
      return false;
    }
  }

  static ArtistCommissionType _fromDto(CommissionTypeDto dto) {
    return ArtistCommissionType(
      id: dto.id,
      name: dto.name,
      startingPriceWon: dto.startingPriceWon,
      workPeriod: '${dto.workPeriodDays}일',
      totalSlots: dto.totalSlots,
      openSlots: dto.openSlots,
      description: dto.description ?? '',
      thumbnailNetworkUrl: dto.thumbnailUrl,
      isActive: dto.isActive,
      sampleImages: [
        for (var i = 0; i < dto.sampleImageUrls.length; i++)
          CommissionSampleImage(
            id: 'sample-${dto.id}-$i',
            networkUrl: dto.sampleImageUrls[i],
          ),
      ],
    );
  }

  static int _workPeriodDays(String text) {
    final match = RegExp(r'\d+').firstMatch(text);
    final days = int.tryParse(match?.group(0) ?? '');
    if (days == null || days < 1) return 7;
    return days;
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
