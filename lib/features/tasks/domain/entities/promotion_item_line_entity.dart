import 'package:salesforce/realm/scheme/item_schemas.dart';

class PromotionItemLineEntity {
  final String itemNo;
  final String itemName;
  final String saleUomCode;
  final double orderQty;
  final double qty;
  final double discountAmount;
  final double discountPercent;
  final String itemPicture;
  final String promotionType;
  final String lineCode;
  final Item? item;

  const PromotionItemLineEntity({
    required this.itemNo,
    required this.itemName,
    required this.saleUomCode,
    required this.promotionType,
    required this.lineCode,
    required this.discountAmount,
    required this.discountPercent,
    required this.item,
    this.qty = 0,
    this.orderQty = 0,
    this.itemPicture = "",
  });

  PromotionItemLineEntity copyWith({double? orderQty}) {
    return PromotionItemLineEntity(
      orderQty: orderQty ?? this.orderQty,
      qty: qty,
      itemNo: itemNo,
      itemName: itemName,
      saleUomCode: saleUomCode,
      promotionType: promotionType,
      discountAmount: discountAmount,
      discountPercent: discountPercent,
      lineCode: lineCode,
      itemPicture: itemPicture,
      item: item,
      
    );
  }
}
