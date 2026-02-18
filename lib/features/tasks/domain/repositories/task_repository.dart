import 'package:dartz/dartz.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/features/tasks/domain/entities/app_version.dart';
import 'package:salesforce/features/tasks/domain/entities/checkout_arg.dart';
import 'package:salesforce/features/tasks/domain/entities/promotion_line_entity.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

abstract class TaskRepository extends BaseAppRepository {
  Future<Either<Failure, List<SalesPersonScheduleMerchandise>>>
  getSalesPersonScheduleMerchandises({Map<String, dynamic>? param});

  Future<Either<Failure, List<SalespersonSchedule>>> getSchedules(
    String visitDate, {
    bool requestApi = true,
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, List<SalespersonSchedule>>> getLocalSchedules({
    Map<String, dynamic>? param,
  });

  Future<void> cleanupSchedules();

  Future<Either<Failure, SalespersonSchedule?>> getSchedule({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, SalespersonSchedule>> checkIn({
    required SalespersonSchedule schedule,
    required CheckInArg args,
  });

  Future<Either<Failure, SalespersonSchedule>> checkout({
    required SalespersonSchedule schedule,
    required CheckInArg args,
  });

  Future<Either<Failure, List<CustomerItemLedgerEntry>>>
  getCustomerItemLegerEntries({Map<String, dynamic>? param, int page = 1});

  Future<Either<Failure, CustomerItemLedgerEntry?>> getCustomerItemLedgerEntry({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, CustomerItemLedgerEntry>> updateItemCheckStock(
    CheckItemStockArg data,
  );

  Future<Either<Failure, List<CustomerItemLedgerEntry>>> deleteItemCheckStock(
    CheckItemStockArg data,
  );

  Future<Either<Failure, CompetitorItemLedgerEntry>>
  updateCompititorItemLedgerEntry(CheckCompititorItemStockArg data);

  Future<Either<Failure, List<CustomerItemLedgerEntry>>> submitCheckStock(
    List<CustomerItemLedgerEntry> records,
  );

  Future<Either<Failure, List<CompetitorItemLedgerEntry>>>
  submitCheckStockCometitorItem(List<CompetitorItemLedgerEntry> records);

  Future<Either<Failure, List<Merchandise>>> merchandises({
    Map<String, dynamic>? param,
    int page = 1,
  });

  Future<Either<Failure, List<PointOfSalesMaterial>>> posms({
    Map<String, dynamic>? param,
    int page = 1,
  });

  Future<Either<Failure, List<Competitor>>> getCompetitors({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, ItemSalesLinePrices?>> getItemSaleLinePrice({
    required String itemNo,
    required String saleType,
    String orderQty = "1",
    String? saleCode,
    String uomCode = "",
  });

  Future<Either<Failure, List<PromotionType>>> getPromotionType();

  Future<Either<Failure, Customer?>> getCustomer({required String no});

  Future<Either<Failure, bool>> insertSale(SaleArg saleArg);

  Future<Either<Failure, bool>> createSchedules(Map data);

  Future<Either<Failure, CustomerAddress?>> getCustomerAddress({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<CustomerAddress>>> getCustomerAddresses({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<CompetitorItem>>> getCompletitorItems({
    Map<String, dynamic>? params,
    int page = 1,
  });

  Future<Either<Failure, List<PosSalesLine>>> getPosSaleLines({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, PosSalesLine?>> getPosSaleLine({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, PosSalesHeader>> getPosSaleHeader({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<PosSalesHeader>>> getPosSaleHeaders({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<SalesHeader>>> getSaleHeaders({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<SalesLine>>> getSaleLines({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, SalesLine?>> getSaleLine({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, CompetitorItemLedgerEntry?>>
  detailItemCompetitorLederEntry({
    required String itemNo,
    required String visitNo,
  });

  Future<Either<Failure, List<CompetitorItemLedgerEntry>>>
  getCompetitorItemLedgetEntry({Map<String, dynamic>? param});

  Future<Either<Failure, List<CompetitorPromtionHeader>>>
  getCompetitorPromotionHeader({Map<String, dynamic>? param, int page = 1});

  Future<Either<Failure, SalesPersonScheduleMerchandise>>
  storeSalesPersonScheduleMerchandise({
    required ItemPosmAndMerchandiseArg args,
  });

  Future<Either<Failure, void>> deleteSalesPersonScheduleMerchandise(
    SalesPersonScheduleMerchandise record,
  );

  Future<Either<Failure, List<SalesPersonScheduleMerchandise>>>
  updateSalesPersonScheduleMerchandiseStatus(
    List<SalesPersonScheduleMerchandise> records, {
    required String status,
  });

  Future<Either<Failure, List<CustomerLedgerEntry>>> getCustomerLedgerEntry({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, CustomerLedgerEntry?>> getDetailCustomerLedgerEntry({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, CashReceiptJournals?>> getCashReceiptJournal({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, List<CashReceiptJournals>>> getCashReceiptJournals({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, List<PaymentMethod>>> getPaymentType({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, List<PaymentTerm>>> getPaymentTerms({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, PaymentTerm?>> getPaymentTerm({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, CashReceiptJournals>> processPayment({
    required PaymentArg arg,
  });

  Future<Either<Failure, bool>> deletedPayment(
    CashReceiptJournals journal,
    CustomerLedgerEntry cEntry,
  );

  Future<Either<Failure, List<CashReceiptJournals>>> processCashReceiptJournals(
    List<CashReceiptJournals> journals,
  );

  Future<Either<Failure, PaymentMethod?>> getPaymentMethod({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, bool>> deletedPosSaleLine(PosSalesLine line);

  Future<Either<Failure, bool>> deletedPosSaleHeader(String headerNo);

  Future<Either<Failure, List<Distributor>>> getDistributors({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, bool>> processCheckout(CheckoutSubmitArg arg);

  Future<Either<Failure, List<ItemPrizeRedemptionHeader>>>
  getItemPrizeRedemptionHeader({Map<String, dynamic>? param});

  Future<Either<Failure, List<ItemPrizeRedemptionLine>>>
  getItemPrizeRedemptionLine({Map<String, dynamic>? param});

  Future<Either<Failure, List<ItemPrizeRedemptionLineEntry>>>
  getItemPrizeRedemptionEntries({Map<String, dynamic>? param});

  Future<Either<Failure, bool>> addItemPromotionToCart({
    required List<PromotionLineEntity> records,
    required SalespersonSchedule schedule,
    required String documentType,
    required double orderQty,
  });

  Future<Either<Failure, List<ItemPrizeRedemptionLineEntry>>>
  processTakeInRedemption({
    required ItemPrizeRedemptionHeader header,
    required SalespersonSchedule schedule,
    required double quantity,
  });

  Future<Either<Failure, bool>> processSubmitRedemption(
    List<ItemPrizeRedemptionLineEntry> entries,
  );

  Future<Either<Failure, bool>> deleteTakeInRedemption(
    ItemPrizeRedemptionHeader header,
    String scheduleId,
  );

  Future<Either<Failure, List<CompetitorPromotionLine>>> getCompetitorProLine({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, AppVersion?>> checkAppVersion({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, bool>> moveOldScheduleToCurrentDate(
    List<SalespersonSchedule> oldSchedules,
  );
  Future<Either<Failure, List<SalePersonGpsModel>>> getSalepersonGps();
  Future<Either<Failure, List<SalespersonSchedule>>> getTeamSchedules({
    Map<String, dynamic>? param,
  });
  
}
