import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/common/widgets/unread_count_badge.dart';
import 'package:art_port/features/chat/chat_room_screen.dart';
import 'package:art_port/features/workroom/models/workroom_sample.dart';
import 'package:art_port/features/workroom/order_detail_screen.dart';
import 'package:art_port/features/workroom/workroom_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 작업실(Workroom) 탭 내부 스크롤 콘텐츠
class WorkroomView extends ConsumerWidget {
  const WorkroomView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subTab = ref.watch(workroomSubTabProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '작업실',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 16),
              _WorkroomSegmentBar(
                selected: subTab,
                onSelect: (tab) =>
                    ref.read(workroomSubTabProvider.notifier).select(tab),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: subTab == WorkroomSubTab.chats
              ? const _ChatsListView()
              : const _OrdersListView(),
        ),
      ],
    );
  }
}

// ─── Segment Bar ────────────────────────────────────────────────────────────

class _WorkroomSegmentBar extends StatelessWidget {
  const _WorkroomSegmentBar({
    required this.selected,
    required this.onSelect,
  });

  final WorkroomSubTab selected;
  final ValueChanged<WorkroomSubTab> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentButton(
              label: '채팅',
              icon: Icons.chat_bubble_outline_rounded,
              isSelected: selected == WorkroomSubTab.chats,
              onTap: () => onSelect(WorkroomSubTab.chats),
            ),
          ),
          Expanded(
            child: _SegmentButton(
              label: '주문 현황',
              icon: Icons.inventory_2_outlined,
              isSelected: selected == WorkroomSubTab.orders,
              onTap: () => onSelect(WorkroomSubTab.orders),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor =
        isSelected ? AppColors.textPrimary : AppColors.textMuted;
    final iconColor =
        isSelected ? AppColors.textPrimary : AppColors.textMuted;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: textColor,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chats List ─────────────────────────────────────────────────────────────

class _ChatsListView extends ConsumerWidget {
  const _ChatsListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chats = ref.watch(workroomChatsProvider);

    if (chats.isEmpty) {
      return const _WorkroomEmptyState(message: '채팅방이 없습니다.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 12, 24),
      itemCount: chats.length,
      separatorBuilder: (_, _) => const SizedBox(height: 4),
      itemBuilder: (context, index) {
        return _ChatListTile(item: chats[index]);
      },
    );
  }
}

class _ChatListTile extends StatelessWidget {
  const _ChatListTile({required this.item});

  final WorkroomChatItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ChatRoomScreen(roomId: item.id),
            ),
          );
        },
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
            backgroundImage: NetworkImage(imageUrl),
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

// ─── Orders List ────────────────────────────────────────────────────────────

class _OrdersListView extends ConsumerWidget {
  const _OrdersListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(workroomOrdersProvider);

    if (orders.isEmpty) {
      return const _WorkroomEmptyState(message: '주문 내역이 없습니다.');
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _OrderCard(item: orders[index]);
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.item});

  final WorkroomOrderItem item;

  @override
  Widget build(BuildContext context) {
    final statusStyle = _OrderStatusStyle.forStatus(item.status);
    final progress = (item.progressPercent.clamp(0, 100)) / 100;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => OrderDetailScreen(orderId: item.id),
            ),
          );
        },
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.chipBackground,
                    backgroundImage: NetworkImage(item.avatarUrl),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.counterpartLabel,
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
                  const SizedBox(width: 8),
                  _OrderStatusBadge(style: statusStyle),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  const Text(
                    '진행률',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${item.progressPercent}%',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: AppColors.chipBackground,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    item.deadlineLabel,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    item.priceLabel,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderStatusStyle {
  const _OrderStatusStyle({
    required this.label,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
  });

  final String label;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;

  static const _inProgressFg = Color(0xFF7C3AED);
  static const _inProgressBg = Color(0xFFEDE9FE);
  static const _reviewFg = Color(0xFFDB2777);
  static const _reviewBg = Color(0xFFFCE7F3);
  static const _completedFg = Color(0xFF16A34A);
  static const _completedBg = Color(0xFFDCFCE7);

  static _OrderStatusStyle forStatus(WorkroomOrderStatus status) {
    return switch (status) {
      WorkroomOrderStatus.inProgress => const _OrderStatusStyle(
          label: '진행 중',
          backgroundColor: _inProgressBg,
          foregroundColor: _inProgressFg,
          icon: Icons.schedule_rounded,
        ),
      WorkroomOrderStatus.review => const _OrderStatusStyle(
          label: '리뷰 중',
          backgroundColor: _reviewBg,
          foregroundColor: _reviewFg,
          icon: Icons.radio_button_checked_rounded,
        ),
      WorkroomOrderStatus.completed => const _OrderStatusStyle(
          label: '완성',
          backgroundColor: _completedBg,
          foregroundColor: _completedFg,
          icon: Icons.check_circle_outline_rounded,
        ),
    };
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.style});

  final _OrderStatusStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(style.icon, size: 14, color: style.foregroundColor),
          const SizedBox(width: 4),
          Text(
            style.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: style.foregroundColor,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _WorkroomEmptyState extends StatelessWidget {
  const _WorkroomEmptyState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
