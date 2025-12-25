import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/data/datasources/realm/base_realm_data_source_impl.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/features/tasks/data/datasources/realm/realm_task_data_source.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class RealmTaskDataSourceImpl extends BaseRealmDataSourceImpl
    implements RealmTaskDataSource {
  final ILocalStorage _storage;

  RealmTaskDataSourceImpl({required super.ils}) : _storage = ils;

  @override
  Future<void> storeItemCheckStock({
    required CustomerItemLedgerEntry cile,
    required CheckItemStockArg arg,
  }) async {
    try {
      final qtyCount = Helpers.toDouble(arg.stockQty);
      final qtyPerUnit = Helpers.toDouble(cile.qtyPerUnitOfMeasure);

      await _storage.writeTransaction((realm) {
        if (!arg.updateOnlyQty) {
          cile.expirationDate = DateTimeExt.parse(
            arg.expirationDate,
          ).toDateString();
          cile.plannedQuantity = Helpers.toDouble(arg.plannedQuantity);
          cile.plannedQuantityBase =
              Helpers.toDouble(arg.plannedQuantity) * qtyPerUnit;
          cile.plannedQuantityReturn = Helpers.toDouble(
            arg.plannedQuantityReturn,
          );
          cile.plannedQuantityReturnBase =
              Helpers.toDouble(arg.plannedQuantityReturn) * qtyPerUnit;
          cile.quantityBuyFromOther = Helpers.toDouble(
            arg.quantityBuyFromOther,
          );
          cile.quantityBuyFromOtherBase =
              Helpers.toDouble(arg.quantityBuyFromOther) * qtyPerUnit;
          cile.lotNo = Helpers.toStrings(arg.lotNo);
          cile.serialNo = Helpers.toStrings(arg.serialNo);
          cile.remark = Helpers.toStrings(arg.remark);
        }

        cile.countingDate = DateTime.now().toDateString();
        cile.quantity = qtyCount;
        cile.quantityBase = qtyCount * qtyPerUnit;

        realm.add(cile, update: true);
        return "Success";
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CustomerItemLedgerEntry>> submitCheckStock(
    List<CustomerItemLedgerEntry> cile,
  ) async {
    try {
      return _storage.writeTransaction((realm) {
        for (var record in cile) {
          record.status = "Submitted";
          record.isSync = "No";
        }

        return cile;
      });
    } catch (e) {
      return [];
    }
  }

  @override
  Future<List<CompetitorItemLedgerEntry>> submitCheckStockCometitorItem(
    List<CompetitorItemLedgerEntry> cile,
  ) async {
    try {
      return _storage.writeTransaction((realm) {
        for (var record in cile) {
          record.status = kStatusSubmit;
          record.isSync = "No";
        }

        return cile;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CustomerItemLedgerEntry>> deleteItemCheckStock(
    CheckItemStockArg data,
  ) async {
    final record = await _storage.getFirst<CustomerItemLedgerEntry>(
      args: {"itemNo": data.item.no},
    );

    if (record != null) {
      await _storage.delete(record);
    }

    final remainingRecords = await _storage.getAll<CustomerItemLedgerEntry>();

    return remainingRecords;
  }

  @override
  Future<List<SalespersonSchedule>> getSchedules({
    Map<String, dynamic>? param,
  }) async {
    try {
      return await _storage.getAll<SalespersonSchedule>(args: param);
    } catch (error) {
      return [];
    }
  }

  @override
  Future<void> storeSchedules(List<SalespersonSchedule> schedules) async {
    try {
      _storage.addAll(schedules);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SalespersonSchedule> checkIn({
    required SalespersonSchedule schedule,
    required CheckInArg args,
    required String internetStatus,
  }) async {
    try {
      final saleperson = await _storage.getFirst<Salesperson>(
        args: {"code": schedule.salespersonCode},
      );

      if (saleperson == null) {
        throw GeneralException(
          "Salesperson code [${schedule.salespersonCode}] not found. Please download the master data to ensure your data is up to date.",
        );
      }

      final auth = getAuth();

      final now = DateTime.now();
      final int docNo = Helpers.generateUniqueNumber();
      final String formattedDate = now.toDateString();
      final String formattedTime = now.toTime24String();

      return await _storage.writeTransaction((realm) {
        //UPDATE SCHEDULE
        schedule
          ..actualLatitude = args.latitude
          ..actualLongitude = args.longitude
          ..status = args.isCloseShop ? kStatusCheckOut : kStatusCheckIn
          ..startingTime = formattedTime
          ..statusInternetCheckIn = internetStatus
          ..checkInPosition = args.checkInPosition;

        if (args.comment.isNotEmpty) {
          schedule.checkInRemark = args.comment;
          if (args.isCloseShop) {
            schedule.checkOutRemark = args.comment;
          }
        }

        final imagePath = args.imagePath?.path ?? "";
        if (imagePath.isNotEmpty) {
          schedule.checkInImage = imagePath;
        }

        if (args.isCloseShop) {
          schedule.shopIsClosed = kStatusYes;
          schedule.endingTime = formattedTime;
          schedule.statusInternetCheckOut = internetStatus;
          schedule.duration = Helpers.calculateDuration(
            schedule.startingTime ?? "00.00.00",
            formattedTime,
          );
          schedule.checkInPosition = args.checkInPosition;
        }

        // STORE GPS ENTRY
        if (args.latitude != 0.0 && args.latitude != 0.0) {
          final gpsTracking = GpsTrackingEntry(
            docNo,
            appId: docNo.toString(),
            username: auth?.email,
            salespersonCode: schedule.salespersonCode,
            fullName: auth?.userName,
            salespersonName: saleperson.name,
            salespersonName2: saleperson.name2,
            trackingDate: now.toDateString(),
            trackingDatetime: now.toDateTimeString(),
            type: "Sales",
            documentType: args.isCloseShop ? kStatusCheckOut : kStatusCheckIn,
            documentNo: schedule.id,
            customerNo: schedule.customerNo,
            customerName: schedule.name,
            customerNname2: schedule.name2,
            latitude: Helpers.toDouble(args.latitude),
            longitude: Helpers.toDouble(args.longitude),
            sourceType: "Visit",
            isSync: "No",
          );

          realm.add(gpsTracking);

          final gpsRoute = GpsRouteTracking(
            schedule.salespersonCode ?? "",
            Helpers.toDouble(args.latitude),
            Helpers.toDouble(args.longitude),
            now.toDateString(),
            now.toTimeString(),
            isSync: kStatusNo,
          );

          realm.add(gpsRoute);
        }

        realm.add(
          SalesPersonScheduleLog(
            Helpers.generateDocumentNo("${auth?.id ?? 1}"),
            visitNo: schedule.id,
            logType: schedule.status,
            logDate: now.toDateTimeString(),
            createAt: formattedDate,
            description: schedule.checkInRemark,
            userId: auth?.id ?? '',
          ),
        );

        realm.add(schedule, update: true);

        return schedule;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<SalespersonSchedule> checkout({
    required SalespersonSchedule schedule,
    required CheckInArg args,
    required String internetStatus,
  }) async {
    try {
      final auth = getAuth();

      final now = DateTime.now();
      final int docNo = Helpers.generateUniqueNumber();
      final String formattedDate = now.toDateString();
      final String formattedTime = now.toTime24String();

      final saleperson = await _storage.getFirst<Salesperson>(
        args: {"code": schedule.salespersonCode},
      );

      if (saleperson == null) {
        throw GeneralException(
          "Salesperson code [${schedule.salespersonCode}] not found. Please download the master data to ensure your data is up to date.",
        );
      }

      return await _storage.writeTransaction((realm) {
        //UPDATE SCHEDULE
        schedule
          ..status = kStatusCheckOut
          ..endingTime = formattedTime
          ..checkOutRemark = args.comment
          ..statusInternetCheckOut = internetStatus
          ..duration = Helpers.calculateDuration(
            schedule.startingTime ?? "00.00.00",
            formattedTime,
          )
          ..checkOutPosition = args.checkOutPosition;
        final imagePath = args.imagePath?.path ?? "";
        if (imagePath.isNotEmpty) {
          schedule.checkOutImage = imagePath;
        }

        // STORE GPS ENTRY
        if (args.latitude != 0.0 && args.latitude != 0.0) {
          final gpsTracking = GpsTrackingEntry(
            docNo,
            appId: docNo.toString(),
            username: auth?.email,
            salespersonCode: schedule.salespersonCode,
            fullName: auth?.userName,
            salespersonName: saleperson.name,
            salespersonName2: saleperson.name2,
            trackingDate: now.toDateString(),
            trackingDatetime: now.toDateTimeString(),
            type: "Sales",
            documentType: kStatusCheckOut,
            documentNo: schedule.id,
            customerNo: schedule.customerNo,
            customerName: schedule.name,
            customerNname2: schedule.name2,
            latitude: Helpers.toDouble(args.latitude),
            longitude: Helpers.toDouble(args.longitude),
            sourceType: "Visit",
            isSync: "No",
          );

          realm.add(gpsTracking);

          final gpsRoute = GpsRouteTracking(
            schedule.salespersonCode ?? "",
            Helpers.toDouble(args.latitude),
            Helpers.toDouble(args.longitude),
            now.toDateString(),
            now.toTimeString(),
            isSync: kStatusNo,
          );

          realm.add(gpsRoute);
        }

        realm.add(
          SalesPersonScheduleLog(
            Helpers.generateDocumentNo("${auth?.id ?? 1}"),
            visitNo: schedule.id,
            logType: schedule.status,
            logDate: now.toDateTimeString(),
            createAt: formattedDate,
            description: schedule.checkOutRemark,
            userId: auth?.id ?? '',
          ),
        );

        realm.add(schedule, update: true);

        return schedule;
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CustomerItemLedgerEntry>> getCustomerItemLedgerEntries({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      return await _storage.getAll<CustomerItemLedgerEntry>(args: param);
    } catch (error) {
      return [];
    }
  }

  @override
  Future<CustomerItemLedgerEntry?> getCustomerItemLedgerEntry({
    Map<String, dynamic>? args,
  }) async {
    return await _storage.getFirst<CustomerItemLedgerEntry>(args: args);
  }

  @override
  Future<List<CompetitorItem>> getCompletitorItems({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    return await _storage.getWithPagination<CompetitorItem>(
      args: param,
      page: page,
    );
  }

  @override
  Future<List<Competitor>> getCompetitors({Map<String, dynamic>? param}) async {
    try {
      return await _storage.getWithPagination<Competitor>(
        args: param,
        page: param?["page"] ?? 1,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Competitor?> getCompetitor({Map<String, dynamic>? param}) async {
    try {
      return await _storage.getFirst<Competitor>(args: param);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<PointOfSalesMaterial>> posms({
    Map<String, dynamic>? param,
  }) async {
    try {
      return await _storage.getWithPagination<PointOfSalesMaterial>(
        args: param,
        page: param?["page"] ?? 1,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Merchandise>> merchandises({Map<String, dynamic>? param}) async {
    try {
      return await _storage.getWithPagination<Merchandise>(
        args: param,
        page: param?["page"] ?? 1,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<CompetitorItemLedgerEntry?> detailItemCompetitorLederEntry({
    Map<String, dynamic>? param,
  }) async {
    try {
      return await _storage.getFirst<CompetitorItemLedgerEntry>(args: param);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> storeComPetitorItemLedgerEntry({
    required CompetitorItemLedgerEntry cile,
    required CheckCompititorItemStockArg arg,
  }) async {
    try {
      final qtyCount = Helpers.toDouble(arg.stockQty);
      double qtyPerUnit = Helpers.toDouble(cile.qtyPerUnitOfMeasure);
      if (qtyPerUnit == 0) {
        qtyPerUnit = 1;
      }

      await _storage.writeTransaction((realm) {
        if (!arg.updateOnlyQty) {
          cile.expirationDate = DateTimeExt.parse(
            arg.expirationDate,
          ).toDateString();
          cile.itemNo = arg.item.no;
          cile.unitOfMeasureCode = arg.item.salesUomCode;
          cile.volumeSalesQuantity = Helpers.formatNumberDb(
            arg.volumSale,
            option: FormatType.quantity,
          );
          cile.volumeSalesQuantityBase = Helpers.formatNumberDb(
            Helpers.toDouble(cile.volumeSalesQuantity) * qtyPerUnit,
            option: FormatType.quantity,
          );
          cile.unitPrice = Helpers.formatNumberDb(
            arg.unitPrice,
            option: FormatType.price,
          );
          cile.unitCost = Helpers.formatNumberDb(
            arg.unitCost,
            option: FormatType.cost,
          );
          cile.lotNo = Helpers.toStrings(arg.lotNo);
          cile.serialNo = Helpers.toStrings(arg.serialNo);
          cile.remark = Helpers.toStrings(arg.remark);
        }

        cile.countingDate = DateTime.now().toDateString();
        cile.quantity = Helpers.formatNumberDb(
          qtyCount,
          option: FormatType.quantity,
        );
        cile.quantityBase = Helpers.formatNumberDb(
          qtyCount * qtyPerUnit,
          option: FormatType.quantity,
        );

        realm.add(cile, update: true);
        return "Success";
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<CompetitorItemLedgerEntry>> getCompetitorItemLedgetEntry({
    Map<String, dynamic>? param,
  }) async {
    try {
      return await _storage.getAll<CompetitorItemLedgerEntry>(args: param);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<SalespersonSchedule?> getSchedule({
    Map<String, dynamic>? param,
  }) async {
    try {
      return await _storage.getFirst<SalespersonSchedule>(args: param);
    } catch (error) {
      rethrow;
    }
  }

  @override
  Future<List<CompetitorPromtionHeader>> getCompetitorPromotionHeader({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      return await _storage.getAll<CompetitorPromtionHeader>(args: param);
    } catch (error) {
      return [];
    }
  }

  @override
  Future<SalesPersonScheduleMerchandise> storeSalesPersonScheduleMerchandise(
    SalesPersonScheduleMerchandise record, {
    required double quantity,
    required String status,
  }) async {
    return _storage.writeTransaction((realm) {
      // Check if the record already exists
      final existingRecord = realm.find<SalesPersonScheduleMerchandise>(
        record.id,
      );

      if (existingRecord != null) {
        existingRecord.quantity = Helpers.formatNumberDb(quantity);
      } else {
        realm.add(record);
      }

      return record;
    });
  }

  @override
  Future<List<SalesPersonScheduleMerchandise>>
  updateSalesPersonScheduleMerchandiseStatus(
    List<SalesPersonScheduleMerchandise> records, {
    required String status,
  }) async {
    return _storage.writeTransaction((realm) {
      for (var record in records) {
        record.status = status;
        realm.add(record, update: true);
      }

      return records;
    });
  }

  @override
  Future<void> deleteSalesPersonScheduleMerchandise(
    SalesPersonScheduleMerchandise record,
  ) async {
    await _storage.delete(record);
  }

  @override
  Future<List<SalesPersonScheduleMerchandise>>
  getSalesPersonScheduleMerchandises({Map<String, dynamic>? args}) async {
    return await _storage.getAll<SalesPersonScheduleMerchandise>(args: args);
  }

  @override
  Future<SalesPersonScheduleMerchandise?> getSalesPersonScheduleMerchandise({
    Map<String, dynamic>? args,
  }) async {
    return await _storage.getFirst<SalesPersonScheduleMerchandise>(args: args);
  }

  @override
  Future<List<CustomerLedgerEntry>> getCustomerLedgerEntry(
    Map<String, dynamic>? param,
  ) async {
    return await _storage.getAll<CustomerLedgerEntry>(args: param);
  }

  @override
  Future<CustomerLedgerEntry?> getDetailCustomerLedgerEntry(
    Map<String, dynamic>? param,
  ) async {
    return await _storage.getFirst<CustomerLedgerEntry>(args: param);
  }

  @override
  Future<List<PaymentMethod>> getPaymentType(
    Map<String, dynamic>? param,
  ) async {
    final Map<String, dynamic> p = {'inactived': 'No', ...?param};

    return await _storage.getAll<PaymentMethod>(args: p);
  }

  @override
  Future<PaymentMethod?> getPaymentMethod({Map<String, dynamic>? param}) async {
    final Map<String, dynamic> p = {'inactived': 'No', ...?param};

    return await _storage.getFirst<PaymentMethod>(args: p);
  }

  @override
  Future<void> processPayment(CashReceiptJournals record) async {
    await _storage.add(record);
  }

  @override
  Future<void> updateRemainingAmount(
    CustomerLedgerEntry record,
    double remainingAmount,
  ) async {
    await _storage.writeTransaction((realm) {
      if (record.currencyFactor == 0) {
        record.currencyFactor = 1.0;
      }

      record.remainingAmount = remainingAmount;
      record.remainingAmountLcy =
          remainingAmount * record.currencyFactor!; // TODO
      realm.add(record, update: true);
    });
  }

  @override
  Future<List<CashReceiptJournals>> getCashReceiptJournals(
    Map<String, dynamic>? param,
  ) async {
    return await _storage.getAll<CashReceiptJournals>(args: param);
  }

  @override
  Future<CashReceiptJournals?> getCashReceiptJournal(
    Map<String, dynamic>? param,
  ) async {
    return await _storage.getFirst<CashReceiptJournals>(args: param);
  }

  @override
  Future<void> deletedPayment(CashReceiptJournals journal) async {
    await _storage.delete(journal);
  }

  @override
  Future<List<CashReceiptJournals>> processCashReceiptJournals(
    List<CashReceiptJournals> journals,
  ) async {
    if (journals.isEmpty) {
      throw GeneralException("No transaction to submit!");
    }

    return await _storage.writeTransaction((realm) {
      for (var journal in journals) {
        journal.status = kStatusSubmit;
        realm.add(journal, update: true);
      }

      return journals;
    });
  }

  @override
  Future<bool> deletedPosSaleLine(PosSalesLine line) async {
    List<PosSalesLine> relatedLines = [];

    if ((line.specialTypeNo ?? "").isNotEmpty) {
      relatedLines = await _storage.getAll<PosSalesLine>(
        args: {
          'special_type_no': line.specialTypeNo,
          'document_no': line.documentNo,
          'refer_line_no': line.referLineNo,
        },
      );
    }

    return _storage.writeTransaction((realm) {
      if (relatedLines.isNotEmpty) {
        realm.deleteMany(relatedLines);
      } else {
        realm.delete(line);
      }

      return true;
    });
  }

  @override
  Future<bool> deletedPosSaleHeader(String headerNo) async {
    final header = await _storage.getFirst<PosSalesHeader>(
      args: {'no': headerNo},
    );

    if (header == null) {
      throw GeneralException("Header not found");
    }

    _storage.delete(header);

    return true;
  }

  @override
  Future<List<PaymentTerm>> getPaymentTerms(Map<String, dynamic>? param) async {
    final Map<String, dynamic> p = {'inactived': 'No', ...?param};

    return _storage.getAll<PaymentTerm>(args: p);
  }

  @override
  Future<List<Distributor>> getDistributors(Map<String, dynamic>? param) async {
    final Map<String, dynamic> p = {'inactived': 'No', ...?param};

    return _storage.getAll<Distributor>(args: p);
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
  Future<List<PosSalesHeader>> getPosSaleHeaders({
    Map<String, dynamic>? params,
  }) async {
    try {
      return await _storage.getAll<PosSalesHeader>(args: params);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> storePosSaleHeaders(List<PosSalesHeader> sales) async {
    _storage.addAll(sales);
  }

  @override
  Future<void> storePosSaleHeader(PosSalesHeader sale) async {
    _storage.add(sale);
  }

  @override
  Future<void> storePosSale({
    required PosSalesHeader saleHeader,
    required List<PosSalesLine> saleLines,
    bool refreshLine = true,
  }) async {
    final header = await _storage.getFirst<PosSalesHeader>(
      args: {'no': saleHeader.no, 'document_type': saleHeader.documentType},
    );

    List<PosSalesLine> allExistedLines = [];
    if (refreshLine) {
      final itemNos = saleLines.map((line) => '"${line.no}"').toList();
      allExistedLines = await _storage.getAll<PosSalesLine>(
        args: {
          'document_no': saleHeader.no,
          'customer_no': saleHeader.customerNo,
          'document_type': saleHeader.documentType,
          'no': 'IN {${itemNos.join(",")}}',
          'special_type_no': '',
        },
      );
    }

    await _storage.writeTransaction((realm) {
      if (header == null) {
        realm.add(saleHeader);
      }

      if (refreshLine && allExistedLines.isNotEmpty) {
        realm.deleteMany(allExistedLines);
      }

      realm.addAll(saleLines);

      return "Success";
    });
  }

  @override
  Future<void> processCheckout({
    required SalesHeader saleHeader,
    required List<SalesLine> saleLines,
    required PosSalesHeader posSaleHeader,
    required List<PosSalesLine> posSaleLines,
  }) async {
    await _storage.writeTransaction((realm) {
      realm.add(saleHeader);
      realm.addAll(saleLines);

      if (posSaleHeader.documentType != kSaleCreditMemo) {
        for (final line in saleLines) {
          double qty =
              Helpers.formatNumberDb(line.quantity) *
              Helpers.formatNumberDb(line.qtyPerUnitOfMeasure);

          realm.add(
            ItemLedgerEntry(
              Helpers.toStrings(line.no ?? ""),
              Helpers.toStrings(line.lotNo ?? ""),
              Helpers.toStrings(line.serialNo ?? ""),
              qty * (-1),
              DateTime.now().toDateString(),
            ),
          );

          final item = realm.find<Item>(line.no);
          if (item != null) {
            final entries = realm.query<ItemLedgerEntry>('item_no = \$0', [
              line.no,
            ]);
            final endingQty = entries.fold<double>(
              0,
              (sum, entry) => sum + (entry.quantity),
            );

            item.inventory = endingQty;
            realm.add(item, update: true);
          }
        }
      }

      // Fetch fresh instance from live realm using primary key
      final livePosSaleHeader = realm.find<PosSalesHeader>(posSaleHeader.id);
      if (livePosSaleHeader != null) {
        realm.delete(livePosSaleHeader);
      }

      // Delete lines using fresh realm instances
      for (final line in posSaleLines) {
        final liveLine = realm.find<PosSalesLine>(line.id);
        if (liveLine != null) {
          realm.delete(liveLine);
        }
      }

      return true;
    });
  }

  @override
  Future<List<PosSalesLine>> getPosSaleLines({
    Map<String, dynamic>? params,
  }) async {
    return _storage.getAll<PosSalesLine>(args: params);
  }

  @override
  Future<PosSalesLine?> getPosSaleLine({Map<String, dynamic>? params}) async {
    return _storage.getFirst<PosSalesLine>(args: params);
  }

  @override
  Future<PaymentTerm?> getPaymentTerm(Map<String, dynamic>? param) {
    return _storage.getFirst<PaymentTerm>(args: param);
  }

  @override
  Future<GeneralJournalBatch?> getGeneralJournalBatch({
    Map<String, dynamic>? param,
  }) {
    return _storage.getFirst<GeneralJournalBatch>(args: param);
  }

  @override
  Future<List<ItemPrizeRedemptionHeader>> getItemPrizeRedemptionHeader({
    Map<String, dynamic>? param,
  }) async {
    return await _storage.getAll<ItemPrizeRedemptionHeader>(args: param);
  }

  @override
  Future<List<ItemPrizeRedemptionLine>> getItemPrizeRedemptionLine({
    Map<String, dynamic>? param,
  }) async {
    return await _storage.getAll<ItemPrizeRedemptionLine>(args: param);
  }

  @override
  Future<List<ItemPrizeRedemptionLineEntry>> getItemPrizeRedemptionEntries({
    Map<String, dynamic>? param,
  }) async {
    return await _storage.getAll<ItemPrizeRedemptionLineEntry>(args: param);
  }

  @override
  Future<List<ItemPrizeRedemptionLineEntry>> processTakeInRedemption(
    ItemPrizeRedemptionHeader header,
    List<ItemPrizeRedemptionLineEntry> entries,
    String scheduleId,
  ) async {
    final existedEntry = await _storage.getAll<ItemPrizeRedemptionLineEntry>(
      args: {'promotion_no': header.no, 'schedule_id': scheduleId},
    );

    return _storage.writeTransaction((realm) {
      if (existedEntry.isNotEmpty) {
        realm.deleteMany(existedEntry);
      }

      for (final line in entries) {
        realm.add(line);
      }

      return entries;
    });
  }

  @override
  Future<bool> deleteTakeInRedemption(
    ItemPrizeRedemptionHeader header,
    String scheduleId,
  ) async {
    final existedEntry = await _storage.getAll<ItemPrizeRedemptionLineEntry>(
      args: {'promotion_no': header.no, 'schedule_id': scheduleId},
    );

    if (existedEntry.isEmpty) {
      return false;
    }

    return _storage.writeTransaction((realm) {
      realm.deleteMany(existedEntry);
      return true;
    });
  }

  @override
  Future<List<CompetitorPromotionLine>> getCompetitorProLine({
    Map<String, dynamic>? param,
  }) async {
    return await _storage.getAll<CompetitorPromotionLine>(args: param);
  }

  @override
  Future<bool> processSubmitRedemption(
    List<ItemPrizeRedemptionLineEntry> entries,
  ) {
    return _storage.writeTransaction((realm) {
      for (var entry in entries) {
        entry.status = kStatusSubmit;
        realm.add(entry, update: true);
      }

      return true;
    });
  }

  @override
  Future<bool> moveOldScheduleToCurrentDate(
    List<SalespersonSchedule> oldSchedules,
  ) async {
    return await _storage.writeTransaction((realm) {
      final today = DateTime.now().toDateString();
      for (final s in oldSchedules) {
        s.remark = "Move from ${s.scheduleDate}";
        s.scheduleDateMoveFrom = s.scheduleDate;
        s.scheduleDate = today;
      }

      return true;
    });
  }
}
