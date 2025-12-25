import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension CompanyInformationExtension on CompanyInformation {
  static CompanyInformation fromMap(Map<String, dynamic> json) {
    return CompanyInformation(
      json['id'].toString(),
      name: Helpers.toStrings(json['name'] ?? ""),
      phoneNo: Helpers.toStrings(json['phone_no'] ?? ""),
      name2: Helpers.toStrings(json['name_2'] ?? ""),
      address: Helpers.toStrings(json['address'] ?? ""),
      address2: Helpers.toStrings(json['address_2'] ?? ""),
      logo128: Helpers.toStrings(json['logo_128'] ?? ""),
      email: Helpers.toStrings(json['email'] ?? ""),
    );
  }
}
