import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/features/mypage/models/commission_type_data.dart';
import 'package:art_port/features/mypage/widgets/commission_type_card.dart';
import 'package:flutter/material.dart';

/// 커미션 타입 폼 — 샘플 이미지 업로드 그리드 (최대 3장)
class CommissionTypeSampleUploadGrid extends StatelessWidget {
  const CommissionTypeSampleUploadGrid({
    super.key,
    required this.sampleImages,
    required this.onUploadTap,
    required this.onRemove,
  });

  final List<CommissionSampleImage?> sampleImages;
  final ValueChanged<int> onUploadTap;
  final ValueChanged<int> onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < CommissionTypeFormState.maxSampleImages; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _UploadSlot(
              image: sampleImages[i],
              onTap: () => onUploadTap(i),
              onRemove: () => onRemove(i),
            ),
          ),
        ],
      ],
    );
  }
}

class _UploadSlot extends StatefulWidget {
  const _UploadSlot({
    required this.image,
    required this.onTap,
    required this.onRemove,
  });

  final CommissionSampleImage? image;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  State<_UploadSlot> createState() => _UploadSlotState();
}

class _UploadSlotState extends State<_UploadSlot> {
  var _imageVisible = false;

  @override
  void initState() {
    super.initState();
    _imageVisible = widget.image?.localPath != null;
  }

  @override
  void didUpdateWidget(covariant _UploadSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.image?.displaySource != widget.image?.displaySource) {
      _imageVisible = widget.image?.localPath != null;
    }
  }

  void _onImageVisibilityChanged(bool visible) {
    if (_imageVisible != visible && mounted) {
      setState(() => _imageVisible = visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    final source = widget.image?.displaySource;
    final hasSource = source != null && source.isNotEmpty;

    return AspectRatio(
      aspectRatio: 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: CustomPaint(
                painter: _DashedBorderPainter(
                  color: AppColors.primary.withValues(alpha: 0.45),
                  radius: 12,
                ),
                child: hasSource
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _SampleImagePreview(
                          source: source,
                          onVisibilityChanged: _onImageVisibilityChanged,
                        ),
                      )
                    : const _UploadPlaceholder(),
              ),
            ),
          ),
          if (_imageVisible)
            Positioned(
              top: -6,
              right: -6,
              child: Material(
                color: const Color(0xFFEF4444),
                shape: const CircleBorder(),
                elevation: 2,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: widget.onRemove,
                  child: const SizedBox(
                    width: 22,
                    height: 22,
                    child: Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// 샘플 이미지가 실제로 렌더링됐을 때만 삭제 버튼을 노출하기 위한 프리뷰
class _SampleImagePreview extends StatelessWidget {
  const _SampleImagePreview({
    required this.source,
    required this.onVisibilityChanged,
  });

  final String source;
  final ValueChanged<bool> onVisibilityChanged;

  @override
  Widget build(BuildContext context) {
    return CommissionTypeImage(
      source: source,
      placeholder: const _UploadPlaceholder(),
      onLoaded: () => onVisibilityChanged(true),
      onFailed: () => onVisibilityChanged(false),
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  const _UploadPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 26,
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 4),
          Text(
            '업로드',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color, required this.radius});

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    const dashWidth = 5.0;
    const dashSpace = 3.0;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1.5, 1.5, size.width - 3, size.height - 3),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          paint,
        );
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.radius != radius;
  }
}
