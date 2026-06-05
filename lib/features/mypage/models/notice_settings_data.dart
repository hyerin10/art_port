/// 작업 슬롯 상태
enum WorkSlotStatus {
  open('슬롯 오픈'),
  closed('슬롯 마감'),
  resting('휴식 중');

  const WorkSlotStatus(this.label);

  final String label;
}

/// 상단 고정 공지
class PinnedNotice {
  const PinnedNotice({
    required this.title,
    required this.bulletPoints,
    required this.createdAt,
    this.isPublic = true,
  });

  static const int maxTitle = 100;
  static const int maxBulletPoints = 10;
  static const int maxBulletLength = 200;

  final String title;
  final List<String> bulletPoints;
  final DateTime createdAt;
  final bool isPublic;

  String get formattedDate {
    return '${createdAt.year}. ${createdAt.month}. ${createdAt.day}';
  }

  PinnedNotice copyWith({
    String? title,
    List<String>? bulletPoints,
    DateTime? createdAt,
    bool? isPublic,
  }) {
    return PinnedNotice(
      title: title ?? this.title,
      bulletPoints: bulletPoints ?? this.bulletPoints,
      createdAt: createdAt ?? this.createdAt,
      isPublic: isPublic ?? this.isPublic,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'bulletPoints': bulletPoints,
        'createdAt': createdAt.toIso8601String(),
        'isPublic': isPublic,
      };
}

/// 일반 공지사항
class GeneralNotice {
  const GeneralNotice({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.isActive = true,
  });

  static const int maxTitle = 80;
  static const int maxContent = 500;

  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final bool isActive;

  String get formattedDate {
    return '${createdAt.year}. ${createdAt.month}. ${createdAt.day}';
  }

  String get preview {
    if (content.length <= 80) return content;
    return '${content.substring(0, 80)}...';
  }

  GeneralNotice copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return GeneralNotice(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'isActive': isActive,
      };
}

/// 공지사항 설정 전체 상태
class NoticeSettingsState {
  const NoticeSettingsState({
    required this.slotStatus,
    required this.statusMessage,
    required this.pinnedNotice,
    required this.generalNotices,
    this.savedSnapshot,
    this.isSaving = false,
  });

  static const int maxStatusMessage = 100;

  final WorkSlotStatus slotStatus;
  final String statusMessage;
  final PinnedNotice pinnedNotice;
  final List<GeneralNotice> generalNotices;
  final NoticeSettingsSnapshot? savedSnapshot;
  final bool isSaving;

  bool get hasChanges {
    final snapshot = savedSnapshot;
    if (snapshot == null) return true;
    return slotStatus != snapshot.slotStatus ||
        statusMessage != snapshot.statusMessage ||
        pinnedNotice.title != snapshot.pinnedNotice.title ||
        !_listEquals(pinnedNotice.bulletPoints, snapshot.pinnedNotice.bulletPoints) ||
        pinnedNotice.isPublic != snapshot.pinnedNotice.isPublic ||
        !_noticesEqual(generalNotices, snapshot.generalNotices);
  }

  NoticeSettingsState copyWith({
    WorkSlotStatus? slotStatus,
    String? statusMessage,
    PinnedNotice? pinnedNotice,
    List<GeneralNotice>? generalNotices,
    NoticeSettingsSnapshot? savedSnapshot,
    bool? isSaving,
  }) {
    return NoticeSettingsState(
      slotStatus: slotStatus ?? this.slotStatus,
      statusMessage: statusMessage ?? this.statusMessage,
      pinnedNotice: pinnedNotice ?? this.pinnedNotice,
      generalNotices: generalNotices ?? this.generalNotices,
      savedSnapshot: savedSnapshot ?? this.savedSnapshot,
      isSaving: isSaving ?? this.isSaving,
    );
  }

  Map<String, dynamic> toJson() => {
        'slotStatus': slotStatus.name,
        'statusMessage': statusMessage,
        'pinnedNotice': pinnedNotice.toJson(),
        'generalNotices': generalNotices.map((n) => n.toJson()).toList(),
      };

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _noticesEqual(List<GeneralNotice> a, List<GeneralNotice> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final left = a[i];
      final right = b[i];
      if (left.id != right.id ||
          left.title != right.title ||
          left.content != right.content ||
          left.isActive != right.isActive) {
        return false;
      }
    }
    return true;
  }
}

/// 저장 스냅샷 (변경 감지용)
class NoticeSettingsSnapshot {
  const NoticeSettingsSnapshot({
    required this.slotStatus,
    required this.statusMessage,
    required this.pinnedNotice,
    required this.generalNotices,
  });

  final WorkSlotStatus slotStatus;
  final String statusMessage;
  final PinnedNotice pinnedNotice;
  final List<GeneralNotice> generalNotices;

  factory NoticeSettingsSnapshot.fromState(NoticeSettingsState state) {
    return NoticeSettingsSnapshot(
      slotStatus: state.slotStatus,
      statusMessage: state.statusMessage,
      pinnedNotice: state.pinnedNotice,
      generalNotices: List.from(state.generalNotices),
    );
  }
}
