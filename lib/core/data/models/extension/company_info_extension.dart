import 'package:salesforce/realm/scheme/schemas.dart';

extension CompanyInformationExtension on CompanyInformation {
  static CompanyInformation fromMap(Map<String, dynamic> json) {
    return CompanyInformation(
      json['id'].toString(),
      name: json['name'] ?? "",
      phoneNo: json['phone_no'] ?? "",
      name2: json['name_2'] ?? "",
      address: json['address'] ?? "",
      address2: json['address_2'] ?? "",
      logo128: json['logo_128'] ?? "",
      email: json['email'] ?? "",
    );
  }
}
