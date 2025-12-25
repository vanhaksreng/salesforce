import 'package:salesforce/realm/scheme/transaction_schemas.dart';

extension CompetitorPromotionHeaderExtension on CompetitorPromtionHeader {
  static CompetitorPromtionHeader fromMap(Map<String, dynamic> item) {
    return CompetitorPromtionHeader(
      item['id'] as String? ?? '',
      no: item['no'] as String?,
      fromDate: item['from_date'] as String?,
      toDate: item['to_date'] as String?,
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      remark: item['remark'] as String?,
      promotionType: item['promotion_type'] as String?,
      salespersonCodeFilter: item['salesperson_code_filter'] as String?,
      distributorCodeFilter: item['distributor_code_filter'] as String?,
      storeCodeFilter: item['store_code_filter'] as String?,
      divisionCodeFilter: item['division_code_filter'] as String?,
      businessUnitCodeFilter: item['business_unit_code_filter'] as String?,
      departmentCodeFilter: item['department_code_filter'] as String?,
      projectCodeFilter: item['project_code_filter'] as String?,
      firstApproverCode: item['first_approver_code'] as String?,
      secondApproverCode: item['second_approver_code'] as String?,
      competitorNo: item['competitor_no'] as String?,
      customerNo: item['customer_no'] as String?,
      name: item['name'] as String?,
      name2: item['name_2'] as String?,
      sourceType: item['source_type'] as String?,
      sourceNo: item['source_no'] as String?,
      status: item['status'] as String?,
      picture: item['picture'] as String?,
      avatar32: item['avatar_32'] as String?,
      avatar128: item['avatar_128'] as String?,
      appId: item['app_id'] as String?,
    );
  }
}
