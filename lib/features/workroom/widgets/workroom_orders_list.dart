import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/workroom/models/workroom_commission_order.dart';
import 'package:art_port/features/workroom/widgets/commission_order_card.dart';
import 'package:art_port/features/workroom/widgets/workroom_empty_state.dart';
import 'package:art_port/features/workroom/workroom_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작업실 주문 현황 탭 목록
class WorkroomOrdersList extends ConsumerWidget {
  const WorkroomOrdersList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    if (!isLoggedIn) {
      return const WorkroomEmptyState(message: '로그인하면 주문을 볼 수 있습니다.');
    }

    final orders = ref.watch(workroomOrdersProvider);
    return ApiAsyncBody<List<WorkroomCommissionOrder>>(
      value: orders,
      onRetry: () => ref.invalidate(workroomOrdersProvider),
      errorMessage: '주문 목록을 불러오지 못했습니다.',
      builder: (data) {
        if (data.isEmpty) {
          return const WorkroomEmptyState(message: '주문 내역이 없습니다.');
        }

        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          itemCount: data.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return CommissionOrderCard(order: data[index]);
          },
        );
      },
    );
  }
}
