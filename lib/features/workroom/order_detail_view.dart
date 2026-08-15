import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/chat/chat_room_screen.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/features/common/widgets/art_port_header.dart';
import 'package:art_port/features/order/data/order_providers.dart';
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

class OrderDetailView extends ConsumerStatefulWidget {
  const OrderDetailView({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<OrderDetailView> createState() => _OrderDetailViewState();
}

class _OrderDetailViewState extends ConsumerState<OrderDetailView> {
  bool _busy = false;

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

  Future<void> _advanceStep(WorkroomOrderDetail order) async {
    final nextStep = order.nextStep;
    final userId = ref.read(currentUserIdProvider);
    if (!order.canAdvanceStep || nextStep == null || userId == null || _busy) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          nextStep == OrderProgressStep.completed ? '작업 완료' : '진행 단계 변경',
        ),
        content: Text(
          nextStep == OrderProgressStep.completed
              ? '작업을 완료 처리할까요?'
              : '진행 단계를 ‘${nextStep.label}’(으)로 변경할까요?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('변경'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(orderRepositoryProvider).updateStep(
            orderId: widget.orderId,
            newStep: nextStep.apiValue,
          );
      refreshOrderQueries(invalidate: ref.invalidate, orderId: widget.orderId);
      if (!mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: nextStep == OrderProgressStep.completed
            ? '작업을 완료 처리했습니다.'
            : '진행 단계를 ‘${nextStep.label}’(으)로 변경했습니다.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '단계 변경에 실패했습니다. 다시 시도해 주세요.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelOrder() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null || _busy) return;

    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _CancelOrderDialog(),
    );
    if (reason == null || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(orderRepositoryProvider).cancel(
            orderId: widget.orderId,
            reason: reason,
          );
      refreshOrderQueries(invalidate: ref.invalidate, orderId: widget.orderId);
      if (!mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '주문을 취소했습니다.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '주문 취소에 실패했습니다. 다시 시도해 주세요.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.orderId;
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

                final nextStep = order.nextStep;
                final canAdvance =
                    order.canAdvanceStep && nextStep != null;
                final writeReview = !isArtistMode && order.isCompleted;
                final primaryLabel = canAdvance
                    ? (nextStep == OrderProgressStep.completed
                        ? '작업 완료 처리'
                        : '다음 단계: ${nextStep.label}')
                    : writeReview
                        ? (existingReview == null
                            ? '⭐ 리뷰 작성하기'
                            : '⭐ 리뷰 수정하기')
                        : '👁️ 현재 시안 보기';

                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 88),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _OrderSummarySection(
                            order: order,
                            cancelEnabled: !_busy,
                            onCancel: order.canCancel ? _cancelOrder : null,
                          ),
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
                        enabled: !_busy,
                        isBusy: _busy && canAdvance,
                        onGoToChat: () =>
                            _onGoToChat(context, order.linkedChatRoomId),
                        primaryLabel: primaryLabel,
                        onPrimary: canAdvance
                            ? () => _advanceStep(order)
                            : writeReview
                                ? () => ReviewFormScreen.open(
                                      context,
                                      orderId: orderId,
                                      commissionTitle: order.commissionTitle,
                                      reviewId: existingReview?.id,
                                      initialRating:
                                          existingReview?.rating ?? 5,
                                      initialContent:
                                          existingReview?.content ?? '',
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
  const _OrderSummarySection({
    required this.order,
    this.onCancel,
    this.cancelEnabled = true,
  });

  final WorkroomOrderDetail order;
  final VoidCallback? onCancel;
  final bool cancelEnabled;

  @override
  Widget build(BuildContext context) {
    final cancelReason = order.cancelReason;

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
          if (cancelReason != null && cancelReason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                '취소 사유: $cancelReason',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ),
          if (onCancel != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: cancelEnabled ? onCancel : null,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                  child: const Text(
                    '주문 취소',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _CancelOrderDialog extends StatefulWidget {
  const _CancelOrderDialog();

  @override
  State<_CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<_CancelOrderDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('주문 취소'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('주문을 취소할까요? 취소 후에는 되돌릴 수 없습니다.'),
          const SizedBox(height: 12),
          TextField(
            controller: _reason,
            maxLines: 3,
            maxLength: 200,
            decoration: const InputDecoration(
              hintText: '취소 사유 (선택)',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _reason.text.trim()),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('취소하기'),
        ),
      ],
    );
  }
}
