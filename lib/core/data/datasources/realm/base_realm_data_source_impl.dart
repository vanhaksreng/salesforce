import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/data/datasources/handlers/table_handler_factory.dart';
import 'package:salesforce/core/data/datasources/realm/base_realm_data_source.dart';
import 'package:salesforce/core/data/models/extension/app_setting_extenstion.dart';
import 'package:salesforce/core/data/models/extension/application_setup_extension.dart';
import 'package:salesforce/core/data/models/extension/company_info_extension.dart';
import 'package:salesforce/core/data/models/extension/distribution_setup_extention.dart';
import 'package:salesforce/core/data/models/extension/org_extension.dart';
import 'package:salesforce/core/data/models/extension/permission_extension.dart';
import 'package:salesforce/core/data/models/extension/table_log_extension.dart';
import 'package:salesforce/core/data/models/extension/user_setup_extenstion.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:realm/realm.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class BaseRealmDataSourceImpl implements BaseRealmDataSource {
  final ILocalStorage _storage;

  BaseRealmDataSourceImpl({required ILocalStorage ils}) : _storage = ils;

  @override
  Future<void> storeAppSyncLog(List<AppSyncLog> logs) async {
    await _storage.writeTransaction((realm) {
      realm.addAll(logs, update: true);
    });
  }

  @override
  Future<List<AppSyncLog>> getAppSyncLogs({Map<String, dynamic>? arg}) async {
    return await _storage.getAll<AppSyncLog>(args: arg);
  }

  @override
  Future<void> storeInitAppData(Map<String, dynamic> args) async {
    final List<AppSyncLog> tableLogs = [];
    return _storage.writeTransaction((realm) {
      final appSetup = ApplicationSetupExtension.fromMap(args["app_setup"]);
      final company = CompanyInformationExtension.fromMap(args["company"]);
      final org = OrganizationExtension.fromMap(args["organizations"]);
      final userSetup = UserSetupExtension.fromMap(args["user_setup"]);

      final List<Permission> permissions = [];
      for (var permission in args["permissions"]) {
        permissions.add(PermissionExtension.fromMap(permission));
      }

      final List<DistributionSetUp> distributionSetUp = [];
      for (var setup in args["dist_setup"]) {
        distributionSetUp.add(DistributionSetUpExtension.fromMap(setup));
      }

      final List<AppSetting> settings = [];
      for (var setting in args["setting"]) {
        settings.add(AppSettingExtension.fromMap(setting));
      }

      try {
        for (var log in args["table_logs"]) {
          final isExisted = realm.find<AppSyncLog>(log['key']);
          if (isExisted != null) {
            isExisted.displayName = log["displayName"];
            realm.add(isExisted, update: true);
            continue;
          }

          tableLogs.add(AppSyncLogExtension.fromMap(log));
        }
      } catch (e) {
        ///
      }

      realm.add(org, update: true);
      realm.add(appSetup, update: true);
      realm.add(company, update: true);
      realm.add(userSetup, update: true);
      realm.addAll(permissions, update: true);
      realm.addAll(distributionSetUp, update: true);
      realm.addAll(settings, update: true);
      realm.addAll(tableLogs, update: true);
    });
  }

  @override
  Future<void> storeAppSetting(List<AppSetting> settings) async {
    await _storage.addAll(settings);
  }

  @override
  Future<void> storeApplicationSetup(ApplicationSetup record) async {
    await _storage.addOrUpdate(record);
  }

  @override
  Future<ApplicationSetup?> getApplicationSetup() async {
    return await _storage.getFirst<ApplicationSetup>();
  }

  @override
  Future<void> storeCompanyInfo(CompanyInformation record) async {
    final existingCompany = await _storage.getAll<CompanyInformation>();
    await _storage.writeTransaction((realm) {
      realm.deleteMany(existingCompany);

      realm.add(record);
    });
  }

  @override
  Future<CompanyInformation?> getCompanyInfo() async {
    return await _storage.getFirst<CompanyInformation>();
  }

  @override
  Future<void> storeDistributionSetup(DistributionSetUp record) async {
    await _storage.addOrUpdate(record);
  }

  @override
  Future<void> storeOrg(Organization record) async {
    await _storage.addOrUpdate(record);
  }

  @override
  Future<Organization?> getOrg() async {
    return await _storage.getFirst<Organization>();
  }

  @override
  Future<LoginSession?> getLoginSession() async {
    return await _storage.getFirst<LoginSession>();
  }

  @override
  Future<void> storeUserSetup(UserSetup user) async {
    _storage.writeTransaction((realm) {
      realm.deleteMany(realm.all<UserSetup>().toList());

      realm.add(user);
    });
  }

  @override
  Future<UserSetup?> getUserSetup({Map<String, dynamic>? param}) async {
    return await _storage.getFirst<UserSetup>(args: param);
  }

  @override
  Future<List<Item>> getItems({
    int page = 1,
    Map<String, dynamic>? param,
  }) async {
    return await _storage.getWithPagination<Item>(page: page, args: param);
  }

  @override
  Future<Item?> getItem({Map<String, dynamic>? param}) async {
    return await _storage.getFirst<Item>(args: param);
  }

  @override
  Future<void> cleanData(String tableName) async {
    final handler = TableHandlerFactory.getHandler(tableName);
    if (handler == null) {
      throw Exception('No handler found for table: $tableName');
    }

    await _storage.writeTransaction((realm) {
      handler.cleanAll(realm);
    });
  }

  @override
  Future<void> storeData<T extends RealmObject>(
    List<T> records,
    String Function(T) keyExtractor,
    String dateTime,
    String tableName, {
    bool reset = false,
  }) async {
    final syncLog = await _storage.getFirst<AppSyncLog>(
      args: {"tableName": tableName},
    );

    final handler = TableHandlerFactory.getHandler(tableName);
    if (handler == null) {
      throw Exception('No handler found for table: $tableName');
    }

    if (tableName == "item") {
      await _storage.writeTransaction((realm) {
        final objects = realm.query<ItemLedgerEntry>("quantity > 0").toList();
        realm.deleteMany(objects);
      });
    }

    await _storage.writeTransaction((realm) {
      if (reset) {
        if (tableName == "cash_receipt_journals") {
          // Don't delete anything - just let the loop handle updates
        } else {
          handler.cleanAll(realm);
        }
      }

      for (var item in records) {
        if (tableName == "item") {
          final itemCollection = item as Item;

          if (Helpers.toDouble(itemCollection.inventory) > 0) {
            realm.add(
              ItemLedgerEntry(
                Helpers.toStrings(itemCollection.no),
                "",
                "",
                Helpers.toDouble(itemCollection.inventory),
                DateTime.now().toDateString(),
              ),
              update: true,
            );
          }

          final entries = realm.query<ItemLedgerEntry>(
            'item_no == \$0 AND quantity < 0',
            [itemCollection.no],
          );

          final endingQty = entries.fold<double>(
            0,
            (sum, entry) => sum + entry.quantity,
          );

          item.inventory =
              Helpers.toDouble(itemCollection.inventory) + endingQty;

          realm.add(item, update: true);
        } else if (tableName == "cash_receipt_journals") {
          final journal = item as CashReceiptJournals;
          final status = (journal.status ?? "").toLowerCase();

          if (status == "approved") {
            final existing = realm.query<CashReceiptJournals>('id == \$0', [
              journal.id,
            ]);

            if (existing.isNotEmpty) {
              final existingJournal = existing.first;

              existingJournal.status = journal.status ?? existingJournal.status;
              existingJournal.amount = journal.amount ?? existingJournal.amount;
              existingJournal.amountLcy =
                  journal.amountLcy ?? existingJournal.amountLcy;
              existingJournal.discountAmount =
                  journal.discountAmount ?? existingJournal.discountAmount;
              existingJournal.discountAmountLcy =
                  journal.discountAmountLcy ??
                  existingJournal.discountAmountLcy;
              existingJournal.postingDate =
                  journal.postingDate ?? existingJournal.postingDate;
              existingJournal.documentNo =
                  journal.documentNo ?? existingJournal.documentNo;
              existingJournal.customerNo =
                  journal.customerNo ?? existingJournal.customerNo;
              existingJournal.isSync = "Yes";
            } else {
              realm.add(journal, update: false);
            }
          } else {
            try {
              realm.add(journal, update: true);
            } catch (e) {
              Logger.log('Error processing cash receipt journal: $e');
            }
          }
        } else {
          try {
            realm.add(item, update: true);
          } catch (e) {
            Logger.log('Error processing record: $e');
          }
        }
      }
    });

    if (syncLog != null) {
      int countRecord = await _storage.writeTransaction((realm) {
        return handler.countAll(realm);
      });

      await _storage.writeTransaction((realm) async {
        syncLog.lastSynchedDatetime = dateTime;
        syncLog.total = countRecord.toString();
        realm.add(syncLog, update: true);
      });
    }
  }

  @override
  Future<void> createSchedules(List<SalespersonSchedule> data) async {
    try {
      await _storage.addAll(data);
    } catch (error) {
      throw GeneralException("Something went wrong");
    }
  }

  @override
  Future<List<Permission>> getPermissions({Map<String, dynamic>? param}) async {
    return await _storage.getAll<Permission>(args: param);
  }

  @override
  Future<Permission?> getPermission({Map<String, dynamic>? param}) async {
    return await _storage.getFirst<Permission>(args: param);
  }

  @override
  Future<DistributionSetUp?> getSetting(String id) async {
    return _storage.find<DistributionSetUp>(id);
  }

  @override
  Future<List<PromotionType>> getPromotionType({
    Map<String, dynamic>? param,
  }) async {
    return await _storage.getAll<PromotionType>(args: param);
  }

  @override
  Future<VatPostingSetup?> getVatSetup({Map<String, dynamic>? param}) async {
    return await _storage.getFirst<VatPostingSetup>(args: param);
  }

  @override
  Future<PosSalesHeader?> getPosSaleHeader({
    Map<String, dynamic>? params,
  }) async {
    try {
      return await _storage.getFirst<PosSalesHeader>(args: params);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<SalesHeader>> updateSales({
    required List<SalesHeader> saleHeaders,
    required List<SalesHeader> remoteSaleHeaders,
    required List<SalesLine> remoteLines,
  }) async {
    final headerNo = saleHeaders.map((h) => '"${h.no}"').toList();
    return _storage.writeTransaction((realm) {
      final localLinesToDelete = realm.query<SalesLine>(
        'document_no IN {${headerNo.join(",")}}',
      );

      realm.deleteMany(localLinesToDelete);

      // Delete headers
      final headersToDelete = realm.query<SalesHeader>(
        'no IN {${headerNo.join(",")}}',
      );

      realm.deleteMany(headersToDelete);

      // Add new data
      for (var r in remoteSaleHeaders) {
        r.isSync = kStatusYes;
        realm.add(r);
      }

      for (var l in remoteLines) {
        l.isSync = kStatusYes;
        realm.add(l);
      }

      return remoteSaleHeaders;
    });
  }

  @override
  Future<List<CashReceiptJournals>> updateCashJournalStatus(
    List<CashReceiptJournals> journals, {
    required List<CashReceiptJournals> remoteJournals,
  }) async {
    return _storage.writeTransaction((realm) {
      realm.deleteMany(journals);

      for (var r in remoteJournals) {
        r.isSync = kStatusYes;
        realm.add(r);
      }

      return remoteJournals;
    });
  }

  @override
  Future<List<SalespersonSchedule>> updateSalepersonScheduleLastSyncDate(
    List<SalespersonSchedule> schedules,
  ) async {
    
    final now = DateTime.now().toDateTimeString();
    return await _storage.writeTransaction((realm) {
      for (var schedule in schedules) {
        schedule.updatedAt = now;
        realm.add(schedule, update: true);
      }

      return schedules;
    });
  }

  @override
  Future<List<SalesPersonScheduleMerchandise>> updateScheduleMerchandiseStatus(
    List<SalesPersonScheduleMerchandise> schedules, {
    required List<SalesPersonScheduleMerchandise> remoteSchedules,
  }) async {
    return await _storage.writeTransaction((realm) {
      realm.deleteMany(schedules);

      for (var r in remoteSchedules) {
        r.isSync = kStatusYes;
        realm.add(r);
      }

      return remoteSchedules;
    });
  }

  @override
  Future<List<CustomerItemLedgerEntry>> updateCheckedStockStatus(
    List<CustomerItemLedgerEntry> records, {
    required List<CustomerItemLedgerEntry> remoteRecords,
  }) async {
    return await _storage.writeTransaction((realm) {
      realm.deleteMany(records);

      for (var r in remoteRecords) {
        r.isSync = kStatusYes;
        realm.add(r);
      }

      return remoteRecords;
    });
  }

  @override
  Future<List<CompetitorItemLedgerEntry>> updateCheckedCompititorStockStatus(
    List<CompetitorItemLedgerEntry> records, {
    required List<CompetitorItemLedgerEntry> remoteRecords,
  }) async {
    return await _storage.writeTransaction((realm) {
      realm.deleteMany(records);

      for (var r in remoteRecords) {
        r.isSync = kStatusYes;
        realm.add(r);
      }

      return remoteRecords;
    });
  }

  @override
  Future<List<Customer>> getCustomers({
    int page = 1,
    Map<String, dynamic>? params,
  }) async {
    return await _storage.getWithPagination<Customer>(page: page, args: params);
  }

  @override
  Future<Customer?> getCustomer({Map<String, dynamic>? params}) async {
    return await _storage.getFirst<Customer>(args: params);
  }

  @override
  Future<ItemSalesLinePrices?> getItemSaleLinePrice({
    Map<String, dynamic>? param,
  }) async {
    return await _storage.getFirst<ItemSalesLinePrices>(
      args: param,
      // sortBy: [
      //   {"field": "startingDate", "order": "DESC"},
      //   {"field": "minimumQuantity", "order": "DESC"},
      // ],
      sortBy: [
        {"startingDate": "DESC"},
        {"minimumQuantity": "DESC"},
      ],
    );
  }

  @override
  Future<ItemUnitOfMeasure?> getItemUom({Map<String, dynamic>? params}) async {
    return _storage.getFirst<ItemUnitOfMeasure>(args: params);
  }

  @override
  Future<List<ItemUnitOfMeasure>> getItemUoms({
    Map<String, dynamic>? params,
  }) async {
    return _storage.getAll<ItemUnitOfMeasure>(args: params);
  }

  @override
  Future<List<CustomerLedgerEntry>> getCustomerLedgerEntry(
    Map<String, dynamic>? param,
  ) async {
    return await _storage.getAll<CustomerLedgerEntry>(args: param);
  }

  @override
  Future<CustomerAddress?> getCustomerAddress({
    Map<String, dynamic>? args,
  }) async {
    return await _storage.getFirst<CustomerAddress>(args: args);
  }

  @override
  Future<List<CustomerAddress>> getCustomerAddresses({
    Map<String, dynamic>? args,
  }) async {
    return await _storage.getAll<CustomerAddress>(args: args);
  }

  @override
  Future<List<Salesperson>> getSalespersons({
    Map<String, dynamic>? args,
  }) async {
    return await _storage.getAll<Salesperson>(args: args);
  }

  @override
  Future<Salesperson?> getSalesperson({Map<String, dynamic>? args}) async {
    return await _storage.getFirst<Salesperson>(args: args);
  }

  @override
  Future<SalesHeader?> getSaleHeader({Map<String, dynamic>? args}) async {
    return await _storage.getFirst<SalesHeader>(args: args);
  }

  @override
  Future<List<SalesHeader>> getSaleHeaders({
    int page = 1,
    List<dynamic>? sortBy,
    Map<String, dynamic>? args,
  }) async {
    return await _storage.getWithPagination<SalesHeader>(
      args: args,
      sortBy: [
        {"posting_date": "desc"},
      ],
      page: page,
    );
  }

  @override
  Future<SalesLine?> getSaleLine({Map<String, dynamic>? args}) async {
    return await _storage.getFirst<SalesLine>(args: args);
  }

  @override
  Future<List<SalesLine>> getSaleLines({Map<String, dynamic>? args}) async {
    return await _storage.getAll<SalesLine>(args: args);
  }

  @override
  Future<List<ItemPromotionHeader>> getItemPromotionHeaders({
    Map<String, dynamic>? args,
  }) async {
    return await _storage.getAll<ItemPromotionHeader>(args: args);
  }

  @override
  Future<List<ItemPromotionLine>> getItemPromotionLines({
    Map<String, dynamic>? args,
  }) async {
    return await _storage.getAll<ItemPromotionLine>(args: args);
  }

  @override
  Future<ItemPromotionScheme?> getPromotionScheme({
    Map<String, dynamic>? args,
  }) async {
    return await _storage.getFirst<ItemPromotionScheme>(args: args);
  }

  @override
  Future<List<GpsTrackingEntry>> getGPSTrackingEntries({
    required Map<String, dynamic> param,
  }) async {
    return await _storage.getAll<GpsTrackingEntry>(args: param);
  }

  @override
  Future<List<ItemPrizeRedemptionLineEntry>> updateRedemptionsStatus(
    List<ItemPrizeRedemptionLineEntry> records, {
    required List<ItemPrizeRedemptionLineEntry> remoteRecords,
  }) async {
    return await _storage.writeTransaction((realm) {
      realm.deleteMany(records);

      for (var r in remoteRecords) {
        r.isSync = kStatusYes;
        realm.add(r);
      }

      return remoteRecords;
    });
  }

  @override
  Future<void> storeLocationOffline(GpsRouteTracking cusOffline) async {
    await _storage.add<GpsRouteTracking>(cusOffline);
  }

  @override
  Future<List<GpsRouteTracking>> getGPSRouteTracking({
    required Map<String, dynamic> param,
  }) async {
    return await _storage.getAll<GpsRouteTracking>(args: param);
  }

  @override
  Future<void> updateTrackingByCreatedDate(
    List<GpsRouteTracking> records,
  ) async {
    final today = DateTime.now().toDateString();

    await _storage.writeTransaction((realm) {
      for (var record in records) {
        record.isSync = kStatusYes;
        realm.add(record, update: true);
      }
    });

    final existed = await _storage.getAll<GpsRouteTracking>(
      args: {'is_sync': kStatusYes, 'created_date': '<> $today'},
    );

    await _storage.writeTransaction((realm) {
      realm.deleteMany(existed);
    });
  }

  @override
  Future<bool> clearAllData(List<AppSyncLog> tables) async {
    return _storage.writeTransaction((realm) {
      for (final table in tables) {
        try {
          final handler = TableHandlerFactory.getHandler(table.tableName);
          if (handler == null) {
            throw Exception('No handler found for table: ${table.tableName}');
          }

          table.lastSynchedDatetime = null;
          realm.add(table, update: true);

          handler.cleanAll(realm);
        } catch (_) {
          //
        }
      }

      realm.deleteMany(realm.all<SalesPersonScheduleLog>().toList());
      realm.deleteMany(realm.all<SalespersonSchedule>().toList());
      realm.deleteMany(realm.all<GpsTrackingEntry>().toList());
      realm.deleteMany(realm.all<GpsRouteTracking>().toList());
      realm.deleteMany(realm.all<Organization>().toList());
      realm.deleteMany(realm.all<CompanyInformation>().toList());
      realm.deleteMany(realm.all<ItemLedgerEntry>().toList());
      realm.deleteMany(realm.all<SalesHeader>().toList());
      realm.deleteMany(realm.all<SalesLine>().toList());
      realm.deleteMany(realm.all<Permission>().toList());
      realm.deleteMany(realm.all<DistributionSetUp>().toList());
      realm.deleteMany(realm.all<CompetitorItemLedgerEntry>().toList());
      realm.deleteMany(realm.all<ItemStockRequestWorkSheet>().toList());

      return true;
    });
  }

  @override
  Future<GpsRouteTracking?> getLastGpsRequest() async {
    return await _storage.getFirst<GpsRouteTracking>(
      args: {'created_date': DateTime.now().toDateString()},
      sortBy: [
        {"field": "created_time", "order": "DESC"},
      ],
    );
  }

  @override
  Future<bool> storeGps(List<GpsRouteTracking> records) async {
    return _storage.writeTransaction((realm) {
      realm.addAll(records);

      return true;
    });
  }

  @override
  Future<bool> updateStatusGPSTrackingEntries({
    required List<GpsTrackingEntry> records,
  }) async {
    return _storage.writeTransaction((realm) {
      for (var record in records) {
        record.isSync = kStatusYes;
        realm.add(record, update: true);
      }

      return true;
    });
  }
}
