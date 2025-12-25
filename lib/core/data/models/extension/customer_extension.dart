import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension CustomerExtension on Customer {
  static Customer fromMap(Map<String, dynamic> item) {
    return Customer(
      item['no'] as String,
      name: item['name'] ?? "",
      name2: item['name_2'] as String?,
      address: item['address'] as String?,
      address2: item['address_2'] as String?,
      email: item["email"] ?? "",
      customerGroupCode: item['customer_group_code'] as String?,
      paymentTermCode: item['payment_term_code'] as String?,
      divisionCode: item['division_code'] as String?,
      businessUnitCode: item['business_unit_code'] as String?,
      salespersonCode: item['salesperson_code'] as String?,
      customerDiscountCode: item['customer_discount_code'] as String?,
      customerPriceGroupCode: item['customer_price_group_code'] as String?,
      recPostingGroupCode: item['rec_posting_group_code'] as String?,
      vatPostingGroupCode: item['vat_posting_group_code'] as String?,
      genBusPostingGroupCode: item['gen_bus_posting_group_code'] as String?,
      creditLimitedAmount: Helpers.toDouble(item['credit_limited_amount'] ?? 0),
      creditLimitedType: Helpers.toStrings(item['credit_limited_type'] ?? ""),
      avatar32: item['avatar_32'] as String?,
      avatar128: item['avatar_128'] as String?,
      inactived: item['inactived'] as String?,
      latitude: Helpers.toDouble(item['latitude']),
      longitude: Helpers.toDouble(item['longitude']),
      phoneNo: item['phone_no'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'name': name,
      'name_2': name2,
      'address': address,
      'address_2': address2,
      'email': email,
      'customer_group_code': customerGroupCode,
      'payment_term_code': paymentTermCode,
      'division_code': divisionCode,
      'business_unit_code': businessUnitCode,
      'salesperson_code': salespersonCode,
      'customer_discount_code': customerDiscountCode,
      'customer_price_group_code': customerPriceGroupCode,
      'rec_posting_group_code': recPostingGroupCode,
      'vat_posting_group_code': vatPostingGroupCode,
      'gen_bus_posting_group_code': genBusPostingGroupCode,
      'avatar_32': avatar32,
      'avatar_128': avatar128,
      'inactived': inactived,
      'latitude': latitude,
      'longitude': longitude,
      'phone_no': phoneNo,
    };
  }

  Customer copyWith({String? address, String? address2, String? phoneNo}) {
    return Customer(
      no,
      name: name,
      name2: name2,
      address: address ?? this.address,
      address2: address2 ?? this.address2,
      email: email,
      customerGroupCode: customerGroupCode,
      paymentTermCode: paymentTermCode,
      divisionCode: divisionCode,
      businessUnitCode: businessUnitCode,
      salespersonCode: salespersonCode,
      customerDiscountCode: customerDiscountCode,
      customerPriceGroupCode: customerPriceGroupCode,
      recPostingGroupCode: recPostingGroupCode,
      vatPostingGroupCode: vatPostingGroupCode,
      genBusPostingGroupCode: genBusPostingGroupCode,
      avatar32: avatar32,
      avatar128: avatar128,
      inactived: inactived,
      latitude: latitude,
      longitude: longitude,
      phoneNo: phoneNo ?? this.phoneNo,
    );
  }
}
