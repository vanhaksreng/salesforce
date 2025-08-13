import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/features/tasks/domain/entities/promotion_line_entity.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class ItemPromotionFormState {
  final bool isLoading;
  final ItemPromotionHeader? header;
  final List<ItemPromotionLine> lines;
  final List<PromotionLineEntity> linesTemplate;
  final double orderQty;
  final SalespersonSchedule? schedule;
  final String documentType;
  final String? errorMsg;
  final double totalExistingQty;
  final double maxAllowedQty;

  const ItemPromotionFormState({
    this.isLoading = false,
    this.header,
    this.lines = const [],
    this.linesTemplate = const [],
    this.orderQty = 1,
    this.documentType = kSaleOrder,
    this.schedule,
    this.errorMsg = "",
    this.totalExistingQty = 0,
    this.maxAllowedQty = 0,
  });

  ItemPromotionFormState copyWith({
    bool? isLoading,
    ItemPromotionHeader? header,
    List<ItemPromotionLine>? lines,
    List<PromotionLineEntity>? linesTemplate,
    double? orderQty,
    SalespersonSchedule? schedule,
    String? documentType,
    String? errorMsg,
    double? totalExistingQty,
    double? maxAllowedQty,
  }) {
    return ItemPromotionFormState(
      isLoading: isLoading ?? this.isLoading,
      header: header ?? this.header,
      lines: lines ?? this.lines,
      linesTemplate: linesTemplate ?? this.linesTemplate,
      orderQty: orderQty ?? this.orderQty,
      schedule: schedule ?? this.schedule,
      documentType: documentType ?? this.documentType,
      errorMsg: errorMsg ?? this.errorMsg,
      totalExistingQty: totalExistingQty ?? this.totalExistingQty,
      maxAllowedQty: maxAllowedQty ?? this.maxAllowedQty,
    );
  }
}
