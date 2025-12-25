import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

extension AppSettingExtension on AppSetting {
  static AppSetting fromMap(Map<String, dynamic> json) {
    return AppSetting(Helpers.toStrings(json["key"]), Helpers.toStrings(json["value"]));
  }
}
