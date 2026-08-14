import 'package:art_port/features/auth/domain/user_role.dart';

class User {
  const User({
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
  final UserRole role;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;
}
