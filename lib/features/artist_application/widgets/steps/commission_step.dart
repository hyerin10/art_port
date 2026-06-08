import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/artist_application/artist_application_providers.dart';
import 'package:art_port/features/artist_application/models/artist_application_data.dart';
import 'package:art_port/features/artist_application/widgets/artist_application_form_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CommissionStep extends ConsumerWidget {
  const CommissionStep({super.key});

  static const _workDayOptions = [7, 10, 14, 21, 30];
  static const _revisionOptions = [0, 1, 2, 3];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(artistApplicationFormProvider).data;
    final notifier = ref.read(artistApplicationFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ArtistApplicationStepTitle(
          titleKo: ArtistApplicationStep.commission.titleKo,
          titleEn: ArtistApplicationStep.commission.titleEn,
        ),
        const SizedBox(height: 24),
        ArtistApplicationSectionHeader(
          title: '커미션 타입 및 가격표',
          trailing: TextButton(
            onPressed: notifier.addCommissionType,
            child: const Text(
              '+ 추가',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(data.commissionTypes.length, (index) {
          final type = data.commissionTypes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _CommissionTypeCard(
              index: index,
              entry: type,
              canRemove: data.commissionTypes.length > 1,
              onChanged: (entry) =>
                  notifier.updateCommissionType(index, entry),
              onRemove: () => notifier.removeCommissionType(index),
            ),
          );
        }),
        const SizedBox(height: 16),
        const ArtistApplicationSectionHeader(
          title: '작업 기간 및 진행 방식',
          icon: Icons.schedule_outlined,
        ),
        const SizedBox(height: 12),
        _DropdownRow(
          label: '최대 작업일',
          value: data.maxWorkDays,
          options: _workDayOptions,
          suffix: '일',
          onChanged: notifier.setMaxWorkDays,
        ),
        const SizedBox(height: 12),
        _DropdownRow(
          label: '러프 수정 횟수',
          value: data.roughRevisionCount,
          options: _revisionOptions,
          suffix: '회',
          onChanged: notifier.setRoughRevisionCount,
        ),
        const SizedBox(height: 12),
        _DropdownRow(
          label: '완성본 수정 횟수',
          value: data.finalRevisionCount,
          options: _revisionOptions,
          suffix: '회',
          onChanged: notifier.setFinalRevisionCount,
        ),
        const SizedBox(height: 24),
        const ArtistApplicationSectionHeader(
          title: '상업적 이용 가능 여부',
        ),
        const SizedBox(height: 12),
        _CommercialToggle(
          title: '비상업용',
          subtitle: 'Non-commercial',
          value: data.nonCommercial,
          onChanged: notifier.setNonCommercial,
        ),
        const SizedBox(height: 10),
        _CommercialToggle(
          title: '상업용/스트리밍',
          subtitle: 'Commercial/Streaming',
          value: data.commercialStreaming,
          onChanged: notifier.setCommercialStreaming,
        ),
        const SizedBox(height: 10),
        _CommercialToggle(
          title: '저작권 양도',
          subtitle: 'Full Copyright Transfer',
          value: data.copyrightTransfer,
          onChanged: notifier.setCopyrightTransfer,
        ),
      ],
    );
  }
}

class _CommissionTypeCard extends StatelessWidget {
  const _CommissionTypeCard({
    required this.index,
    required this.entry,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  final int index;
  final CommissionTypeEntry entry;
  final bool canRemove;
  final ValueChanged<CommissionTypeEntry> onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.chipBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Type ${index + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              if (canRemove)
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  color: AppColors.textMuted,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ArtistApplicationTextField(
            key: ValueKey('type-name-$index-${entry.typeName}'),
            label: '',
            hintText: '타입명 (예: 반신샷, 전신)',
            value: entry.typeName,
            onChanged: (v) => onChanged(entry.copyWith(typeName: v)),
          ),
          const SizedBox(height: 12),
          ArtistApplicationTextField(
            key: ValueKey('type-price-$index-${entry.basePrice}'),
            label: '',
            hintText: '기본 가격',
            prefixText: '₩ ',
            value: entry.basePrice,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (v) => onChanged(entry.copyWith(basePrice: v)),
          ),
          const SizedBox(height: 12),
          ArtistApplicationTextField(
            key: ValueKey('type-desc-$index-${entry.description}'),
            label: '',
            hintText: '설명 (선택)',
            value: entry.description,
            maxLines: 3,
            onChanged: (v) => onChanged(entry.copyWith(description: v)),
          ),
        ],
      ),
    );
  }
}

class _DropdownRow extends StatelessWidget {
  const _DropdownRow({
    required this.label,
    required this.value,
    required this.options,
    required this.suffix,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> options;
  final String suffix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: DropdownButtonFormField<int>(
            initialValue: value,
            items: options
                .map(
                  (v) => DropdownMenuItem(
                    value: v,
                    child: Text('$v$suffix'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.chipBackground,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CommercialToggle extends StatelessWidget {
  const _CommercialToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.chipBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
