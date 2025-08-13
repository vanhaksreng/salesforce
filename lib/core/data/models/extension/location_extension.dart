import 'package:salesforce/realm/scheme/schemas.dart';

extension LocationExtension on Location {
  static Location fromMap(Map<String, dynamic> item) {
    return Location(
      item['code'] as String? ?? "",
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      address: item['address'] as String?,
      address2: item['address_2'] as String?,
      isIntransit: item['is_intransit'] as String?,
      inactived: item['inactived'] as String?,
    );
  }
}
