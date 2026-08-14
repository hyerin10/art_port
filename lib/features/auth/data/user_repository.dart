import 'package:art_port/core/network/api_client.dart';
import 'package:art_port/features/auth/data/dto/user_dto.dart';
import 'package:art_port/features/auth/domain/user.dart';

class UserRepository {
  UserRepository(this._client);

  final ApiClient _client;

  Future<User> getUser(String id) async {
    final json = await _client.get('/users/$id');
    return UserDto.fromJson(json).toDomain();
  }

  Future<User> login(String email, String password) async {
    final json = await _client.post(
      '/users/login',
      body: LoginRequest(email: email, password: password).toJson(),
    );
    return UserDto.fromJson(json).toDomain();
  }

  Future<User> createUser(CreateUserRequest request) async {
    final json = await _client.post('/users', body: request.toJson());
    return UserDto.fromJson(json).toDomain();
  }

  Future<User> updateUser(String id, UpdateUserRequest request) async {
    final json = await _client.patch('/users/$id', body: request.toJson());
    return UserDto.fromJson(json).toDomain();
  }

  Future<void> deactivateUser(String id) async {
    await _client.delete('/users/$id');
  }
}
