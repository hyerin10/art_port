class User {
  const User({
    required this.id,
    required this.email,
    required this.name,
    required this.phone,
    required this.isAdmin,
    this.clientProfileId,
    this.artistProfileId,
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
  final bool isAdmin;
  final String? clientProfileId;
  final String? artistProfileId;
  final bool isEmailVerified;
  final bool isActive;
  final DateTime? lastLoginAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasClientProfile => clientProfileId != null;

  bool get hasArtistProfile => artistProfileId != null;
}
