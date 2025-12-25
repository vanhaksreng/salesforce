import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

extension ItemPrizeRedemptionHeaderExtension on ItemPrizeRedemptionHeader {
  static ItemPrizeRedemptionHeader fromMap(Map<String, dynamic> item) {
    return ItemPrizeRedemptionHeader(
      Helpers.toInt(item['id']),
      no: Helpers.toStrings(item['no']),
      itemNo: item['item_no'] as String?,
      fromDate: DateTimeExt.parse(item['from_date']).toDateString(),
      toDate: DateTimeExt.parse(item['to_date']).toDateString(),
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      remark: item['remark'] as String?,
      customerGroupCodeFilter: item['customer_group_code_filter'] as String?,
      salespersonCodeFilter: item['salesperson_code_filter'] as String?,
      distributorCodeFilter: item['distributor_code_filter'] as String?,
      storeCodeFilter: item['store_code_filter'] as String?,
      divisionCodeFilter: item['division_code_filter'] as String?,
      businessUnitCodeFilter: item['business_unit_code_filter'] as String?,
      departmentCodeFilter: item['department_code_filter'] as String?,
      projectCodeFilter: item['project_code_filter'] as String?,
      territoryCodeFilter: item['territory_code_filter'] as String?,
      unitOfMeasure: item['unit_of_measure'] as String?,
      quantity: Helpers.toDouble(item['quantity']),
      status: item['status'] as String? ?? "Open",
      picture: item['picture'] as String?,
      avatar32: item['avatar_32'] as String?,
      avatar128: item['avatar_128'] as String?,
      isSync: item['is_sync'] as String? ?? "Yes",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'no': no,
      'item_no': itemNo,
      'from_date': fromDate,
      'to_date': toDate,
      'description': description,
      'description_2': description2,
      'remark': remark,
      'customer_group_code_filter': customerGroupCodeFilter,
      'salesperson_code_filter': salespersonCodeFilter,
      'distributor_code_filter': distributorCodeFilter,
      'store_code_filter': storeCodeFilter,
      'division_code_filter': divisionCodeFilter,
      'business_unit_code_filter': businessUnitCodeFilter,
      'department_code_filter': departmentCodeFilter,
      'project_code_filter': projectCodeFilter,
      'territory_code_filter': territoryCodeFilter,
      'unit_of_measure': unitOfMeasure,
      'quantity': quantity,
      'status': status,
      'picture': picture,
      'avatar_32': avatar32,
      'avatar_128': avatar128,
      'is_sync': isSync,
    };
  }
}
