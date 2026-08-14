import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/common/widgets/empty_state_view.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:art_port/features/review/data/review_providers.dart';
import 'package:art_port/features/review/models/review_list_item.dart';
import 'package:art_port/features/review/review_form_screen.dart';
import 'package:art_port/features/review/widgets/review_card.dart';
import 'package:art_port/features/review/widgets/review_list_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReviewListKind { mine, received }

class MyReviewsView extends ConsumerWidget {
  const MyReviewsView({super.key, required this.kind});

  final ReviewListKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoggedIn = ref.watch(isLoggedInProvider);
    final asyncItems = kind == ReviewListKind.mine
        ? ref.watch(myReviewItemsProvider)
        : ref.watch(receivedReviewItemsProvider);
    final title = kind == ReviewListKind.mine ? '내가 작성한 리뷰' : '받은 리뷰';

    return MyPageSubScreenScaffold(
      header: ReviewListHeader(
        title: title,
        onBack: () => Navigator.of(context).pop(),
      ),
      body: !isLoggedIn
          ? const EmptyStateView(
              icon: Icons.star_outline_rounded,
              title: '로그인이 필요합니다',
              subtitle: '로그인하면 리뷰를 확인할 수 있습니다',
            )
          : ApiAsyncBody<List<ReviewListItem>>(
              value: asyncItems,
              onRetry: () {
                if (kind == ReviewListKind.mine) {
                  ref.invalidate(myReviewItemsProvider);
                } else {
                  ref.invalidate(receivedReviewItemsProvider);
                }
              },
              errorMessage: '리뷰를 불러오지 못했습니다.',
              builder: (items) {
                if (items.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.star_outline_rounded,
                    title: kind == ReviewListKind.mine
                        ? '아직 작성한 리뷰가 없습니다'
                        : '아직 받은 리뷰가 없습니다',
                    subtitle: kind == ReviewListKind.mine
                        ? '완료된 주문에서 리뷰를 남겨보세요'
                        : '완료된 작업에 대한 리뷰가 여기에 표시됩니다',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return ReviewCard(
                      item: item,
                      onEdit: kind == ReviewListKind.mine
                          ? () => ReviewFormScreen.open(
                                context,
                                orderId: item.review.orderId,
                                commissionTitle: item.title,
                                reviewId: item.review.id,
                                initialRating: item.review.rating,
                                initialContent: item.review.content ?? '',
                                artistUserId: item.review.artistId,
                              )
                          : null,
                      onDelete: kind == ReviewListKind.mine
                          ? () => _confirmDelete(context, ref, item)
                          : null,
                    );
                  },
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    ReviewListItem item,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('리뷰 삭제'),
        content: const Text('이 리뷰를 삭제할까요?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    try {
      await ref.read(reviewRepositoryProvider).delete(
            reviewId: item.review.id,
            clientId: userId,
          );
      invalidateReviewQueries(ref, artistUserId: item.review.artistId);
      if (!context.mounted) return;
      AppToast.show(ScaffoldMessenger.of(context), message: '리뷰가 삭제되었습니다.');
    } on ApiException catch (e) {
      if (!context.mounted) return;
      AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
    } catch (_) {
      if (!context.mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '리뷰 삭제에 실패했습니다. 다시 시도해 주세요.',
      );
    }
  }
}
