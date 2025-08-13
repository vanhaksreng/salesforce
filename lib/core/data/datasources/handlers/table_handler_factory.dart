import 'package:realm/realm.dart';
import 'package:salesforce/core/data/datasources/handlers/bank_account_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/competitor_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/competitor_item_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/competitor_promotion_line_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/competitor_promotion_header_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/currency_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/customer_address_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/customer_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/distributor_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/handler.dart';
import 'package:salesforce/core/data/datasources/handlers/item_group_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/item_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/item_journal_batch_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/item_promotion_scheme_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/item_sales_line_discount_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/item_sales_line_prices_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/item_unit_of_measure_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/location_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/merchandise_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/payment_method_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/payment_term_handler.dart';
import 'package:salesforce/core/data/datasources/handlers/table_handler.dart';

class TableHandlerFactory {
  static final Map<String, TableHandler> _handlers = {
    "bank_account": BankAccountHandler(),
    "customer": CustomerHandler(),
    "competitor": CompetitorHandler(),
    "competitor_item": CompetitorItemHandler(),
    "currency": CurrencyHandler(),
    "customer_address": CustomerAddressHandler(),
    "distributor": DistributorHandler(),
    "item": ItemHandler(),
    "item_group": ItemGroupHandler(),
    "item_unit_of_measure": ItemUnitOfMeasureHandler(),
    "item_sales_line_prices": ItemSalesLinePricesHandler(),
    "item_sales_line_discount": ItemSalesLineDiscountHandler(),
    "item_promotion_scheme": ItemPromotionSchemeHandler(),
    "item_journal_batch": ItemJournalBatchHandler(),
    "location": LocationHandler(),
    "merchandise": MerchandiseHandler(),
    "payment_method": PaymentMethodHandler(),
    "payment_term": PaymentTermHandler(),
    "general_journal_batch": GeneralJournalBatchHandler(),
    "promotion_type": PromotionTypeHandler(),
    "point_of_sales_material": PointOfSalesMaterialHandler(),
    "salesperson": SalespersonHandler(),
    "sub_contract_type": SubContractTypeHandler(),
    // "unit_of_measure": UnitOfMeasureHandler(),
    "vat_posting_setup": VatPostingSetupHandler(),
    "competitor_item_ledger_entry": CompetitorItemLedgerEntryHandler(),
    "customer_item_ledger_entry": CustomerItemLedgerEntryHandler(),
    "salesperson_schedule_merchandise": SalesPersonScheduleMerchandiseHandler(),
    "item_prize_redemption_line_entry": ItemPrizeRedemptionLineEntryHandler(),
    "currency_exchange_rate": CurrencyExchangeRateHandler(),
    "salesperson_schedule": SalespersonScheduleHandler(),
    "competitor_promotion_header": CompetitorPromotionHeaderHandler(),
    "competitor_promotion_line": CompetitorPromotionLineHandler(),
    "customer_ledger_entry": CustomerLedgetEntryHandler(),
    "cash_receipt_journals": CashReceiptJournalsHandler(),
    "item_promotion_header": ItemPromotionHeadereHandler(),
    "item_promotion_line": ItemPromotionLineHandler(),
    "item_prize_redemption_header": ItemPrizeRedemptionHeaderHandler(),
    "item_prize_redemption_line": ItemPrizeRedemptionLineHandler(),
  };

  static TableHandler<RealmObject>? getHandler(String tableName) {
    final handler = _handlers[tableName];
    if (handler == null) {
      return null;
    }

    return handler;
  }
}
