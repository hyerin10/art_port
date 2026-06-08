import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/search/search_constants.dart';
import 'package:art_port/features/search/search_providers.dart';
import 'package:art_port/features/search/widgets/filters/filter_list_tile.dart';
import 'package:art_port/features/search/widgets/filters/filter_popup_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PriceFilterPopup extends StatefulWidget {
  const PriceFilterPopup({
    super.key,
    required this.filter,
    required this.onClose,
    required this.onApply,
    required this.onPreset,
  });

  final SearchFilterState filter;
  final VoidCallback onClose;
  final void Function(int? minMan, int? maxMan) onApply;
  final ValueChanged<SearchPricePreset> onPreset;

  @override
  State<PriceFilterPopup> createState() => _PriceFilterPopupState();
}

class _PriceFilterPopupState extends State<PriceFilterPopup> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  @override
  void initState() {
    super.initState();
    _minController = TextEditingController(
      text: '${widget.filter.priceMinMan ?? 0}',
    );
    _maxController = TextEditingController(
      text: widget.filter.priceMaxMan != null
          ? '${widget.filter.priceMaxMan}'
          : '∞',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  int? _parseMan(String text, {required bool isMax}) {
    final trimmed = text.trim();
    if (isMax && (trimmed.isEmpty || trimmed == '∞')) return null;
    return int.tryParse(trimmed);
  }

  void _submitCustom() {
    final min = _parseMan(_minController.text, isMax: false) ?? 0;
    final max = _parseMan(_maxController.text, isMax: true);
    widget.onApply(min, max);
  }

  @override
  Widget build(BuildContext context) {
    return FilterPopupShell(
      width: kSearchPricePopupWidth,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _PriceManField(controller: _minController)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '만 ~',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              Expanded(child: _PriceManField(controller: _maxController)),
              const Padding(
                padding: EdgeInsets.only(left: 4),
                child: Text(
                  '만',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 44,
            child: FilledButton(
              onPressed: _submitCustom,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '선택',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          for (final preset in SearchPricePreset.presets)
            FilterListTile(
              label: preset.label,
              onTap: () => widget.onPreset(preset),
            ),
        ],
      ),
    );
  }
}

class _PriceManField extends StatelessWidget {
  const _PriceManField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9∞]')),
      ],
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.chipBackground,
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.35),
          ),
        ),
      ),
    );
  }
}
