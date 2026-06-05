import 'package:art_port/features/workroom/models/workroom_sample.dart';

/// 주문 진행 단계 (0: 입금 ~ 4: 완료)
enum OrderProgressStep {
  deposit,
  sketch,
  lineArt,
  coloring,
  completed,
}

extension OrderProgressStepX on OrderProgressStep {
  int get index => OrderProgressStep.values.indexOf(this);

  String get label => switch (this) {
        OrderProgressStep.deposit => '입금',
        OrderProgressStep.sketch => '스케치',
        OrderProgressStep.lineArt => '라인아트',
        OrderProgressStep.coloring => '채색',
        OrderProgressStep.completed => '완료',
      };
}

/// 결제 내역
class WorkroomOrderPayment {
  const WorkroomOrderPayment({
    required this.basePriceLabel,
    required this.additionalOptionsLabel,
    required this.platformFeeLabel,
    required this.totalLabel,
  });

  final String basePriceLabel;
  final String additionalOptionsLabel;
  final String platformFeeLabel;
  final String totalLabel;
}

/// 주문 상세 화면 데이터
class WorkroomOrderDetail {
  const WorkroomOrderDetail({
    required this.summary,
    required this.currentStep,
    required this.progressStatusLabel,
    required this.deadlineSummaryLabel,
    required this.commissionTitle,
    required this.projectName,
    required this.artistName,
    required this.usagePurpose,
    required this.requestDetails,
    required this.referenceImageUrls,
    required this.payment,
    this.hiddenReferenceImageCount = 0,
    this.linkedChatRoomId,
  });

  final WorkroomOrderItem summary;
  final OrderProgressStep currentStep;
  final String progressStatusLabel;
  final String deadlineSummaryLabel;
  final String commissionTitle;
  final String projectName;
  final String artistName;
  final String usagePurpose;
  final String requestDetails;
  final List<String> referenceImageUrls;
  final int hiddenReferenceImageCount;
  final WorkroomOrderPayment payment;
  final String? linkedChatRoomId;

  int get currentStepIndex => currentStep.index;
}

/// 주문 상세 더미 데이터
abstract final class WorkroomOrderDetailData {
  static const _ref1 =
      'https://images.unsplash.com/photo-1578632762645-7723ead50408?w=200&h=200&fit=crop';
  static const _ref2 =
      'https://images.unsplash.com/photo-1521120413309-42d978e308ae?w=200&h=200&fit=crop';
  static const _ref3 =
      'https://images.unsplash.com/photo-1579546929518-9e396f3cc809?w=200&h=200&fit=crop';

  static WorkroomOrderDetail? forOrderId(String orderId) {
    final summary = WorkroomDummyData.orders
        .cast<WorkroomOrderItem?>()
        .where((o) => o!.id == orderId)
        .map((o) => o!)
        .firstOrNull;
    if (summary == null) return null;

    return _overrides[orderId] ?? _defaultDetail(summary);
  }

  static WorkroomOrderDetail _defaultDetail(WorkroomOrderItem summary) {
    final step = switch (summary.progressPercent) {
      >= 100 => OrderProgressStep.completed,
      >= 80 => OrderProgressStep.coloring,
      >= 50 => OrderProgressStep.lineArt,
      >= 25 => OrderProgressStep.sketch,
      _ => OrderProgressStep.deposit,
    };

    return WorkroomOrderDetail(
      summary: summary,
      currentStep: step,
      progressStatusLabel: '진행 중 (${summary.progressPercent}%)',
      deadlineSummaryLabel: summary.deadlineLabel.replaceFirst('마감일: ', '⏰ '),
      commissionTitle: summary.title,
      projectName: summary.title,
      artistName: summary.counterpartName,
      usagePurpose: '비상업적 (개인 사용)',
      requestDetails: '의뢰 상세 내용이 아직 등록되지 않았습니다.',
      referenceImageUrls: const [],
      payment: WorkroomOrderPayment(
        basePriceLabel: summary.priceLabel,
        additionalOptionsLabel: '0원',
        platformFeeLabel: '0원',
        totalLabel: summary.priceLabel,
      ),
    );
  }

  static final _overrides = <String, WorkroomOrderDetail>{
    'order-c1': WorkroomOrderDetail(
      summary: WorkroomDummyData.orders[0],
      currentStep: OrderProgressStep.lineArt,
      progressStatusLabel: '진행 중 (60%)',
      deadlineSummaryLabel: '⏰ D-14 (Dec 20)',
      commissionTitle: 'Anime Portrait Commission',
      projectName: 'Anime Portrait',
      artistName: 'MikaArt',
      usagePurpose: '비상업적 (개인 사용)',
      requestDetails:
          '긴 검은 머리카락에 보라색 눈을 가진 여성 캐릭터입니다. '
          '부드럽고 우아한 분위기로 그려주세요. '
          '의상은 하얀색 드레스이며, 배경은 별이 빛나는 밤하늘입니다.',
      referenceImageUrls: [_ref1, _ref2, _ref3],
      hiddenReferenceImageCount: 2,
      linkedChatRoomId: 'chat-c1',
      payment: const WorkroomOrderPayment(
        basePriceLabel: r'$35',
        additionalOptionsLabel: r'$0',
        platformFeeLabel: r'$0',
        totalLabel: r'$35',
      ),
    ),
  };
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
