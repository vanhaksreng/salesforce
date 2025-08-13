import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

extension PromotionTypeExtension on PromotionType {
  static PromotionType fromMap(Map<String, dynamic> item) {
    return PromotionType(
      item['code'] as String? ?? "",
      description: item['description'] as String?,
      description2: item['description_2'] as String?,
      allowManual: item['allow_manual'] ?? kStatusNo,
      inactived: item['inactived'] as String?,
    );
  }
}
