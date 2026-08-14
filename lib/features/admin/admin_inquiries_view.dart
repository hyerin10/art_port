import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/admin/admin_providers.dart';
import 'package:art_port/features/admin/widgets/admin_status_filter_bar.dart';
import 'package:art_port/features/common/widgets/app_toast.dart';
import 'package:art_port/features/common/widgets/empty_state_view.dart';
import 'package:art_port/features/mypage/inquiry_navigation.dart';
import 'package:art_port/features/mypage/models/support_inquiry_item.dart';
import 'package:art_port/features/mypage/widgets/inquiry_header.dart';
import 'package:art_port/features/mypage/widgets/inquiry_list_card.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const supportInquiryStatusOptions = <(String, String)>[
  ('open', '접수 대기'),
  ('in_progress', '진행 중'),
  ('resolved', '해결됨'),
  ('closed', '종료됨'),
];

Future<String?> pickSupportInquiryStatus(
  BuildContext context, {
  required String currentStatus,
}) {
  return showModalBottomSheet<String>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              '문의 상태 변경',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          for (final option in supportInquiryStatusOptions)
            ListTile(
              title: Text(option.$2),
              trailing: currentStatus == option.$1
                  ? const Icon(Icons.check_rounded, color: AppColors.primary)
                  : null,
              onTap: () => Navigator.pop(context, option.$1),
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}

class AdminInquiriesView extends ConsumerWidget {
  const AdminInquiriesView({super.key});

  static const _filters = <(String?, String)>[
    (null, '전체'),
    ('open', '접수 대기'),
    ('in_progress', '진행 중'),
    ('resolved', '해결됨'),
    ('closed', '종료됨'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(adminInquiryStatusFilterProvider);
    final inquiriesAsync = ref.watch(adminSupportInquiriesProvider);

    return MyPageSubScreenScaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      header: InquiryHeader(
        title: '고객센터 문의 관리',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          AdminStatusFilterBar(
            selected: filter,
            options: _filters,
            onSelected: (value) => ref
                .read(adminInquiryStatusFilterProvider.notifier)
                .select(value),
          ),
          Expanded(
            child: ApiAsyncBody<List<SupportInquiryItem>>(
              value: inquiriesAsync,
              onRetry: () => ref.invalidate(adminSupportInquiriesProvider),
              errorMessage: '문의 목록을 불러오지 못했습니다.',
              builder: (inquiries) {
                if (inquiries.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: '해당 문의가 없습니다',
                    subtitle: '선택한 상태의 고객센터 문의가 없습니다',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: inquiries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = inquiries[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        InquiryListCard(
                          item: item,
                          onTap: () => InquiryNavigation.openExisting(
                            context,
                            item.id,
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () => _changeStatus(context, ref, item),
                            child: Text(
                              '상태: ${item.statusLabel}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _changeStatus(
    BuildContext context,
    WidgetRef ref,
    SupportInquiryItem item,
  ) async {
    final next = await pickSupportInquiryStatus(
      context,
      currentStatus: item.status,
    );
    if (next == null || next == item.status) return;

    try {
      await updateAdminInquiryStatus(ref, inquiryId: item.id, status: next);
      if (!context.mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '문의 상태를 변경했습니다.',
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      AppToast.show(ScaffoldMessenger.of(context), message: e.displayMessage);
    } catch (_) {
      if (!context.mounted) return;
      AppToast.show(
        ScaffoldMessenger.of(context),
        message: '상태 변경에 실패했습니다. 다시 시도해 주세요.',
      );
    }
  }
}
