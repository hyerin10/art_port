import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 하단 탭 바에서 현재 선택된 탭 인덱스.
final currentTabProvider = NotifierProvider<CurrentTabNotifier, int>(
  CurrentTabNotifier.new,
);

class CurrentTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void selectTab(int index) {
    state = index;
  }
}
