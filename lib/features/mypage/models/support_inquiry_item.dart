/// 1:1 문의(고객센터) 목록 아이템
class SupportInquiryItem {
  const SupportInquiryItem({
    required this.id,
    required this.category,
    required this.status,
    this.title,
    required this.lastMessagePreview,
    required this.lastMessageAt,
    this.unreadCount = 0,
  });

  final String id;
  final String category;
  final String status;
  final String? title;
  final String lastMessagePreview;
  final DateTime lastMessageAt;
  final int unreadCount;

  String get displayTitle {
    final trimmed = title?.trim();
    if (trimmed != null && trimmed.isNotEmpty) return trimmed;
    return categoryLabel;
  }

  String get categoryLabel => categoryLabelOf(category);

  String get statusLabel => statusLabelOf(status);

  String get timeAgoLabel => _formatTimeAgo(lastMessageAt);

  SupportInquiryItem copyWith({
    String? lastMessagePreview,
    DateTime? lastMessageAt,
    int? unreadCount,
  }) {
    return SupportInquiryItem(
      id: id,
      category: category,
      status: status,
      title: title,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }

  static String categoryLabelOf(String category) {
    return switch (category) {
      'payment' => '결제',
      'order' => '주문',
      'account' => '계정',
      'artist' => '작가',
      _ => '기타',
    };
  }

  static String statusLabelOf(String status) {
    return switch (status) {
      'in_progress' => '상담 진행 중',
      'resolved' => '해결됨',
      'closed' => '종료됨',
      _ => '접수 대기',
    };
  }

  static String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final local = dateTime.toLocal();
    final diff = now.difference(local);

    if (diff.inMinutes < 1) return '방금';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';

    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDay = DateTime(local.year, local.month, local.day);
    if (messageDay == yesterday) return '어제';

    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${local.month}월 ${local.day}일';
  }
}

/// ArtPort 고객센터 상수
abstract final class SupportInquiryConstants {
  static const String centerName = 'ArtPort 고객센터';
  static const String centerAvatarAsset = 'assets/branding/art_port_icon.png';
  static const String roomPrefix = 'support:';

  static const categories = <({String id, String label})>[
    (id: 'order', label: '주문'),
    (id: 'payment', label: '결제'),
    (id: 'account', label: '계정'),
    (id: 'artist', label: '작가'),
    (id: 'etc', label: '기타'),
  ];

  static String roomIdFor(String inquiryId) => '$roomPrefix$inquiryId';

  static String? inquiryIdFromRoom(String roomId) {
    if (roomId.startsWith(roomPrefix)) {
      return roomId.substring(roomPrefix.length);
    }
    return null;
  }

  static bool isInquiryRoom(String roomId) => roomId.startsWith(roomPrefix);
}
