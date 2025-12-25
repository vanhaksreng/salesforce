import 'package:salesforce/realm/scheme/schemas.dart';

extension MerchandiseExtension on Merchandise {
  static Merchandise fromMap(Map<String, dynamic> item) {
    return Merchandise(
      item['code'] as String? ?? "",
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      inactived: item['inactived'] as String?,
    );
  }
}
