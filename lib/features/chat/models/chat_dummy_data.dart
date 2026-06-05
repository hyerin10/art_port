import 'package:art_port/features/chat/models/chat_message.dart';

/// 채팅방 더미 데이터 (시안 MikaArt 대화 기준)
abstract final class ChatDummyData {
  static const _mikaAvatar =
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&h=80&fit=crop';
  static const _referenceImage =
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=400&h=300&fit=crop';

  static ChatRoomDetail? roomFor(String roomId) {
    return switch (roomId) {
      'chat-mika' => const ChatRoomDetail(
          id: 'chat-mika',
          counterpartName: 'MikaArt',
          avatarUrl: _mikaAvatar,
          isOnline: true,
          statusLabel: 'Status: Rough Sketch / 러프 진행 중',
        ),
      _ => null,
    };
  }

  static List<ChatMessage> initialMessages(String roomId) {
    if (roomId != 'chat-mika') {
      return const [];
    }

    return const [
      ChatMessage(
        id: 'm1',
        isMine: false,
        type: ChatMessageType.text,
        timeLabel: '10:30',
        text:
            '안녕하세요! 커미션 신청해주셔서 감사합니다. 레퍼런스와 원하시는 포즈가 있으시면 공유해 주세요.',
      ),
      ChatMessage(
        id: 'm2',
        isMine: true,
        type: ChatMessageType.text,
        timeLabel: '10:32',
        text: '네, 감사합니다! 캐릭터 시트와 포즈 레퍼런스 보내드릴게요.',
      ),
      ChatMessage(
        id: 'm3',
        isMine: true,
        type: ChatMessageType.image,
        timeLabel: '10:33',
        attachmentLabel: 'reference_image.jpg',
        attachmentUrl: _referenceImage,
      ),
      ChatMessage(
        id: 'm4',
        isMine: false,
        type: ChatMessageType.text,
        timeLabel: '10:35',
        text: '이미지 잘 받았어요! 러프 스케치 작업 시작할게요. 진행되면 바로 공유드릴게요.',
      ),
      ChatMessage(
        id: 'm5',
        isMine: true,
        type: ChatMessageType.text,
        timeLabel: '10:36',
        text: '좋아요, 기대하고 있을게요! 궁금한 점 있으시면 편하게 말씀해 주세요.',
      ),
    ];
  }

  static String formatNow() {
    final now = DateTime.now();
    final h = now.hour.toString().padLeft(2, '0');
    final m = now.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
