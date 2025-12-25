import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/competitor_promotion_header_extension.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CompetitorPromotionHeaderHandler extends BaseTableHandler<CompetitorPromtionHeader> {
  @override
  String get tableName => "competitor_promotion_header";

  @override
  CompetitorPromtionHeader fromMap(Map<String, dynamic> map) {
    return CompetitorPromotionHeaderExtension.fromMap(map);
  }

  @override
  String extractKey(CompetitorPromtionHeader record) => record.id;

  @override
  Type get type => CompetitorPromtionHeader;
}
