import 'package:art_port/features/common/widgets/empty_state_view.dart';
import 'package:art_port/features/common/widgets/primary_pill_button.dart';
import 'package:art_port/features/mypage/inquiry_navigation.dart';
import 'package:art_port/features/mypage/inquiry_providers.dart';
import 'package:art_port/features/mypage/widgets/inquiry_header.dart';
import 'package:art_port/features/mypage/widgets/inquiry_list_card.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 1:1 문의 목록 화면
class InquiryListView extends ConsumerWidget {
  const InquiryListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inquiries = ref.watch(supportInquiriesProvider);

    return MyPageSubScreenScaffold(
      header: InquiryHeader(
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          if (inquiries.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: PrimaryPillButton(
                label: '+ 새 문의 시작하기',
                onTap: () => InquiryNavigation.createAndOpen(context, ref),
              ),
            ),
          Expanded(
            child: inquiries.isEmpty
                ? EmptyStateView(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: '아직 문의 내역이 없습니다',
                    subtitle: '궁금하신 점이 있으시면\n새 문의를 시작해주세요',
                    actionLabel: '새 문의 시작하기',
                    onAction: () => InquiryNavigation.createAndOpen(context, ref),
                    actionPlacement: EmptyStateActionPlacement.bottom,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    itemCount: inquiries.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = inquiries[index];
                      return InquiryListCard(
                        item: item,
                        onTap: () =>
                            InquiryNavigation.openExisting(context, ref, item.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
