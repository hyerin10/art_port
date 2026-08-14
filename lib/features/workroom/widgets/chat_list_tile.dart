import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/common/widgets/unread_count_badge.dart';
import 'package:art_port/features/workroom/models/workroom_sample.dart';
import 'package:art_port/features/workroom/workroom_actions.dart';
import 'package:flutter/material.dart';

/// 작업실 채팅 목록 타일
class ChatListTile extends StatelessWidget {
  const ChatListTile({super.key, required this.item});

  final WorkroomChatItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => WorkroomActions.openChat(context, item.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              _OnlineAvatar(imageUrl: item.avatarUrl, isOnline: item.isOnline),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.counterpartName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      item.lastMessagePreview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    item.timeAgoLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (item.unreadCount > 0)
                    UnreadCountBadge(
                      count: item.unreadCount,
                      backgroundColor: AppColors.primary,
                    )
                  else
                    const SizedBox(height: 22),
                ],
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 22,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnlineAvatar extends StatelessWidget {
  const _OnlineAvatar({
    required this.imageUrl,
    required this.isOnline,
  });

  final String imageUrl;
  final bool isOnline;

  static const double _size = 52;

  static ImageProvider _avatarImage(String url) {
    if (url.startsWith('assets/')) {
      return AssetImage(url);
    }
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return NetworkImage(url);
    }
    return const AssetImage('assets/branding/art_port_icon.png');
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CircleAvatar(
            radius: _size / 2,
            backgroundColor: AppColors.chipBackground,
            backgroundImage: _avatarImage(imageUrl),
          ),
          if (isOnline)
            Positioned(
              right: 2,
              bottom: 2,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.onlineStatus,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
