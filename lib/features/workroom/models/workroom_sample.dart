// 작업실 채팅·주문 더미 데이터 모델
//
// isReceivedAsArtist — true면 작가로서 접수한 항목, false면 의뢰인으로 신청한 항목.
// 실제 API 연동 시 appModeProvider.isArtistMode에 맞춰 필터링합니다.

enum WorkroomOrderStatus {
  inProgress,
  review,
  completed,
}

class WorkroomChatItem {
  const WorkroomChatItem({
    required this.id,
    required this.counterpartName,
    required this.avatarUrl,
    required this.lastMessagePreview,
    required this.timeAgoLabel,
    required this.isReceivedAsArtist,
    this.unreadCount = 0,
    this.isOnline = false,
  });

  final String id;
  final String counterpartName;
  final String avatarUrl;
  final String lastMessagePreview;
  final String timeAgoLabel;
  final int unreadCount;
  final bool isOnline;
  final bool isReceivedAsArtist;
}

class WorkroomOrderItem {
  const WorkroomOrderItem({
    required this.id,
    required this.title,
    required this.counterpartName,
    required this.avatarUrl,
    required this.status,
    required this.progressPercent,
    required this.deadlineLabel,
    required this.priceWon,
    required this.isReceivedAsArtist,
  });

  final String id;
  final String title;
  final String counterpartName;
  final String avatarUrl;
  final WorkroomOrderStatus status;
  final int progressPercent;
  final String deadlineLabel;
  final int priceWon;
  final bool isReceivedAsArtist;

  String get counterpartLabel => 'by $counterpartName';

  String get priceLabel => _formatWon(priceWon);

  static String _formatWon(int won) {
    final s = won.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return '${buf.toString()}원';
  }
}

/// 작업실 플레이스홀더 데이터
abstract final class WorkroomDummyData {
  static const _avatar1 =
      'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=80&h=80&fit=crop';
  static const _avatar2 =
      'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=80&h=80&fit=crop';
  static const _avatar3 =
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=80&h=80&fit=crop';
  static const _avatar4 =
      'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=80&h=80&fit=crop';

  static const chatRooms = [
    // 의뢰인 모드: 내가 신청한 채팅방
    WorkroomChatItem(
      id: 'chat-c1',
      counterpartName: '초코쌤',
      avatarUrl: _avatar1,
      lastMessagePreview: '스케치 감사해요! 수정 사항 보내드릴게요.',
      timeAgoLabel: '2분 전',
      unreadCount: 2,
      isOnline: true,
      isReceivedAsArtist: false,
    ),
    WorkroomChatItem(
      id: 'chat-c2',
      counterpartName: '소라드로우',
      avatarUrl: _avatar2,
      lastMessagePreview: '최종 시안 확인 부탁드려요.',
      timeAgoLabel: '1시간 전',
      unreadCount: 1,
      isOnline: true,
      isReceivedAsArtist: false,
    ),
    WorkroomChatItem(
      id: 'chat-c3',
      counterpartName: '루나픽셀',
      avatarUrl: _avatar3,
      lastMessagePreview: '좋아요! 배경 작업 바로 시작할게요.',
      timeAgoLabel: '3시간 전',
      isOnline: false,
      isReceivedAsArtist: false,
    ),
    // 작가 모드: 내가 접수한 채팅방
    WorkroomChatItem(
      id: 'chat-mika',
      counterpartName: 'MikaArt',
      avatarUrl: _avatar1,
      lastMessagePreview: '이미지 잘 받았어요! 러프 스케치 작업 시작할게요.',
      timeAgoLabel: '방금',
      unreadCount: 1,
      isOnline: true,
      isReceivedAsArtist: true,
    ),
    WorkroomChatItem(
      id: 'chat-a1',
      counterpartName: '별하늘님',
      avatarUrl: _avatar4,
      lastMessagePreview: '레퍼런스 이미지 추가로 보냈어요!',
      timeAgoLabel: '5분 전',
      unreadCount: 3,
      isOnline: true,
      isReceivedAsArtist: true,
    ),
    WorkroomChatItem(
      id: 'chat-a2',
      counterpartName: '민트캣',
      avatarUrl: _avatar1,
      lastMessagePreview: '마감일 하루만 연장 가능할까요?',
      timeAgoLabel: '30분 전',
      unreadCount: 1,
      isOnline: true,
      isReceivedAsArtist: true,
    ),
    WorkroomChatItem(
      id: 'chat-a3',
      counterpartName: '하늘조각',
      avatarUrl: _avatar2,
      lastMessagePreview: '컨펌 완료했습니다. 감사합니다!',
      timeAgoLabel: '2시간 전',
      isOnline: false,
      isReceivedAsArtist: true,
    ),
  ];

  static const orders = [
    // 의뢰인 모드: 내가 신청한 주문
    WorkroomOrderItem(
      id: 'order-c1',
      title: '애니메이션 두상 커미션',
      counterpartName: '초코쌤',
      avatarUrl: _avatar1,
      status: WorkroomOrderStatus.inProgress,
      progressPercent: 60,
      deadlineLabel: '마감일: 12월 20일',
      priceWon: 50000,
      isReceivedAsArtist: false,
    ),
    WorkroomOrderItem(
      id: 'order-c2',
      title: '전신 일러스트',
      counterpartName: '소라드로우',
      avatarUrl: _avatar2,
      status: WorkroomOrderStatus.review,
      progressPercent: 90,
      deadlineLabel: '마감일: 12월 15일',
      priceWon: 35000,
      isReceivedAsArtist: false,
    ),
    WorkroomOrderItem(
      id: 'order-c3',
      title: '로고 디자인',
      counterpartName: '루나픽셀',
      avatarUrl: _avatar3,
      status: WorkroomOrderStatus.completed,
      progressPercent: 100,
      deadlineLabel: '마감일: 11월 28일',
      priceWon: 40000,
      isReceivedAsArtist: false,
    ),
    // 작가 모드: 내가 접수한 주문
    WorkroomOrderItem(
      id: 'order-a1',
      title: '캐릭터 두상 (급행)',
      counterpartName: '별하늘님',
      avatarUrl: _avatar4,
      status: WorkroomOrderStatus.inProgress,
      progressPercent: 45,
      deadlineLabel: '마감일: 12월 22일',
      priceWon: 45000,
      isReceivedAsArtist: true,
    ),
    WorkroomOrderItem(
      id: 'order-a2',
      title: '굿즈 일러스트',
      counterpartName: '민트캣',
      avatarUrl: _avatar1,
      status: WorkroomOrderStatus.review,
      progressPercent: 85,
      deadlineLabel: '마감일: 12월 18일',
      priceWon: 28000,
      isReceivedAsArtist: true,
    ),
    WorkroomOrderItem(
      id: 'order-a3',
      title: '배경 일러스트',
      counterpartName: '하늘조각',
      avatarUrl: _avatar2,
      status: WorkroomOrderStatus.completed,
      progressPercent: 100,
      deadlineLabel: '마감일: 12월 1일',
      priceWon: 60000,
      isReceivedAsArtist: true,
    ),
  ];
}
