import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/resource_ids.dart';
import 'package:art_port/features/artist_profile/data/dto/artist_profile_dto.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/mypage/data/mypage_write_providers.dart';
import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final noticeSettingsProvider =
    NotifierProvider<NoticeSettingsNotifier, NoticeSettingsState>(
  NoticeSettingsNotifier.new,
);

class NoticeSettingsNotifier extends Notifier<NoticeSettingsState> {
  List<String> _loadedNoticeIds = const [];

  static PinnedNotice get _emptyPinned => PinnedNotice(
        title: '',
        bulletPoints: const [],
        createdAt: DateTime.now(),
      );

  @override
  NoticeSettingsState build() {
    Future.microtask(_load);
    return NoticeSettingsState(
      slotStatus: WorkSlotStatus.open,
      statusMessage: '',
      pinnedNotice: _emptyPinned,
      generalNotices: const [],
    );
  }

  Future<void> _load() async {
    final profileId = ref.read(currentArtistProfileIdProvider);
    if (profileId == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    try {
      final repo = ref.read(artistProfileRepositoryProvider);
      final profile = await repo.getById(profileId);
      final notices = await repo.getNotices(profileId, manage: true);
      _loadedNoticeIds = [for (final notice in notices) notice.id];

      final pinnedDto = notices.where((notice) => notice.isPinned).firstOrNull;
      final general = notices.where((notice) => !notice.isPinned).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final next = NoticeSettingsState(
        slotStatus: _slotStatusFrom(profile),
        statusMessage: profile.statusMessage ?? '',
        pinnedNotice: pinnedDto == null
            ? _emptyPinned
            : PinnedNotice(
                id: pinnedDto.id,
                title: pinnedDto.title,
                bulletPoints: pinnedDto.bulletPoints,
                createdAt: pinnedDto.createdAt,
                isPublic: pinnedDto.isPublic,
              ),
        generalNotices: [
          for (final notice in general)
            GeneralNotice(
              id: notice.id,
              title: notice.title,
              content: notice.content ?? '',
              createdAt: notice.createdAt,
              isActive: notice.isActive,
            ),
        ],
        isLoaded: true,
      );
      state = next.copyWith(savedSnapshot: NoticeSettingsSnapshot.fromState(next));
    } catch (_) {
      state = state.copyWith(
        isLoaded: true,
        saveError: '공지사항을 불러오지 못했습니다.',
      );
    }
  }

  void updateSlotStatus(WorkSlotStatus status) {
    state = state.copyWith(slotStatus: status, clearSaveError: true);
  }

  void updateStatusMessage(String value) {
    if (value.length > NoticeSettingsState.maxStatusMessage) return;
    state = state.copyWith(statusMessage: value);
  }

  void updatePinnedNotice(PinnedNotice notice) {
    state = state.copyWith(pinnedNotice: notice);
  }

  void toggleGeneralNoticeActive(String id) {
    state = state.copyWith(
      generalNotices: [
        for (final notice in state.generalNotices)
          if (notice.id == id)
            notice.copyWith(isActive: !notice.isActive)
          else
            notice,
      ],
    );
  }

  void addGeneralNotice(GeneralNotice notice) {
    state = state.copyWith(
      generalNotices: [notice, ...state.generalNotices],
    );
  }

  void updateGeneralNotice(GeneralNotice notice) {
    state = state.copyWith(
      generalNotices: [
        for (final item in state.generalNotices)
          if (item.id == notice.id) notice else item,
      ],
    );
  }

  void removeGeneralNotice(String id) {
    state = state.copyWith(
      generalNotices:
          state.generalNotices.where((notice) => notice.id != id).toList(),
    );
  }

  GeneralNotice? findGeneralNotice(String id) {
    for (final notice in state.generalNotices) {
      if (notice.id == id) return notice;
    }
    return null;
  }

  Future<bool> saveAll() async {
    if (state.isSaving) return false;

    final profileId = ref.read(currentArtistProfileIdProvider);
    final userId = ref.read(currentUserIdProvider);
    if (profileId == null || userId == null) {
      state = state.copyWith(saveError: '로그인이 필요합니다.');
      return false;
    }

    state = state.copyWith(isSaving: true, clearSaveError: true);

    try {
      final repo = ref.read(artistProfileRepositoryProvider);
      await repo.update(
        profileId,
        slotStatus: state.slotStatus.name,
        statusMessage: state.statusMessage.trim(),
        isRestMode: state.slotStatus == WorkSlotStatus.resting,
      );

      await _syncPinned(profileId: profileId, userId: userId);
      await _syncGeneral(profileId: profileId, userId: userId);

      invalidateArtistWorkspaceQueries(ref, artistProfileId: profileId);
      state = state.copyWith(
        savedSnapshot: NoticeSettingsSnapshot.fromState(state),
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

  Future<void> _syncPinned({
    required String profileId,
    required String userId,
  }) async {
    final repo = ref.read(artistProfileRepositoryProvider);
    final pinned = state.pinnedNotice;
    final hasContent =
        pinned.title.trim().isNotEmpty && pinned.bulletPoints.isNotEmpty;

    if (!hasContent) {
      final id = pinned.id;
      if (id != null && ResourceIds.isUuid(id)) {
        await repo.deleteNotice(noticeId: id, userId: userId);
        state = state.copyWith(pinnedNotice: _emptyPinned);
      }
      return;
    }

    if (pinned.id != null && ResourceIds.isUuid(pinned.id!)) {
      await repo.updateNotice(
        noticeId: pinned.id!,
        userId: userId,
        type: 'pinned',
        title: pinned.title.trim(),
        bulletPoints: pinned.bulletPoints,
        isPublic: pinned.isPublic,
      );
      return;
    }

    final created = await repo.createNotice(
      profileId: profileId,
      type: 'pinned',
      title: pinned.title.trim(),
      bulletPoints: pinned.bulletPoints,
      isPublic: pinned.isPublic,
    );
    state = state.copyWith(
      pinnedNotice: pinned.copyWith(id: created.id, createdAt: created.createdAt),
    );
  }

  Future<void> _syncGeneral({
    required String profileId,
    required String userId,
  }) async {
    final repo = ref.read(artistProfileRepositoryProvider);
    final currentIds = [
      for (final notice in state.generalNotices)
        if (ResourceIds.isUuid(notice.id)) notice.id,
    ];

    for (final id in _loadedNoticeIds) {
      final stillPinned = state.pinnedNotice.id == id;
      if (!currentIds.contains(id) && !stillPinned) {
        await repo.deleteNotice(noticeId: id, userId: userId);
      }
    }

    final next = <GeneralNotice>[];
    for (final notice in state.generalNotices) {
      if (ResourceIds.isUuid(notice.id)) {
        await repo.updateNotice(
          noticeId: notice.id,
          userId: userId,
          type: 'general',
          title: notice.title.trim(),
          content: notice.content.trim(),
          isActive: notice.isActive,
        );
        next.add(notice);
      } else {
        final created = await repo.createNotice(
          profileId: profileId,
          type: 'general',
          title: notice.title.trim(),
          content: notice.content.trim(),
          isActive: notice.isActive,
        );
        next.add(
          notice.copyWith(id: created.id, createdAt: created.createdAt),
        );
      }
    }

    state = state.copyWith(generalNotices: next);
    _loadedNoticeIds = [
      ?state.pinnedNotice.id,
      for (final notice in next) notice.id,
    ];
  }

  static WorkSlotStatus _slotStatusFrom(ArtistProfileDto profile) {
    if (profile.isRestMode) return WorkSlotStatus.resting;
    return switch (profile.slotStatus) {
      'closed' => WorkSlotStatus.closed,
      'resting' => WorkSlotStatus.resting,
      _ => WorkSlotStatus.open,
    };
  }
}
