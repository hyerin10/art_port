import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/order/data/order_mappers.dart';
import 'package:art_port/features/order/data/order_providers.dart';
import 'package:art_port/features/workroom/models/workroom_order_detail.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workroomOrderDetailProvider =
    FutureProvider.family<WorkroomOrderDetail?, String>((ref, orderId) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;

  try {
    final order = await ref.watch(orderRepositoryProvider).getById(
          orderId: orderId,
          userId: userId,
        );
    final lookups = await ParticipantLookups.resolve(
      ref,
      userIds: [order.clientId, order.artistId],
    );
    return OrderMappers.toOrderDetail(
      order,
      lookups: lookups,
      isArtistMode: ref.watch(appModeProvider),
    );
  } on ApiException catch (e) {
    if (e.status == 404 || e.code == 'ORDER_NOT_FOUND') {
      return null;
    }
    rethrow;
  }
});
