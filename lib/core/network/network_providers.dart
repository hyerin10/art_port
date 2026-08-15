import 'package:art_port/core/auth/token_storage.dart';
import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/auth/data/dto/auth_response_dto.dart';
import 'package:art_port/features/auth/data/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(tokenStorageProvider);

  late final ApiClient client;
  client = ApiClient(
    accessTokenProvider: storage.readAccessToken,
    tokenRefresher: () async {
      final refreshToken = await storage.readRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await storage.clear();
        return false;
      }

      try {
        final json = await client.post(
          '/auth/refresh',
          body: {'refreshToken': refreshToken},
          authenticated: false,
        );
        final session = AuthResponseDto.fromJson(json).toDomain();
        await storage.saveTokens(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
        );
        return true;
      } catch (_) {
        await storage.clear();
        return false;
      }
    },
  );

  ref.onDispose(client.close);
  return client;
});

final authRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(ref.watch(apiClientProvider));
});
