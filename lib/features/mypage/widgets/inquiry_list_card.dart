import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/common/widgets/unread_count_badge.dart';
import 'package:art_port/features/mypage/models/support_inquiry_item.dart';
import 'package:flutter/material.dart';

class InquiryListCard extends StatelessWidget {
  const InquiryListCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final SupportInquiryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SupportCenterAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SupportInquiryConstants.centerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.lastMessagePreview,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                        height: 1.35,
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
                    UnreadCountBadge(count: item.unreadCount)
                  else
                    const SizedBox(height: 22),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportCenterAvatar extends StatelessWidget {
  const SupportCenterAvatar({super.key});

  static const double _size = 52;

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
            backgroundColor: AppColors.primarySoft,
            backgroundImage: const AssetImage(
              SupportInquiryConstants.centerAvatarAsset,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: const Icon(
                Icons.chat_bubble_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
