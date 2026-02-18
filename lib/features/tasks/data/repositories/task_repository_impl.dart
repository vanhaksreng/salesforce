import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/data/models/extension/sale_header_extension.dart';
import 'package:salesforce/core/data/models/extension/sale_line_extension.dart';
import 'package:salesforce/core/data/models/extension/salesperson_schedule_extension.dart';
import 'package:salesforce/core/data/repositories/base_app_repository_impl.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/errors/exceptions.dart';
import 'package:salesforce/core/errors/failures.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/domain/services/calculate_sale_price.dart';
import 'package:salesforce/features/auth/domain/entities/user.dart';
import 'package:salesforce/features/tasks/data/datasources/api/api_task_data_source.dart';
import 'package:salesforce/features/tasks/data/datasources/realm/realm_task_data_source.dart';
import 'package:salesforce/features/tasks/domain/entities/app_version.dart';
import 'package:salesforce/features/tasks/domain/entities/checkout_arg.dart';
import 'package:salesforce/features/tasks/domain/entities/promotion_line_entity.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_person_gps_model.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class TaskRepositoryImpl extends BaseAppRepositoryImpl
    implements TaskRepository {
  final ApiTaskDataSource _remote;
  final RealmTaskDataSource _local;
  final NetworkInfo _networkInfo;

  const TaskRepositoryImpl({
    required ApiTaskDataSource super.remote,
    required RealmTaskDataSource super.local,
    required super.networkInfo,
  }) : _remote = remote,
       _local = local,
       _networkInfo = networkInfo;

  @override
  Future<Either<Failure, CustomerItemLedgerEntry>> updateItemCheckStock(
    CheckItemStockArg data,
  ) async {
    try {
      final schedule = data.schedule;
      final item = data.item;
      CustomerItemLedgerEntry? cile = await _local.getCustomerItemLedgerEntry(
        args: {'schedule_id': schedule.id, 'item_no': item.no},
      );

      if (cile == null) {
        final User? auth = getAuth();

        final uom = await _local.getItemUom(
          params: {
            "item_no": item.no,
            "unit_of_measure_code": item.stockUomCode,
          },
        );

        if (uom == null) {
          throw GeneralException(
            "Unit of Measure for item [${item.no}] not found. Please download the master data to ensure your data is up to date.",
          );
        }

        final unid = Helpers.generateDocumentNo(auth?.id ?? "");

        cile = CustomerItemLedgerEntry(
          unid,
          itemNo: item.no,
          appId: unid,
          scheduleId: schedule.id,
          customerNo: schedule.customerNo,
          customerName: schedule.name,
          customerName2: schedule.name2,
          itemDescription: item.description,
          itemDescription2: item.description2,
          quantity: Helpers.toDouble(data.stockQty),
          status: kStatusOpen,
          unitOfMeasureCode: item.stockUomCode,
          qtyPerUnitOfMeasure: Helpers.toDouble(uom.qtyPerUnit ?? 1),
        );
      }

      if (cile.status != null && cile.status != kStatusOpen) {
        throw GeneralException(
          "You cannot modify while the record have been submited.",
        );
      }

      await _local.storeItemCheckStock(cile: cile, arg: data);

      return Right(cile);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SalespersonSchedule>> checkIn({
    required SalespersonSchedule schedule,
    required CheckInArg args,
  }) async {
    try {
      String statusInternet = kOffline;
      if (await _networkInfo.isConnected) {
        statusInternet = kOnline;
      }
      XFile? validatedImage;
      if (args.imagePath != null) {
        final fileExists = await File(args.imagePath!.path).exists();
        if (fileExists) {
          validatedImage = args.imagePath;
        } else {
          validatedImage = null;
        }
      }

      final newArg = CheckInArg(
        latitude: args.latitude,
        longitude: args.longitude,
        comment: args.comment,
        imagePath: validatedImage,
        checkInPosition: args.checkInPosition,
        isCloseShop: args.isCloseShop,
      );

      final result = await _local.checkIn(
        schedule: schedule,
        args: newArg,
        internetStatus: statusInternet,
      );

      if (await _networkInfo.isConnected && await _remote.isValidApiSession()) {
        _remote.updateSchedule(result, type: result.status ?? kStatusCheckIn);

        await syncOfflineLocationToBackend();

        await processUploadGpsTracking();
      }

      return Right(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, SalespersonSchedule>> checkout({
    required SalespersonSchedule schedule,
    required CheckInArg args,
  }) async {
    try {
      String statusInternet = kOffline;
      if (await _networkInfo.isConnected) {
        statusInternet = kOnline;
      }

      XFile? validatedImage;
      if (args.imagePath != null) {
        final fileExists = await File(args.imagePath!.path).exists();
        if (fileExists) {
          validatedImage = args.imagePath;
        } else {
          validatedImage = null;
        }
      }

      final newArg = CheckInArg(
        latitude: args.latitude,
        longitude: args.longitude,
        comment: args.comment,
        imagePath: validatedImage,
        checkOutPosition: args.checkOutPosition,
        isCloseShop: args.isCloseShop,
      );

      final result = await _local.checkout(
        schedule: schedule,
        args: newArg,
        internetStatus: statusInternet,
      );

      if (await _networkInfo.isConnected && await _remote.isValidApiSession()) {
        _remote.updateSchedule(result, type: result.status ?? kStatusCheckOut);

        await syncOfflineLocationToBackend();

        await processUploadGpsTracking();
      }

      return Right(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, SalespersonSchedule?>> getSchedule({
    Map<String, dynamic>? param,
  }) async {
    try {
      final result = await _local.getSchedule(param: param);
      return Right(result);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Either<Failure, List<SalespersonSchedule>>> getSchedules(
    String visitDate, {
    bool requestApi = true,
    Map<String, dynamic>? param,
  }) async {
    if (requestApi && !await _networkInfo.isConnected) {
      return const Left(CacheFailure(errorInternetMessage));
    }

    if (param == null) {
      param = {"schedule_date": visitDate};
    } else {
      param["schedule_date"] = visitDate;
    }

    late List<SalespersonSchedule> localSchedules = [];

    try {
      final date = DateTime.parse(visitDate);
      if (date.isAfter(DateTime.now()) && await _remote.isValidApiSession()) {
        final schedules = await _remote.getSchedules(visitDate);
        return Right(schedules);
      }

      localSchedules = await _local.getSchedules(param: param);

      //IF NEED REQUEST API
      if (requestApi && await _networkInfo.isConnected) {
        await _remote.isValidApiSession();

        final schedules = await _remote.getSchedules(visitDate);

        if (localSchedules.length == schedules.length) {
          return Right(localSchedules);
        }

        final localIds = localSchedules.map((e) => e.id).toSet();

        final newSchedules = schedules.where((s) {
          return !localIds.contains(s.id);
        }).toList();

        _local.storeSchedules(newSchedules);

        return Right([...localSchedules, ...newSchedules]);
      }

      return Right(localSchedules);
    } on Exception {
      return Right(localSchedules);
    }
  }

  @override
  Future<Either<Failure, List<SalespersonSchedule>>> getLocalSchedules({
    Map<String, dynamic>? param,
  }) async {
    try {
      final schedules = await _local.getSchedules(param: param);
      return Right(schedules);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception {
      return const Left(CacheFailure(errorMessage));
    }
  }

  Future<Either<Failure, List<Permission>>> getPermissions({
    Map<String, dynamic>? param,
  }) async {
    try {
      final permissions = await _local.getPermissions(param: param);
      return Right(permissions);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  Future<Either<Failure, Permission?>> getPermission({
    Map<String, dynamic>? param,
  }) async {
    try {
      final permission = await _local.getPermission(param: param);
      return Right(permission);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  Future<Either<Failure, List<CustomerItemLedgerEntry>>>
  getCustomerItemLedgerEntries({Map<String, dynamic>? param}) async {
    try {
      final records = await _local.getCustomerItemLedgerEntries(param: param);
      return Right(records);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
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

  @override
  Future<Either<Failure, Customer?>> getCustomer({required String no}) async {
    try {
      final customer = await _getCustomer(no: no);
      return Right(customer);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, CustomerAddress?>> getCustomerAddress({
    Map<String, dynamic>? params,
  }) async {
    try {
      final customerAddress = await _getCustomerAddress(params: params);
      return Right(customerAddress);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<CustomerAddress>>> getCustomerAddresses({
    Map<String, dynamic>? params,
  }) async {
    try {
      final customerAddress = await _local.getCustomerAddresses(args: params);

      return Right(customerAddress);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  Future<CustomerAddress?> _getCustomerAddress({
    Map<String, dynamic>? params,
  }) async {
    return await _local.getCustomerAddress(args: params);
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

  Future<Customer?> _getCustomer({required String no}) async {
    return await _local.getCustomer(params: {'no': no});
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

  Future<PosSalesHeader?> _getPosSaleHeader({
    required String no,
    required String documentType,
  }) async {
    return await _local.getPosSaleHeader(
      params: {'no': no, 'document_type': documentType},
    );
  }

  Future<ItemUnitOfMeasure?> _getItemUom({
    required String itemNo,
    required String uomCode,
  }) async {
    return await _local.getItemUom(
      params: {'item_no': itemNo, 'unit_of_measure_code': uomCode},
    );
  }

  Future<PosSalesHeader> _generateNewSaleHeader({
    required String documentNo,
    required SalespersonSchedule schedule,
    required Customer customer,
    required String documentType,
  }) async {
    try {
      final int headerId = Helpers.generateUniqueNumber();
      final String today = DateTime.now().toDateString();
      CustomerAddress? customerAddress;

      if (schedule.shipToCode != null) {
        customerAddress = await _getCustomerAddress(
          params: {'customer_no': customer.no, 'code': schedule.shipToCode},
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
        salespersonCode: schedule.salespersonCode,
        storeCode: userSetup.storeCode,
        divisionCode: userSetup.divisionCode,
        businessUnitCode: userSetup.businessUnitCode,
        departmentCode: userSetup.departmentCode,
        projectCode: userSetup.projectCode,
        sourceType: kSourceTypeVisit,
        sourceNo: schedule.id,
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

  @override
  Future<Either<Failure, bool>> insertSale(SaleArg saleArg) async {
    try {
      final inputs = saleArg.inputs;
      final item = saleArg.item;
      final schedule = saleArg.schedule;

      final customer = await _getCustomer(no: schedule.customerNo ?? "");
      if (customer == null) {
        throw GeneralException('Customer not found');
      }

      final user = getAuth();
      if (user == null) {
        throw GeneralException('Please kill app and open again.');
      }

      final String saleNo = Helpers.getSaleDocumentNo(
        scheduleId: schedule.id,
        documentType: saleArg.documentType,
      );

      PosSalesHeader? saleHeader = await _getPosSaleHeader(
        no: saleNo,
        documentType: saleArg.documentType,
      );

      saleHeader ??= await _generateNewSaleHeader(
        schedule: schedule,
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

            unitPrice = Helpers.formatNumberDb(
              itemUom.price,
              option: FormatType.price,
            );

            if (unitPrice == 0) {
              unitPrice = item.unitPrice ?? 0;
            }
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
            amountLcy: calculated.amount,
            amountIncludingVat: calculated.amountIncludeVat,
            amountIncludingVatLcy: calculated.amountIncludeVat,
            manualUnitPrice: manualPrice,
            isManualEdit: manualPrice > 0 ? kStatusYes : kStatusNo,
            documentDate: DateTime.now().toDateString(),
            unitPriceOri: Helpers.formatNumberDb(
              saleArg.itemUnitPrice,
              option: FormatType.price,
            ),
            serialNo: schedule.id,
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

  @override
  Future<Either<Failure, bool>> processCheckout(CheckoutSubmitArg arg) async {
    try {
      final posHeader = arg.salesHeader;
      final shipment = arg.shipmentAddress;
      final term = arg.paymentTerm;

      final saleDoc = Helpers.generateSaleId(arg.scheduleId);
      final now = DateTime.now();

      List<SalesHeader> totalSales = await _local.getSaleHeaders(
        args: {
          'posting_date': now.toDateString(),
          'document_type': posHeader.documentType,
        },
      );

      final posLines = await _local.getPosSaleLines(
        params: {
          'document_no': posHeader.no,
          'document_type': posHeader.documentType,
        },
      );

      if (posLines.isEmpty) {
        throw GeneralException("Nothing to checkout");
      }

      int headerNoIncrease = 0;
      if (totalSales.isNotEmpty) {
        headerNoIncrease = totalSales.length + 1;
      }

      int headerNo = saleDoc + headerNoIncrease;
      List<SalesLine> saleLines = [];

      // final DeviceInfoPlugin device = DeviceInfoPlugin();
      // String deviceId = "";

      // if (Platform.isAndroid) {
      //   final AndroidDeviceInfo android = await device.androidInfo;
      //   deviceId = android.id;
      // } else {
      //   final IosDeviceInfo ios = await device.iosInfo;
      //   deviceId = ios.identifierForVendor ?? "";
      // }

      final saleHeader = SalesHeader(
        headerNo,
        no: "${Helpers.getSalePrefix(posHeader.documentType ?? "")}$saleDoc",
        appId: "${Helpers.getSalePrefix(posHeader.documentType ?? "")}$saleDoc",
        documentType: posHeader.documentType,
        requestShipmentDate: arg.requestShipmentDate,
        postingDate: now.toDateString(),
        documentDate: now.toDateString(),
        orderDate: posHeader.orderDate,
        remark: arg.comments,
        customerNo: posHeader.customerNo,
        customerName: posHeader.customerName,
        customerName2: posHeader.customerName2,
        address: posHeader.address,
        address2: posHeader.address2,
        assignToUserId: posHeader.assignToUserId,
        customerGroupCode: posHeader.customerGroupCode,
        priceIncludeVat: posHeader.priceIncludeVat,
        shipToCode: shipment.code,
        shipToName: shipment.name,
        shipToName2: shipment.name2,
        shipToAddress: shipment.address,
        shipToAddress2: shipment.address2,
        shipToPhoneNo: shipment.phoneNo,
        shipToPhoneNo2: shipment.phoneNo2,
        shipToContactName: shipment.contactName,
        locationCode: posHeader.locationCode,
        businessUnitCode: posHeader.businessUnitCode,
        storeCode: posHeader.storeCode,
        departmentCode: posHeader.departmentCode,
        distributorCode: arg.distributor?.code,
        divisionCode: posHeader.divisionCode,
        projectCode: posHeader.projectCode,
        genBusPostingGroupCode: posHeader.genBusPostingGroupCode,
        arPostingGroupCode: posHeader.arPostingGroupCode,
        vatBusPostingGroupCode: posHeader.vatBusPostingGroupCode,
        status: kStatusApprove,
        isSync: kStatusNo,
        paymentTermCode: term?.code,
        paymentMethodCode: arg.paymentMethod?.code ?? "",
        salespersonCode: posHeader.salespersonCode,
        externalDocumentNo: posHeader.externalDocumentNo,
        sourceNo: posHeader.sourceNo,
        sourceType: posHeader.sourceType,
        amount: Helpers.formatNumberDb(
          arg.paymentAmount,
          option: FormatType.amount,
        ),
        orderDateTime: DateTime.now().toDateString(),
      );

      // print(saleHeader.amount);
      // print(arg.paymentAmount);

      int lineNo = 0;
      for (var line in posLines) {
        lineNo += 1;

        final lineId = Helpers.generateUniqueNumber();

        saleLines.add(
          SalesLine(
            lineId,
            appId:
                "${Helpers.getSalePrefix(posHeader.documentType ?? "")}$saleDoc",
            documentNo: saleHeader.no,
            documentType: saleHeader.documentType,
            lineNo: lineNo,
            specialType: line.specialType,
            specialTypeNo: line.specialType,
            type: line.type,
            referLineNo: 1,
            customerNo: line.customerNo,
            no: line.no,
            description: line.description,
            description2: line.description2,
            itemBrandCode: line.itemBrandCode,
            itemCategoryCode: line.itemCategoryCode,
            itemGroupCode: line.itemGroupCode,
            itemDiscGroupCode: line.itemDiscGroupCode,
            postingGroup: line.postingGroup,
            genProdPostingGroupCode: line.genProdPostingGroupCode,
            vatProdPostingGroupCode: line.vatProdPostingGroupCode,
            genBusPostingGroupCode: line.genBusPostingGroupCode,
            vatBusPostingGroupCode: line.vatBusPostingGroupCode,
            locationCode: line.locationCode,
            salespersonCode: line.salespersonCode,
            storeCode: line.storeCode,
            divisionCode: line.divisionCode,
            distributorCode: line.distributorCode,
            departmentCode: line.departmentCode,
            businessUnitCode: line.businessUnitCode,
            projectCode: line.projectCode,
            requestShipmentDate: line.requestShipmentDate,
            currencyCode: line.currencyCode,
            currencyFactor: line.currencyFactor,
            vatCalculationType: line.vatCalculationType,
            vatPercentage: line.vatPercentage,
            unitOfMeasure: line.unitOfMeasure,
            qtyPerUnitOfMeasure: line.qtyPerUnitOfMeasure,
            quantity: line.quantity,
            quantityToShip: line.quantityToShip,
            quantityToInvoice: line.quantityToInvoice,
            outstandingQuantity: line.outstandingQuantity,
            outstandingQuantityBase: line.outstandingQuantityBase,
            quantityInvoiced: 0,
            quantityShipped: 0,
            unitPrice: line.unitPrice,
            unitPriceLcy: line.unitPriceLcy,
            discountAmount: line.discountAmount,
            discountPercentage: line.discountPercentage,
            vatAmount: line.vatAmount,
            vatBaseAmount: line.vatBaseAmount,
            amount: line.amount,
            amountLcy: line.amountLcy,
            amountIncludingVat: line.amountIncludingVat,
            amountIncludingVatLcy: line.amountIncludingVatLcy,
            manualUnitPrice: line.manualUnitPrice,
            isManualEdit: line.isManualEdit,
            isSync: kStatusNo,
            documentDate: DateTime.now().toDateString(),
            unitPriceOri: line.unitPriceOri,
            serialNo: line.sourceNo,
          ),
        );
      }
      if (await _networkInfo.isConnected) {
        await _processUploadSale(
          salesHeaders: [saleHeader],
          salesLines: saleLines,
        );
      }

      await _local.processCheckout(
        saleHeader: saleHeader,
        saleLines: saleLines,
        posSaleHeader: posHeader,
        posSaleLines: posLines,
      );

      return const Right(true);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  Future<void> _processUploadSale({
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
        return;
      }

      final result = await _remote.processUpload(
        data: {'table_name': 'sales', 'data': jsonEncode(jsonData)},
      );

      if (result['status'] != 'success') {
        throw Exception(result['message'] ?? 'Upload failed');
      }

      final List<SalesHeader> remoteSalesHeaders = [];
      for (var sh in result['headers']) {
        remoteSalesHeaders.add(SalesHeaderExtension.fromMap(sh));
      }

      final List<SalesLine> remoteLines = [];
      for (var sh in result['lines']) {
        remoteLines.add(SalesLineExtension.fromMap(sh));
      }

      await _local.updateSales(
        saleHeaders: salesHeaders,
        remoteSaleHeaders: remoteSalesHeaders,
        remoteLines: remoteLines,
      );
    } catch (e) {
      throw GeneralException(e.toString());
    }
  }

  @override
  Future<Either<Failure, bool>> addItemPromotionToCart({
    required List<PromotionLineEntity> records,
    required SalespersonSchedule schedule,
    required String documentType,
    required double orderQty,
  }) async {
    try {
      final customer = await _getCustomer(no: schedule.customerNo ?? "");
      if (customer == null) {
        throw GeneralException('Customer not found');
      }

      final user = getAuth();
      if (user == null) {
        throw GeneralException('Please kill app and open again.');
      }

      final String saleNo = Helpers.getSaleDocumentNo(
        scheduleId: schedule.id,
        documentType: documentType,
      );

      PosSalesHeader? saleHeader = await _getPosSaleHeader(
        no: saleNo,
        documentType: documentType,
      );

      String priceIncludeVat = customer.priceIncludeVat ?? kStatusNo;

      final bus = customer.vatPostingGroupCode ?? "";

      saleHeader ??= await _generateNewSaleHeader(
        schedule: schedule,
        documentNo: saleNo,
        customer: customer,
        documentType: documentType,
      );

      List<PosSalesLine> saleLines = [];
      int lineNo = 0;
      int referentLineNo = Helpers.generateUniqueNumber();

      for (final record in records) {
        for (final l in record.lines.where((pl) => pl.orderQty > 0)) {
          VatPostingSetup? vatSetup;

          if (record.type != "G/L Account") {
            final prod = l.item?.vatProdPostingGroupCode ?? "";
            vatSetup = await _getVatSetup(
              busPostingGroup: bus,
              prodPostingGroup: prod,
            );

            if (vatSetup == null) {
              throw GeneralException(
                'Item[${l.item?.no}] : vat setup not found. Product posting [$prod] with Bus. Posting [$bus]',
              );
            }
          }

          final int lineId = Helpers.generateUniqueNumber();
          lineNo += 10000;

          ItemUnitOfMeasure? itemUom;

          double unitPrice = Helpers.formatNumberDb(
            record.line.unitPrice,
            option: FormatType.price,
          );

          if (['Item', 'G/L Account'].contains(record.type)) {
            if (record.type == "Item") {
              itemUom = await _getItemUom(
                itemNo: l.item?.no ?? "",
                uomCode: l.saleUomCode,
              );
            }
          } else {
            itemUom = await _getItemUom(
              itemNo: l.itemNo,
              uomCode: l.item?.salesUomCode ?? "",
            );

            unitPrice = Helpers.formatNumberDb(
              l.item?.unitPrice,
              option: FormatType.price,
            );
          }

          double qtyPerUnit = 1;
          if (record.type != "G/L Account") {
            if (itemUom == null) {
              throw GeneralException("Item uom not found.[${l.itemName}]");
            }

            qtyPerUnit = Helpers.toDouble(itemUom.qtyPerUnit);
            if (qtyPerUnit <= 0) {
              throw GeneralException(
                "Quantity per unit of item uom cannot be zero. [${itemUom.unitOfMeasureCode}]",
              );
            }
          }

          if (qtyPerUnit == 0) {
            qtyPerUnit = 1;
          }

          final calculated = CalculateSalePrices(
            unitPrice: unitPrice,
            quantity: Helpers.toDouble(l.orderQty),
            vatPercentage: Helpers.toDouble(vatSetup?.vatAmount),
            discountAmount: Helpers.formatNumberDb(
              record.line.discountAmount,
              option: FormatType.amount,
            ),
            discountPercentage: Helpers.formatNumberDb(
              record.line.discountPercentage,
              option: FormatType.percentage,
            ),
            priceIncludeVat: priceIncludeVat == kStatusYes,
          );

          final saleLine = PosSalesLine(
            lineId,
            documentNo: saleHeader.no,
            headerId: saleHeader.id,
            headerQuantity: orderQty,
            specialType: l.promotionType,
            specialTypeNo: record.line.promotionNo,
            type: record.line.type == "G/L Account" ? 'G/L Account' : kTypeItem,
            lineNo: lineNo,
            referLineNo: referentLineNo,
            customerNo: customer.no,
            no: l.itemNo,
            description: l.itemName,
            description2: record.line.description2,
            itemBrandCode: l.item?.itemBrandCode,
            itemCategoryCode: l.item?.itemCategoryCode,
            itemGroupCode: l.item?.itemGroupCode,
            itemDiscGroupCode: l.item?.itemDiscountGroupCode,
            postingGroup: l.item?.invPostingGroupCode,
            genProdPostingGroupCode: l.item?.genProdPostingGroupCode,
            vatProdPostingGroupCode: l.item?.vatProdPostingGroupCode,
            genBusPostingGroupCode: saleHeader.genBusPostingGroupCode,
            vatBusPostingGroupCode: saleHeader.vatBusPostingGroupCode,
            locationCode: saleHeader.locationCode,
            documentType: saleHeader.documentType,
            salespersonCode: saleHeader.salespersonCode,
            storeCode: saleHeader.storeCode,
            divisionCode: saleHeader.divisionCode,
            distributorCode: saleHeader.distributorCode,
            departmentCode: saleHeader.departmentCode,
            businessUnitCode: saleHeader.businessUnitCode,
            projectCode: saleHeader.projectCode,
            requestShipmentDate: saleHeader.requestShipmentDate,
            currencyCode: saleHeader.currencyCode,
            currencyFactor: saleHeader.currencyFactor,
            vatCalculationType:
                vatSetup?.vatCalculationType ?? "VAT After Disc.",
            vatPercentage: Helpers.toDouble(vatSetup?.vatAmount),
            unitOfMeasure: itemUom?.unitOfMeasureCode ?? "",
            qtyPerUnitOfMeasure: qtyPerUnit,
            quantity: calculated.quantity,
            quantityToShip: calculated.quantity,
            quantityToInvoice: calculated.quantity,
            outstandingQuantity: calculated.quantity,
            outstandingQuantityBase: calculated.quantity * qtyPerUnit,
            quantityInvoiced: 0,
            quantityShipped: 0,
            unitPrice: unitPrice,
            unitPriceLcy: unitPrice,
            discountAmount: Helpers.formatNumberDb(
              record.line.discountAmount,
              option: FormatType.amount,
            ),
            discountPercentage: Helpers.formatNumberDb(
              record.line.discountPercentage,
              option: FormatType.percentage,
            ),
            vatAmount: calculated.vatAmount,
            vatBaseAmount: calculated.vatBaseAmount,
            amount: calculated.amount,
            amountIncludingVat: calculated.amountIncludeVat,
            amountIncludingVatLcy: calculated.amountIncludeVat,
            isManualEdit: kStatusNo,
            documentDate: DateTime.now().toDateString(),
          );

          saleLines.add(saleLine);
        }
      }

      await _local.storePosSale(
        saleHeader: saleHeader,
        saleLines: saleLines,
        refreshLine: false,
      );

      return const Right(true);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> createSchedules(Map data) async {
    if (!await _networkInfo.isConnected) {
      throw GeneralException(errorInternetMessage);
    }

    try {
      final salePersonSchedule = await _remote.createSchedules(data);
      await _local.createSchedules(salePersonSchedule);

      return const Right(true);
    } on ServerException {
      return Left(ServerFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, List<CompetitorItem>>> getCompletitorItems({
    Map<String, dynamic>? params,
    int page = 1,
  }) async {
    try {
      final records = await _local.getCompletitorItems(
        param: params,
        page: page,
      );
      return Right(records);
    } on Exception {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<Competitor>>> getCompetitors({
    Map<String, dynamic>? param,
  }) async {
    try {
      final competitors = await _local.getCompetitors(param: param);
      return Right(competitors);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<PointOfSalesMaterial>>> posms({
    Map<String, dynamic>? param,
    int? page,
  }) async {
    try {
      final posms = await _local.posms(param: param);

      return Right(posms);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<Merchandise>>> merchandises({
    Map<String, dynamic>? param,
    int? page,
  }) async {
    try {
      final merchandises = await _local.merchandises(param: param);

      return Right(merchandises);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<SalesPersonScheduleMerchandise>>>
  getSalesPersonScheduleMerchandises({Map<String, dynamic>? param}) async {
    try {
      final merchandiseSchedule = await _local
          .getSalesPersonScheduleMerchandises(args: param);
      return Right(merchandiseSchedule);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<CustomerLedgerEntry>>> getCustomerLedgerEntry({
    Map<String, dynamic>? param,
  }) async {
    try {
      final List<CustomerLedgerEntry> cusLedgerEntry = await _local
          .getCustomerLedgerEntry(param);
      return Right(cusLedgerEntry);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, CustomerLedgerEntry?>> getDetailCustomerLedgerEntry({
    Map<String, dynamic>? param,
  }) async {
    try {
      final CustomerLedgerEntry? cusLedgerEntry = await _local
          .getDetailCustomerLedgerEntry(param);
      return Right(cusLedgerEntry);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<PaymentMethod>>> getPaymentType({
    Map<String, dynamic>? param,
  }) async {
    try {
      final List<PaymentMethod> paymentMethods = await _local.getPaymentType(
        param,
      );
      return Right(paymentMethods);
    } on GeneralException {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, List<CustomerItemLedgerEntry>>> deleteItemCheckStock(
    CheckItemStockArg data,
  ) async {
    try {
      final success = await _local.deleteItemCheckStock(data);

      return Right(success);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CustomerItemLedgerEntry?>> getCustomerItemLedgerEntry({
    Map<String, dynamic>? param,
  }) async {
    try {
      final cile = await _local.getCustomerItemLedgerEntry(args: param);
      return Right(cile);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomerItemLedgerEntry>>>
  getCustomerItemLegerEntries({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      final cile = await _local.getCustomerItemLedgerEntries(
        param: param,
        page: page,
      );
      return Right(cile);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CustomerItemLedgerEntry>>> submitCheckStock(
    List<CustomerItemLedgerEntry> records,
  ) async {
    try {
      final cile = await _local.submitCheckStock(records);
      return Right(cile);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PosSalesHeader>> getPosSaleHeader({
    Map<String, dynamic>? params,
  }) async {
    final saleHeader = await _local.getPosSaleHeader(params: params);
    if (saleHeader == null) {
      return Left(ServerFailure("Sale header not found."));
    }

    return Right(saleHeader);
  }

  @override
  Future<Either<Failure, List<PosSalesHeader>>> getPosSaleHeaders({
    Map<String, dynamic>? params,
  }) async {
    try {
      final headers = await _local.getPosSaleHeaders(params: params);
      return Right(headers);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PosSalesLine>>> getPosSaleLines({
    Map<String, dynamic>? params,
  }) async {
    try {
      final saleLines = await _local.getPosSaleLines(params: params);
      return Right(saleLines);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PosSalesLine?>> getPosSaleLine({
    Map<String, dynamic>? params,
  }) async {
    try {
      final saleLine = await _local.getPosSaleLine(params: params);
      return Right(saleLine);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetitorItemLedgerEntry>>>
  submitCheckStockCometitorItem(List<CompetitorItemLedgerEntry> records) async {
    try {
      final cile = await _local.submitCheckStockCometitorItem(records);
      return Right(cile);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CompetitorItemLedgerEntry?>>
  detailItemCompetitorLederEntry({
    required String itemNo,
    required String visitNo,
  }) async {
    try {
      final records = await _local.detailItemCompetitorLederEntry(
        param: {"item_no": itemNo, "schedule_id": visitNo},
      );

      return Right(records);
    } on Exception {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, CompetitorItemLedgerEntry>>
  updateCompititorItemLedgerEntry(CheckCompititorItemStockArg data) async {
    try {
      final schedule = data.schedule;
      final item = data.item;

      CompetitorItemLedgerEntry? cile = await _local
          .detailItemCompetitorLederEntry(
            param: {'schedule_id': schedule.id, 'item_no': item.no},
          );

      if (cile == null) {
        final User? auth = getAuth();
        final unid = Helpers.generateDocumentNo(auth?.id ?? "");

        if ((item.competitorNo ?? "").isEmpty) {
          throw GeneralException("This item not link to competitor.");
        }

        final compititor = await _local.getCompetitor(
          param: {'no': item.competitorNo},
        );

        if (compititor == null) {
          throw GeneralException("Competitor not found.[${item.competitorNo}]");
        }

        // final uom = await _local.getItemUom(params: {
        //   "item_no": item.no,
        //   "unit_of_measure_code": item.salesUomCode,
        // });

        // if (uom == null) {
        //   throw GeneralException(
        //       "Unit of Measure for item [${item.no}] not found. Please download the master data to ensure your data is up to date.");
        // }

        cile = CompetitorItemLedgerEntry(
          unid,
          appId: unid,
          itemNo: item.no,
          itemDescription: item.description,
          itemDescription2: item.description2,
          description: item.description,
          description2: item.description2,
          scheduleId: schedule.id,
          customerNo: schedule.customerNo,
          customerName: schedule.name,
          customerName2: schedule.name2,
          status: kStatusOpen,
          unitOfMeasureCode: item.salesUomCode,
          qtyPerUnitOfMeasure: 1,
          competitorNo: item.competitorNo,
          competitorName: compititor.name,
          competitorName2: compititor.name2,
          lotNo: data.lotNo,
          serialNo: data.serialNo,
          remark: data.remark,
          quantity: Helpers.formatNumberDb(
            data.stockQty,
            option: FormatType.quantity,
          ),
          volumeSalesQuantity: Helpers.formatNumberDb(
            data.volumSale,
            option: FormatType.quantity,
          ),
          unitPrice: Helpers.formatNumberDb(
            data.unitPrice,
            option: FormatType.price,
          ),
          unitCost: Helpers.formatNumberDb(
            data.unitCost,
            option: FormatType.cost,
          ),
        );
      }

      if (cile.status != null && cile.status != kStatusOpen) {
        throw GeneralException(
          "You cannot modify while the record have been submited.",
        );
      }

      await _local.storeComPetitorItemLedgerEntry(cile: cile, arg: data);

      return Right(cile);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetitorItemLedgerEntry>>>
  getCompetitorItemLedgetEntry({Map<String, dynamic>? param}) async {
    try {
      final cile = await _local.getCompetitorItemLedgetEntry(param: param);
      return Right(cile);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetitorPromtionHeader>>>
  getCompetitorPromotionHeader({
    Map<String, dynamic>? param,
    int page = 1,
  }) async {
    try {
      final records = await _local.getCompetitorPromotionHeader(
        param: param,
        page: page,
      );
      return Right(records);
    } on Exception {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  Future<SalesPersonScheduleMerchandise?> _getSalesPersonScheduleMerchandise({
    Map<String, dynamic>? param,
  }) async {
    return await _local.getSalesPersonScheduleMerchandise(args: param);
  }

  @override
  Future<Either<Failure, SalesPersonScheduleMerchandise>>
  storeSalesPersonScheduleMerchandise({
    required ItemPosmAndMerchandiseArg args,
  }) async {
    try {
      final User? auth = getAuth();
      String documentType = kMerchandize;
      String description = args.merchandis?.description ?? "";
      String description2 = args.merchandis?.description2 ?? "";

      if (args.posmMerchandType == PosmMerchandingType.psom) {
        documentType = kPOSM;
        description = args.posm?.description ?? "";
        description2 = args.posm?.description2 ?? "";
      }

      String merchandiseCode = args.merchandis?.code ?? "";
      if (args.posmMerchandType == PosmMerchandingType.psom) {
        merchandiseCode = args.posm?.code ?? "";
      }

      late SalesPersonScheduleMerchandise? merchandiseSchedule;

      merchandiseSchedule = await _getSalesPersonScheduleMerchandise(
        param: {
          'visit_no': args.schedule.id,
          'merchandise_code': merchandiseCode,
          'merchandise_option': documentType,
          'competitor_no': args.competitor?.no,
        },
      );

      final docNo = Helpers.generateDocumentNo(auth?.id ?? "1");

      merchandiseSchedule =
          merchandiseSchedule ??
          SalesPersonScheduleMerchandise(
            docNo,
            merchandiseCode: merchandiseCode,
            quantity: Helpers.formatNumberDb(args.qty),
            appId: docNo,
            visitNo: Helpers.toInt(args.schedule.id),
            scheduleDate: DateTimeExt.parse(
              args.schedule.scheduleDate,
            ).toDateString(),
            customerNo: args.schedule.customerNo ?? "",
            name: args.schedule.name ?? "",
            name2: args.schedule.name2 ?? "",
            salespersonCode: args.schedule.salespersonCode ?? "",
            description: description,
            description2: description2,
            merchandiseOption: documentType,
            competitorNo: args.competitor?.no,
            merchandiseType: "Competitor",
            status: kStatusOpen,
            isSync: kStatusNo,
            flag: kStatusNo,
          );

      final reuslt = await _local.storeSalesPersonScheduleMerchandise(
        merchandiseSchedule,
        quantity: args.qty,
        status: kStatusOpen,
      );

      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteSalesPersonScheduleMerchandise(
    SalesPersonScheduleMerchandise record,
  ) async {
    try {
      await _local.deleteSalesPersonScheduleMerchandise(record);
      return const Right(true);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception {
      return const Left(CacheFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, List<SalesPersonScheduleMerchandise>>>
  updateSalesPersonScheduleMerchandiseStatus(
    List<SalesPersonScheduleMerchandise> records, {
    required String status,
  }) async {
    try {
      final results = await _local.updateSalesPersonScheduleMerchandiseStatus(
        records,
        status: status,
      );

      return Right(results);
    } on GeneralException catch (e) {
      return Left(CacheFailure(e.message));
    } on Exception {
      return const Left(CacheFailure(errorMessage));
    }
  }

  @override
  Future<Either<Failure, PaymentMethod?>> getPaymentMethod({
    Map<String, dynamic>? param,
  }) async {
    try {
      final reuslt = await _local.getPaymentMethod(param: param);
      return Right(reuslt);
    } on Exception {
      return const Left(CacheFailure(errorInternetMessage));
    }
  }

  @override
  Future<Either<Failure, CashReceiptJournals>> processPayment({
    required PaymentArg arg,
  }) async {
    try {
      final cEntry = arg.customerLedgerEntry;
      final paymentMethod = arg.paymentMethod;
      final schedule = arg.schedule;

      if (Helpers.toStrings(paymentMethod.balanceAccountNo).isEmpty) {
        throw GeneralException('Payment type missing link balance account no');
      }

      if (Helpers.toStrings(paymentMethod.balanceAccountType).isEmpty) {
        throw GeneralException(
          'Payment type missing link balance account type',
        );
      }

      final customer = await _getCustomer(no: schedule.customerNo ?? "");
      if (customer == null) {
        throw GeneralException('Customer not found');
      }

      final userSetup = await _local.getUserSetup();
      if (userSetup == null) {
        throw GeneralException("User setup not found");
      }

      final batchCode = userSetup.genJournalBatchName ?? "";

      final batch = await _local.getGeneralJournalBatch(
        param: {'code': batchCode},
      );

      if (batch == null) {
        throw GeneralException("General journal batch not found.[$batchCode]");
      }

      // Generate a unique document number that does not exist in the journals
      late int docNo;
      late int workingTime = 0;
      while (true) {
        workingTime++;
        docNo = Helpers.generateUniqueNumber();
        final journal = await _local.getCashReceiptJournals({"id": docNo});
        if (journal.isEmpty || workingTime > 5) {
          break;
        }
      }

      final cashJournal = CashReceiptJournals(
        "$docNo",
        appId: "$docNo",
        journalType: "Cash Receipts Journal",
        journalBatchName: userSetup.cashJournalBatchName,
        noSeries: batch.noSeriesCode,
        documentNo: "CC$docNo",
        businessUnitCode: cEntry.businessUnitCode,
        departmentCode: cEntry.departmentCode,
        projectCode: cEntry.projectCode,
        applyToDocNo: cEntry.documentNo,
        applyToDocType: cEntry.documentType,
        documentType: "Receipt",
        sourceType: "Visit",
        sourceNo: schedule.id,
        documentDate: DateTime.now().toDateString(),
        postingDate: DateTime.now().toDateString(),
        customerNo: customer.no,
        description: customer.name,
        description2: customer.name2,
        customerGroupCode: customer.customerGroupCode,
        postingGroup: customer.recPostingGroupCode,
        genBusPostingGroup: customer.genBusPostingGroupCode,
        paymentMethodCode: paymentMethod.code,
        balAccountNo: paymentMethod.balanceAccountNo,
        balAccountType: paymentMethod.balanceAccountType,
        amount: arg.amount,
        amountLcy: arg.amount,
        status: kStatusOpen,
        salespersonCode: userSetup.salespersonCode,
        storeCode: userSetup.storeCode,
        assignToUserId: Helpers.toStrings(userSetup.userId),
        isSync: kStatusNo,
      );

      await _local.processPayment(cashJournal);

      _updateRemainingAmount(cEntry);

      return Right(cashJournal);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  void _updateRemainingAmount(CustomerLedgerEntry cEntry) async {
    final journal = await _local.getCashReceiptJournals({
      "apply_to_doc_no": cEntry.documentNo,
    });

    final totalAmt = journal.fold(0.0, (sum, j) {
      return sum + Helpers.toDouble(j.amountLcy);
    });

    final remainingAmt = Helpers.toDouble(cEntry.amountLcy) - totalAmt;
    _local.updateRemainingAmount(cEntry, remainingAmt);
  }

  @override
  Future<Either<Failure, List<CashReceiptJournals>>> getCashReceiptJournals({
    Map<String, dynamic>? param,
  }) async {
    try {
      final List<CashReceiptJournals> reuslt = await _local
          .getCashReceiptJournals(param);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CashReceiptJournals?>> getCashReceiptJournal({
    Map<String, dynamic>? param,
  }) async {
    try {
      final reuslt = await _local.getCashReceiptJournal(param);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletedPayment(
    CashReceiptJournals journal,
    CustomerLedgerEntry cEntry,
  ) async {
    try {
      await _local.deletedPayment(journal);
      _updateRemainingAmount(cEntry);

      return const Right(true);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CashReceiptJournals>>> processCashReceiptJournals(
    List<CashReceiptJournals> journals,
  ) async {
    try {
      final reuslt = await _local.processCashReceiptJournals(journals);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletedPosSaleHeader(String headerNo) async {
    try {
      await _local.deletedPosSaleHeader(headerNo);
      return const Right(true);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deletedPosSaleLine(PosSalesLine line) async {
    try {
      await _local.deletedPosSaleLine(line);
      return const Right(true);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<PaymentTerm>>> getPaymentTerms({
    Map<String, dynamic>? param,
  }) async {
    try {
      final reuslt = await _local.getPaymentTerms(param);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Distributor>>> getDistributors({
    Map<String, dynamic>? param,
  }) async {
    try {
      final reuslt = await _local.getDistributors(param);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PaymentTerm?>> getPaymentTerm({
    Map<String, dynamic>? param,
  }) async {
    try {
      final reuslt = await _local.getPaymentTerm(param);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesHeader>>> getSaleHeaders({
    Map<String, dynamic>? params,
  }) async {
    try {
      final reuslt = await _local.getSaleHeaders(args: params);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalesLine>>> getSaleLines({
    Map<String, dynamic>? params,
  }) async {
    try {
      final reuslt = await _local.getSaleLines(args: params);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
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
  Future<Either<Failure, List<ItemPrizeRedemptionLineEntry>>>
  getItemPrizeRedemptionEntries({Map<String, dynamic>? param}) async {
    try {
      final reuslt = await _local.getItemPrizeRedemptionEntries(param: param);

      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CompetitorPromotionLine>>> getCompetitorProLine({
    Map<String, dynamic>? param,
  }) async {
    try {
      final reuslt = await _local.getCompetitorProLine(param: param);
      return Right(reuslt);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ItemPrizeRedemptionLineEntry>>>
  processTakeInRedemption({
    required ItemPrizeRedemptionHeader header,
    required SalespersonSchedule schedule,
    required double quantity,
  }) async {
    try {
      final customer = await _getCustomer(no: schedule.customerNo ?? "");
      if (customer == null) {
        throw GeneralException('Customer not found');
      }

      final lines = await _local.getItemPrizeRedemptionLine(
        param: {'promotion_no': header.no},
      );

      if (lines.isEmpty) {
        return Left(ServerFailure("Line not found."));
      }

      final today = DateTime.now();

      List<ItemPrizeRedemptionLineEntry> entries = [];
      for (final line in lines) {
        final id = Helpers.generateUniqueNumber();

        final entry = ItemPrizeRedemptionLineEntry(
          id.toString(),
          appId: id.toString(),
          scheduleId: schedule.id,
          scheduleDate: today.toDateString(),
          promotionNo: header.no,
          salespersonCode: schedule.salespersonCode,
          lineNo: Helpers.toInt(line.lineNo),
          customerNo: customer.no,
          customerName: customer.name,
          customerName2: customer.name2,
          itemNo: line.itemNo,
          unitOfMeasureCode: line.unitOfMeasureCode,
          qtyPerUnitOfMeasure: line.qtyPerUnitOfMeasure,
          description: line.description,
          description2: line.description2,
          isSync: kStatusNo,
          status: kStatusOpen,
          sourceType: "Visit",
          sourceNo: schedule.id,
          quantity: Helpers.toDouble(line.quantity) * quantity,
          redemptionType: line.redemptionType,
        );

        entries.add(entry);
      }

      await _local.processTakeInRedemption(header, entries, schedule.id);

      return Right(entries);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteTakeInRedemption(
    ItemPrizeRedemptionHeader header,
    String scheduleId,
  ) async {
    try {
      await _local.deleteTakeInRedemption(header, scheduleId);
      return const Right(true);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> processSubmitRedemption(
    List<ItemPrizeRedemptionLineEntry> entries,
  ) async {
    try {
      await _local.processSubmitRedemption(entries);
      return const Right(true);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, SalesLine?>> getSaleLine({
    Map<String, dynamic>? params,
  }) async {
    try {
      final sale = await _local.getSaleLine(args: params);
      return Right(sale);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AppVersion?>> checkAppVersion({
    Map<String, dynamic>? param,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final appVersion = await _remote.checkAppVersion(data: param);
        return Right(appVersion);
      }
      return const Right(null);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> moveOldScheduleToCurrentDate(
    List<SalespersonSchedule> oldSchedules,
  ) async {
    try {
      if (await _networkInfo.isConnected && await _remote.isValidApiSession()) {
        List<Map<String, dynamic>> jsonData = [];
        for (var record in oldSchedules) {
          final s = record.toJson();
          jsonData.add(s);
        }

        if (jsonData.isEmpty) {
          return const Left(CacheFailure("Nothing to upload"));
        }

        await _remote.processUpload(
          data: {'table_name': 'schedule', 'data': jsonEncode(jsonData)},
        );
      }
      final result = await _local.moveOldScheduleToCurrentDate(oldSchedules);
      return Right(result);
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalePersonGpsModel>>> getSalepersonGps() async {
    try {
      if (await _networkInfo.isConnected && await _remote.isValidApiSession()) {
        final result = await _remote.getSalepersonGps();
        List<SalePersonGpsModel> salePersonGps = [];
        for (var r in result["records"]) {
          salePersonGps.add(SalePersonGpsModel.fromJson(r));
        }
        return Right(salePersonGps);
      }

      return Left(ServerFailure(errorInternetMessage));
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<SalespersonSchedule>>> getTeamSchedules({
    Map<String, dynamic>? param,
  }) async {
    try {
      if (await _networkInfo.isConnected) {
        final schedules = await _remote.getTeamSchedule(param: param);
        List<SalespersonSchedule> teamSchedules = [];
        for (var a in schedules["records"]) {
          teamSchedules.add(SalespersonScheduleExtension.fromMap(a));
        }

        return Right(teamSchedules);
      }
      return const Left(CacheFailure(errorInternetMessage));
    } on GeneralException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
  
  @override
  Future<void> cleanupSchedules() {
    return _local.cleanupSchedules();
  }
}
