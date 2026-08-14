import 'package:art_port/features/auth/domain/user.dart';
import 'package:art_port/features/auth/domain/user_role.dart';

class UserDto {
  const UserDto({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.role,
    required this.isEmailVerified,
    required this.isActive,
    this.lastLoginAt,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String email;
  final String name;
  final String phone;
  final String role;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      role: json['role'] as String,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      lastLoginAt: _parseDateTime(json['lastLoginAt']),
      createdAt: _parseDateTime(json['createdAt'])!,
      updatedAt: _parseDateTime(json['updatedAt'])!,
    );
  }

  User toDomain() {
    return User(
      id: id,
      email: email,
      name: name,
      phone: phone,
      role: UserRole.fromString(role),
      isEmailVerified: isEmailVerified,
      isActive: isActive,
      lastLoginAt: lastLoginAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }
}

class LoginRequest {
  const LoginRequest({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class CreateUserRequest {
  const CreateUserRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    this.role = UserRole.client,
  });

  final String email;
  final String password;
  final String name;
  final String phone;
  final UserRole role;

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'role': role.value,
    };
  }
}

class UpdateUserRequest {
  const UpdateUserRequest({
    this.name,
    this.phone,
  });

  final String? name;
  final String? phone;

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
    };
  }
}
