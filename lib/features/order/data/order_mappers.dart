import 'package:art_port/core/formatters/currency_formatter.dart';
import 'package:art_port/features/auth/domain/user.dart';
import 'package:art_port/features/auth/presentation/auth_session_providers.dart';
import 'package:art_port/features/commission/data/commission_catalog.dart';
import 'package:art_port/features/commission/data/commission_catalog_providers.dart';
import 'package:art_port/features/commission/data/dto/commission_type_dto.dart';
import 'package:art_port/features/commission/models/commission_apply_args.dart';
import 'package:art_port/features/commission/models/commission_price_option.dart';
import 'package:art_port/features/commission/models/commission_status.dart';
import 'package:art_port/features/commission/models/commission_transaction.dart';
import 'package:art_port/features/order/data/dto/order_dto.dart';
import 'package:art_port/features/workroom/models/workroom_commission_order.dart';
import 'package:art_port/features/workroom/models/workroom_order_detail.dart';
import 'package:art_port/features/workroom/models/workroom_sample.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const fallbackAvatarUrl =
    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=80&h=80&fit=crop';

class ParticipantLookups {
  const ParticipantLookups({
    required this.catalog,
    required this.usersById,
  });

  final CommissionCatalog? catalog;
  final Map<String, User> usersById;

  String nameFor(String userId) {
    final artist = catalog?.artistsByUserId[userId];
    if (artist != null) return artist.displayName;
    return usersById[userId]?.name ?? '사용자';
  }

  String avatarFor(String userId) {
    final url = catalog?.artistsByUserId[userId]?.avatarUrl;
    if (url != null && url.isNotEmpty) return url;
    return fallbackAvatarUrl;
  }

  String? artistProfileIdFor(String userId) =>
      catalog?.artistsByUserId[userId]?.id;

  CommissionTypeDto? typeById(String id) => catalog?.typeById(id);

  static Future<ParticipantLookups> resolve(
    Ref ref, {
    required Iterable<String> userIds,
  }) async {
    CommissionCatalog? catalog = ref.watch(commissionCatalogProvider).valueOrNull;
    if (catalog == null) {
      try {
        catalog = await ref.watch(commissionCatalogProvider.future);
      } catch (_) {}
    }

    final missing = <String>{};
    for (final id in userIds) {
      if (id.isEmpty) continue;
      if (catalog?.artistsByUserId.containsKey(id) == true) continue;
      missing.add(id);
    }

    final usersById = <String, User>{};
    if (missing.isNotEmpty) {
      final repo = ref.read(userRepositoryProvider);
      final results = await Future.wait(
        missing.map((id) async {
          try {
            return MapEntry(id, await repo.getUser(id));
          } catch (_) {
            return null;
          }
        }),
      );
      for (final entry in results) {
        if (entry != null) usersById[entry.key] = entry.value;
      }
    }

    return ParticipantLookups(catalog: catalog, usersById: usersById);
  }
}

abstract final class OrderMappers {
  static CommissionStatus statusFrom(String status) {
    return switch (status) {
      'accepted' => CommissionStatus.accepted,
      'payment_requested' => CommissionStatus.paymentRequested,
      'paid' => CommissionStatus.paid,
      'working' => CommissionStatus.working,
      'completed' => CommissionStatus.completed,
      'rejected' => CommissionStatus.rejected,
      'cancelled' => CommissionStatus.cancelled,
      'refunded' => CommissionStatus.refunded,
      _ => CommissionStatus.submitted,
    };
  }

  static OrderProgressStep stepFrom(String? step) {
    return switch (step) {
      'sketch' => OrderProgressStep.sketch,
      'line_art' => OrderProgressStep.lineArt,
      'coloring' => OrderProgressStep.coloring,
      'completed' => OrderProgressStep.completed,
      _ => OrderProgressStep.deposit,
    };
  }

  static CommissionUsagePurpose usageFrom(String? purpose) {
    return switch (purpose) {
      'commercial' => CommissionUsagePurpose.commercial,
      'broadcasting' => CommissionUsagePurpose.broadcasting,
      _ => CommissionUsagePurpose.personal,
    };
  }

  static String usageLabel(String? purpose) {
    return switch (purpose) {
      'commercial' => '상업적 이용',
      'broadcasting' => '방송 사용',
      'personal' => '비상업적 (개인 사용)',
      _ => '-',
    };
  }

  static String deadlineLabel(DateTime? deadline) {
    if (deadline == null) return '';
    final local = deadline.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '마감일: ${local.year}.$month.$day';
  }

  static String deadlineSummaryLabel(DateTime? deadline) {
    final label = deadlineLabel(deadline);
    if (label.isEmpty) return '';
    return label.replaceFirst('마감일: ', '⏰ ');
  }

  static String formatDateYmd(DateTime date) {
    final local = date.toLocal();
    final month = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    return '${local.year}-$month-$day';
  }

