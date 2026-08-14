import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/chat/chat_room_screen.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/features/common/widgets/art_port_header.dart';
import 'package:art_port/features/review/data/review_providers.dart';
import 'package:art_port/features/review/review_form_screen.dart';
import 'package:art_port/features/workroom/models/workroom_order_detail.dart';
import 'package:art_port/features/workroom/order_detail_providers.dart';
import 'package:art_port/features/workroom/widgets/order_detail_action_bar.dart';
import 'package:art_port/features/workroom/widgets/order_detail_header.dart';
import 'package:art_port/features/workroom/widgets/order_payment_info_card.dart';
import 'package:art_port/features/workroom/widgets/order_progress_step_bar.dart';
import 'package:art_port/features/workroom/widgets/order_request_info_card.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderDetailView extends ConsumerWidget {
  const OrderDetailView({super.key, required this.orderId});

  final String orderId;

  void _onGoToChat(BuildContext context, String? chatRoomId) {
    if (chatRoomId == null) {
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '연결된 채팅방이 없습니다.',
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ChatRoomScreen(roomId: chatRoomId),
      ),
    );
  }

  void _onViewDraft(BuildContext context) {
    AppToast.show(
      ScaffoldMessenger.of(context),
      message: '현재 시안을 불러오는 중입니다.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(workroomOrderDetailProvider(orderId));
    final isArtistMode = ref.watch(appModeProvider);
    final existingReview = ref.watch(reviewForOrderProvider(orderId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const ArtPortHeader(),
          OrderDetailHeader(onBack: () => Navigator.of(context).pop()),
          Expanded(
            child: ApiAsyncBody<WorkroomOrderDetail?>(
              value: orderAsync,
              onRetry: () =>
                  ref.invalidate(workroomOrderDetailProvider(orderId)),
              errorMessage: '주문 정보를 불러오지 못했습니다.',
              builder: (order) {
                if (order == null) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '주문을 찾을 수 없습니다.',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('돌아가기'),
                        ),
                      ],
                    ),
                  );
                }

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 88),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _OrderSummarySection(order: order),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                            child: Text(
                              '의뢰 정보',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: OrderRequestInfoCard(order: order),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              '결제 정보',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                                height: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                            child: OrderPaymentInfoCard(payment: order.payment),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: OrderDetailActionBar(
                        onGoToChat: () =>
                            _onGoToChat(context, order.linkedChatRoomId),
                        primaryLabel: !isArtistMode && order.isCompleted
                            ? (existingReview == null
                                ? '⭐ 리뷰 작성하기'
                                : '⭐ 리뷰 수정하기')
                            : '👁️ 현재 시안 보기',
                        onPrimary: !isArtistMode && order.isCompleted
                            ? () => ReviewFormScreen.open(
                                  context,
                                  orderId: orderId,
                                  commissionTitle: order.commissionTitle,
                                  reviewId: existingReview?.id,
                                  initialRating: existingReview?.rating ?? 5,
                                  initialContent: existingReview?.content ?? '',
                                  artistUserId: order.artistUserId,
                                )
                            : () => _onViewDraft(context),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: ArtPortBottomNav(
        onTabSelected: (index) {
          ref.read(currentTabProvider.notifier).selectTab(index);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _OrderSummarySection extends StatelessWidget {
  const _OrderSummarySection({required this.order});

  final WorkroomOrderDetail order;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.primarySoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    order.progressStatusLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      height: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  order.deadlineSummaryLabel,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          OrderProgressStepBar(currentStepIndex: order.currentStepIndex),
        ],
      ),
    );
  }
}
