import 'package:dartz/dartz.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/features/more/domain/entities/item_sale_arg.dart';
import 'package:salesforce/features/more/domain/entities/record_sale_header.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/domain/entities/user_info.dart';
import 'package:salesforce/features/tasks/domain/entities/app_version.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

abstract class MoreRepository extends BaseAppRepository {
  Future<Either<Failure, RecordSaleHeader>> getSaleHeaders({
    Map<String, dynamic>? param,
    int page = 1,
    bool fetchingApi = true,
  });

  Future<Either<Failure, List<SalesLine>>> getSaleLines({
    Map<String, dynamic>? param,
    int page = 1,
    bool fetchingApi = true,
  });

  Future<Either<Failure, List<PosSalesLine>>> getPosSaleLines({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, SaleDetail?>> getSaleDetails({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, List<Salesperson>>> getSalespersons({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, Customer>> storeNewCustomer({
    Map<String, dynamic>? param,
  });

  Future<Either<Failure, Customer>> updateCustomer(Customer record);

  Future<Either<Failure, CustomerAddress>> storeNewCustomerAddress(
    CustomerAddress address,
  );

  Future<Either<Failure, CustomerAddress>> updateCustomerAddress(
    CustomerAddress address,
  );

  Future<Either<Failure, Customer?>> getCustomer({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, List<CustomerAddress>>> getCustomerAddresses({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, CustomerAddress?>> getCustomerAddress({
    Map<String, dynamic>? params,
  });

  Future<Either<Failure, bool>> processUploadSale({
    required List<SalesHeader> salesHeaders,
    required List<SalesLine> salesLines,
  });

  Future<Either<Failure, List<CustomerItemLedgerEntry>>>
  processUploadCheckStock({required List<CustomerItemLedgerEntry> records});

  Future<Either<Failure, List<CompetitorItemLedgerEntry>>>
  processUploadCompetitorCheckStock({
    required List<CompetitorItemLedgerEntry> records,
  });

  Future<Either<Failure, bool>> processUploadCollection({
    required List<CashReceiptJournals> records,
  });

  Future<Either<Failure, List<SalesPersonScheduleMerchandise>>>
  processUploadMerchandiseAndPosm({
    required List<SalesPersonScheduleMerchandise> records,
  });

  Future<Either<Failure, List<SalespersonSchedule>>> processUploadSchedule({
    required List<SalespersonSchedule> records,
  });

  Future<Either<Failure, List<ItemPrizeRedemptionLineEntry>>>
  processUploadRedemptions({
    required List<ItemPrizeRedemptionLineEntry> records,
  });

  Future<Either<Failure, String>> getAddressFrmLatLng(double lat, double lng);

  Future<Either<Failure, bool>> deleteCustomerAddress(CustomerAddress address);

  Future<Either<Failure, String>> resetPassword({Map<String, dynamic>? params});
  Future<Either<Failure, List<ItemPrizeRedemptionHeader>>>
  getItemPrizeRedemptionHeader({Map<String, dynamic>? param});

  Future<Either<Failure, List<ItemPrizeRedemptionLine>>>
  getItemPrizeRedemptionLine({Map<String, dynamic>? param});

  Future<void> updateProfileUser(UserInfo user);

  Future<Either<Failure, String>> getInvoiceHtml({Map<String, dynamic>? param});
  Future<Either<Failure, ItemSalesLinePrices?>> getItemSaleLinePrice({
    required String itemNo,
    required String saleType,
    String orderQty = "1",
    String? saleCode,
    String uomCode = "",
  });

  Future<Either<Failure, bool>> insertSale(SaleItemArg saleArg);
  Future<Either<Failure, DevicePrinter>> storeDevicePrinter(
    DevicePrinter customer,
  );
  Future<Either<Failure, List<DevicePrinter>>> getDevicePrinter({
    Map<String, dynamic>? param,
  });
  Future<Either<Failure, bool>> deletePrinter({required DevicePrinter device});

  Future<Either<Failure, AppVersion?>> checkAppVersion({
    Map<String, dynamic>? param,
  });
}
