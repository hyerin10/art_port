import 'package:art_port/core/network/json_parsers.dart';
import 'package:art_port/features/commission/models/commission_price_option.dart';

class OrderDto {
  const OrderDto({
    required this.id,
    required this.commissionTypeId,
    required this.clientId,
    required this.artistId,
    this.chatRoomId,
    required this.requestContent,
    required this.referenceImageUrls,
    this.usagePurpose,
    this.desiredDeadline,
    this.selectedOption,
    required this.baseAmountWon,
    required this.additionalAmountWon,
    required this.serviceFeeWon,
    required this.totalAmountWon,
    required this.status,
    this.currentStep,
    this.projectName,
    this.deadlineAt,
    this.completedAt,
    this.cancelledAt,
    this.cancelReason,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String commissionTypeId;
  final String clientId;
  final String artistId;
  final String? chatRoomId;
  final String requestContent;
  final List<String> referenceImageUrls;
  final String? usagePurpose;
  final DateTime? desiredDeadline;
  final CommissionPriceOption? selectedOption;
  final int baseAmountWon;
  final int additionalAmountWon;
  final int serviceFeeWon;
  final int totalAmountWon;
  final String status;
  final String? currentStep;
  final String? projectName;
  final DateTime? deadlineAt;
  final DateTime? completedAt;
  final DateTime? cancelledAt;
  final String? cancelReason;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    final optionJson = json['selectedOption'];
    return OrderDto(
      id: JsonParsers.string(json['id']),
      commissionTypeId: JsonParsers.string(json['commissionTypeId']),
      clientId: JsonParsers.string(json['clientId']),
      artistId: JsonParsers.string(json['artistId']),
      chatRoomId: JsonParsers.optionalString(json['chatRoomId']),
      requestContent: JsonParsers.string(json['requestContent']),
      referenceImageUrls: JsonParsers.stringList(json['referenceImageUrls']),
      usagePurpose: JsonParsers.optionalString(json['usagePurpose']),
      desiredDeadline: JsonParsers.dateTime(json['desiredDeadline']),
      selectedOption: optionJson is Map<String, dynamic>
          ? CommissionPriceOption(
              label: JsonParsers.string(optionJson['label']),
              priceWon: JsonParsers.integer(optionJson['priceWon']),
            )
          : null,
      baseAmountWon: JsonParsers.integer(json['baseAmountWon']),
      additionalAmountWon: JsonParsers.integer(json['additionalAmountWon']),
      serviceFeeWon: JsonParsers.integer(json['serviceFeeWon']),
      totalAmountWon: JsonParsers.integer(json['totalAmountWon']),
      status: JsonParsers.string(json['status'], 'submitted'),
      currentStep: JsonParsers.optionalString(json['currentStep']),
      projectName: JsonParsers.optionalString(json['projectName']),
      deadlineAt: JsonParsers.dateTime(json['deadlineAt']),
      completedAt: JsonParsers.dateTime(json['completedAt']),
      cancelledAt: JsonParsers.dateTime(json['cancelledAt']),
      cancelReason: JsonParsers.optionalString(json['cancelReason']),
      createdAt: JsonParsers.requireDateTime(json['createdAt']),
      updatedAt: JsonParsers.requireDateTime(json['updatedAt']),
    );
  }
}
