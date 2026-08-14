class ArtistApplicationDto {
  const ArtistApplicationDto({
    required this.id,
    required this.userId,
    required this.status,
  });

  final String id;
  final String userId;
  final String status;

  factory ArtistApplicationDto.fromJson(Map<String, dynamic> json) {
    return ArtistApplicationDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      status: json['status'] as String,
    );
  }

  bool get isPending => status == 'pending';
}
