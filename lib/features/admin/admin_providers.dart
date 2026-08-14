import 'package:art_port/features/artist_application/data/artist_application_providers.dart';
import 'package:art_port/features/artist_application/data/dto/artist_application_dto.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/mypage/data/dto/support_inquiry_dto.dart';
import 'package:art_port/features/mypage/inquiry_providers.dart';
import 'package:art_port/features/mypage/models/support_inquiry_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final adminApplicationStatusFilterProvider =
    NotifierProvider<AdminStatusFilterNotifier, String?>(
  AdminStatusFilterNotifier.new,
);

final adminInquiryStatusFilterProvider =
    NotifierProvider<AdminStatusFilterNotifier, String?>(
  AdminStatusFilterNotifier.new,
);

class AdminStatusFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? status) => state = status;
}

final adminArtistApplicationsProvider =
    FutureProvider<List<ArtistApplicationDto>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.isAdmin) return const [];

  return ref.watch(artistApplicationRepositoryProvider).getAllForAdmin(
        adminUserId: user.id,
        status: ref.watch(adminApplicationStatusFilterProvider),
      );
});

final adminSupportInquiriesProvider =
    FutureProvider<List<SupportInquiryItem>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null || !user.isAdmin) return const [];

  final inquiries = await ref.watch(supportRepositoryProvider).getAllForAdmin(
        adminUserId: user.id,
        status: ref.watch(adminInquiryStatusFilterProvider),
      );
  return [
    for (final inquiry in inquiries)
      SupportInquiryItem(
        id: inquiry.id,
        category: inquiry.category,
        status: inquiry.status,
        title: inquiry.title,
        lastMessagePreview: inquiry.lastMessagePreview ?? inquiry.title ?? '',
        lastMessageAt: inquiry.lastMessageAt ?? inquiry.createdAt,
        unreadCount: inquiry.unreadCount,
      ),
  ]..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
});

Future<ArtistApplicationDto> reviewArtistApplication(
  WidgetRef ref, {
  required String applicationId,
  required String status,
  String? rejectionReason,
}) async {
  final adminId = ref.read(currentUserIdProvider);
  if (adminId == null) {
    throw StateError('로그인이 필요합니다.');
  }

  final updated = await ref.read(artistApplicationRepositoryProvider).review(
        applicationId: applicationId,
        reviewedBy: adminId,
        status: status,
        rejectionReason: rejectionReason,
      );
  ref.invalidate(adminArtistApplicationsProvider);
  ref.invalidate(commissionCatalogProvider);
  return updated;
}

Future<SupportInquiryDto> updateAdminInquiryStatus(
  WidgetRef ref, {
  required String inquiryId,
  required String status,
}) async {
  final adminId = ref.read(currentUserIdProvider);
  if (adminId == null) {
    throw StateError('로그인이 필요합니다.');
  }

  final updated = await ref.read(supportRepositoryProvider).updateStatus(
        inquiryId: inquiryId,
        adminUserId: adminId,
        status: status,
      );
  ref.invalidate(adminSupportInquiriesProvider);
  invalidateSupportQueries(ref, inquiryId: inquiryId);
  return updated;
}
