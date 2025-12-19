import 'package:salesforce/core/data/datasources/realm/base_realm_data_source_impl.dart';
import 'package:salesforce/features/more/domain/entities/user_info.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/features/more/data/datasources/realm/realm_more_data_source.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class RealmMoreDataSourceImpl extends BaseRealmDataSourceImpl
    implements RealmMoreDataSource {
  final ILocalStorage ils;
  RealmMoreDataSourceImpl({required this.ils}) : super(ils: ils);

  @override
  Future<SaleDetail?> getSaleDetails({Map<String, dynamic>? param}) async {
    return await ils.getFirst(args: param);
  }

  @override
  Future<PosSalesHeader?> getPosSaleHeader({
    Map<String, dynamic>? param,
  }) async {
    return await ils.getFirst(args: param);
  }

  @override
  Future<List<PosSalesLine>> getPosSaleLines({
    Map<String, dynamic>? param,
  }) async {
    return ils.getAll<PosSalesLine>(args: param);
  }

  @override
  Future<CustomerAddress> updateOrNewCustomerAddress(
    CustomerAddress address,
  ) async {
    return await ils.writeTransaction((realm) {
      realm.add(address, update: true);

      return address;
    });
  }

  @override
  Future<Customer> storeNewCustomer(Customer customer) async {
    return await ils.writeTransaction((realm) {
      realm.add(customer);

      return customer;
    });
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    return await ils.writeTransaction((realm) {
      customer.name = customer.name;
      customer.phoneNo = customer.phoneNo;
      customer.address = customer.address;
      customer.email = customer.email;
      customer.latitude = customer.latitude;
      customer.longitude = customer.longitude;

      realm.add(customer, update: true);

      return customer;
    });
  }

  @override
  Future<void> deleteCustomerAddress(CustomerAddress address) async {
    return await ils.delete<CustomerAddress>(address);
  }

  @override
  Future<List<ItemPrizeRedemptionHeader>> getItemPrizeRedemptionHeader({
    Map<String, dynamic>? param,
  }) async {
    return await ils.getAll<ItemPrizeRedemptionHeader>(args: param);
  }

  @override
  Future<List<ItemPrizeRedemptionLine>> getItemPrizeRedemptionLine({
    Map<String, dynamic>? param,
  }) async {
    return await ils.getAll<ItemPrizeRedemptionLine>(args: param);
  }

  @override
  Future<void> updateProfileUser({
    required LoginSession user,
    UserInfo? userInfo,
  }) async {
    return await ils.writeTransaction((realm) {
      user.username = userInfo?.userName ?? "";
      user.avatar128 = userInfo?.userImagePath ?? "";
      user.phoneNo = userInfo?.phoneNumber ?? "";

      realm.add(user, update: true);
    });
  }

  @override
  Future<void> storePosSale({
    required PosSalesHeader saleHeader,
    required List<PosSalesLine> saleLines,
    bool refreshLine = true,
  }) async {
    final header = await ils.getFirst<PosSalesHeader>(
      args: {'no': saleHeader.no, 'document_type': saleHeader.documentType},
    );

    List<PosSalesLine> allExistedLines = [];
    if (refreshLine) {
      final itemNos = saleLines.map((line) => '"${line.no}"').toList();
      allExistedLines = await ils.getAll<PosSalesLine>(
        args: {
          'document_no': saleHeader.no,
          'customer_no': saleHeader.customerNo,
          'document_type': saleHeader.documentType,
          'no': 'IN {${itemNos.join(",")}}',
          'special_type_no': '',
        },
      );
    }

    await ils.writeTransaction((realm) {
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
  Future<DevicePrinter> storeDevicePrinter(DevicePrinter customer) async {
    return await ils.add(customer);
  }

  @override
  Future<List<DevicePrinter>> getDevicePrinter({
    Map<String, dynamic>? param,
  }) async {
    return await ils.getAll<DevicePrinter>();
  }

  @override
  Future<void> deletePrinter(DevicePrinter device) async {
    return await ils.delete<DevicePrinter>(device);
  }

  @override
  Future<void> storeSaleHeaders({required List<SalesHeader> saleHeader}) async {
    return await ils.addAll<SalesHeader>(saleHeader);
  }

  @override
  Future<void> deletSaleHeader({required List<SalesHeader> saleHeader}) async {
    return await ils.deleteAll<SalesHeader>();
  }

  @override
  Future<void> storeSaleLine({required List<SalesLine> saleLine}) async {
    return await ils.addAll<SalesLine>(saleLine);
  }
}
