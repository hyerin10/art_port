import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/review/data/review_providers.dart';
import 'package:art_port/features/review/widgets/review_list_header.dart';
import 'package:art_port/features/review/widgets/review_stars.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReviewFormScreen extends StatelessWidget {
  const ReviewFormScreen({
    super.key,
    required this.orderId,
    required this.commissionTitle,
    this.reviewId,
    this.initialRating = 5,
    this.initialContent = '',
    this.artistUserId,
  });

  final String orderId;
  final String commissionTitle;
  final String? reviewId;
  final double initialRating;
  final String initialContent;
  final String? artistUserId;

  static void open(
    BuildContext context, {
    required String orderId,
    required String commissionTitle,
    String? reviewId,
    double initialRating = 5,
    String initialContent = '',
    String? artistUserId,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReviewFormScreen(
          orderId: orderId,
          commissionTitle: commissionTitle,
          reviewId: reviewId,
          initialRating: initialRating,
          initialContent: initialContent,
          artistUserId: artistUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ReviewFormView(
      orderId: orderId,
      commissionTitle: commissionTitle,
      reviewId: reviewId,
      initialRating: initialRating,
      initialContent: initialContent,
      artistUserId: artistUserId,
    );
  }
}

class _ReviewFormView extends ConsumerStatefulWidget {
  const _ReviewFormView({
    required this.orderId,
    required this.commissionTitle,
    required this.reviewId,
    required this.initialRating,
    required this.initialContent,
    required this.artistUserId,
  });

  final String orderId;
  final String commissionTitle;
  final String? reviewId;
  final double initialRating;
  final String initialContent;
  final String? artistUserId;

  @override
  ConsumerState<_ReviewFormView> createState() => _ReviewFormViewState();
}

class _ReviewFormViewState extends ConsumerState<_ReviewFormView> {
  late double _rating;
  late final TextEditingController _contentController;
  var _isSubmitting = false;

  bool get _isEdit => widget.reviewId != null;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating < 1 ? 5 : widget.initialRating;
    _contentController = TextEditingController(text: widget.initialContent);
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (_isSubmitting) return;
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      AppToast.show(ScaffoldMessenger.of(context), message: '로그인이 필요합니다.');
      return;
    }

    setState(() => _isSubmitting = true);
    final content = _contentController.text.trim();

    try {
      if (_isEdit) {
        await ref.read(reviewRepositoryProvider).update(
              reviewId: widget.reviewId!,
              clientId: userId,
              rating: _rating,
              content: content,
            );
      } else {
        await ref.read(reviewRepositoryProvider).create(
              orderId: widget.orderId,
              clientId: userId,
              rating: _rating,
              content: content.isEmpty ? null : content,
            );
      }
      invalidateReviewQueries(ref, artistUserId: widget.artistUserId);
      if (!mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: _isEdit ? '리뷰가 수정되었습니다.' : '리뷰가 등록되었습니다.',
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '리뷰 저장에 실패했습니다. 다시 시도해 주세요.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ReviewListHeader(
            title: _isEdit ? '리뷰 수정' : '리뷰 작성',
            onBack: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
              children: [
                Text(
                  widget.commissionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '별점',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                ReviewStars(
                  rating: _rating,
                  size: 36,
                  onChanged: (value) => setState(() => _rating = value),
                ),
                const SizedBox(height: 24),
                const Text(
                  '리뷰 내용',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _contentController,
                  maxLines: 6,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText: '작가와의 작업은 어땠나요?',
                    hintStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.chipBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _isSubmitting
                          ? '저장 중...'
                          : _isEdit
                              ? '수정하기'
                              : '등록하기',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
