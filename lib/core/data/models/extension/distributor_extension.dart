import 'package:salesforce/realm/scheme/schemas.dart';

extension DistributorExtension on Distributor {
  static Distributor fromMap(Map<String, dynamic> item) {
    return Distributor(
      item['code'] as String? ?? "",
      name: item['name'] as String? ?? "",
      name2: item['name2'] as String? ?? "",
      address: item['address'] as String? ?? "",
      address2: item['address2'] as String? ?? "",
      village: item['village'] as String? ?? "",
      commune: item['commune'] as String? ?? "",
      district: item['district'] as String? ?? "",
      province: item['province'] as String? ?? "",
      countryCode: item['countryCode'] as String? ?? "",
      locationCode: item['locationCode'] as String? ?? "",
      phoneNo: item['phoneNo'] as String? ?? "",
      phoneNo2: item['phoneNo2'] as String? ?? "",
      email: item['email'] as String? ?? "",
      contactName: item['contactName'] as String? ?? "",
      inactived: item['inactived'] as String? ?? "",
    );
  }
}
