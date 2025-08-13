import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension CompetitorExtension on Competitor {
  static Competitor fromMap(Map<String, dynamic> item) {
    return Competitor(
      item['no'] as String,
      name: item['name'] ?? "",
      name2: item['name_2'] ?? "",
      address: item['address'] ?? "",
      address2: item['address_2'] ?? "",
      phoneNo: item['phone_no'] ?? "",
      phoneNo2: item['phone_no_2'] ?? "",
      email: item['email'] ?? "",
      storeCode: item['store_code'] ?? "",
      divisionCode: item['division_code'] ?? "",
      businessUnitCode: item['business_unit_code'] ?? "",
      departmentCode: item['department_code'] ?? "",
      projectCode: item['project_code'] ?? "",
      purchaserCode: item['purchaser_code'] ?? "",
      distributorCode: item['distributor_code'] ?? "",
      locationCode: item['location_code'] ?? "",
      apPostingGroupCode: item['ap_posting_group_code'] ?? "",
      genBusPostingGroupCode: item['gen_bus_posting_group_code'] ?? "",
      vatBusPostingGroupCode: item['vat_bus_posting_group_code'] ?? "",
      logo: item['logo'] ?? "",
      avatar32: item['avatar_32'] ?? "",
      avatar128: item['avatar_128'] ?? "",
      inactived: item['inactived'] ?? kStatusNo,
    );
  }
}
