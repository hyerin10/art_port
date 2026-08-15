import 'package:art_port/core/network/api_exception.dart';
import 'package:art_port/core/network/network_providers.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/mypage/data/dto/support_inquiry_dto.dart';
import 'package:art_port/features/mypage/data/support_repository.dart';
import 'package:art_port/features/mypage/models/support_inquiry_item.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  return SupportRepository(ref.watch(apiClientProvider));
});

final mySupportInquiriesProvider = FutureProvider<List<SupportInquiryItem>>((
  ref,
) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];

  final inquiries = await ref.watch(supportRepositoryProvider).getMy();
  final items = [
    for (final inquiry in inquiries) _toItem(inquiry),
  ]..sort((a, b) => b.lastMessageAt.compareTo(a.lastMessageAt));
  return items;
});

final supportInquiryDetailProvider =
    FutureProvider.family<SupportInquiryDto?, String>((ref, inquiryId) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null || inquiryId.isEmpty) return null;

  try {
    return await ref.watch(supportRepositoryProvider).getById(inquiryId);
  } on ApiException catch (e) {
    if (e.status == 404 || e.code == 'SUPPORT_INQUIRY_NOT_FOUND') {
      return null;
    }
    rethrow;
  }
});

SupportInquiryItem _toItem(SupportInquiryDto inquiry) {
  return SupportInquiryItem(
    id: inquiry.id,
    category: inquiry.category,
    status: inquiry.status,
    title: inquiry.title,
    lastMessagePreview: inquiry.lastMessagePreview ?? inquiry.title ?? '',
    lastMessageAt: inquiry.lastMessageAt ?? inquiry.createdAt,
    unreadCount: inquiry.unreadCount,
  );
}

void invalidateSupportQueries(dynamic ref, {String? inquiryId}) {
  ref.invalidate(mySupportInquiriesProvider);
  if (inquiryId != null && inquiryId.isNotEmpty) {
    ref.invalidate(supportInquiryDetailProvider(inquiryId));
  }
}
