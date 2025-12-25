import 'package:salesforce/realm/scheme/schemas.dart';

extension SalespersonExtension on Salesperson {
  static Salesperson fromMap(Map<String, dynamic> json) {
    return Salesperson(
      json['code'] as String? ?? "",
      name: json['name'] as String?,
      name2: json['name2'] as String?,
      title: json['title'] as String?,
      divisionCode: json['division_code'] as String?,
      branchCode: json['branchCode'] as String?,
      businessUnitCode: json['business_unit_code'] as String?,
      salespersonGroupCode: json['salesperson_group_code'] as String?,
      email: json['email'] as String?,
      phoneNo: json['phone_no'] as String?,
      avatar: json['avatar'] as String?,
      avatar32: json['avatar_32'] as String?,
      avatar128: json['avatar_128'] as String?,
      stockCheckOption: json['stock_check_option'] as String?,
      level: json['level'] as String?,
      downLineData: json['downline_data'] as String,
      levelIndex: json['level_index'] as String?,
      joinedDate: json['joined_date'] as String?,
      inactived: json['inactived'] as String?,
      customerStockCheck: json['customer_stock_check'] as String?,
    );
  }
}
