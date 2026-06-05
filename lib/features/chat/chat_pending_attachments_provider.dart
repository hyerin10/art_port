import 'package:art_port/features/chat/models/pending_attachment.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 채팅방별 업로드 대기 첨부 목록 (`selectedFiles` 역할)
final chatPendingAttachmentsProvider = NotifierProvider.family<
    ChatPendingAttachmentsNotifier, List<PendingAttachment>, String>(
  ChatPendingAttachmentsNotifier.new,
);

class ChatPendingAttachmentsNotifier
    extends FamilyNotifier<List<PendingAttachment>, String> {
  @override
  List<PendingAttachment> build(String roomId) => [];

  void addAll(List<PendingAttachment> items) {
    if (items.isEmpty) return;
    state = [...state, ...items];
  }

  void removeAt(int index) {
    if (index < 0 || index >= state.length) return;
    state = [...state]..removeAt(index);
  }

  void clear() => state = [];
}
