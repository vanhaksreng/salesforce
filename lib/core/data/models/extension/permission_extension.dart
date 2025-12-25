import 'package:salesforce/realm/scheme/schemas.dart';

extension PermissionExtension on Permission {
  static Permission fromMap(Map<String, dynamic> json) {
    return Permission(json["key"] ?? "", json["value"] ?? "");
  }
}
