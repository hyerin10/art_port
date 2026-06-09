import 'package:art_port/features/chat/models/chat_dummy_data.dart';
import 'package:art_port/features/chat/models/chat_message.dart';
import 'package:art_port/features/commission/models/commission_apply_args.dart';
import 'package:art_port/features/commission/models/commission_status.dart';
import 'package:art_port/features/commission/models/commission_transaction.dart';
import 'package:art_port/features/commission/models/commission_price_option.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/workroom/workroom_chat_registry.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 사용자가 작가 시점인지 (전역 모드)
final commissionIsArtistProvider = Provider<bool>((ref) {
  return ref.watch(appModeProvider);
});

/// 등록된 모든 커미션 거래 목록
final allCommissionTransactionsProvider =
    Provider<List<CommissionTransaction>>((ref) {
  return ref.watch(commissionTransactionRegistryProvider).values.toList();
});

/// 채팅방별 커미션 거래 상태
final commissionTransactionProvider =
    Provider.family<CommissionTransaction?, String>((ref, roomId) {
  final registry = ref.watch(commissionTransactionRegistryProvider);
  return registry[roomId];
});

/// 채팅방별 커미션 거래 Notifier
final commissionTransactionNotifierProvider = NotifierProvider.family<
    CommissionTransactionNotifier, CommissionTransaction?, String>(
  CommissionTransactionNotifier.new,
);

class CommissionTransactionNotifier
    extends FamilyNotifier<CommissionTransaction?, String> {
  @override
  CommissionTransaction? build(String roomId) {
    return ref.watch(commissionTransactionRegistryProvider)[roomId];
  }

  bool get _isArtist => ref.read(appModeProvider);

  void acceptApplication() {
    final current = state;
    if (current == null ||
        current.status != CommissionStatus.submitted ||
        current.isDeclined ||
        !_isArtist) {
      return;
    }

    ref.read(commissionTransactionRegistryProvider.notifier).updateStatus(
          arg,
          CommissionStatus.accepted,
        );
  }

  void rejectApplication() {
    final current = state;
    if (current == null ||
        current.status != CommissionStatus.submitted ||
        !_isArtist) {
      return;
    }

    ref
        .read(commissionTransactionRegistryProvider.notifier)
        .markDeclined(arg);
  }

  void requestPayment() {
    final current = state;
    if (current == null ||
        current.status != CommissionStatus.accepted ||
        !_isArtist) {
      return;
    }

    ref.read(commissionTransactionRegistryProvider.notifier).updateStatus(
          arg,
          CommissionStatus.paymentRequested,
        );
  }

  void completePayment() {
    final current = state;
    if (current == null ||
        current.status != CommissionStatus.paymentRequested ||
        _isArtist) {
      return;
    }

    ref.read(commissionTransactionRegistryProvider.notifier).updateStatus(
          arg,
          CommissionStatus.paid,
        );
  }
}

/// 전역 거래 레지스트리 (Mock — 추후 API 연동)
final commissionTransactionRegistryProvider = NotifierProvider<
    CommissionTransactionRegistryNotifier,
    Map<String, CommissionTransaction>>(CommissionTransactionRegistryNotifier.new);

