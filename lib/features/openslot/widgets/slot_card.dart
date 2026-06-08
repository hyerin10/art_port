import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/openslot/models/slot_model.dart';
import 'package:art_port/features/openslot/open_slot_colors.dart';
import 'package:flutter/material.dart';

/// 커미션 슬롯 목록 카드
class SlotCard extends StatelessWidget {
  const SlotCard({
    super.key,
    required this.slot,
    required this.onEdit,
    required this.onDelete,
  });

  final SlotModel slot;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      slot.title,
                      maxLines: 2,
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
                      slot.subType,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _SlotStatusBadge(isFull: slot.isFull),
            ],
          ),
          const SizedBox(height: 12),
          _SlotMetaRow(slot: slot),
          const SizedBox(height: 12),
          _SlotProgressBar(slot: slot),
          const SizedBox(height: 14),
          _SlotActionRow(onEdit: onEdit, onDelete: onDelete),
        ],
      ),
    );
  }
}

class _SlotStatusBadge extends StatelessWidget {
  const _SlotStatusBadge({required this.isFull});

  final bool isFull;

  @override
  Widget build(BuildContext context) {
    final bg = isFull ? OpenSlotColors.fullBg : OpenSlotColors.recruitingBg;
    final fg = isFull ? OpenSlotColors.fullFg : OpenSlotColors.recruitingFg;
    final label = isFull ? '마감' : '모집 중';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
          height: 1.2,
        ),
      ),
    );
  }
}

class _SlotMetaRow extends StatelessWidget {
  const _SlotMetaRow({required this.slot});

  final SlotModel slot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MetaItem(icon: Icons.payments_outlined, label: slot.priceLabel),
        const SizedBox(width: 14),
        _MetaItem(icon: Icons.event_available_outlined, label: slot.slotsLabel),
        const SizedBox(width: 14),
        _MetaItem(icon: Icons.schedule_outlined, label: slot.durationLabel),
      ],
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlotProgressBar extends StatelessWidget {
  const _SlotProgressBar({required this.slot});

  final SlotModel slot;

  @override
  Widget build(BuildContext context) {
    final fillColor =
        slot.isFull ? OpenSlotColors.progressFull : AppColors.primary;
    final fillRatio = slot.isFull ? 1.0 : slot.fillRatio;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: OpenSlotColors.progressTrack),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: fillRatio.clamp(0.0, 1.0),
              child: ColoredBox(color: fillColor),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotActionRow extends StatelessWidget {
  const _SlotActionRow({
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: OpenSlotColors.editActionBg,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.edit_outlined,
                      size: 18,
                      color: AppColors.primary.withValues(alpha: 0.9),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '수정하기',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Material(
          color: OpenSlotColors.deleteActionBg,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onDelete,
            borderRadius: BorderRadius.circular(12),
            child: const SizedBox(
              width: 48,
              height: 44,
              child: Icon(
                Icons.delete_outline_rounded,
                size: 22,
                color: OpenSlotColors.deleteActionIcon,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
