import 'package:realm/realm.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

abstract class BaseRealmDataSource {
  Future<void> storeAppSetting(List<AppSetting> settings);

  Future<void> storeAppSyncLog(List<AppSyncLog> logs);
  Future<List<AppSyncLog>> getAppSyncLogs({Map<String, dynamic>? arg});

  Future<LoginSession?> getLoginSession();

  Future<void> storeUserSetup(UserSetup user);
  Future<UserSetup?> getUserSetup({Map<String, dynamic>? param});

  Future<void> storeCompanyInfo(CompanyInformation record);
  Future<CompanyInformation?> getCompanyInfo();

  Future<void> storeDistributionSetup(DistributionSetUp record);

  Future<void> storeOrg(Organization record);
  Future<Organization?> getOrg();

  Future<void> storeApplicationSetup(ApplicationSetup user);
  Future<ApplicationSetup?> getApplicationSetup();

  Future<List<Item>> getItems({int page = 1, Map<String, dynamic>? param});

  Future<Item?> getItem({Map<String, dynamic>? param});

  Future<void> createSchedules(List<SalespersonSchedule> schedules);

  Future<void> cleanData(String tableName);
  Future<void> storeData<T extends RealmObject>(
    List<T> records,
    String Function(T) keyExtractor,
    String dateTime,
    String tableName, {
    bool reset = false,
  });

  Future<List<Permission>> getPermissions({Map<String, dynamic>? param});
  Future<Permission?> getPermission({Map<String, dynamic>? param});
  Future<DistributionSetUp?> getSetting(String id);

  Future<void> storeInitAppData(Map<String, dynamic> args);

  Future<List<Customer>> getCustomers({
    int page = 1,
    Map<String, dynamic>? params,
  });

  Future<Customer?> getCustomer({Map<String, dynamic>? params});

  Future<List<PromotionType>> getPromotionType({Map<String, dynamic>? param});

  Future<VatPostingSetup?> getVatSetup({Map<String, dynamic>? param});

  Future<ItemSalesLinePrices?> getItemSaleLinePrice({
    Map<String, dynamic>? param,
  });

  Future<CustomerAddress?> getCustomerAddress({Map<String, dynamic>? args});

  Future<List<CustomerAddress>> getCustomerAddresses({
    Map<String, dynamic>? args,
  });

  Future<ItemUnitOfMeasure?> getItemUom({Map<String, dynamic>? params});
  Future<List<ItemUnitOfMeasure>> getItemUoms({Map<String, dynamic>? params});

  Future<List<Salesperson>> getSalespersons({Map<String, dynamic>? args});

  Future<Salesperson?> getSalesperson({Map<String, dynamic>? args});

  Future<List<CustomerLedgerEntry>> getCustomerLedgerEntry(
    Map<String, dynamic>? param,
  );

  Future<List<ItemPromotionHeader>> getItemPromotionHeaders({
    Map<String, dynamic>? args,
  });

  Future<List<ItemPromotionLine>> getItemPromotionLines({
    Map<String, dynamic>? args,
  });

  Future<ItemPromotionScheme?> getPromotionScheme({Map<String, dynamic>? args});

  Future<SalesLine?> getSaleLine({Map<String, dynamic>? args});
  Future<SalesHeader?> getSaleHeader({Map<String, dynamic>? args});
  Future<List<SalesLine>> getSaleLines({Map<String, dynamic>? args});
  Future<List<SalesHeader>> getSaleHeaders({
    int page = 1,
    Map<String, dynamic>? args,
  });

  Future<List<SalesHeader>> updateSales({
    required List<SalesHeader> saleHeaders,
    required List<SalesHeader> remoteSaleHeaders,
    required List<SalesLine> remoteLines,
  });

  Future<List<CashReceiptJournals>> updateCashJournalStatus(
    List<CashReceiptJournals> journals, {
    required List<CashReceiptJournals> remoteJournals,
  });

  Future<List<SalespersonSchedule>> updateSalepersonScheduleLastSyncDate(
    List<SalespersonSchedule> schedules,
  );
  Future<List<ItemPrizeRedemptionLineEntry>> updateRedemptionsStatus(
    List<ItemPrizeRedemptionLineEntry> records, {
    required List<ItemPrizeRedemptionLineEntry> remoteRecords,
  });

  Future<List<SalesPersonScheduleMerchandise>> updateScheduleMerchandiseStatus(
    List<SalesPersonScheduleMerchandise> schedules, {
    required List<SalesPersonScheduleMerchandise> remoteSchedules,
  });

  Future<List<CustomerItemLedgerEntry>> updateCheckedStockStatus(
    List<CustomerItemLedgerEntry> records, {
    required List<CustomerItemLedgerEntry> remoteRecords,
  });

  Future<List<CompetitorItemLedgerEntry>> updateCheckedCompititorStockStatus(
    List<CompetitorItemLedgerEntry> records, {
    required List<CompetitorItemLedgerEntry> remoteRecords,
  });

  Future<void> storeLocationOffline(GpsRouteTracking cusOffline);

  Future<List<GpsRouteTracking>> getGPSRouteTracking({
    required Map<String, dynamic> param,
  });

  Future<List<GpsTrackingEntry>> getGPSTrackingEntries({
    required Map<String, dynamic> param,
  });

  Future<bool> updateStatusGPSTrackingEntries({
    required List<GpsTrackingEntry> records,
  });

  Future<void> updateTrackingByCreatedDate(List<GpsRouteTracking> records);
  Future<bool> clearAllData(List<AppSyncLog> tables);

  Future<GpsRouteTracking?> getLastGpsRequest();
  Future<bool> storeGps(List<GpsRouteTracking> records);

  Future<PosSalesHeader?> getPosSaleHeader({Map<String, dynamic>? params});
}
