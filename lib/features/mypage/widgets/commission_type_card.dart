import 'dart:io';

import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/dashed_border.dart';
import 'package:art_port/features/mypage/models/commission_type_data.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 커미션 타입 목록 카드
class CommissionTypeCard extends StatelessWidget {
  const CommissionTypeCard({
    super.key,
    required this.type,
    required this.onToggleActive,
    required this.onEdit,
    required this.onDelete,
  });

  final ArtistCommissionType type;
  final ValueChanged<bool> onToggleActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final inactiveOpacity = type.isActive ? 1.0 : 0.55;

    return Opacity(
      opacity: inactiveOpacity,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ThumbnailImage(source: type.thumbnailSource),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              type.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              type.formattedPrice,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: type.isActive,
                        onChanged: onToggleActive,
                        activeTrackColor: AppColors.primary,
                        activeThumbColor: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_outlined,
                        size: 15,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        type.workPeriod,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _SlotStatusBadge(type: type),
                    ],
                  ),
                  if (type.description.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      type.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        height: 1.45,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  _SamplePreviewRow(type: type),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 1, color: AppColors.borderLight),
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.edit_outlined,
                      label: '수정',
                      color: AppColors.textPrimary,
                      onTap: onEdit,
                    ),
                  ),
                  Container(
                    width: 1,
                    color: AppColors.borderLight,
                  ),
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.delete_outline_rounded,
                      label: '삭제',
                      color: const Color(0xFFEF4444),
                      onTap: onDelete,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThumbnailImage extends StatelessWidget {
  const _ThumbnailImage({required this.source});

  final String? source;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 56,
        height: 56,
        child: _CommissionImage(
          source: source,
          placeholder: const ColoredBox(
            color: AppColors.chipBackground,
            child: Icon(
              Icons.image_outlined,
              size: 24,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _SlotStatusBadge extends StatelessWidget {
  const _SlotStatusBadge({required this.type});

  final ArtistCommissionType type;

  @override
  Widget build(BuildContext context) {
    final isClosed = type.isSlotsClosed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isClosed ? const Color(0xFFFEE2E2) : const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        type.slotStatusLabel,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isClosed ? const Color(0xFFEF4444) : const Color(0xFF16A34A),
          height: 1.2,
        ),
      ),
    );
  }
}

class _SamplePreviewRow extends StatelessWidget {
  const _SamplePreviewRow({required this.type});

  final ArtistCommissionType type;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < ArtistCommissionType.maxSampleImages; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: AspectRatio(
              aspectRatio: 1,
              child: i < type.sampleImages.length
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _CommissionImage(
                        source: type.sampleImages[i].displaySource,
                        placeholder: _EmptySampleSlot(showPlus: false),
                      ),
                    )
                  : const _EmptySampleSlot(showPlus: true),
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptySampleSlot extends StatelessWidget {
  const _EmptySampleSlot({required this.showPlus});

  final bool showPlus;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.borderLight,
          style: BorderStyle.solid,
        ),
      ),
      child: DashedBorder(
        color: AppColors.textMuted.withValues(alpha: 0.5),
        radius: 8,
        strokeWidth: 1.2,
        dashWidth: 4,
        dashGap: 3,
        child: Center(
          child: showPlus
              ? Icon(
                  Icons.add_rounded,
                  size: 20,
                  color: AppColors.textMuted.withValues(alpha: 0.7),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CommissionImage extends StatelessWidget {
  const _CommissionImage({
    required this.source,
    required this.placeholder,
  });

  final String? source;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) {
    if (source == null || source!.isEmpty) return placeholder;

    if (source!.startsWith('http')) {
      return Image.network(
        source!,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    if (!kIsWeb) {
      return Image.file(
        File(source!),
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => placeholder,
      );
    }

    return placeholder;
  }
}

/// 공통 이미지 위젯 (폼에서도 사용)
class CommissionTypeImage extends StatefulWidget {
  const CommissionTypeImage({
    super.key,
    required this.source,
    required this.placeholder,
    this.fit = BoxFit.cover,
    this.onLoaded,
    this.onFailed,
  });

  final String? source;
  final Widget placeholder;
  final BoxFit fit;
  final VoidCallback? onLoaded;
  final VoidCallback? onFailed;

  @override
  State<CommissionTypeImage> createState() => _CommissionTypeImageState();
}

class _CommissionTypeImageState extends State<CommissionTypeImage> {
  bool? _lastNotifiedLoaded;

  @override
  void didUpdateWidget(covariant CommissionTypeImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.source != widget.source) {
      _lastNotifiedLoaded = null;
    }
  }

  void _notify(bool loaded) {
    if (_lastNotifiedLoaded == loaded) return;
    _lastNotifiedLoaded = loaded;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (loaded) {
        widget.onLoaded?.call();
      } else {
        widget.onFailed?.call();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.source;
    if (source == null || source.isEmpty) {
      _notify(false);
      return widget.placeholder;
    }

    if (source.startsWith('http')) {
      return Image.network(
        source,
        fit: widget.fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            _notify(true);
            return child;
          }
          _notify(false);
          return widget.placeholder;
        },
        errorBuilder: (_, _, _) {
          _notify(false);
          return widget.placeholder;
        },
      );
    }

    if (!kIsWeb) {
      return Image.file(
        File(source),
        fit: widget.fit,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) {
            _notify(true);
          }
          return child;
        },
        errorBuilder: (_, _, _) {
          _notify(false);
          return widget.placeholder;
        },
      );
    }

    _notify(false);
    return widget.placeholder;
  }
}
