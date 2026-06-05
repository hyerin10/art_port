import 'package:art_port/features/chat/models/chat_dummy_data.dart';
import 'package:art_port/features/mypage/models/support_inquiry_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1:1 문의 목록 (최신 메시지 순 정렬)
final supportInquiriesProvider =
    NotifierProvider<SupportInquiriesNotifier, List<SupportInquiryItem>>(
  SupportInquiriesNotifier.new,
);

class SupportInquiriesNotifier extends Notifier<List<SupportInquiryItem>> {
  @override
  List<SupportInquiryItem> build() {
    return _sorted(_seedItems());
  }

  /// 새 문의 채팅방 생성 후 roomId 반환
  String createNewInquiry() {
    final now = DateTime.now();
    final id = 'inquiry-${now.millisecondsSinceEpoch}';

    ChatDummyData.registerSupportInquiryRoom(id);

    final item = SupportInquiryItem(
      id: id,
      lastMessagePreview: '안녕하세요, ArtPort 고객센터입니다. 무엇을 도와드릴까요?',
      lastMessageAt: now,
      unreadCount: 1,
    );

    state = _sorted([item, ...state]);
    return id;
  }

  void markAsRead(String id) {
    state = [
      for (final item in state)
        if (item.id == id) item.copyWith(unreadCount: 0) else item,
    ];
  }

  List<SupportInquiryItem> _sorted(List<SupportInquiryItem> items) {
    final copy = List<SupportInquiryItem>.from(items);
    copy.sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
    return copy;
  }

  List<SupportInquiryItem> _seedItems() {
    final now = DateTime.now();

    return [
      SupportInquiryItem(
        id: 'inquiry-payment',
        lastMessagePreview: '결제가 정상적으로 확인되었습니다. 추가 문의 사항이 있으시면 말씀해 주세요.',
        lastMessageAt: now.subtract(const Duration(minutes: 12)),
        unreadCount: 1,
      ),
      SupportInquiryItem(
        id: 'inquiry-refund',
        lastMessagePreview: '환불 절차 안내드립니다. 영업일 기준 3~5일 내 처리됩니다.',
        lastMessageAt: now.subtract(const Duration(hours: 2)),
        unreadCount: 3,
      ),
      SupportInquiryItem(
        id: 'inquiry-resolved',
        lastMessagePreview: '감사합니다. 문의가 해결되어 이 채팅방을 종료합니다.',
        lastMessageAt: now.subtract(const Duration(days: 1)),
      ),
      SupportInquiryItem(
        id: 'inquiry-report',
        lastMessagePreview: '작가 신고 접수가 완료되었습니다. 검토 후 안내드리겠습니다.',
        lastMessageAt: now.subtract(const Duration(days: 3)),
      ),
    ];
  }
}
