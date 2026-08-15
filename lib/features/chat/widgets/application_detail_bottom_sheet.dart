import 'package:art_port/core/config/api_config.dart';
import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/formatters/currency_formatter.dart';
import 'package:art_port/core/network/resource_ids.dart';
import 'package:art_port/core/widgets/local_or_network_image.dart';
import 'package:art_port/features/chat/models/chat_image_attachment.dart';
import 'package:art_port/features/chat/widgets/chat_image_viewer.dart';
import 'package:art_port/features/commission/models/commission_transaction.dart';
import 'package:flutter/material.dart';

/// 신청서 상세 바텀 시트
class ApplicationDetailBottomSheet extends StatelessWidget {
  const ApplicationDetailBottomSheet({
    super.key,
    required this.transaction,
  });

  final CommissionTransaction transaction;

  static Future<void> show(
    BuildContext context, {
    required CommissionTransaction transaction,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ApplicationDetailBottomSheet(transaction: transaction),
    );
  }

  String _formatDeadline(DateTime? date) {
    if (date == null) return '-';
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  @override
  Widget build(BuildContext context) {
    final application = transaction.application;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: DraggableScrollableSheet(
        initialChildSize: 0.82,
        minChildSize: 0.45,
        maxChildSize: 0.95,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '신청서 상세',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${transaction.clientName}님의 커미션 신청 내용',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                        color: AppColors.textSecondary,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.sell_outlined,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                application.selectedOption.displayLabel,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            Text(
                              CurrencyFormatter.formatWonWithSuffix(
                                application.selectedOption.priceWon,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const _SectionTitle(
                        icon: Icons.article_outlined,
                        label: '요청 내용',
                      ),
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          application.requestContent,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SectionTitle(
                        icon: Icons.image_outlined,
                        label:
                            '참고 이미지 (${application.referenceImagePaths.length})',
                      ),
                      const SizedBox(height: 10),
                      _ReferenceGrid(paths: application.referenceImagePaths),
                      const SizedBox(height: 20),
                      _InfoBar(
                        icon: Icons.language_outlined,
                        label: '사용 용도',
                        value: application.usagePurpose.labelKo,
                      ),
                      const SizedBox(height: 10),
                      _InfoBar(
                        icon: Icons.calendar_today_outlined,
                        label: '희망 마감일',
                        value: _formatDeadline(application.desiredDeadline),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _ReferenceGrid extends StatelessWidget {
  const _ReferenceGrid({required this.paths});

  final List<String> paths;

  @override
  Widget build(BuildContext context) {
    if (paths.isEmpty) {
      return Row(
        children: List.generate(
          3,
          (index) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: index == 0 ? 0 : 8),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: paths.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final path = paths[index];
          final attachment = _attachmentFor(path, index);
          return GestureDetector(
            onTap: () => ChatImageViewer.open(context, attachment),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 88,
                height: 88,
                child: Hero(
                  tag: attachment.heroTag,
                  child: Material(
                    color: Colors.transparent,
                    child: LocalOrNetworkImage(source: path),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  static ChatImageAttachment _attachmentFor(String path, int index) {
    final isRemote =
        ResourceIds.isRemoteUrl(path) || path.startsWith('/');
    return ChatImageAttachment(
      messageId: 'order-ref-$index-${path.hashCode}',
      fileName: '참고이미지_${index + 1}.jpg',
      localPath: isRemote ? null : path,
      networkUrl: isRemote ? ApiConfig.resolveMediaUrl(path) : null,
    );
  }
}

class _InfoBar extends StatelessWidget {
  const _InfoBar({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
