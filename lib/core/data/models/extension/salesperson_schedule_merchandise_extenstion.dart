import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

extension SalesPersonScheduleMerchandiseExtension on SalesPersonScheduleMerchandise {
  static SalesPersonScheduleMerchandise fromMap(Map<String, dynamic> item) {
    return SalesPersonScheduleMerchandise(
      Helpers.toStrings(item['id']),
      appId: Helpers.toStrings(item['app_id'] ?? ""),
      visitNo: Helpers.toInt(item['visit_no'] ?? ""),
      customerNo: item['customer_no'] as String?,
      name: item['name'] as String?,
      name2: item['name_2'] as String?,
      salespersonCode: item['salesperson_code'] as String?,
      competitorNo: item['competitor_no'] as String?,
      merchandiseType: item['merchandise_type'] as String?,
      merchandiseOption: item['merchandise_option'] as String?,
      merchandiseCode: item['merchandise_code'] as String?,
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      remark: item['remark'] as String?,
      picture: item['picture'] as String?,
      status: item['status'] as String? ?? "Open",
      quantity: Helpers.formatNumberDb(item['quantity'], option: FormatType.quantity),
      flag: item['flag'] as String? ?? "No",
      isSync: item['is_sync'] as String? ?? "Yes",
      scheduleDate: DateTimeExt.parse(item['schedule_date']).toDateString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'visit_no': visitNo,
      'schedule_date': scheduleDate,
      'customer_no': customerNo,
      'name': name,
      'name_2': name2,
      'salesperson_code': salespersonCode,
      'competitor_no': competitorNo,
      'merchandise_type': merchandiseType,
      'merchandise_option': merchandiseOption,
      'merchandise_code': merchandiseCode,
      'description': description,
      'description_2': description2,
      'quantity': quantity,
      'status': status,
      'remark': remark,
      'picture': picture,
      'flag': flag,
      'app_id': appId,
    };
  }
}
