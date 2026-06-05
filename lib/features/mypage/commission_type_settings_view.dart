import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/features/mypage/commission_type_form_screen.dart';
import 'package:art_port/features/mypage/commission_type_settings_providers.dart';
import 'package:art_port/features/mypage/mypage_providers.dart';
import 'package:art_port/features/mypage/widgets/commission_type_card.dart';
import 'package:art_port/features/mypage/widgets/commission_type_settings_header.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 커미션 타입 설정 메인 화면
class CommissionTypeSettingsView extends ConsumerWidget {
  const CommissionTypeSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(commissionTypeSettingsProvider);
    final notifier = ref.read(commissionTypeSettingsProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          CommissionTypeSettingsHeader(
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              children: [
                const _InfoBanner(),
                const SizedBox(height: 16),
                _AddTypeButton(
                  onTap: () => CommissionTypeFormScreen.openAdd(context),
                ),
                const SizedBox(height: 16),
                if (state.types.isEmpty)
                  const _EmptyTypesState()
                else
                  ...[
                    for (var i = 0; i < state.types.length; i++) ...[
                      if (i > 0) const SizedBox(height: 12),
                      CommissionTypeCard(
                        type: state.types[i],
                        onToggleActive: (value) {
                          if (value != state.types[i].isActive) {
                            notifier.toggleActive(state.types[i].id);
                          }
                        },
                        onEdit: () => CommissionTypeFormScreen.openEdit(
                          context,
                          state.types[i].id,
                        ),
                        onDelete: () => _confirmDelete(
                          context,
                          ref,
                          state.types[i].id,
                          state.types[i].name,
                        ),
                      ),
                    ],
                  ],
              ],
            ),
          ),
          _SaveAllButton(
            enabled: state.hasChanges && !state.isSaving,
            isSaving: state.isSaving,
            onSave: () => _onSaveAll(context, ref),
          ),
        ],
      ),
      bottomNavigationBar: ArtPortBottomNav(
        onTabSelected: (index) {
          ref.read(showMyPageProvider.notifier).close();
          ref.read(currentTabProvider.notifier).selectTab(index);
          Navigator.of(context).popUntil((route) => route.isFirst);
        },
      ),
    );
  }

  Future<void> _onSaveAll(BuildContext context, WidgetRef ref) async {
    final success =
        await ref.read(commissionTypeSettingsProvider.notifier).saveAll();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('커미션 타입 설정이 저장되었습니다.')),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('타입 삭제'),
        content: Text('\'$name\' 타입을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFEF4444),
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      ref.read(commissionTypeSettingsProvider.notifier).removeType(id);
    }
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: const Text(
        '커미션 타입과 가격을 설정하세요. 각 타입별로 슬롯을 관리할 수 있습니다.',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
          height: 1.5,
        ),
      ),
    );
  }
}

class _AddTypeButton extends StatelessWidget {
  const _AddTypeButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shadowColor: AppColors.primary.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(28),
      color: AppColors.primary,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.add_rounded, size: 22, color: Colors.white),
              SizedBox(width: 6),
              Text(
                '새 타입 추가',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyTypesState extends StatelessWidget {
  const _EmptyTypesState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: AppColors.chipBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 36,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '등록된 커미션 타입이 없습니다',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '새 타입 추가 버튼으로\n첫 커미션 타입을 등록해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveAllButton extends StatelessWidget {
  const _SaveAllButton({
    required this.enabled,
    required this.isSaving,
    required this.onSave,
  });

  final bool enabled;
  final bool isSaving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        decoration: BoxDecoration(
          color: AppColors.background,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton(
            onPressed: enabled ? onSave : null,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primaryLight,
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white.withValues(alpha: 0.7),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: isSaving
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    '모든 변경사항 저장',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
