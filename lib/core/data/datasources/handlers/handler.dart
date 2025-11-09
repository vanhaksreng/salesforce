import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/cash_receipt_journals_extension.dart';
import 'package:salesforce/core/data/models/extension/competitor_item_ledger_entry_extension.dart';
import 'package:salesforce/core/data/models/extension/currency_exchange_rate_extension.dart';
import 'package:salesforce/core/data/models/extension/customer_item_ledger_entry_extension.dart';
import 'package:salesforce/core/data/models/extension/customer_ledger_entry_extension.dart';
import 'package:salesforce/core/data/models/extension/general_journal_batch_extension.dart';
import 'package:salesforce/core/data/models/extension/item_prize_redemption_header_extension.dart';
import 'package:salesforce/core/data/models/extension/item_prize_redemption_line_entry_extension.dart';
import 'package:salesforce/core/data/models/extension/item_prize_redemption_line_extension.dart';
import 'package:salesforce/core/data/models/extension/item_promotion_header_extension.dart';
import 'package:salesforce/core/data/models/extension/item_promotion_line_extension.dart';
import 'package:salesforce/core/data/models/extension/point_of_sales_material_extension.dart';
import 'package:salesforce/core/data/models/extension/promotion_type_extension.dart';
import 'package:salesforce/core/data/models/extension/salesperson_extension.dart';
import 'package:salesforce/core/data/models/extension/salesperson_schedule_extension.dart';
import 'package:salesforce/core/data/models/extension/salesperson_schedule_merchandise_extenstion.dart';
import 'package:salesforce/core/data/models/extension/sub_contract_type_extension.dart';
import 'package:salesforce/core/data/models/extension/vat_posting_setup_extension.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class GeneralJournalBatchHandler extends BaseTableHandler<GeneralJournalBatch> {
  @override
  String get tableName => "general_journal_batch";

  @override
  GeneralJournalBatch fromMap(Map<String, dynamic> map) {
    return GeneralJournalBatchExtension.fromMap(map);
  }

  @override
  String extractKey(GeneralJournalBatch record) => record.id;

  @override
  Type get type => GeneralJournalBatch;
}

class PromotionTypeHandler extends BaseTableHandler<PromotionType> {
  @override
  String get tableName => "promotion_type";

  @override
  PromotionType fromMap(Map<String, dynamic> map) {
    return PromotionTypeExtension.fromMap(map);
  }

  @override
  String extractKey(PromotionType record) => record.code;

  @override
  Type get type => PromotionType;
}

class PointOfSalesMaterialHandler
    extends BaseTableHandler<PointOfSalesMaterial> {
  @override
  String get tableName => "point_of_sales_material";

  @override
  PointOfSalesMaterial fromMap(Map<String, dynamic> map) {
    return PointOfSalesMaterialExtension.fromMap(map);
  }

  @override
  String extractKey(PointOfSalesMaterial record) => record.code;

  @override
  Type get type => PointOfSalesMaterial;
}

class SalespersonHandler extends BaseTableHandler<Salesperson> {
  @override
  String get tableName => "salesperson";

  @override
  Salesperson fromMap(Map<String, dynamic> map) {
    return SalespersonExtension.fromMap(map);
  }

  @override
  String extractKey(Salesperson record) => record.code;

  @override
  Type get type => Salesperson;
}

class SubContractTypeHandler extends BaseTableHandler<SubContractType> {
  @override
  String get tableName => "sub_contract_type";

  @override
  SubContractType fromMap(Map<String, dynamic> map) {
    return SubContractTypeExtension.fromMap(map);
  }

  @override
  String extractKey(SubContractType record) => record.code;

  @override
  Type get type => SubContractType;
}

// class UnitOfMeasureHandler extends BaseTableHandler<UnitOfMeasure> {
//   @override
//   String get tableName => "unit_of_measure";

//   @override
//   UnitOfMeasure fromMap(Map<String, dynamic> map) {
//     return UnitOfMeasureExtension.fromMap(map);
//   }

//   @override
//   String extractKey(UnitOfMeasure record) => record.code;

//   @override
//   Type get type => UnitOfMeasure;
// }

class VatPostingSetupHandler extends BaseTableHandler<VatPostingSetup> {
  @override
  String get tableName => "vat_posting_setup";

  @override
  VatPostingSetup fromMap(Map<String, dynamic> map) {
    return VatPostingSetupExtension.fromMap(map);
  }

  @override
  String extractKey(VatPostingSetup record) => record.id;

  @override
  Type get type => VatPostingSetup;
}

class CompetitorItemLedgerEntryHandler
    extends BaseTableHandler<CompetitorItemLedgerEntry> {
  @override
  String get tableName => "competitor_item_ledger_entry";

  @override
  CompetitorItemLedgerEntry fromMap(Map<String, dynamic> map) {
    return CompetitorItemLedgerEntryExtension.fromMap(map);
  }

  @override
  String extractKey(CompetitorItemLedgerEntry record) => record.entryNo;

  @override
  Type get type => CompetitorItemLedgerEntry;
}

