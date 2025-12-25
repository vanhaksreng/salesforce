import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

extension ItemPrizeRedemptionLineEntryExtension on ItemPrizeRedemptionLineEntry {
  static ItemPrizeRedemptionLineEntry fromMap(Map<String, dynamic> item) {
    return ItemPrizeRedemptionLineEntry(
      Helpers.toStrings(item['id']),
      appId: Helpers.toStrings(item['app_id']),
      scheduleId: Helpers.toStrings(item['schedule_id']),
      scheduleDate: DateTimeExt.parse(item['schedule_date']).toDateString(),
      lineNo: Helpers.toInt(item['line_no']),
      promotionNo: item['promotion_no'] as String?,
      customerNo: item['customer_no'] as String?,
      customerName: item['customer_name'] as String?,
      customerName2: item['customer_name_2'] as String?,
      shipToCode: item['ship_to_code'] as String?,
      itemNo: item['item_no'] as String?,
      variantCode: item['variant_code'] as String?,
      redemptionType: item['redemption_type'] as String?,
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      unitOfMeasureCode: item['unit_of_measure_code'] as String?,
      qtyPerUnitOfMeasure: Helpers.toDouble(item['qty_per_unit_of_measure']),
      quantity: Helpers.toDouble(item['quantity']),
      sourceType: item['source_type'] as String?,
      sourceNo: item['source_no'] as String?,
      salespersonCode: item['salesperson_code'] as String?,
      itemCategoryCode: item['item_category_code'] as String?,
      itemGroupCode: item['item_group_code'] as String?,
      itemBrandCode: item['item_brand_code'] as String?,
      status: item['status'] as String? ?? "Approved",
      isSync: item['is_sync'] as String? ?? "Yes",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'schedule_id': scheduleId,
      'schedule_date': scheduleDate,
      'line_no': lineNo,
      'promotion_no': promotionNo,
      'customer_no': customerNo,
      'customer_name': customerName,
      'customer_name_2': customerName2,
      'ship_to_code': shipToCode,
      'item_no': itemNo,
      'variant_code': variantCode,
      'redemption_type': redemptionType,
      'description': description,
      'description_2': description2,
      'unit_of_measure_code': unitOfMeasureCode,
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure,
      'quantity': quantity,
      'source_type': sourceType,
      'source_no': sourceNo,
      'salesperson_code': salespersonCode,
      'item_category_code': itemCategoryCode,
      'item_group_code': itemGroupCode,
      'item_brand_code': itemBrandCode,
      'status': status,
      'is_sync': isSync,
    };
  }
}
