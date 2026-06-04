import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/openslot/models/slot_model.dart';
import 'package:art_port/features/openslot/open_slot_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 슬롯 관리(Open Slot) 탭 — 아티스트 모드 전용
class OpenSlotView extends ConsumerWidget {
  const OpenSlotView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(openSlotDashboardProvider);
    final slots = ref.watch(mySlotsProvider);

    return ScrollConfiguration(
      behavior: const _OpenSlotScrollBehavior(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _TitleSection(),
            const SizedBox(height: 20),
            _DashboardRow(stats: dashboard),
            const SizedBox(height: 20),
            const _CreateSlotButton(),
            const SizedBox(height: 24),
            const Text(
              '내 슬롯',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 12),
            if (slots.isEmpty)
              const _EmptySlotsMessage()
            else
              ...slots.map(
                (slot) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _SlotCard(
                    slot: slot,
                    onEdit: () {
                      // TODO: 슬롯 수정 화면으로 이동
                    },
                    onDelete: () =>
                        ref.read(mySlotsProvider.notifier).removeSlot(slot.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _OpenSlotScrollBehavior extends ScrollBehavior {
  const _OpenSlotScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

// ─── Title ──────────────────────────────────────────────────────────────────

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '슬롯 관리',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.15,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '내 커미션 슬롯을 효율적으로 관리하세요',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

// ─── Dashboard ──────────────────────────────────────────────────────────────

class _DashboardRow extends StatelessWidget {
  const _DashboardRow({required this.stats});

  final OpenSlotDashboardStats stats;

  // 이미지 기준 파스텔 배경 + 포인트 컬러
  static const _activeFg = Color(0xFF7C4DFF);
  static const _activeBg = Color(0xFFF3F0FF);
  static const _ordersFg = Color(0xFFFF69B4);
  static const _ordersBg = Color(0xFFFFF0F5);
  static const _earningsFg = Color(0xFF00ACC1);
  static const _earningsBg = Color(0xFFE0F7FA);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _DashboardCard(
              value: '${stats.activeSlotCount}',
              label: '활성 슬롯',
              valueColor: _activeFg,
              backgroundColor: _activeBg,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DashboardCard(
              value: '${stats.ordersInProgress}',
              label: '진행 중인 주문',
              valueColor: _ordersFg,
              backgroundColor: _ordersBg,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _DashboardCard(
              value: stats.earningsLabel,
              label: '이번 달 정산 금액',
              valueColor: _earningsFg,
              backgroundColor: _earningsBg,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.value,
    required this.label,
    required this.valueColor,
    required this.backgroundColor,
  });

  final String value;
  final String label;
  final Color valueColor;
  final Color backgroundColor;

  static const double _cardHeight = 96;
  static const double _valueLineHeight = 32;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _cardHeight,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: _valueLineHeight,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: valueColor,
                      height: 1.0,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Create Button ──────────────────────────────────────────────────────────

class _CreateSlotButton extends StatelessWidget {
  const _CreateSlotButton();

  static const _gradientStart = Color(0xFF7C4DFF);
  static const _gradientEnd = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // TODO: 새 슬롯 등록 화면
        },
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [_gradientStart, _gradientEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: _gradientEnd.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 22),
                SizedBox(width: 6),
                Text(
                  '새 커미션 슬롯 등록',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Slot Card ──────────────────────────────────────────────────────────────

class _SlotCard extends StatelessWidget {
  const _SlotCard({
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

  static const _activeFg = Color(0xFF16A34A);
  static const _activeBg = Color(0xFFDCFCE7);
  static const _fullFg = Color(0xFF6B7280);
  static const _fullBg = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final bg = isFull ? _fullBg : _activeBg;
    final fg = isFull ? _fullFg : _activeFg;
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

  static const _fullBarColor = Color(0xFF4B5563);
  static const _trackColor = Color(0xFFF3F4F6);
  static const _activeFillColor = AppColors.primary;

  @override
  Widget build(BuildContext context) {
    final fillColor = slot.isFull ? _fullBarColor : _activeFillColor;
    final fillRatio = slot.isFull ? 1.0 : slot.fillRatio;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 10,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const ColoredBox(color: _trackColor),
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

  static const _editBg = Color(0xFFEEF2FF);
  static const _deleteBg = Color(0xFFFCE7F3);
  static const _deleteIcon = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: _editBg,
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
          color: _deleteBg,
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
                color: _deleteIcon,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptySlotsMessage extends StatelessWidget {
  const _EmptySlotsMessage();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Text(
          '등록된 슬롯이 없습니다.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
