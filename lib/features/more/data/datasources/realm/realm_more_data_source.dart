import 'package:salesforce/core/data/datasources/realm/base_realm_data_source.dart';
import 'package:salesforce/features/more/domain/entities/sale_detail.dart';
import 'package:salesforce/features/more/domain/entities/user_info.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

abstract class RealmMoreDataSource extends BaseRealmDataSource {
  Future<SaleDetail?> getSaleDetails({Map<String, dynamic>? param});

  Future<PosSalesHeader?> getPosSaleHeader({Map<String, dynamic>? param});

  Future<List<PosSalesLine>> getPosSaleLines({Map<String, dynamic>? param});

  Future<Customer> updateCustomer(Customer customer);
  Future<Customer> storeNewCustomer(Customer customer);
  Future<void> deleteCustomerAddress(CustomerAddress address);

  Future<CustomerAddress> updateOrNewCustomerAddress(CustomerAddress address);
  Future<List<ItemPrizeRedemptionHeader>> getItemPrizeRedemptionHeader({
    Map<String, dynamic>? param,
  });

  Future<List<ItemPrizeRedemptionLine>> getItemPrizeRedemptionLine({
    Map<String, dynamic>? param,
  });

  Future<void> updateProfileUser({
    required LoginSession user,
    UserInfo? userInfo,
  });
  Future<void> storePosSale({
    required PosSalesHeader saleHeader,
    required List<PosSalesLine> saleLines,
    bool refreshLine = true,
  });
  Future<DevicePrinter> storeDevicePrinter(DevicePrinter customer);
  Future<List<DevicePrinter>> getDevicePrinter({Map<String, dynamic>? param});
}
