import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/competitor_promotion_line_extension.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CompetitorPromotionLineHandler extends BaseTableHandler<CompetitorPromotionLine> {
  @override
  String get tableName => "competitor_promotion_line";

  @override
  CompetitorPromotionLine fromMap(Map<String, dynamic> map) {
    return CompetitorPromotionLineExtension.fromMap(map);
  }

  @override
  String extractKey(CompetitorPromotionLine record) => record.id;

  @override
  Type get type => CompetitorPromotionLine;
}
