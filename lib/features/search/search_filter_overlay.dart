import 'package:art_port/features/search/search_constants.dart';
import 'package:flutter/material.dart';

enum SearchFilterOverlayKind { price, deadline, age }

/// 칩 앵커 기준 필터 드롭다운 Overlay 관리
class SearchFilterOverlayController {
  SearchFilterOverlayController({this.onChanged});

  final VoidCallback? onChanged;

  final GlobalKey priceChipKey = GlobalKey();
  final GlobalKey deadlineChipKey = GlobalKey();
  final GlobalKey ageChipKey = GlobalKey();

  OverlayEntry? _overlay;
  SearchFilterOverlayKind? openFilter;

  void dispose() => hide();

  void hide() {
    _overlay?.remove();
    _overlay = null;
    if (openFilter != null) {
      openFilter = null;
      onChanged?.call();
    }
  }

  /// 칩 [bottomRight] ↔ 팝업 [topRight] 우측 정렬 (가로 스크롤 좌표 보정)
  ({double left, double top})? popupPositionForAnchor({
    required GlobalKey anchorKey,
    required double popupWidth,
    required double screenWidth,
  }) {
    final anchorBox =
        anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (anchorBox == null || !anchorBox.hasSize) return null;

    final origin = anchorBox.localToGlobal(Offset.zero);
    final size = anchorBox.size;

    final top = origin.dy + size.height + kSearchFilterPopupGapY;
    var left = origin.dx + size.width - popupWidth;
    left = left.clamp(
      kSearchFilterPopupEdgeInset,
      screenWidth - popupWidth - kSearchFilterPopupEdgeInset,
    );

    return (left: left, top: top);
  }

  void toggle({
    required BuildContext context,
    required SearchFilterOverlayKind kind,
    required GlobalKey anchorKey,
    required Widget popup,
    required double popupWidth,
  }) {
    if (openFilter == kind) {
      hide();
      return;
    }
    hide();
    openFilter = kind;
    onChanged?.call();

    _overlay = OverlayEntry(
      builder: (overlayContext) {
        final screenWidth = MediaQuery.sizeOf(overlayContext).width;
        final position = popupPositionForAnchor(
          anchorKey: anchorKey,
          popupWidth: popupWidth,
          screenWidth: screenWidth,
        );

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: hide,
                behavior: HitTestBehavior.translucent,
                child: const ColoredBox(color: Colors.transparent),
              ),
            ),
            if (position != null)
              Positioned(
                left: position.left,
                top: position.top,
                child: GestureDetector(
                  onTap: () {},
                  behavior: HitTestBehavior.opaque,
                  child: Material(
                    color: Colors.transparent,
                    child: popup,
                  ),
                ),
              ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlay!);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _overlay?.markNeedsBuild();
    });
  }
}
