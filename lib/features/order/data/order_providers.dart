import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/order/data/dto/order_dto.dart';
import 'package:art_port/features/order/data/order_mappers.dart';
import 'package:art_port/features/order/data/order_repository.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepository(ref.watch(apiClientProvider));
});

final myOrdersProvider = FutureProvider<List<OrderDto>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];

  final repo = ref.watch(orderRepositoryProvider);
  final isArtistMode = ref.watch(appModeProvider);
  return isArtistMode ? repo.getMyArtist(userId) : repo.getMyClient(userId);
});

final orderLookupsProvider = FutureProvider<ParticipantLookups>((ref) async {
  final orders = await ref.watch(myOrdersProvider.future);
  return ParticipantLookups.resolve(
    ref,
    userIds: [
      for (final order in orders) ...[order.clientId, order.artistId],
    ],
  );
});