  static CommissionTransaction toTransaction(
    OrderDto order,
    ParticipantLookups lookups,
  ) {
    final type = lookups.typeById(order.commissionTypeId);
    final title = type?.name ?? order.projectName ?? '커미션';
    final option = order.selectedOption ??
        CommissionPriceOption(label: '기본', priceWon: order.baseAmountWon);
    final status = statusFrom(order.status);

    return CommissionTransaction(
      orderId: order.id,
      roomId: order.chatRoomId ?? '',
      status: status,
      application: CommissionApplySubmission(
        commissionId: order.commissionTypeId,
        commissionTitle: title,
        artistName: lookups.nameFor(order.artistId),
        selectedOption: option,
        requestContent: order.requestContent,
        referenceImagePaths: order.referenceImageUrls,
        usagePurpose: usageFrom(order.usagePurpose),
        desiredDeadline: order.desiredDeadline,
        submittedAt: order.createdAt,
      ),
      artistName: lookups.nameFor(order.artistId),
      artistAvatarUrl: lookups.avatarFor(order.artistId),
      clientName: lookups.nameFor(order.clientId),
      clientAvatarUrl: lookups.avatarFor(order.clientId),
      commissionTitle: title,
      updatedAt: order.updatedAt,
      artistId: lookups.artistProfileIdFor(order.artistId),
      isDeclined: status.isDeclined,
      baseAmountWon: order.baseAmountWon,
      additionalAmountWon: order.additionalAmountWon,
      serviceFeeWon: order.serviceFeeWon,
      totalAmountWon: order.totalAmountWon,
    );
  }

  static WorkroomCommissionOrder toWorkroomOrder(
    OrderDto order, {
    required ParticipantLookups lookups,
    required bool isArtistMode,
  }) {
    final transaction = toTransaction(order, lookups);
    return WorkroomCommissionOrder.fromTransaction(
      transaction,
      isArtistMode: isArtistMode,
      orderId: order.id,
    );
  }

  static WorkroomOrderDetail toOrderDetail(
    OrderDto order, {
    required ParticipantLookups lookups,
    required bool isArtistMode,
  }) {
    final type = lookups.typeById(order.commissionTypeId);
    final title = type?.name ?? order.projectName ?? '커미션';
    final status = statusFrom(order.status);
    final step = order.status == 'completed'
        ? OrderProgressStep.completed
        : stepFrom(order.currentStep);
    final counterpartId = isArtistMode ? order.clientId : order.artistId;
    final deadline = order.desiredDeadline ?? order.deadlineAt;

    return WorkroomOrderDetail(
      summary: WorkroomOrderItem(
        id: order.id,
        title: title,
        counterpartName: lookups.nameFor(counterpartId),
        avatarUrl: lookups.avatarFor(counterpartId),
        status: _workroomStatus(status),
        progressPercent: _progressPercent(step),
        deadlineLabel: deadlineLabel(deadline),
        priceWon: order.totalAmountWon,
        isReceivedAsArtist: isArtistMode,
      ),
      currentStep: step,
      progressStatusLabel: _progressStatusLabel(status, step),
      deadlineSummaryLabel: deadlineSummaryLabel(deadline),
      commissionTitle: title,
      projectName: order.projectName ?? title,
      artistName: lookups.nameFor(order.artistId),
      usagePurpose: usageLabel(order.usagePurpose),
      requestDetails: order.requestContent,
      referenceImageUrls: order.referenceImageUrls,
      payment: WorkroomOrderPayment(
        basePriceLabel: CurrencyFormatter.formatWon(order.baseAmountWon),
        additionalOptionsLabel:
            CurrencyFormatter.formatWon(order.additionalAmountWon),
        platformFeeLabel: CurrencyFormatter.formatWon(order.serviceFeeWon),
        totalLabel: CurrencyFormatter.formatWon(order.totalAmountWon),
      ),
      linkedChatRoomId: order.chatRoomId,
      artistUserId: order.artistId,
      isCompleted: order.status == 'completed',
      canAdvanceStep: isArtistMode &&
          _stepUpdatableStatuses.contains(order.status) &&
          step != OrderProgressStep.completed,
      canCancel: !_terminalStatuses.contains(order.status),
      nextStep: step.next,
      cancelReason: order.cancelReason,
    );
  }

  static const _stepUpdatableStatuses = {
    'accepted',
    'payment_requested',
    'paid',
    'working',
  };

  static const _terminalStatuses = {
    'rejected',
    'completed',
    'cancelled',
    'refunded',
  };

  static WorkroomOrderStatus _workroomStatus(CommissionStatus status) {
    return switch (status) {
      CommissionStatus.completed => WorkroomOrderStatus.completed,
      CommissionStatus.rejected ||
      CommissionStatus.cancelled ||
      CommissionStatus.refunded => WorkroomOrderStatus.review,
      _ => WorkroomOrderStatus.inProgress,
    };
  }

  static int _progressPercent(OrderProgressStep step) {
    return switch (step) {
      OrderProgressStep.deposit => 0,
      OrderProgressStep.sketch => 25,
      OrderProgressStep.lineArt => 50,
      OrderProgressStep.coloring => 80,
      OrderProgressStep.completed => 100,
    };
  }

  static String _progressStatusLabel(
    CommissionStatus status,
    OrderProgressStep step,
  ) {
    return switch (status) {
      CommissionStatus.completed => '완료',
      CommissionStatus.rejected => '거절됨',
      CommissionStatus.cancelled => '취소됨',
      CommissionStatus.refunded => '환불됨',
      CommissionStatus.submitted => '신청서 제출됨',
      _ => '진행 중 (${step.label})',
    };
  }
}
