import 'package:salesforce/features/tasks/domain/entities/promotion_line_entity.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class PromotionDetailState {
  final bool isLoading;
  final ItemPromotionHeader? header;
  final List<ItemPromotionLine> lines;
  final List<PromotionLineEntity> linesTemplate;
  final double orderQty;
  final SalespersonSchedule? schedule;
  final String? documentType;

  const PromotionDetailState({
    this.isLoading = false,
    this.header,
    this.lines = const [],
    this.linesTemplate = const [],
    this.orderQty = 1,
    this.documentType,
    this.schedule,
  });

  PromotionDetailState copyWith({
    bool? isLoading,
    ItemPromotionHeader? header,
    List<ItemPromotionLine>? lines,
    List<PromotionLineEntity>? linesTemplate,
    double? orderQty,
    SalespersonSchedule? schedule,
    String? documentType,
  }) {
    return PromotionDetailState(
      isLoading: isLoading ?? this.isLoading,
      header: header ?? this.header,
      lines: lines ?? this.lines,
      linesTemplate: linesTemplate ?? this.linesTemplate,
      orderQty: orderQty ?? this.orderQty,
      schedule: schedule ?? this.schedule,
      documentType: documentType ?? this.documentType,
    );
  }
}
