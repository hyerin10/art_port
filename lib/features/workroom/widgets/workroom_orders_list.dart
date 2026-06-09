import 'package:art_port/features/workroom/widgets/commission_order_card.dart';
import 'package:art_port/features/workroom/widgets/workroom_empty_state.dart';
import 'package:art_port/features/workroom/workroom_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작업실 주문 현황 탭 목록 — [commissionTransactionRegistryProvider] 구독
class WorkroomOrdersList extends ConsumerWidget {
  const WorkroomOrdersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(workroomOrdersProvider);

    if (orders.isEmpty) {
      return const WorkroomEmptyState(message: '주문 내역이 없습니다.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return CommissionOrderCard(order: orders[index]);
      },
    );
  }
}
