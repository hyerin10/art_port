import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 앱 전역 모드(일반 / 작가). `true` = 작가 모드.
final appModeProvider = NotifierProvider<AppModeNotifier, bool>(
  AppModeNotifier.new,
);

class AppModeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  bool get isArtistMode => state;

  void toggleMode() {
    state = !state;
  }

  void setArtistMode(bool value) {
    state = value;
  }
}
