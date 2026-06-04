import 'package:art_port/core/navigation/app_tab.dart';
import 'package:art_port/features/common/widgets/art_port_bottom_nav.dart';
import 'package:art_port/features/common/widgets/art_port_header.dart';
import 'package:art_port/features/explore/explore_screen.dart';
import 'package:art_port/features/openslot/open_slot_screen.dart';
import 'package:art_port/features/search/search_screen.dart';
import 'package:art_port/features/workroom/workroom_screen.dart';
import 'package:art_port/providers/app_mode_provider.dart';
import 'package:art_port/providers/current_tab_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainScreen extends ConsumerWidget {
  const MainScreen({super.key});

  static const _artistScreens = [
    ExploreScreen(),
    SearchScreen(),
    OpenSlotScreen(),
    WorkroomScreen(),
  ];

  static const _clientScreens = [
    ExploreScreen(),
    SearchScreen(),
    WorkroomScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<bool>(appModeProvider, (previous, next) {
      if (previous == null || previous == next) return;
      final currentIndex = ref.read(currentTabProvider);
      final remapped = AppTabNavigation.remapIndex(
        currentIndex: currentIndex,
        fromArtistMode: previous,
        toArtistMode: next,
      );
      ref.read(currentTabProvider.notifier).selectTab(remapped);
    });

    final isArtistMode = ref.watch(appModeProvider);
    final screens = isArtistMode ? _artistScreens : _clientScreens;
    final currentIndex = ref.watch(currentTabProvider);
    final safeIndex = currentIndex.clamp(0, screens.length - 1);

    if (safeIndex != currentIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(currentTabProvider.notifier).selectTab(safeIndex);
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const ArtPortHeader(),
          Expanded(
            child: IndexedStack(
              index: safeIndex,
              children: screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: const ArtPortBottomNav(),
    );
  }
}
