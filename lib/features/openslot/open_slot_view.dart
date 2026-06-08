import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/no_overscroll_scroll_view.dart';
import 'package:art_port/features/openslot/open_slot_actions.dart';
import 'package:art_port/features/openslot/open_slot_providers.dart';
import 'package:art_port/features/openslot/widgets/open_slot_create_button.dart';
import 'package:art_port/features/openslot/widgets/open_slot_dashboard_row.dart';
import 'package:art_port/features/openslot/widgets/open_slot_header.dart';
import 'package:art_port/features/openslot/widgets/open_slot_load_error.dart';
import 'package:art_port/features/openslot/widgets/slot_card.dart';
import 'package:art_port/features/openslot/widgets/slot_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 슬롯 관리(Open Slot) 탭 — 아티스트 모드 전용
class OpenSlotView extends ConsumerWidget {
  const OpenSlotView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(openSlotDashboardProvider);
    final slotsAsync = ref.watch(mySlotsProvider);

    return NoOverscrollScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const OpenSlotHeader(),
          const SizedBox(height: 20),
          dashboardAsync.when(
            data: (stats) => OpenSlotDashboardRow(stats: stats),
            loading: () => const OpenSlotDashboardPlaceholder(),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          OpenSlotCreateButton(
            onTap: () => OpenSlotActions.openCreate(context),
          ),
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
          slotsAsync.when(
            data: (slots) {
              if (slots.isEmpty) {
                return const SlotEmptyState();
              }
              return Column(
                children: [
                  for (var i = 0; i < slots.length; i++) ...[
                    if (i > 0) const SizedBox(height: 12),
                    SlotCard(
                      slot: slots[i],
                      onEdit: () =>
                          OpenSlotActions.openEdit(context, slots[i].id),
                      onDelete: () => OpenSlotActions.confirmDelete(
                        context,
                        ref,
                        slots[i],
                      ),
                    ),
                  ],
                ],
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => OpenSlotLoadError(
              onRetry: () => OpenSlotActions.reload(ref),
            ),
          ),
        ],
      ),
    );
  }
}