class CustomerItemLedgerEntryHandler
    extends BaseTableHandler<CustomerItemLedgerEntry> {
  @override
  String get tableName => "customer_item_ledger_entry";

  @override
  CustomerItemLedgerEntry fromMap(Map<String, dynamic> map) {
    return CustomerItemLedgerEntryExtension.fromMap(map);
  }

  @override
  String extractKey(CustomerItemLedgerEntry record) => record.entryNo;

  @override
  Type get type => CustomerItemLedgerEntry;
}

class SalesPersonScheduleMerchandiseHandler
    extends BaseTableHandler<SalesPersonScheduleMerchandise> {
  @override
  String get tableName => "salesperson_schedule_merchandise";

  @override
  SalesPersonScheduleMerchandise fromMap(Map<String, dynamic> map) {
    return SalesPersonScheduleMerchandiseExtension.fromMap(map);
  }

  @override
  String extractKey(SalesPersonScheduleMerchandise record) => record.id ?? "";

  @override
  Type get type => SalesPersonScheduleMerchandise;
}

class ItemPrizeRedemptionLineEntryHandler
    extends BaseTableHandler<ItemPrizeRedemptionLineEntry> {
  @override
  String get tableName => "item_prize_redemption_line_entry";

  @override
  ItemPrizeRedemptionLineEntry fromMap(Map<String, dynamic> map) {
    return ItemPrizeRedemptionLineEntryExtension.fromMap(map);
  }

  @override
  String extractKey(ItemPrizeRedemptionLineEntry record) => record.id;

  @override
  Type get type => ItemPrizeRedemptionLineEntry;
}

class CurrencyExchangeRateHandler
    extends BaseTableHandler<CurrencyExchangeRate> {
  @override
  String get tableName => "currency_exchange_rate";

  @override
  CurrencyExchangeRate fromMap(Map<String, dynamic> map) {
    return CurrencyExchangeRateExtension.fromMap(map);
  }

  @override
  String extractKey(CurrencyExchangeRate record) => record.id;

  @override
  Type get type => CurrencyExchangeRate;
}

class SalespersonScheduleHandler extends BaseTableHandler<SalespersonSchedule> {
  @override
  String get tableName => "salesperson_schedule";

  @override
  SalespersonSchedule fromMap(Map<String, dynamic> map) {
    return SalespersonScheduleExtension.fromMap(map);
  }

  @override
  String extractKey(SalespersonSchedule record) => record.id;

  @override
  Type get type => SalespersonSchedule;
}

class CustomerLedgetEntryHandler extends BaseTableHandler<CustomerLedgerEntry> {
  @override
  String get tableName => "customer_ledger_entry";

  @override
  CustomerLedgerEntry fromMap(Map<String, dynamic> map) {
    return CustomerLedgerEntryExtension.fromMap(map);
  }

  @override
  String extractKey(CustomerLedgerEntry record) => record.entryNo;

  @override
  Type get type => CustomerLedgerEntry;
}

class CashReceiptJournalsHandler extends BaseTableHandler<CashReceiptJournals> {
  @override
  // String get tableName => "customer_ledger_entry";
  String get tableName => "cash_receipt_journals";

  @override
  CashReceiptJournals fromMap(Map<String, dynamic> map) {
    return CashReceiptJournalsExtension.fromMap(map);
  }

  @override
  String extractKey(CashReceiptJournals record) => record.id;

  @override
  Type get type => CashReceiptJournals;
}

class ItemPromotionHeadereHandler
    extends BaseTableHandler<ItemPromotionHeader> {
  @override
  String get tableName => "item_promotion_header";

  @override
  ItemPromotionHeader fromMap(Map<String, dynamic> map) {
    return ItemPromotionHeaderExtension.fromMap(map);
  }

  @override
  String extractKey(ItemPromotionHeader record) => record.id;

  @override
  Type get type => ItemPromotionHeader;
}

class ItemPromotionLineHandler extends BaseTableHandler<ItemPromotionLine> {
  @override
  String get tableName => "item_promotion_line";

  @override
  ItemPromotionLine fromMap(Map<String, dynamic> map) {
    return ItemPromotionLineExtension.fromMap(map);
  }

  @override
  String extractKey(ItemPromotionLine record) => record.id;

  @override
  Type get type => ItemPromotionLine;
}

class ItemPrizeRedemptionHeaderHandler
    extends BaseTableHandler<ItemPrizeRedemptionHeader> {
  @override
  String get tableName => "item_prize_redemption_header";

  @override
  ItemPrizeRedemptionHeader fromMap(Map<String, dynamic> map) {
    return ItemPrizeRedemptionHeaderExtension.fromMap(map);
  }

  @override
  String extractKey(ItemPrizeRedemptionHeader record) => "${record.id}";

  @override
  Type get type => ItemPrizeRedemptionHeader;
}

class ItemPrizeRedemptionLineHandler
    extends BaseTableHandler<ItemPrizeRedemptionLine> {
  @override
  String get tableName => "item_prize_redemption_line";

  @override
  ItemPrizeRedemptionLine fromMap(Map<String, dynamic> map) {
    return ItemPrizeRedemptionLineExtension.fromMap(map);
  }

  @override
  String extractKey(ItemPrizeRedemptionLine record) => "${record.id}";

  @override
  Type get type => ItemPrizeRedemptionLine;
}
