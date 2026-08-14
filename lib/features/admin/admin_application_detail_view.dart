import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/features/admin/admin_providers.dart';
import 'package:art_port/features/artist_application/data/dto/artist_application_dto.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/mypage/widgets/inquiry_header.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminApplicationDetailView extends ConsumerStatefulWidget {
  const AdminApplicationDetailView({super.key, required this.application});

  final ArtistApplicationDto application;

  static void open(
    BuildContext context, {
    required ArtistApplicationDto application,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AdminApplicationDetailView(application: application),
      ),
    );
  }

  @override
  ConsumerState<AdminApplicationDetailView> createState() =>
      _AdminApplicationDetailViewState();
}

class _AdminApplicationDetailViewState
    extends ConsumerState<AdminApplicationDetailView> {
  late ArtistApplicationDto _application;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _application = widget.application;
  }

  Future<void> _review({
    required String status,
    String? rejectionReason,
  }) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final updated = await reviewArtistApplication(
        ref,
        applicationId: _application.id,
        status: status,
        rejectionReason: rejectionReason,
      );
      if (!mounted) return;
      setState(() => _application = updated);
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: status == 'approved' ? '신청을 승인했습니다.' : '신청을 거절했습니다.',
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
    } catch (_) {
      if (!mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '심사 처리에 실패했습니다. 다시 시도해 주세요.',
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _confirmApprove() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('신청 승인'),
        content: const Text('이 아티스트 신청을 승인할까요? 승인 시 작가 프로필이 생성됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('닫기'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('승인'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _review(status: 'approved');
    }
  }

  Future<void> _confirmReject() async {
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => const _RejectReasonDialog(),
    );
    if (reason == null || reason.isEmpty) return;
    await _review(status: 'rejected', rejectionReason: reason);
  }

  @override
  Widget build(BuildContext context) {
    final item = _application;

    return MyPageSubScreenScaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      header: InquiryHeader(
        title: '신청 상세',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          _InfoCard(
            children: [
              _InfoRow(label: '활동명', value: item.artistName),
              _InfoRow(label: '상태', value: item.statusLabel),
              if (item.styleTags.isNotEmpty)
                _InfoRow(label: '스타일', value: item.styleTags.join(', ')),
              if (item.maxWorkDays != null)
                _InfoRow(label: '최대 작업일', value: '${item.maxWorkDays}일'),
              _InfoRow(
                label: '수정 횟수',
                value:
                    '러프 ${item.roughRevisionCount ?? 0} / 최종 ${item.finalRevisionCount ?? 0}',
              ),
              _InfoRow(
                label: '이용 범위',
                value: [
                  if (item.allowNonCommercial) '비상업',
                  if (item.allowCommercialStreaming) '상업 스트리밍',
                  if (item.allowCopyrightTransfer) '저작권 양도',
                ].join(', ').ifEmpty('없음'),
              ),
              if (item.rejectionReason != null)
                _InfoRow(label: '거절 사유', value: item.rejectionReason!),
            ],
          ),
          if (item.portfolioImageUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              '포트폴리오',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: item.portfolioImageUrls.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      item.portfolioImageUrls[index],
                      width: 90,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const ColoredBox(
                        color: AppColors.chipBackground,
                        child: SizedBox(
                          width: 90,
                          child: Icon(Icons.image_outlined),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
          if (item.isPending) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _busy ? null : _confirmReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('거절'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _busy ? null : _confirmApprove,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _busy
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('승인'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectReasonDialog extends StatefulWidget {
  const _RejectReasonDialog();

  @override
  State<_RejectReasonDialog> createState() => _RejectReasonDialogState();
}

class _RejectReasonDialogState extends State<_RejectReasonDialog> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('신청 거절'),
      content: TextField(
        controller: _reason,
        maxLines: 3,
        maxLength: 200,
        decoration: const InputDecoration(
          hintText: '거절 사유를 입력해 주세요',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('닫기'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _reason.text.trim()),
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: const Text('거절'),
        ),
      ],
    );
  }
}

extension on String {
  String ifEmpty(String fallback) => isEmpty ? fallback : this;
}