class CommissionTransactionRegistryNotifier
    extends Notifier<Map<String, CommissionTransaction>> {
  static const _demoRoomId = 'chat-commission-demo';
  static const _mikaAvatar =
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=80&h=80&fit=crop';

  @override
  Map<String, CommissionTransaction> build() {
    WorkroomChatRegistry.register(
      roomId: _demoRoomId,
      artistName: _demoTransaction.artistName,
      artistAvatarUrl: _demoTransaction.artistAvatarUrl,
      clientName: _demoTransaction.clientName,
      clientAvatarUrl: _demoTransaction.clientAvatarUrl,
      preview: '커미션 신청서가 제출되었습니다.',
    );
    return {_demoRoomId: _demoTransaction};
  }

  static final _demoTransaction = CommissionTransaction(
    roomId: _demoRoomId,
    status: CommissionStatus.submitted,
    application: CommissionApplySubmission(
      commissionId: 'mika-character',
      commissionTitle: '캐릭터 일러스트 커미션',
      artistName: 'MikaArt',
      selectedOption: const CommissionPriceOption(
        label: '전신',
        subtitle: 'Full Body',
        priceWon: 50000,
      ),
      requestContent:
          '세미리얼 스타일의 전신 캐릭터 일러스트를 요청드립니다. 차분하고 따뜻한 분위기로, 배경은 단색으로 부탁드립니다. 의상은 첨부한 레퍼런스를 참고해 주세요.',
      referenceImagePaths: const [],
      usagePurpose: CommissionUsagePurpose.personal,
      desiredDeadline: DateTime(2026, 7, 15),
      submittedAt: DateTime(2026, 6, 9, 10, 31),
    ),
    artistName: 'MikaArt',
    artistAvatarUrl: _mikaAvatar,
    clientName: 'ChocoLatte',
    clientAvatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=80&h=80&fit=crop',
    commissionTitle: '캐릭터 일러스트 커미션',
    updatedAt: DateTime(2026, 6, 9, 10, 31),
    artistId: 'mika-art',
  );

  void updateStatus(String roomId, CommissionStatus status) {
    final current = state[roomId];
    if (current == null) return;

    final updated = current.copyWith(
      status: status,
      updatedAt: DateTime.now(),
    );
    state = {...state, roomId: updated};

    ChatDummyData.updateRoomStatus(roomId, updated.status.statusBarLabel);
    WorkroomChatRegistry.updatePreview(
      roomId: roomId,
      preview: _previewForStatus(status),
    );
  }

  void markDeclined(String roomId) {
    final current = state[roomId];
    if (current == null) return;

    state = {
      ...state,
      roomId: current.copyWith(
        isDeclined: true,
        updatedAt: DateTime.now(),
      ),
    };
    WorkroomChatRegistry.updatePreview(
      roomId: roomId,
      preview: '신청서가 거절되었습니다.',
    );
  }

  /// 신청서 제출 시 새 거래·채팅방 생성
  String registerFromSubmission({
    required CommissionApplySubmission submission,
    required String artistAvatarUrl,
    String? artistId,
  }) {
    final client = ref.read(clientProfileProvider);
    final roomId = 'chat-comm-${submission.submittedAt.millisecondsSinceEpoch}';

    final transaction = CommissionTransaction(
      roomId: roomId,
      status: CommissionStatus.submitted,
      application: submission,
      artistName: submission.artistName,
      artistAvatarUrl: artistAvatarUrl,
      clientName: client.name,
      clientAvatarUrl: client.avatarUrl,
      commissionTitle: submission.commissionTitle,
      updatedAt: submission.submittedAt,
      artistId: artistId,
    );

    state = {...state, roomId: transaction};

    ChatDummyData.registerCommissionRoom(
      roomId: roomId,
      artistName: submission.artistName,
      artistAvatarUrl: artistAvatarUrl,
      clientName: client.name,
      clientAvatarUrl: client.avatarUrl,
      artistId: artistId,
      statusLabel: CommissionStatus.submitted.statusBarLabel,
      initialMessages: _initialMessages(submission),
    );

    WorkroomChatRegistry.register(
      roomId: roomId,
      artistName: submission.artistName,
      artistAvatarUrl: artistAvatarUrl,
      clientName: client.name,
      clientAvatarUrl: client.avatarUrl,
      preview: '커미션 신청서가 제출되었습니다.',
    );

    return roomId;
  }

  static String _previewForStatus(CommissionStatus status) => switch (status) {
        CommissionStatus.submitted => '커미션 신청서가 제출되었습니다.',
        CommissionStatus.accepted => '✓ 수락됨 · Accepted',
        CommissionStatus.paymentRequested => '결제 요청이 도착했습니다.',
        CommissionStatus.paid => '✓ 결제 완료',
      };

  static List<ChatMessage> _initialMessages(
    CommissionApplySubmission submission,
  ) {
    final time = ChatDummyData.formatNow();
    return [
      const ChatMessage(
        id: 'welcome',
        isMine: false,
        type: ChatMessageType.text,
        timeLabel: '10:30',
        text: '안녕하세요! 커미션 문의 감사합니다 :)',
      ),
      ChatMessage(
        id: 'client-intro',
        isMine: true,
        type: ChatMessageType.text,
        timeLabel: time,
        text:
            '안녕하세요! ${submission.commissionTitle} 의뢰하고 싶어서 신청서를 작성했어요.',
      ),
    ];
  }
}
