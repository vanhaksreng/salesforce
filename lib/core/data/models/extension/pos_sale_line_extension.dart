import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';

extension PosSalesLineExtension on PosSalesLine {
  static PosSalesLine fromMap(Map<String, dynamic> json) {
    return PosSalesLine(
      json['id'] ?? 0,
      lineNo: Helpers.toInt(json['line_no'] as String? ?? ""),
      documentNo: json['document_no'] as String? ?? '',
      customerNo: json['customer_no'] as String? ?? "",
      no: json['no'] as String? ?? '',
      description: json['description'] as String? ?? '',
      description2: json['description_2'] as String? ?? '',
      quantity: Helpers.toDouble(json['quantity']),
      discountPercentage: Helpers.toDouble(json['discount_percentage']),
      discountAmount: Helpers.toDouble(json['discount_amount']),
      amount: Helpers.toDouble(json['amount']),
      vatPercentage: Helpers.toDouble(json['vat_percentage']),
      vatAmount: Helpers.toDouble(json['vat_amount']),
      amountIncludingVat: Helpers.toDouble(json['amount_including_vat']),
      amountIncludingVatLcy: Helpers.toDouble(json['amount_including_vat_lcy']),
      specialType: json['special_type'] as String? ?? '',
      unitOfMeasure: json['unit_of_measure'] as String? ?? "",
      specialTypeNo: json['special_type_no'] as String? ?? '',
      unitPrice: Helpers.toDouble(json['unit_price']),
      itemCategoryCode: json['item_category_code'] as String? ?? '',
      itemGroupCode: json['item_group_code'] as String? ?? '',
      itemDiscGroupCode: json['item_disc_group_code'] as String? ?? '',
      itemBrandCode: json['item_brand_code'] as String? ?? '',
      storeCode: json['store_code'] as String? ?? '',
      divisionCode: json['division_code'] as String? ?? '',
      businessUnitCode: json['business_unit_code'] as String? ?? '',
      departmentCode: json['department_code'] as String? ?? '',
      projectCode: json['project_code'] as String? ?? '',
      salespersonCode: json['salesperson_code'] as String? ?? '',
      distributorCode: json['distributor_code'] as String? ?? '',
      customerGroupCode: json['customer_group_code'] as String? ?? '',
      currencyCode: json['currency_code'] as String? ?? '',
      imgUrl: json['imgUrl'] as String? ?? '',
      currencyFactor: Helpers.toDouble(json['currency_factor']),
      quantityShipped: Helpers.toDouble(json['quantity_shipped']),
      quantityToInvoice: Helpers.toDouble(json['quantity_invoiced']),
    );
  }
}
