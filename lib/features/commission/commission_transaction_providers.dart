import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/commission/models/commission_status.dart';
import 'package:art_port/features/commission/models/commission_transaction.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/order/data/order_mappers.dart';
import 'package:art_port/features/order/data/order_providers.dart';
import 'package:art_port/features/workroom/order_detail_providers.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 현재 사용자가 작가 시점인지 (전역 모드)
final commissionIsArtistProvider = Provider<bool>((ref) {
  return ref.watch(appModeProvider);
});

/// 등록된 모든 커미션 거래 목록
final allCommissionTransactionsProvider =
    Provider<List<CommissionTransaction>>((ref) {
  final orders = ref.watch(myOrdersProvider).valueOrNull ?? const [];
  final lookups = ref.watch(orderLookupsProvider).valueOrNull;
  if (lookups == null) return const [];
  return [for (final order in orders) OrderMappers.toTransaction(order, lookups)];
});

/// 채팅방별 커미션 거래 상태
final commissionTransactionProvider =
    Provider.family<CommissionTransaction?, String>((ref, roomId) {
  final orders = ref.watch(myOrdersProvider).valueOrNull;
  final lookups = ref.watch(orderLookupsProvider).valueOrNull;
  if (orders == null || lookups == null || roomId.isEmpty) return null;

  final matches = [
    for (final order in orders)
      if (order.chatRoomId == roomId) order,
  ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  if (matches.isEmpty) return null;
  return OrderMappers.toTransaction(matches.first, lookups);
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
    return ref.watch(commissionTransactionProvider(roomId));
  }

  bool get _isArtist => ref.read(appModeProvider);

  Future<void> acceptApplication() async {
    final current = state;
    final userId = ref.read(currentUserIdProvider);
    if (current == null ||
        current.status != CommissionStatus.submitted ||
        current.isDeclined ||
        !_isArtist ||
        userId == null) {
      return;
    }

    await ref.read(orderRepositoryProvider).accept(current.orderId);
    _refresh(current.orderId);
  }

  Future<void> rejectApplication({
    String reason = '일정이 맞지 않아 수락이 어렵습니다.',
  }) async {
    final current = state;
    final userId = ref.read(currentUserIdProvider);
    if (current == null ||
        current.status != CommissionStatus.submitted ||
        !_isArtist ||
        userId == null) {
      return;
    }

    await ref.read(orderRepositoryProvider).reject(
          orderId: current.orderId,
          reason: reason,
        );
    _refresh(current.orderId);
  }

  Future<void> requestPayment() async {
    throw const ApiException(
      code: 'NOT_IMPLEMENTED',
      status: 501,
      message: '결제 요청 API는 아직 준비되지 않았습니다.',
    );
  }

  Future<void> completePayment() async {
    throw const ApiException(
      code: 'NOT_IMPLEMENTED',
      status: 501,
      message: '결제 API는 아직 준비되지 않았습니다.',
    );
  }

  void _refresh(String orderId) {
    refreshOrderQueries(invalidate: ref.invalidate, orderId: orderId);
  }
}

Future<void> runCommissionAction({
  required WidgetRef ref,
  required BuildContext context,
  required Future<void> Function() action,
  String fallbackMessage = '요청 처리에 실패했습니다. 다시 시도해 주세요.',
}) async {
  try {
    await action();
  } on ApiException catch (e) {
    if (!context.mounted) return;
    AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
  } catch (_) {
    if (!context.mounted) return;
    AppToast.show(ScaffoldMessenger.of(context), message: fallbackMessage);
  }
}
