import 'package:art_port/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// 채팅방 상단 헤더 — 스크롤과 무관하게 고정
class ChatRoomHeader extends StatelessWidget {
  const ChatRoomHeader({
    super.key,
    required this.counterpartName,
    required this.avatarUrl,
    required this.isOnline,
    required this.onBack,
    this.onProfileTap,
  });

  final String counterpartName;
  final String avatarUrl;
  final bool isOnline;
  final VoidCallback onBack;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
        child: Row(
          children: [
            IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.textPrimary,
              padding: const EdgeInsets.all(8),
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            ),
            Expanded(
              child: GestureDetector(
                onTap: onProfileTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    _ChatAvatar(imageUrl: avatarUrl, isOnline: isOnline),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            counterpartName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isOnline ? '온라인' : '오프라인',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatAvatar extends StatelessWidget {
  const _ChatAvatar({
    required this.imageUrl,
    required this.isOnline,
  });

  final String imageUrl;
  final bool isOnline;

  static const double _size = 44;

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
              right: 0,
              bottom: 0,
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
