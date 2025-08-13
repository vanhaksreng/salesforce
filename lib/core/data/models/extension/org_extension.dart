import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension OrganizationExtension on Organization {
  static Organization fromMap(Map<String, dynamic> json) {
    return Organization(
      Helpers.toStrings(json["id"]),
      organizationName: json["organization_name"],
      phoneNo: json["phone_no"],
      logo: json["logo"],
      email: json["email"],
    );
  }
}
