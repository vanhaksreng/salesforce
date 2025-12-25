import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';

extension ItemPromotionHeaderExtension on ItemPromotionHeader {
  static ItemPromotionHeader fromMap(Map<String, dynamic> item) {
    return ItemPromotionHeader(
      Helpers.toStrings(item['id'] ?? ""),
      Helpers.toStrings(item['created_at'] ?? ""),
      Helpers.toStrings(item['updated_at'] ?? ""),
      no: Helpers.toStrings(item['no'] ?? ""),
      fromDate: Helpers.toStrings(item['from_date'] ?? ""),
      toDate: Helpers.toStrings(item['to_date'] ?? ""),
      description: Helpers.toStrings(item['description'] ?? ""),
      description2: Helpers.toStrings(item['description_2'] ?? ""),
      remark: Helpers.toStrings(item['remark'] ?? ""),
      promotionType: Helpers.toStrings(item['promotion_type'] ?? ""),
      status: Helpers.toStrings(item['status'] ?? "Approved"),
      picture: Helpers.toStrings(item['picture'] ?? ""),
      avatar32: Helpers.toStrings(item['avatar_32'] ?? ""),
      avatar128: Helpers.toStrings(item['avatar_128'] ?? ""),
      maximumOfferCustomer: Helpers.toDouble(item['maximum_offer_customer'] ?? 0),
      maximumOfferSalesperson: Helpers.toDouble(item['maximum_offer_salesperson'] ?? 0),
      isSync: Helpers.toStrings(item['is_sync'] ?? "Yes"),
    );
  }
}
