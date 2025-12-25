import 'package:salesforce/realm/scheme/schemas.dart';

extension AppSyncLogExtension on AppSyncLog {
  static AppSyncLog fromMap(Map<String, dynamic> json) {
    return AppSyncLog(
      json["key"],
      type: json["type"],
      displayName: json["displayName"],
      lastSynchedDatetime: "",
      total: "0",
    );
  }
}
