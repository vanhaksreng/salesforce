import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:realm/realm.dart';
import 'package:path/path.dart' as path;
import 'package:salesforce/env.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class RealmConfig {
  static Realm? _realm;

  static Future<Realm> getRealmInstance() async {
    if (_realm == null) {
      final config = await getConfig();
      _realm = Realm(config); // Open Realm only once
    }
    return _realm!;
  }

  static Future<Configuration> getConfig() async {
    final documents = await getApplicationDocumentsDirectory();
    String realmPath = path.join(documents.path, 'ClearViewSalesforce.realm');

    if (kDebugMode && Platform.isIOS && kDbPath.isNotEmpty) {
      realmPath = kDbPath;
    }

    // if (Platform.isAndroid) {
    //   final external = await getExternalStorageDirectory();

    //   final copiedPath = path.join(external!.path, 'ClearViewSalesforce.realm');
    //   final copiedFile = File(copiedPath);
    //   if (copiedFile.existsSync()) {
    //     copiedFile.deleteSync();
    //   }
    // }

    var config = Configuration.local(
      [
        AppServer.schema,
        AppSetting.schema,
        AppSyncLog.schema,
        ApplicationSetup.schema,
        BankAccount.schema,
        CashReceiptJournals.schema,
        CompanyInformation.schema,
        Competitor.schema,
        CompetitorItem.schema,
        CompetitorItemLedgerEntry.schema,
        CompetitorPromtionHeader.schema,
        CompetitorPromotionLine.schema,
        Currency.schema,
        CurrencyExchangeRate.schema,
        Customer.schema,
        CustomerAddress.schema,
        CustomerItemLedgerEntry.schema,
        CustomerLedgerEntry.schema,
        DistributionSetUp.schema,
        Distributor.schema,
        GeneralJournalBatch.schema,
        GpsTrackingEntry.schema,
        Item.schema,
        ItemGroup.schema,
        ItemJournalBatch.schema,
        ItemPrizeRedemptionLineEntry.schema,
        ItemPrizeRedemptionHeader.schema,
        ItemPrizeRedemptionLine.schema,
        ItemPromotionHeader.schema,
        ItemPromotionLine.schema,
        ItemPromotionScheme.schema,
        ItemSalesLineDiscount.schema,
        ItemSalesLinePrices.schema,
        ItemStockRequestWorkSheet.schema,
        ItemUnitOfMeasure.schema,
        ItemLedgerEntry.schema,
        Location.schema,
        LoginSession.schema,
        Merchandise.schema,
        Organization.schema,
        PaymentMethod.schema,
        PaymentTerm.schema,
        Permission.schema,
        PointOfSalesMaterial.schema,
        PosSalesHeader.schema,
        PosSalesLine.schema,
        PromotionType.schema,
        SalesHeader.schema,
        SalesLine.schema,
        SalesPersonScheduleLog.schema,
        SalesPersonScheduleMerchandise.schema,
        Salesperson.schema,
        SalespersonSchedule.schema,
        SubContractType.schema,
        TmpSalesShipmentPlaning.schema,
        UserSetup.schema,
        VatPostingSetup.schema,
        GpsRouteTracking.schema,
      ],
      path: realmPath,
      schemaVersion: 1,
      shouldDeleteIfMigrationNeeded: false,
      migrationCallback: _performMigration,
    );

    return config;
  }

  static void _performMigration(Migration migration, int oldSchemaVersion) {
    // Migration from Version 1 to 2
    if (oldSchemaVersion < 2) {
      _migrateToVersion2(migration);
    }

    // Migration from Version 2 to 3
    if (oldSchemaVersion < 3) {
      _migrateToVersion3(migration);
    }
  }

  static void _migrateToVersion2(Migration migration) {
    //
  }

  static void _migrateToVersion3(Migration migration) {}
}
