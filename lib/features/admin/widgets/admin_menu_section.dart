import 'package:art_port/features/admin/admin_applications_screen.dart';
import 'package:art_port/features/admin/admin_inquiries_screen.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/mypage/widgets/menu_list_item.dart';
import 'package:art_port/features/mypage/widgets/section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminMenuSection extends ConsumerWidget {
  const AdminMenuSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(isAdminProvider)) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: 24),
        SectionCard(
          title: '관리자',
          children: [
            MenuListItem(
              label: '아티스트 신청 심사',
              icon: Icons.assignment_ind_rounded,
              iconBackgroundColor: const Color(0xFFDBEAFE),
              iconColor: const Color(0xFF2563EB),
              onTap: () => AdminApplicationsScreen.open(context),
            ),
            MenuListItem(
              label: '고객센터 문의 관리',
              icon: Icons.support_agent_rounded,
              iconBackgroundColor: const Color(0xFFD1FAE5),
              iconColor: const Color(0xFF059669),
              onTap: () => AdminInquiriesScreen.open(context),
            ),
          ],
        ),
      ],
    );
  }
}
