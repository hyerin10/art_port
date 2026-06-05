/// 채팅 메시지 유형
enum ChatMessageType { text, image, file }

/// 1:1 채팅 메시지
class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.isMine,
    required this.type,
    required this.timeLabel,
    this.text,
    this.attachmentLabel,
    this.attachmentUrl,
    this.attachmentLocalPath,
    this.attachmentSizeLabel,
  });

  final String id;
  final bool isMine;
  final ChatMessageType type;
  final String timeLabel;
  final String? text;
  final String? attachmentLabel;
  final String? attachmentUrl;
  final String? attachmentLocalPath;
  final String? attachmentSizeLabel;
}

/// 채팅방 상세(헤더·상태 바)
class ChatRoomDetail {
  const ChatRoomDetail({
    required this.id,
    required this.counterpartName,
    required this.avatarUrl,
    required this.isOnline,
    required this.statusLabel,
    this.artistId,
  });

  final String id;
  final String counterpartName;
  final String avatarUrl;
  final bool isOnline;
  final String statusLabel;
  final String? artistId;

  ChatRoomDetail copyWith({
    String? id,
    String? counterpartName,
    String? avatarUrl,
    bool? isOnline,
    String? statusLabel,
    String? artistId,
  }) {
    return ChatRoomDetail(
      id: id ?? this.id,
      counterpartName: counterpartName ?? this.counterpartName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isOnline: isOnline ?? this.isOnline,
      statusLabel: statusLabel ?? this.statusLabel,
      artistId: artistId ?? this.artistId,
    );
  }
}
