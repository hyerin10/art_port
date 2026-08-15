import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/auth/data/dto/auth_response_dto.dart';
import 'package:art_port/features/auth/data/dto/user_dto.dart';
import 'package:art_port/features/auth/domain/user.dart';

class UserRepository {
  UserRepository(this._client);

  final ApiClient _client;

  Future<User> getUser(String id) async {
    final json = await _client.get('/users/$id');
    return UserDto.fromJson(json).toDomain();
  }

  Future<User> getMe() async {
    final json = await _client.get('/users/me');
    return UserDto.fromJson(json).toDomain();
  }

  Future<AuthSession> login(String email, String password) async {
    final json = await _client.post(
      '/users/login',
      body: LoginRequest(email: email, password: password).toJson(),
      authenticated: false,
    );
    return AuthResponseDto.fromJson(json).toDomain();
  }

  Future<AuthSession> refresh(String refreshToken) async {
    final json = await _client.post(
      '/auth/refresh',
      body: {'refreshToken': refreshToken},
      authenticated: false,
    );
    return AuthResponseDto.fromJson(json).toDomain();
  }

  Future<void> logout(String refreshToken) async {
    await _client.postEmpty(
      '/auth/logout',
      body: {'refreshToken': refreshToken},
      authenticated: false,
    );
  }

  Future<User> createUser(CreateUserRequest request) async {
    final json = await _client.post(
      '/users',
      body: request.toJson(),
      authenticated: false,
    );
    return UserDto.fromJson(json).toDomain();
  }

  Future<User> updateMe(UpdateUserRequest request) async {
    final json = await _client.patch('/users/me', body: request.toJson());
    return UserDto.fromJson(json).toDomain();
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    await _client.patchEmpty(
      '/users/me/password',
      body: request.toJson(),
    );
  }

  Future<void> deactivateMe() async {
    await _client.delete('/users/me');
  }

  Future<void> sendVerificationEmail(String email) async {
    await _client.postEmpty(
      '/users/send-verification-email',
      body: EmailVerificationRequest(email: email).toJson(),
      authenticated: false,
    );
  }

  Future<void> resendVerificationEmail(String email) async {
    await _client.postEmpty(
      '/users/resend-verification-email',
      body: EmailVerificationRequest(email: email).toJson(),
      authenticated: false,
    );
  }

  Future<User> verifyEmail({
    required String email,
    required String code,
  }) async {
    final json = await _client.post(
      '/users/verify-email',
      body: VerifyEmailRequest(email: email, code: code).toJson(),
      authenticated: false,
    );
    return UserDto.fromJson(json).toDomain();
  }
}
