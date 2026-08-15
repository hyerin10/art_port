import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/local_or_network_image.dart';
import 'package:art_port/features/workroom/models/workroom_order_detail.dart';
import 'package:flutter/material.dart';

/// 의뢰 정보 카드
class OrderRequestInfoCard extends StatelessWidget {
  const OrderRequestInfoCard({
    super.key,
    required this.order,
  });

  final WorkroomOrderDetail order;

  static const _visibleImageCount = 3;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.chipBackground,
                backgroundImage: NetworkImage(order.summary.avatarUrl),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.commissionTitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'by ${order.artistName}',
                      style: const TextStyle(
                        fontSize: 13,
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  icon: Icons.palette_outlined,
                  label: '프로젝트',
                  value: order.projectName,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoBox(
                  icon: Icons.person_outline_rounded,
                  label: '아티스트',
                  value: order.artistName,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _InfoBox(
            icon: Icons.description_outlined,
            label: '사용 용도',
            value: order.usagePurpose,
            fullWidth: true,
          ),
          const SizedBox(height: 16),
          const Text(
            '요청 사항',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            order.requestDetails,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
          if (order.referenceImageUrls.isNotEmpty ||
              order.hiddenReferenceImageCount > 0) ...[
            const SizedBox(height: 16),
            const Text(
              '참고 이미지',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 10),
            _ReferenceImageRow(order: order),
          ],
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
    this.fullWidth = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                  height: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReferenceImageRow extends StatelessWidget {
  const _ReferenceImageRow({required this.order});

  final WorkroomOrderDetail order;

  @override
  Widget build(BuildContext context) {
    final visible = order.referenceImageUrls
        .take(OrderRequestInfoCard._visibleImageCount)
        .toList();
    final showOverflow = order.hiddenReferenceImageCount > 0;

    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length + (showOverflow ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          if (showOverflow && index == visible.length) {
            return _OverflowThumbnail(count: order.hiddenReferenceImageCount);
          }
          return _ReferenceThumbnail(imageUrl: visible[index]);
        },
      ),
    );
  }
}

class _ReferenceThumbnail extends StatelessWidget {
  const _ReferenceThumbnail({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 72,
        height: 72,
        child: LocalOrNetworkImage(source: imageUrl),
      ),
    );
  }
}

class _OverflowThumbnail extends StatelessWidget {
  const _OverflowThumbnail({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(10),
      ),
      alignment: Alignment.center,
      child: Text(
        '+$count',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
