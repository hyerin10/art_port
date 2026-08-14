class FollowerListItem {
  const FollowerListItem({
    required this.userId,
    required this.name,
    required this.avatarUrl,
    this.artistProfileId,
  });

  final String userId;
  final String name;
  final String avatarUrl;
  final String? artistProfileId;
}
