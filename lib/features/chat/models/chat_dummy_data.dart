import 'package:art_port/features/chat/models/chat_message.dart';
import 'package:art_port/features/mypage/models/support_inquiry_item.dart';

/// 채팅방 더미 데이터 (시안 MikaArt 대화 기준)
abstract final class ChatDummyData {
  static const _mikaAvatar =
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&h=80&fit=crop';
  static const _referenceImage =
      'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=400&h=300&fit=crop';

  static final Map<String, ChatRoomDetail> _dynamicRooms = {};
  static final Map<String, List<ChatMessage>> _dynamicMessages = {};

  static const _supportRoomDetail = ChatRoomDetail(
    id: 'support',
    counterpartName: SupportInquiryConstants.centerName,
    avatarUrl: SupportInquiryConstants.centerAvatarAsset,
    isOnline: true,
    statusLabel: '고객센터 상담',
  );

  static ChatRoomDetail? roomFor(String roomId) {
    if (_dynamicRooms.containsKey(roomId)) {
      return _dynamicRooms[roomId];
    }

    if (roomId.startsWith('inquiry-')) {
      return _supportRoomDetail.copyWith(id: roomId);
    }

    return switch (roomId) {
      'chat-mika' => const ChatRoomDetail(
          id: 'chat-mika',
          counterpartName: 'MikaArt',
          avatarUrl: _mikaAvatar,
          isOnline: true,
          statusLabel: 'Status: Rough Sketch / 러프 진행 중',
          artistId: 'mika-art',
        ),
      _ => null,
    };
  }

  /// 새 1:1 문의 채팅방 등록
  static void registerSupportInquiryRoom(String roomId) {
    _dynamicRooms[roomId] = _supportRoomDetail.copyWith(id: roomId);
    _dynamicMessages[roomId] = [
      ChatMessage(
        id: '$roomId-welcome',
        isMine: false,
        type: ChatMessageType.text,
        timeLabel: formatNow(),
        text: '안녕하세요, ArtPort 고객센터입니다. 무엇을 도와드릴까요?',
      ),
    ];
  }

  static List<ChatMessage> initialMessages(String roomId) {
    if (_dynamicMessages.containsKey(roomId)) {
      return List<ChatMessage>.from(_dynamicMessages[roomId]!);
    }

    if (roomId.startsWith('inquiry-')) {
      return List<ChatMessage>.from(_supportInquiryMessages[roomId] ?? const []);
    }

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

  static const _supportInquiryMessages = <String, List<ChatMessage>>{
    'inquiry-payment': [
      ChatMessage(
        id: 'ip1',
        isMine: true,
        type: ChatMessageType.text,
        timeLabel: '14:20',
        text: '결제가 완료됐는데 주문 상태가 변경되지 않아요.',
      ),
      ChatMessage(
        id: 'ip2',
        isMine: false,
        type: ChatMessageType.text,
        timeLabel: '14:25',
        text: '확인해 보겠습니다. 주문 번호를 알려주시겠어요?',
      ),
      ChatMessage(
        id: 'ip3',
        isMine: true,
        type: ChatMessageType.text,
        timeLabel: '14:26',
        text: 'ORD-2024-12847 입니다.',
      ),
      ChatMessage(
        id: 'ip4',
        isMine: false,
        type: ChatMessageType.text,
        timeLabel: '14:32',
        text: '결제가 정상적으로 확인되었습니다. 추가 문의 사항이 있으시면 말씀해 주세요.',
      ),
    ],
    'inquiry-refund': [
      ChatMessage(
        id: 'ir1',
        isMine: true,
        type: ChatMessageType.text,
        timeLabel: '11:00',
        text: '커미션 취소 후 환불은 언제 되나요?',
      ),
      ChatMessage(
        id: 'ir2',
        isMine: false,
        type: ChatMessageType.text,
        timeLabel: '11:15',
        text: '환불 절차 안내드립니다. 영업일 기준 3~5일 내 처리됩니다.',
      ),
    ],
    'inquiry-resolved': [
      ChatMessage(
        id: 'irs1',
        isMine: true,
        type: ChatMessageType.text,
        timeLabel: '09:10',
        text: '계정 로그인이 안 됩니다.',
      ),
      ChatMessage(
        id: 'irs2',
        isMine: false,
        type: ChatMessageType.text,
        timeLabel: '09:30',
        text: '비밀번호 재설정 후 정상 로그인 확인되었습니다.',
      ),
      ChatMessage(
        id: 'irs3',
        isMine: false,
        type: ChatMessageType.text,
        timeLabel: '09:31',
        text: '감사합니다. 문의가 해결되어 이 채팅방을 종료합니다.',
      ),
    ],
    'inquiry-report': [
      ChatMessage(
        id: 'ire1',
        isMine: true,
        type: ChatMessageType.text,
        timeLabel: '16:00',
        text: '작가 신고를 접수하고 싶습니다.',
      ),
      ChatMessage(
        id: 'ire2',
        isMine: false,
        type: ChatMessageType.text,
        timeLabel: '16:20',
        text: '작가 신고 접수가 완료되었습니다. 검토 후 안내드리겠습니다.',
      ),
    ],
  };
}
