import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/navigation/app_tab.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ArtPortBottomNav extends ConsumerWidget {
  const ArtPortBottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isArtistMode = ref.watch(appModeProvider);
    final currentIndex = ref.watch(currentTabProvider);
    final tabs = AppTabNavigation.tabsForMode(isArtistMode: isArtistMode);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(tabs.length, (index) {
              final tab = tabs[index];
              final isSelected = index == currentIndex;
              return Expanded(
                child: _BottomNavItem(
                  tab: tab,
                  isSelected: isSelected,
                  onTap: () =>
                      ref.read(currentTabProvider.notifier).selectTab(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  final AppTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.primary : AppColors.textMuted;
    final icon = isSelected ? tab.activeIcon : tab.icon;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            tab.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
