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

  User copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    bool? isAdmin,
    String? clientProfileId,
    String? artistProfileId,
    bool? isEmailVerified,
    bool? isActive,
    DateTime? lastLoginAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      isAdmin: isAdmin ?? this.isAdmin,
      clientProfileId: clientProfileId ?? this.clientProfileId,
      artistProfileId: artistProfileId ?? this.artistProfileId,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
