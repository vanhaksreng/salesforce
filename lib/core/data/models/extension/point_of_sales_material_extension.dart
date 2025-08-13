import 'package:salesforce/realm/scheme/schemas.dart';

extension PointOfSalesMaterialExtension on PointOfSalesMaterial {
  static PointOfSalesMaterial fromMap(Map<String, dynamic> item) {
    return PointOfSalesMaterial(
      item['code'] as String? ?? "",
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      inactived: item['inactived'] as String?,
    );
  }
}
