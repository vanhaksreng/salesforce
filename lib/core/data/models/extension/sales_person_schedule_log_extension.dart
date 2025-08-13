import 'package:salesforce/realm/scheme/tasks_schemas.dart';

extension SalesPersonScheduleLogExtension on SalesPersonScheduleLog {
  static SalesPersonScheduleLog fromMap(Map<String, dynamic> json) {
    return SalesPersonScheduleLog(
      json['id'].toString(),
      visitNo: json['visit_no'] as String?,
      logType: json['log_type'] as String?,
      logDate: json['log_date'] as String?,
      shopIsClosed: json['shop_is_closed'] as String?,
      description: json['description'] as String?,
      userId: json['user_id'] as String?,
      isSync: json['is_sync'] as String?,
      createAt: json['create_at'] as String?,
      updateAt: json['update_at'] as String?,
    );
  }
}
