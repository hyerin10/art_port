import 'package:art_port/features/chat/models/chat_message.dart';
import 'package:art_port/features/commission/models/commission_transaction.dart';

/// 채팅 타임라인 아이템 (텍스트 메시지 + 시스템 카드)
enum ChatTimelineItemType {
  message,
  commissionApplication,
  paymentRequest,
}

class ChatTimelineItem {
  const ChatTimelineItem.message(this.message)
      : type = ChatTimelineItemType.message;

  const ChatTimelineItem.commissionApplication()
      : type = ChatTimelineItemType.commissionApplication,
        message = null;

  const ChatTimelineItem.paymentRequest()
      : type = ChatTimelineItemType.paymentRequest,
        message = null;

  final ChatTimelineItemType type;
  final ChatMessage? message;
}

List<ChatTimelineItem> buildChatTimeline({
  required List<ChatMessage> messages,
  CommissionTransaction? transaction,
}) {
  final items = messages
      .map((message) => ChatTimelineItem.message(message))
      .toList();

  if (transaction == null) return items;

  items.add(const ChatTimelineItem.commissionApplication());

  if (transaction.status.showsPaymentCard) {
    items.add(const ChatTimelineItem.paymentRequest());
  }

  return items;
}
