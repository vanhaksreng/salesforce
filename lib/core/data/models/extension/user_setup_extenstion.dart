import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

extension UserSetupExtension on UserSetup {
  static UserSetup fromMap(Map<String, dynamic> json) {
    return UserSetup(
      Helpers.toStrings(json["email"]),
      roleCode: json["role_code"],
      permissionCode: json["permission_code"],
      locationCode: json["location_code"],
      intransitLocationCode: json["intransit_location_code"],
      businessUnitCode: json["business_unit_code"],
      divisionCode: json["division_code"],
      storeCode: json["store_code"],
      projectCode: json["project_code"],
      salespersonCode: json["salesperson_code"],
      distributorCode: json["distributor_code"],
      departmentCode: json["department_code"],
      cashJournalBatchName: json["cash_journal_batch_name"],
      cashBankAccountCode: json["cash_bank_account_code"],
      payJournalBatchName: json["pay_journal_batch_name"],
      genJournalBatchName: json["gen_journal_batch_name"],
      itemJournalBatchName: json["item_journal_batch_name"],
      type: json["type"],
      fromLocationCode: json["from_location_code"],
      customerNo: json["customer_no"],
      vendorNo: json["vendor_no"],
      userId: Helpers.toInt(json["user_id"]),
    );
  }
}
