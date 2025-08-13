import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

extension ItemUnitOfMeasureExtension on ItemUnitOfMeasure {
  static ItemUnitOfMeasure fromMap(Map<String, dynamic> item) {
    return ItemUnitOfMeasure(
      Helpers.toStrings(item['id'] ?? ""),
      itemNo: item['item_no'] ?? "",
      unitOfMeasureCode: item['unit_of_measure_code'] ?? "",
      unitOption: item['unit_option'] ?? "",
      identifierCode: item['identifier_code'] ?? "",
      description: item['description'] ?? "",
      description2: item['description_2'] ?? "",
      qtyPerUnit: Helpers.toDouble(item['qty_per_unit']),
      quantityDecimal: item['quantityDecimal'] ?? "",
      price: Helpers.formatNumberDb(item['price'], option: FormatType.price),
      priceOption: item['priceOption'] ?? "",
      inactived: item['inactived'] ?? "",
    );
  }
}
