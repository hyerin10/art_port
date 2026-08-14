import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/chat/data/chat_providers.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/commission/models/commission_apply_args.dart';
import 'package:art_port/features/order/data/order_mappers.dart';
import 'package:art_port/features/order/data/order_providers.dart';
import 'package:art_port/features/workroom/workroom_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커미션 신청 제출 내역
final commissionApplySubmissionsProvider = NotifierProvider<
    CommissionApplySubmissionsNotifier, List<CommissionApplySubmission>>(
  CommissionApplySubmissionsNotifier.new,
);

class CommissionApplySubmissionsNotifier
    extends Notifier<List<CommissionApplySubmission>> {
  @override
  List<CommissionApplySubmission> build() => [];

  Future<String> submit(CommissionApplySubmission submission) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      throw const ApiException(
        code: 'UNAUTHORIZED',
        status: 401,
        message: '로그인이 필요합니다.',
      );
    }

    final catalog = await ref.read(commissionCatalogProvider.future);
    final detail = catalog.detailFor(submission.commissionId);
    if (detail == null || detail.artistUserId.isEmpty) {
      throw const ApiException(
        code: 'COMMISSION_TYPE_NOT_FOUND',
        status: 404,
        message: '커미션을 찾을 수 없습니다.',
      );
    }

    final room = await ref.read(chatRoomRepositoryProvider).findOrCreate(
          userId: userId,
          clientId: userId,
          artistId: detail.artistUserId,
        );

    final isBaseOption = submission.selectedOption.label == '기본';
    final remoteImageUrls = [
      for (final path in submission.referenceImagePaths)
        if (path.startsWith('http')) path,
    ];

    await ref.read(orderRepositoryProvider).submit(
          clientId: userId,
          commissionTypeId: submission.commissionId,
          requestContent: submission.requestContent,
          referenceImageUrls: remoteImageUrls,
          usagePurpose: submission.usagePurpose.name,
          desiredDeadline: submission.desiredDeadline == null
              ? null
              : OrderMappers.formatDateYmd(submission.desiredDeadline!),
          selectedOption: isBaseOption
              ? null
              : {
                  'label': submission.selectedOption.label,
                  'priceWon': submission.selectedOption.priceWon,
                },
        );

    state = [...state, submission];
    ref.invalidate(myOrdersProvider);
    ref.invalidate(orderLookupsProvider);
    ref.invalidate(workroomChatsProvider);
    return room.id;
  }
}
