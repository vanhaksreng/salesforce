import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/data/models/extension/cash_receipt_journals_extension.dart';
import 'package:salesforce/core/data/models/extension/competitor_item_ledger_entry_extension.dart';
import 'package:salesforce/core/data/models/extension/customer_address_extension.dart';
import 'package:salesforce/core/data/models/extension/customer_extension.dart';
import 'package:salesforce/core/data/models/extension/customer_item_ledger_entry_extension.dart';
import 'package:salesforce/core/data/models/extension/item_prize_redemption_line_entry_extension.dart';
import 'package:salesforce/core/data/models/extension/sale_header_extension.dart';
import 'package:salesforce/core/data/models/extension/sale_line_extension.dart';
import 'package:salesforce/core/data/models/extension/salesperson_schedule_extension.dart';
import 'package:salesforce/core/data/models/extension/salesperson_schedule_merchandise_extenstion.dart';
import 'package:salesforce/core/data/repositories/base_app_repository_impl.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/domain/services/calculate_sale_price.dart';
import 'package:salesforce/features/more/domain/entities/item_sale_arg.dart';
import 'package:salesforce/features/more/domain/entities/record_sale_header.dart';
import 'package:salesforce/features/more/domain/entities/user_info.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/features/more/data/datasources/api/api_more_data_source.dart';
import 'package:salesforce/features/more/data/datasources/realm/realm_more_data_source.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class MoreRepositoryImpl extends BaseAppRepositoryImpl
    implements MoreRepository {
  final ApiMoreDataSource _remote;
  final RealmMoreDataSource _local;
  final NetworkInfo _networkInfo;

  MoreRepositoryImpl({
    required ApiMoreDataSource super.remote,
    required RealmMoreDataSource super.local,
    required super.networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, RecordSaleHeader>> getSaleHeaders({
    Map<String, dynamic>? param,
    int page = 1,
    bool fetchingApi = true,
  }) async {
    try {
      final localSale = await _local.getSaleHeaders(args: param);

      if (fetchingApi && await _networkInfo.isConnected) {
        param?['page'] = page;
        final Map<String, dynamic> cloudSales = await _remote.getSaleHeaders(
          data: param,
        );

        if (localSale.length == cloudSales.length) {
          return Right(RecordSaleHeader());
        }

        // final localIds = localSale.map((e) => e.id).toSet();

        // final newSales = cloudSales.where((s) {
        //   return !localIds.contains(s.id);
        // }).toList();

        // _local.storeSaleHeaders(newSales);

        final List<SalesHeader> records = [];
        for (var item in cloudSales["records"] ?? []) {
          records.add(SalesHeaderExtension.fromMap(item));
        }

        return Right(
          RecordSaleHeader(
            saleHeaders: records,
            currentPage: cloudSales["currentPage"] ?? 1,
            lastPage: cloudSales["lastPage"] ?? 1,
          ),
        );
      }

      return Right(RecordSaleHeader());
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<SalesLine>>> getSaleLines({
    Map<String, dynamic>? param,
    int page = 1,
    bool fetchingApi = true,
  }) async {
    try {
      final localeSaleLines = await _local.getSaleLines(args: param);

      if (fetchingApi && await _networkInfo.isConnected) {
        param?['page'] = page;
        final saleLineCloud = await _remote.getSaleLines(data: param);

        // final localIds = localeSaleLines.map((e) => e.id).toSet();

        // final newSaleLines = saleLineCloud.where((s) {
        //   return !localIds.contains(s.id);
        // }).toList();

        // _local.storeLines(newSaleLines);
        return Right(saleLineCloud);
      }

      return Right(localeSaleLines);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, SaleDetail?>> getSaleDetails({
    Map<String, dynamic>? param,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final sales = await _remote.getSaleDetails(data: param);
        return Right(sales);
      } else {
        param = {"no": param?.values.first};
        final header = await _local.getPosSaleHeader(param: param);

        final lines = await _local.getPosSaleLines(
          param: {"document_no": header?.no},
        );

        final saleDetail = SaleDetail(header: header!, lines: lines);

        return Right(saleDetail);
      }
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<Salesperson>>> getSalespersons({
    Map<String, dynamic>? param,
  }) async {
    try {
      final salerPersons = await _local.getSalespersons(args: param);
      return Right(salerPersons);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, Customer?>> getCustomer({
    Map<String, dynamic>? params,
  }) async {
    try {
      final customer = await _local.getCustomer(params: params);
      return Right(customer);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<CustomerAddress>>> getCustomerAddresses({
    Map<String, dynamic>? params,
  }) async {
    try {
      final customerAddresses = await _local.getCustomerAddresses(args: params);
      return Right(customerAddresses);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, Customer>> storeNewCustomer({
    Map<String, dynamic>? param,
  }) async {
    try {
      final result = await _remote.createNewCustomer(data: param);
      Customer customer = CustomerExtension.fromMap(result['customer']);

      final existed = await _local.getCustomer(params: {'no': customer.no});
      if (existed != null) {
        customer = await _local.updateCustomer(customer);
      } else {
        customer = await _local.storeNewCustomer(customer);
      }

      return Right(customer);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, Customer>> updateCustomer(Customer record) async {
    try {
      final result = await _remote.updateCustomer(
        data: {'data': jsonEncode(record.toJson())},
      );

      Customer customer = CustomerExtension.fromMap(result['customer']);

      customer = await _local.updateCustomer(record);
      return Right(customer);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, CustomerAddress>> storeNewCustomerAddress(
    CustomerAddress address,
  ) async {
    try {
      final result = await _remote.createNewCustomerAddress(
        data: {'data': jsonEncode(address.toJson())},
      );

      final cAddress = CustomerAddressExtension.fromMap(result['address']);

      _local.updateOrNewCustomerAddress(cAddress);

      return Right(cAddress);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, CustomerAddress>> updateCustomerAddress(
    CustomerAddress address,
  ) async {
    try {
      final result = await _remote.updateCustomerAddress(
        data: {'data': jsonEncode(address.toJson())},
      );

      final cAddress = CustomerAddressExtension.fromMap(result['address']);

      _local.updateOrNewCustomerAddress(cAddress);

      return Right(cAddress);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, CustomerAddress?>> getCustomerAddress({
    Map<String, dynamic>? params,
  }) async {
    try {
      final customerAddress = await _local.getCustomerAddress(args: params);
      return Right(customerAddress);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<CustomerItemLedgerEntry>>>
  processUploadCheckStock({
    required List<CustomerItemLedgerEntry> records,
  }) async {
    try {
      List<Map<String, dynamic>> jsonData = [];
      for (var record in records) {
        jsonData.add(record.toJson());
      }

      if (jsonData.isEmpty) {
        return const Left(CacheFailure("Nothing to upload"));
      }

      final resultRemote = await _remote.processUpload(
        data: {'table_name': 'check_item_stock', 'data': jsonEncode(jsonData)},
      );

      final List<CustomerItemLedgerEntry> remoteRecords = [];
      for (var rr in resultRemote['records']) {
        remoteRecords.add(CustomerItemLedgerEntryExtension.fromMap(rr));
      }

      final result = await _local.updateCheckedStockStatus(
        records,
        remoteRecords: remoteRecords,
      );

      return Right(result);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, String>> getAddressFrmLatLng(
    double lat,
    double lng,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const Right("");
    }

    try {
      final data = await _remote.getAddressFromLatLng(lat, lng);

      if (data['status'] == 'OK') {
        final results = data['results'];
        if (results.isNotEmpty) {
          final components = results.first['address_components'];

          String street = '';
          String village = '';
          String commune = '';
          String district = '';
          String province = '';
          String country = '';
          String postalCode = '';

          for (var comp in components) {
            final types = comp['types'] as List;

            if (types.contains('route')) {
              street = comp['long_name'];
            } else if (types.contains('sublocality') ||
                types.contains('sublocality_level_1')) {
              village = comp['long_name'];
            } else if (types.contains('locality')) {
              commune = comp['long_name'];
            } else if (types.contains('administrative_area_level_2')) {
              district = comp['long_name'];
            } else if (types.contains('administrative_area_level_1')) {
              province = comp['long_name'];
            } else if (types.contains('country')) {
              country = comp['long_name'];
            } else if (types.contains('postal_code')) {
              postalCode = comp['long_name'];
            }
          }

          final fullAddress = [
            if (street.isNotEmpty) street,
            if (village.isNotEmpty) village,
            if (commune.isNotEmpty) commune,
            if (district.isNotEmpty) district,
            if (province.isNotEmpty) province,
            if (country.isNotEmpty) country,
            if (postalCode.isNotEmpty) postalCode,
          ].join(', ');

          return Right(fullAddress);
        }
      }
      return const Right("");
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteCustomerAddress(
    CustomerAddress address,
  ) async {
    try {
      await _remote.deleteCustomerAddress(data: {'code': address.code});

      await _local.deleteCustomerAddress(address);
      return const Right(true);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, bool>> processUploadCollection({
    required List<CashReceiptJournals> records,
  }) async {
    try {
      List<Map<String, dynamic>> jsonData = [];
      for (var record in records) {
        jsonData.add(record.toJson());
      }

      if (jsonData.isEmpty) {
        return const Left(CacheFailure("Nothing to upload"));
      }

      final result = await _remote.processUpload(
        data: {'table_name': 'cashjournal', 'data': jsonEncode(jsonData)},
      );

      final List<CashReceiptJournals> remoteJournal = [];
      for (var rj in result['records']) {
        remoteJournal.add(CashReceiptJournalsExtension.fromMap(rj));
      }

      _local.updateCashJournalStatus(records, remoteJournals: remoteJournal);

      return const Right(true);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception {
      return const Left(CacheFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, List<CompetitorItemLedgerEntry>>>
  processUploadCompetitorCheckStock({
    required List<CompetitorItemLedgerEntry> records,
  }) async {
    try {
      List<Map<String, dynamic>> jsonData = [];
      for (var record in records) {
        jsonData.add(record.toJson());
      }

      if (jsonData.isEmpty) {
        return const Left(CacheFailure("Nothing to upload"));
      }

      final resultRemote = await _remote.processUpload(
        data: {
          'table_name': 'check_competitor_item_stock',
          'data': jsonEncode(jsonData),
        },
      );

      final List<CompetitorItemLedgerEntry> remoteRecords = [];
      for (var rr in resultRemote['records']) {
        remoteRecords.add(CompetitorItemLedgerEntryExtension.fromMap(rr));
      }

      final result = await _local.updateCheckedCompititorStockStatus(
        records,
        remoteRecords: remoteRecords,
      );

      return Right(result);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesPersonScheduleMerchandise>>>
  processUploadMerchandiseAndPosm({
    required List<SalesPersonScheduleMerchandise> records,
  }) async {
    try {
      List<Map<String, dynamic>> jsonData = [];
      for (var record in records) {
        jsonData.add(record.toJson());
      }

      if (jsonData.isEmpty) {
        return const Left(CacheFailure("Nothing to upload"));
      }

      final resultRemote = await _remote.processUpload(
        data: {
          'table_name': 'schedule_merchandise',
          'data': jsonEncode(jsonData),
        },
      );

      final List<SalesPersonScheduleMerchandise> remoteRecords = [];
      for (var rr in resultRemote['records']) {
        remoteRecords.add(SalesPersonScheduleMerchandiseExtension.fromMap(rr));
      }

      final result = await _local.updateScheduleMerchandiseStatus(
        records,
        remoteSchedules: remoteRecords,
      );

      return Right(result);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> processUploadSale({
    required List<SalesHeader> salesHeaders,
    required List<SalesLine> salesLines,
  }) async {
    try {
      List<Map<String, dynamic>> jsonData = [];
      for (var sale in salesHeaders) {
        final lines = salesLines.where((e) => e.documentNo == sale.no).toList();
        if (lines.isNotEmpty) {
          final s = sale.toJsonWithLines(lines);
          jsonData.add(s);
        }
      }

      if (jsonData.isEmpty) {
        return const Left(CacheFailure("Nothing to upload"));
      }

      final result = await _remote.processUpload(
        data: {'table_name': 'sales', 'data': jsonEncode(jsonData)},
      );

      final List<SalesHeader> remoteSalesHeaders = [];
      for (var sh in result['headers']) {
        remoteSalesHeaders.add(SalesHeaderExtension.fromMap(sh));
      }

      final List<SalesLine> remoteLines = [];
      for (var sh in result['lines']) {
        remoteLines.add(SalesLineExtension.fromMap(sh));
      }

      _local.updateSales(
        saleHeaders: salesHeaders,
        remoteSaleHeaders: remoteSalesHeaders,
        remoteLines: remoteLines,
      );

      return const Right(true);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemPrizeRedemptionLineEntry>>>
  processUploadRedemptions({
    required List<ItemPrizeRedemptionLineEntry> records,
  }) async {
    try {
      List<Map<String, dynamic>> jsonData = [];
      for (var record in records) {
        jsonData.add(record.toJson());
      }

      if (jsonData.isEmpty) {
        return const Left(CacheFailure("Nothing to upload"));
      }

      final resultRemote = await _remote.processUpload(
        data: {'table_name': 'redemption', 'data': jsonEncode(jsonData)},
      );

      final List<ItemPrizeRedemptionLineEntry> remoteRecords = [];
      for (var rr in resultRemote['records']) {
        remoteRecords.add(ItemPrizeRedemptionLineEntryExtension.fromMap(rr));
      }

      final result = await _local.updateRedemptionsStatus(
        records,
        remoteRecords: remoteRecords,
      );

      return Right(result);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalespersonSchedule>>> processUploadSchedule({
    required List<SalespersonSchedule> records,
  }) async {
    try {
      List<Map<String, dynamic>> jsonData = [];
      for (var record in records) {
        final s = record.toJson();
        jsonData.add(s);
      }

      if (jsonData.isEmpty) {
        return const Left(CacheFailure("Nothing to upload"));
      }

      await _remote.processUpload(
        data: {'table_name': 'schedule', 'data': jsonEncode(jsonData)},
      );

      final result = await _local.updateSalepersonScheduleLastSyncDate(records);

      return Right(result);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({
    Map<String, dynamic>? params,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final record = await _remote.resetPassword(data: params);
        if (record["status"] == "success") {
          return Right(record["message"]);
        }
      }
      return const Right("");
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemPrizeRedemptionHeader>>>
  getItemPrizeRedemptionHeader({Map<String, dynamic>? param}) async {
    try {
      final reuslt = await _local.getItemPrizeRedemptionHeader(param: param);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemPrizeRedemptionLine>>>
  getItemPrizeRedemptionLine({Map<String, dynamic>? param}) async {
    try {
      final reuslt = await _local.getItemPrizeRedemptionLine(param: param);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<void> updateProfileUser(UserInfo user) async {
    LoginSession? getUser = await _local.getLoginSession();
    if (await _networkInfo.isConnected) {
      await _remote.updateProfileUer(
        data: {
          "first_name": user.firstName,
          "last_name": user.lastName,
          "phone_number": user.phoneNumber,
        },
        imagePath: XFile(user.userImagePath),
      );
    }

    if (getUser == null) return;
    await _local.updateProfileUser(user: getUser, userInfo: user);
    await setAuthInjection(getUser);
  }

  @override
  Future<Either<Failure, String>> getInvoiceHtml({
    Map<String, dynamic>? param,
  }) async {
    try {
      final result = await _remote.getInvoiceHtml(data: param);
      if (result.isEmpty) {
        return const Left(CacheFailure("No HTML content found"));
      }

      final String html = """${(result['html'] ?? "")}""";
      return Right(html);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PosSalesLine>>> getPosSaleLines({
    Map<String, dynamic>? params,
  }) async {
    try {
      final saleLines = await _local.getPosSaleLines(param: params);
      return Right(saleLines);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PromotionType>>> getPromotionType() async {
    // if (await _networkInfo.isConnected && await _remote.isValidApiSession()) {
    //   const String tableName = "promotion_type";
    //   final datas = await _remote.downloadTranData(data: {
    //     "table": tableName,
    //   });

    //   final handler = TableHandlerFactory.getHandler(tableName);
    //   if (handler == null) {
    //     return throw Exception("No handler found for table: $tableName");
    //   }

    //   final date = datas['datetime'] as String;

    //   final records = (datas["records"] as List).map((item) {
    //     return handler.fromMap(item as Map<String, dynamic>);
    //   }).toList();

    //   await _local.storeData(records, handler.extractKey, date, tableName);
    // }

    final localData = await _local.getPromotionType(
      param: {'allow_manual': 'Yes'},
    );

    return Right(localData);
  }

  @override
  Future<Either<Failure, ItemSalesLinePrices?>> getItemSaleLinePrice({
    required String itemNo,
    required String saleType,
    String orderQty = "1",
    String? saleCode,
    String uomCode = "",
  }) async {
    try {
      final salingPrice = await _getItemSaleLinePrice(
        saleType: saleType,
        saleCode: saleCode,
        orderQty: orderQty,
        itemNo: itemNo,
        uomCode: uomCode,
      );

      return Right(salingPrice);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  Future<ItemSalesLinePrices?> _getItemSaleLinePrice({
    required String itemNo,
    required String saleType,
    String orderQty = "1",
    String? saleCode,
    String uomCode = "",
  }) async {
    final now = DateTime.now();
    final date = "${now.year}-${now.month}-${now.day}";
    Map<String, dynamic> p = {
      "item_no": itemNo,
      "sales_type": saleType,
      'starting_date': '<=$date',
      'ending_date': '>=$date',
      'minimum_quantity': '<=$orderQty',
      'uom_code': uomCode,
    };

    if (saleCode != null) {
      p["sales_code"] = saleCode;
    }

    return await _local.getItemSaleLinePrice(param: p);
  }

  Future<ItemUnitOfMeasure?> _getItemUom({
    required String itemNo,
    required String uomCode,
  }) async {
    return await _local.getItemUom(
      params: {'item_no': itemNo, 'unit_of_measure_code': uomCode},
    );
  }

  Future<Customer?> _getCustomer({required String no}) async {
    return await _local.getCustomer(params: {'no': no});
  }

  Future<PosSalesHeader?> _getPosSaleHeader({
    required String no,
    required String documentType,
  }) async {
    return await _local.getPosSaleHeader(
      param: {'no': no, 'document_type': documentType},
    );
  }

  Future<CustomerAddress?> _getCustomerAddress({
    Map<String, dynamic>? params,
  }) async {
    return await _local.getCustomerAddress(args: params);
  }

  Future<PosSalesHeader> _generateNewSaleHeader({
    required String documentNo,
    required Customer customer,
    required String documentType,
  }) async {
    try {
      final int headerId = Helpers.generateUniqueNumber();
      final String today = DateTime.now().toDateString();
      CustomerAddress? customerAddress;

      if (customer.shipToCode != null) {
        customerAddress = await _getCustomerAddress(
          params: {'customer_no': customer.no, 'code': customer.shipToCode},
        );
      }

      final userSetup = await _local.getUserSetup();
      if (userSetup == null) {
        throw GeneralException("User setup not found");
      }

      if (userSetup.locationCode == null) {
        throw GeneralException("User setup not link to location yet.");
      }

      final header = PosSalesHeader(
        headerId,
        no: documentNo,
        locationCode: userSetup.locationCode,
        documentType: documentType,
        customerNo: customer.no,
        customerName: customer.name,
        customerName2: customer.name2,
        address: customer.address,
        address2: customer.address2,
        shipToName: customer.name,
        shipToName2: customer.name2,
        shipToAddress: customer.address,
        shipToAddress2: customer.address2,
        shipToContactName: customer.contactName,
        shipToPhoneNo: customer.phoneNo,
        shipToPhoneNo2: customer.phoneNo2,
        arPostingGroupCode: customer.recPostingGroupCode,
        genBusPostingGroupCode: customer.genBusPostingGroupCode,
        vatBusPostingGroupCode: customer.vatPostingGroupCode,
        priceIncludeVat: customer.priceIncludeVat,
        paymentTermCode: customer.paymentTermCode,
        orderDate: today,
        documentDate: today,
        postingDate: today,
        status: kStatusOpen,
        storeCode: userSetup.storeCode,
        divisionCode: userSetup.divisionCode,
        businessUnitCode: userSetup.businessUnitCode,
        departmentCode: userSetup.departmentCode,
        projectCode: userSetup.projectCode,
        sourceType: kSourceTypeVisit,
        sourceNo: "",
        currencyCode: "",
        currencyFactor: 1,
      );

      if (customerAddress != null) {
        header.shipToCode = customerAddress.code;
        header.shipToName = customerAddress.name;
        header.shipToName = customerAddress.name2;
        header.shipToAddress = customerAddress.address;
        header.shipToAddress2 = customerAddress.address2;
        header.shipToContactName = customerAddress.contactName;
        header.shipToPhoneNo = customerAddress.phoneNo;
        header.shipToPhoneNo2 = customerAddress.phoneNo2;
      }

      return header;
    } catch (e) {
      rethrow;
    }
  }

  Future<VatPostingSetup?> _getVatSetup({
    required String busPostingGroup,
    required String prodPostingGroup,
  }) async {
    return await _local.getVatSetup(
      param: {
        'vat_bus_posting_group': busPostingGroup,
        'vat_prod_posting_group': prodPostingGroup,
      },
    );
  }

  @override
  Future<Either<Failure, bool>> insertSale(SaleItemArg saleArg) async {
    try {
      final inputs = saleArg.inputs;
      final item = saleArg.item;

      final customer = await _getCustomer(no: saleArg.customer.no);
      if (customer == null) {
        throw GeneralException('Customer not found');
      }

      final user = getAuth();
      if (user == null) {
        throw GeneralException('Please kill app and open again.');
      }

      final String saleNo = Helpers.getSaleDocumentNo(
        scheduleId: customer.no,
        documentType: saleArg.documentType,
      );

      PosSalesHeader? saleHeader = await _getPosSaleHeader(
        no: saleNo,
        documentType: saleArg.documentType,
      );

      saleHeader ??= await _generateNewSaleHeader(
        documentNo: saleNo,
        customer: customer,
        documentType: saleArg.documentType,
      );

      String priceIncludeVat = customer.priceIncludeVat ?? kStatusNo;

      final bus = customer.vatPostingGroupCode ?? "";
      final prod = item.vatProdPostingGroupCode ?? "";

      final vatSetup = await _getVatSetup(
        busPostingGroup: bus,
        prodPostingGroup: prod,
      );
      if (vatSetup == null) {
        throw GeneralException(
          'VAT setup not found. Product posting [$prod] with Bus. Posting [$bus]',
        );
      }

      List<PosSalesLine> saleLines = [];
      int lineNo = 0;
      int referentLineNo = Helpers.generateUniqueNumber();

      await Future.wait(
        inputs.map((input) async {
          final itemUom = await _getItemUom(
            itemNo: item.no,
            uomCode: input.uomCode,
          );

          if (itemUom == null) {
            throw GeneralException("Item uom not found.[${input.uomCode}]");
          }

          final qtyPerUnit = Helpers.toDouble(itemUom.qtyPerUnit);
          if (qtyPerUnit <= 0) {
            throw GeneralException(
              "Quantity per unit of item uom cannot zero.[${input.uomCode}]",
            );
          }

          double discountAmt = saleArg.discountAmount ?? 0;
          double discountPercent = saleArg.discountPercentage ?? 0;
          double manualPrice = 0;
          double unitPrice = 0;

          if (input.code != kPromotionTypeStd) {
            discountPercent = 100;
            discountAmt = 0;
            unitPrice = item.unitPrice ?? 0;
          } else {
            manualPrice = Helpers.formatNumberDb(
              saleArg.manualPrice,
              option: FormatType.price,
            );
            unitPrice = Helpers.formatNumberDb(
              saleArg.itemUnitPrice,
              option: FormatType.price,
            );
            if (manualPrice > 0) {
              unitPrice = manualPrice;
            }
          }

          final calculated = CalculateSalePrices(
            unitPrice: unitPrice,
            quantity: input.quantity,
            vatPercentage: Helpers.toDouble(vatSetup.vatAmount),
            discountAmount: discountAmt,
            discountPercentage: discountPercent,
            priceIncludeVat: priceIncludeVat == kStatusYes,
          );

          if (discountAmt > calculated.baseAmount) {
            throw GeneralException(
              "Discount amount[$discountAmt] cannot greather than base amount[${calculated.baseAmount}]",
            );
          }

          final int lineId = Helpers.generateUniqueNumber();
          lineNo += 10000;

          final saleLine = PosSalesLine(
            lineId,
            documentNo: saleHeader?.no,
            specialType: input.code,
            specialTypeNo: "",
            type: kTypeItem,
            lineNo: lineNo,
            referLineNo: referentLineNo,
            customerNo: customer.no,
            no: item.no,
            description: item.description,
            description2: item.description2,
            itemBrandCode: item.itemBrandCode,
            itemCategoryCode: item.itemCategoryCode,
            itemGroupCode: item.itemGroupCode,
            itemDiscGroupCode: item.itemDiscountGroupCode,
            postingGroup: item.invPostingGroupCode,
            genProdPostingGroupCode: item.genProdPostingGroupCode,
            vatProdPostingGroupCode: item.vatProdPostingGroupCode,
            genBusPostingGroupCode: saleHeader?.genBusPostingGroupCode,
            vatBusPostingGroupCode: saleHeader?.vatBusPostingGroupCode,
            locationCode: saleHeader?.locationCode,
            documentType: saleHeader?.documentType,
            salespersonCode: saleHeader?.salespersonCode,
            storeCode: saleHeader?.storeCode,
            divisionCode: saleHeader?.divisionCode,
            distributorCode: saleHeader?.distributorCode,
            departmentCode: saleHeader?.departmentCode,
            businessUnitCode: saleHeader?.businessUnitCode,
            projectCode: saleHeader?.projectCode,
            requestShipmentDate: saleHeader?.requestShipmentDate,
            currencyCode: saleHeader?.currencyCode,
            currencyFactor: saleHeader?.currencyFactor,
            vatCalculationType: vatSetup.vatCalculationType,
            vatPercentage: Helpers.toDouble(vatSetup.vatAmount),
            unitOfMeasure: itemUom.unitOfMeasureCode,
            qtyPerUnitOfMeasure: qtyPerUnit,
            quantity: input.quantity,
            quantityToShip: input.quantity,
            quantityToInvoice: input.quantity,
            outstandingQuantity: input.quantity,
            outstandingQuantityBase: input.quantity * qtyPerUnit,
            quantityInvoiced: 0,
            quantityShipped: 0,
            unitPrice: unitPrice,
            unitPriceLcy: unitPrice,
            discountAmount: discountAmt,
            discountPercentage: discountPercent,
            vatAmount: calculated.vatAmount,
            vatBaseAmount: calculated.vatBaseAmount,
            amount: calculated.amount,
            amountIncludingVat: calculated.amountIncludeVat,
            amountIncludingVatLcy: calculated.amountIncludeVat,
            manualUnitPrice: manualPrice,
            isManualEdit: manualPrice > 0 ? kStatusYes : kStatusNo,
            documentDate: DateTime.now().toDateString(),
            unitPriceOri: Helpers.formatNumberDb(
              saleArg.itemUnitPrice,
              option: FormatType.price,
            ),
          );

          saleLines.add(saleLine);
        }),
      );

      await _local.storePosSale(saleHeader: saleHeader, saleLines: saleLines);

      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
