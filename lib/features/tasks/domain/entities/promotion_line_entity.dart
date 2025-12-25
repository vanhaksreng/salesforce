import 'package:salesforce/features/tasks/domain/entities/promotion_item_line_entity.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

class PromotionLineEntity {
  final String type;
  final String promotionType;
  final double qty;
  final double addedQty;
  final double totalLineQty;
  final List<PromotionItemLineEntity> lines;
  final ItemPromotionLine line;

  const PromotionLineEntity({
    required this.type,
    required this.promotionType,
    required this.lines,
    required this.line,
    this.qty = 0,
    this.addedQty = 0,
    this.totalLineQty = 0,
  });

  PromotionLineEntity copyWith({double? addedQty, double? totalLineQty, List<PromotionItemLineEntity>? lines}) {
    return PromotionLineEntity(
      addedQty: addedQty ?? this.addedQty,
      totalLineQty: totalLineQty ?? this.totalLineQty,
      promotionType: promotionType,
      qty: qty,
      lines: lines ?? this.lines,
      line: line,
      type: type,
    );
  }
}
