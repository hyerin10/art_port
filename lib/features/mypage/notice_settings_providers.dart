import 'dart:developer' as developer;

import 'package:art_port/features/mypage/models/notice_settings_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final noticeSettingsProvider =
    NotifierProvider<NoticeSettingsNotifier, NoticeSettingsState>(
  NoticeSettingsNotifier.new,
);

class NoticeSettingsNotifier extends Notifier<NoticeSettingsState> {
  static NoticeSettingsState _initialState() {
    final pinned = PinnedNotice(
      title: '필독! 커미션 신청 전 확인사항',
      bulletPoints: const [
        '작업 기간: 기본 7-14일 소요',
        '수정 횟수: 스케치 2회, 채색 1회',
        '저작권: 개인 소장용 포함, 상업적 사용은 별도 협의',
        '그리지 않는 것: 고어, 실존 인물, 정치적 내용',
      ],
      createdAt: DateTime(2024, 1, 15),
      isPublic: true,
    );

    final generalNotices = [
      GeneralNotice(
        id: 'notice-1',
        title: '1월 휴무 안내',
        content:
            '설 연휴 기간 (2/8 ~ 2/12) 동안 커미션 접수 및 작업이 중단됩니다. 연휴 전 접수 건은 2/13부터 순차적으로 작업을 시작합니다.',
        createdAt: DateTime(2024, 1, 20),
        isActive: true,
      ),
      GeneralNotice(
        id: 'notice-2',
        title: '가격 조정 안내',
        content:
            '2024년 3월부터 일부 커미션 타입의 가격이 조정됩니다. 기존 신청 건은 기존 가격이 적용됩니다.',
        createdAt: DateTime(2024, 1, 10),
        isActive: false,
      ),
    ];

    return NoticeSettingsState(
      slotStatus: WorkSlotStatus.resting,
      statusMessage: '현재 대기 시간: 약 2주',
      pinnedNotice: pinned,
      generalNotices: generalNotices,
      savedSnapshot: NoticeSettingsSnapshot(
        slotStatus: WorkSlotStatus.resting,
        statusMessage: '현재 대기 시간: 약 2주',
        pinnedNotice: pinned,
        generalNotices: List.from(generalNotices),
      ),
    );
  }

  @override
  NoticeSettingsState build() => _initialState();

  void updateSlotStatus(WorkSlotStatus status) {
    state = state.copyWith(slotStatus: status);
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

    state = state.copyWith(isSaving: true);
    await Future<void>.delayed(const Duration(milliseconds: 600));

    // TODO: API 연동
    developer.log(
      'Notice settings saved: ${state.toJson()}',
      name: 'NoticeSettings',
    );

    state = state.copyWith(
      savedSnapshot: NoticeSettingsSnapshot.fromState(state),
      isSaving: false,
    );
    return true;
  }
}
