import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension CustomerAddressExtension on CustomerAddress {
  static CustomerAddress fromMap(Map<String, dynamic> item) {
    return CustomerAddress(
      Helpers.toStrings(item['id']),
      customerNo: item['customer_no'] as String? ?? "",
      code: item['code'] as String? ?? "",
      name: item['name'] as String? ?? "",
      name2: item['name_2'] as String? ?? "",
      address: item['address'] as String? ?? "",
      address2: item['address_2'] as String? ?? "",
      phoneNo: item['phone_no'] as String? ?? "",
      phoneNo2: item['phone_no_2'] as String? ?? "",
      email: item['email'] as String? ?? "",
      contactName: item['contact_name'] as String? ?? "",
      latitude: Helpers.toDouble(item['latitude']),
      longitude: Helpers.toDouble(item['longitude']),
      inactived: item['inactived'] as String? ?? "No",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_no': customerNo,
      'code': code,
      'name': name,
      'name_2': name2,
      'address': address,
      'address_2': address2,
      'phone_no': phoneNo,
      'phone_no_2': phoneNo2,
      'email': email,
      'contact_name': contactName,
      'latitude': latitude,
      'longitude': longitude,
      'inactived': inactived,
    };
  }
}
