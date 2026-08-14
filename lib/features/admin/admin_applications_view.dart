import 'package:art_port/core/constants/app_colors.dart';
import 'package:art_port/core/widgets/api_async_body.dart';
import 'package:art_port/features/admin/admin_application_detail_view.dart';
import 'package:art_port/features/admin/admin_providers.dart';
import 'package:art_port/features/admin/widgets/admin_status_filter_bar.dart';
import 'package:art_port/features/artist_application/data/dto/artist_application_dto.dart';
import 'package:art_port/features/common/widgets/empty_state_view.dart';
import 'package:art_port/features/mypage/widgets/inquiry_header.dart';
import 'package:art_port/features/mypage/widgets/mypage_sub_screen_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminApplicationsView extends ConsumerWidget {
  const AdminApplicationsView({super.key});

  static const _filters = <(String?, String)>[
    (null, '전체'),
    ('pending', '대기'),
    ('approved', '승인'),
    ('rejected', '거절'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(adminApplicationStatusFilterProvider);
    final applicationsAsync = ref.watch(adminArtistApplicationsProvider);

    return MyPageSubScreenScaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      header: InquiryHeader(
        title: '아티스트 신청 심사',
        onBack: () => Navigator.of(context).pop(),
      ),
      body: Column(
        children: [
          AdminStatusFilterBar(
            selected: filter,
            options: _filters,
            onSelected: (value) => ref
                .read(adminApplicationStatusFilterProvider.notifier)
                .select(value),
          ),
          Expanded(
            child: ApiAsyncBody<List<ArtistApplicationDto>>(
              value: applicationsAsync,
              onRetry: () => ref.invalidate(adminArtistApplicationsProvider),
              errorMessage: '신청 목록을 불러오지 못했습니다.',
              builder: (applications) {
                if (applications.isEmpty) {
                  return const EmptyStateView(
                    icon: Icons.assignment_outlined,
                    title: '해당 신청이 없습니다',
                    subtitle: '선택한 상태의 아티스트 신청이 없습니다',
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  itemCount: applications.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = applications[index];
                    return _ApplicationCard(
                      item: item,
                      onTap: () => AdminApplicationDetailView.open(
                        context,
                        application: item,
                      ),
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
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.item,
    required this.onTap,
  });

  final ArtistApplicationDto item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.artistName.isEmpty ? '이름 없음' : item.artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (item.styleTags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.styleTags.join(', '),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.statusLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
