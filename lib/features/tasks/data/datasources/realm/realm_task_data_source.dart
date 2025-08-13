import 'package:salesforce/core/data/datasources/realm/base_realm_data_source.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

abstract class RealmTaskDataSource extends BaseRealmDataSource {
  Future<SalespersonSchedule> checkIn({required SalespersonSchedule schedule, required CheckInArg args});

  Future<SalespersonSchedule> checkout({required SalespersonSchedule schedule, required CheckInArg args});

  Future<List<CustomerItemLedgerEntry>> getCustomerItemLedgerEntries({Map<String, dynamic>? param, int page = 1});

  Future<CustomerItemLedgerEntry?> getCustomerItemLedgerEntry({Map<String, dynamic>? args});

  Future<List<CustomerItemLedgerEntry>> submitCheckStock(List<CustomerItemLedgerEntry> customerItemLe);

  Future<List<CompetitorItemLedgerEntry>> submitCheckStockCometitorItem(List<CompetitorItemLedgerEntry> compeItemLe);

  Future<void> storeItemCheckStock({required CustomerItemLedgerEntry cile, required CheckItemStockArg arg});

  Future<List<CustomerItemLedgerEntry>> deleteItemCheckStock(CheckItemStockArg data);

  Future<List<Competitor>> getCompetitors({Map<String, dynamic>? param});
  Future<Competitor?> getCompetitor({Map<String, dynamic>? param});

  Future<List<CompetitorItem>> getCompletitorItems({Map<String, dynamic>? param, int page = 1});

  Future<List<PointOfSalesMaterial>> posms({Map<String, dynamic>? param});
  Future<List<Merchandise>> merchandises({Map<String, dynamic>? param});
  Future<CompetitorItemLedgerEntry?> detailItemCompetitorLederEntry({Map<String, dynamic>? param});

  Future<void> storeComPetitorItemLedgerEntry({
    required CompetitorItemLedgerEntry cile,
    required CheckCompititorItemStockArg arg,
  });

  Future<List<PosSalesHeader>> getPosSaleHeaders({Map<String, dynamic>? params});

  Future<PosSalesHeader?> getPosSaleHeader({Map<String, dynamic>? params});

  Future<List<PosSalesLine>> getPosSaleLines({Map<String, dynamic>? params});
  Future<PosSalesLine?> getPosSaleLine({Map<String, dynamic>? params});

  Future<void> storePosSaleHeaders(List<PosSalesHeader> salesHeaders);
  Future<void> storePosSaleHeader(PosSalesHeader saleHeader);

  Future<void> storePosSale({
    required PosSalesHeader saleHeader,
    required List<PosSalesLine> saleLines,
    bool refreshLine = true,
  });

  Future<void> processCheckout({
    required SalesHeader saleHeader,
    required List<SalesLine> saleLines,
    required PosSalesHeader posSaleHeader,
    required List<PosSalesLine> posSaleLines,
  });

  Future<List<CompetitorItemLedgerEntry>> getCompetitorItemLedgetEntry({Map<String, dynamic>? param});

  Future<List<SalespersonSchedule>> getSchedules({Map<String, dynamic>? param});
  Future<void> storeSchedules(List<SalespersonSchedule> schedules);
  Future<SalespersonSchedule?> getSchedule({Map<String, dynamic>? param});
  Future<List<CompetitorPromtionHeader>> getCompetitorPromotionHeader({Map<String, dynamic>? param, int page = 1});

  Future<List<SalesPersonScheduleMerchandise>> getSalesPersonScheduleMerchandises({Map<String, dynamic>? args});

  Future<SalesPersonScheduleMerchandise?> getSalesPersonScheduleMerchandise({Map<String, dynamic>? args});

  Future<SalesPersonScheduleMerchandise> storeSalesPersonScheduleMerchandise(
    SalesPersonScheduleMerchandise record, {
    required double quantity,
    required String status,
  });

  Future<List<SalesPersonScheduleMerchandise>> updateSalesPersonScheduleMerchandiseStatus(
    List<SalesPersonScheduleMerchandise> records, {
    required String status,
  });

  Future<void> deleteSalesPersonScheduleMerchandise(SalesPersonScheduleMerchandise record);

  Future<CustomerLedgerEntry?> getDetailCustomerLedgerEntry(Map<String, dynamic>? param);

  Future<List<PaymentMethod>> getPaymentType(Map<String, dynamic>? param);
  Future<List<PaymentTerm>> getPaymentTerms(Map<String, dynamic>? param);
  Future<PaymentTerm?> getPaymentTerm(Map<String, dynamic>? param);

  Future<void> processPayment(CashReceiptJournals record);

  Future<void> updateRemainingAmount(CustomerLedgerEntry record, double remainingAmount);

  Future<List<CashReceiptJournals>> getCashReceiptJournals(Map<String, dynamic>? param);

  Future<CashReceiptJournals?> getCashReceiptJournal(Map<String, dynamic>? param);

  Future<void> deletedPayment(CashReceiptJournals journal);

  Future<List<CashReceiptJournals>> processCashReceiptJournals(List<CashReceiptJournals> journals);

  Future<bool> deletedPosSaleLine(PosSalesLine line);
  Future<bool> deletedPosSaleHeader(String headerNo);

  Future<PaymentMethod?> getPaymentMethod({Map<String, dynamic>? param});

  Future<List<Distributor>> getDistributors(Map<String, dynamic>? param);

  Future<GeneralJournalBatch?> getGeneralJournalBatch({Map<String, dynamic>? param});

  Future<List<ItemPrizeRedemptionHeader>> getItemPrizeRedemptionHeader({Map<String, dynamic>? param});

  Future<List<ItemPrizeRedemptionLine>> getItemPrizeRedemptionLine({Map<String, dynamic>? param});

  Future<List<ItemPrizeRedemptionLineEntry>> getItemPrizeRedemptionEntries({Map<String, dynamic>? param});

  Future<List<ItemPrizeRedemptionLineEntry>> processTakeInRedemption(
    ItemPrizeRedemptionHeader header,
    List<ItemPrizeRedemptionLineEntry> entries,
    String scheduleId,
  );

  Future<bool> deleteTakeInRedemption(ItemPrizeRedemptionHeader header, String scheduleId);

  Future<bool> processSubmitRedemption(List<ItemPrizeRedemptionLineEntry> entries);

  Future<List<CompetitorPromotionLine>> getCompetitorProLine({Map<String, dynamic>? param});

  Future<bool> moveOldScheduleToCurrentDate(List<SalespersonSchedule> oldSchedules);
}
