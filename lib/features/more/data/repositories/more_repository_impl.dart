import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/constants/app_config.dart';
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
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/features/more/domain/entities/record_sale_header.dart';
import 'package:salesforce/features/more/domain/entities/user_info.dart';
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

class MoreRepositoryImpl extends BaseAppRepositoryImpl implements MoreRepository {
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
        final Map<String, dynamic> cloudSales = await _remote.getSaleHeaders(data: param);

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
  Future<Either<Failure, SaleDetail?>> getSaleDetails({Map<String, dynamic>? param}) async {
    try {
      if (await _networkInfo.isConnected) {
        final sales = await _remote.getSaleDetails(data: param);
        return Right(sales);
      } else {
        param = {"no": param?.values.first};
        final header = await _local.getPosSaleHeader(param: param);

        final lines = await _local.getPosSaleLines(param: {"document_no": header?.no});

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
  Future<Either<Failure, List<Salesperson>>> getSalespersons({Map<String, dynamic>? param}) async {
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
  Future<Either<Failure, Customer?>> getCustomer({Map<String, dynamic>? params}) async {
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
  Future<Either<Failure, List<CustomerAddress>>> getCustomerAddresses({Map<String, dynamic>? params}) async {
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
  Future<Either<Failure, Customer>> storeNewCustomer({Map<String, dynamic>? param}) async {
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
      final result = await _remote.updateCustomer(data: {'data': jsonEncode(record.toJson())});

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
  Future<Either<Failure, CustomerAddress>> storeNewCustomerAddress(CustomerAddress address) async {
    try {
      final result = await _remote.createNewCustomerAddress(data: {'data': jsonEncode(address.toJson())});

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
  Future<Either<Failure, CustomerAddress>> updateCustomerAddress(CustomerAddress address) async {
    try {
      final result = await _remote.updateCustomerAddress(data: {'data': jsonEncode(address.toJson())});

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
  Future<Either<Failure, CustomerAddress?>> getCustomerAddress({Map<String, dynamic>? params}) async {
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
  Future<Either<Failure, List<CustomerItemLedgerEntry>>> processUploadCheckStock({
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

      final result = await _local.updateCheckedStockStatus(records, remoteRecords: remoteRecords);

      return Right(result);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (_) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, String>> getAddressFrmLatLng(double lat, double lng) async {
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
            } else if (types.contains('sublocality') || types.contains('sublocality_level_1')) {
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
  Future<Either<Failure, bool>> deleteCustomerAddress(CustomerAddress address) async {
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
  Future<Either<Failure, bool>> processUploadCollection({required List<CashReceiptJournals> records}) async {
    try {
      List<Map<String, dynamic>> jsonData = [];
      for (var record in records) {
        jsonData.add(record.toJson());
      }

      if (jsonData.isEmpty) {
        return const Left(CacheFailure("Nothing to upload"));
      }

      final result = await _remote.processUpload(data: {'table_name': 'cashjournal', 'data': jsonEncode(jsonData)});

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
  Future<Either<Failure, List<CompetitorItemLedgerEntry>>> processUploadCompetitorCheckStock({
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
        data: {'table_name': 'check_competitor_item_stock', 'data': jsonEncode(jsonData)},
      );

      final List<CompetitorItemLedgerEntry> remoteRecords = [];
      for (var rr in resultRemote['records']) {
        remoteRecords.add(CompetitorItemLedgerEntryExtension.fromMap(rr));
      }

      final result = await _local.updateCheckedCompititorStockStatus(records, remoteRecords: remoteRecords);

      return Right(result);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesPersonScheduleMerchandise>>> processUploadMerchandiseAndPosm({
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
        data: {'table_name': 'schedule_merchandise', 'data': jsonEncode(jsonData)},
      );

      final List<SalesPersonScheduleMerchandise> remoteRecords = [];
      for (var rr in resultRemote['records']) {
        remoteRecords.add(SalesPersonScheduleMerchandiseExtension.fromMap(rr));
      }

      final result = await _local.updateScheduleMerchandiseStatus(records, remoteSchedules: remoteRecords);

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

      final result = await _remote.processUpload(data: {'table_name': 'sales', 'data': jsonEncode(jsonData)});

      final List<SalesHeader> remoteSalesHeaders = [];
      for (var sh in result['headers']) {
        remoteSalesHeaders.add(SalesHeaderExtension.fromMap(sh));
      }

      final List<SalesLine> remoteLines = [];
      for (var sh in result['lines']) {
        remoteLines.add(SalesLineExtension.fromMap(sh));
      }

      _local.updateSales(saleHeaders: salesHeaders, remoteSaleHeaders: remoteSalesHeaders, remoteLines: remoteLines);

      return const Right(true);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemPrizeRedemptionLineEntry>>> processUploadRedemptions({
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

      final result = await _local.updateRedemptionsStatus(records, remoteRecords: remoteRecords);

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

      await _remote.processUpload(data: {'table_name': 'schedule', 'data': jsonEncode(jsonData)});

      final result = await _local.updateSalepersonScheduleLastSyncDate(records);

      return Right(result);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword({Map<String, dynamic>? params}) async {
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
  Future<Either<Failure, List<ItemPrizeRedemptionHeader>>> getItemPrizeRedemptionHeader({
    Map<String, dynamic>? param,
  }) async {
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
  Future<Either<Failure, List<ItemPrizeRedemptionLine>>> getItemPrizeRedemptionLine({
    Map<String, dynamic>? param,
  }) async {
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
        data: {"first_name": user.firstName, "last_name": user.lastName, "phone_number": user.phoneNumber},
        imagePath: XFile(user.userImagePath),
      );
    }

    if (getUser == null) return;
    await _local.updateProfileUser(user: getUser, userInfo: user);
    await setAuthInjection(getUser);
  }

  @override
  Future<Either<Failure, String>> getInvoiceHtml({Map<String, dynamic>? param}) async {
    try {
      final result = await _remote.getInvoiceHtml(data: param);
      final String html = """${(result['html'] ?? "")}""";

      if (result.isEmpty) {
        return const Left(CacheFailure("No HTML content found"));
      }
      return Right(html);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
