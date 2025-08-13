import 'package:realm/realm.dart';
import 'package:salesforce/core/constants/constants.dart';

part 'general_schemas.realm.dart';

@MapTo("USER_SETUP")
@RealmModel()
class _UserSetup {
  @PrimaryKey()
  late String email;
  @MapTo('role_code')
  String? roleCode;
  @MapTo('permission_code')
  String? permissionCode;
  @MapTo('location_code')
  String? locationCode;
  @MapTo('intransit_location_code')
  String? intransitLocationCode;
  @MapTo('business_unit_code')
  String? businessUnitCode;
  @MapTo('division_code')
  String? divisionCode;
  @MapTo('store_code')
  String? storeCode;
  @MapTo('project_code')
  String? projectCode;
  @MapTo('salesperson_code')
  String? salespersonCode;
  @MapTo('distributor_code')
  String? distributorCode;
  @MapTo('department_code')
  String? departmentCode;
  @MapTo('cash_journal_batch_name')
  String? cashJournalBatchName;
  @MapTo('cash_bank_account_code')
  String? cashBankAccountCode;
  @MapTo('pay_journal_batch_name')
  String? payJournalBatchName;
  @MapTo('gen_journal_batch_name')
  String? genJournalBatchName;
  @MapTo('item_journal_batch_name')
  String? itemJournalBatchName;
  String? type;
  @MapTo('from_location_code')
  String? fromLocationCode;
  @MapTo('customer_no')
  String? customerNo;
  @MapTo('vendor_no')
  String? vendorNo;

  @MapTo('user_id')
  int? userId;
}

@MapTo("PROFILE")
@RealmModel()
class _Profile {
  @PrimaryKey()
  late String email;
  @MapTo('first_name')
  String? firstName;
  @MapTo('last_name')
  String? lastName;
  String? gender;
  @MapTo('date_of_birth')
  String? dateOfBirth;
  @MapTo('id_card_no')
  String? idCardNo;
  @MapTo('phone_no')
  String? phoneNo;
  @MapTo('user_email')
  String? userEmail;
  @MapTo('organization_name')
  String? organizationName;
  @MapTo('business_industry')
  String? businessIndustry;
  @MapTo('sub_business_industry')
  String? subBusinessIndustry;
  @MapTo('user_type')
  String? userType;
  String? address;
  @MapTo('address_2')
  String? address2;
  @MapTo('country_code')
  String? countryCode;
  String? city;
  String? avatar;
  @MapTo('avatar_32')
  String? avatar32;
  @MapTo('avatar_128')
  String? avatar128;
  String? locale;
  @MapTo('time_zone')
  String? timeZone;
  @MapTo('table_pagination')
  int? tablePagination;
}

@MapTo("APPLICATION_SETUP")
@RealmModel()
class _ApplicationSetup {
  @PrimaryKey()
  late String id;
  @MapTo('decimal_point')
  late String? decimalPoint;
  @MapTo('separator_symbol')
  late String? separatorSymbol;
  @MapTo('quantity_decimal')
  late int? quantityDecimal;
  @MapTo('price_decimal')
  late int? priceDecimal;
  @MapTo('cost_decimal')
  late int? costDecimal;
  @MapTo('measurement_decimal')
  late int? measurementDecimal;
  @MapTo('general_decimal')
  late int? generalDecimal;
  @MapTo('amount_decimal')
  late int? amountDecimal;
  @MapTo('percentage_decimal')
  late int? percentageDecimal;
  @MapTo('item_qty_format')
  late int? itemQtyFormat = 0;
  @MapTo('allow_posting_from')
  late String? allowPostingFrom;
  @MapTo('allow_posting_to')
  late String? allowPostingTo;
  @MapTo('local_currency_code')
  late String? localCurrencyCode = "USD";
  @MapTo('decimal_zero')
  late String? decimalZero;
  @MapTo('income_closing_period')
  late String? incomeClosingPeriod;
  @MapTo('scroll_pagination')
  late String? scrollPagination;
  @MapTo('default_sales_vat_acc_no')
  late String? defaultSalesVatAccNo;
  @MapTo('default_purchase_vat_acc_no')
  late String? defaultPurchaseVatAccNo;
  @MapTo('default_ap_acc_no')
  late String? defaultApAccNo;
  @MapTo('default_ar_acc_no')
  late String? defaultArAccNo;
  @MapTo('default_bank_acc_no')
  late String? defaultBankAccNo;
  @MapTo('default_cash_acc_no')
  late String? defaultCashAccNo;
  @MapTo('default_cost_acc_no')
  late String? defaultCostAccNo;
  @MapTo('default_sales_acc_no')
  late String? defaultSalesAccNo;
  @MapTo('default_purchase_acc_no')
  late String? defaultPurchaseAccNo;
  @MapTo('default_inventory_acc_no')
  late String? defaultInventoryAccNo;
  @MapTo('default_positive_adj_account_no')
  late String? defaultPositiveAdjAccountNo;
  @MapTo('default_negative_adj_account_no')
  late String? defaultNegativeAdjAccountNo;
  @MapTo('default_inv_posting_group')
  late String? defaultInvPostingGroup;
  @MapTo('default_ap_posting_group')
  late String? defaultApPostingGroup;
  @MapTo('default_ar_posting_group')
  late String? defaultArPostingGroup;
  @MapTo('default_gen_bus_posting_group')
  late String? defaultGenBusPostingGroup;
  @MapTo('default_gen_prod_posting_group')
  late String? defaultGenProdPostingGroup;
  @MapTo('default_vat_bus_posting_group')
  late String? defaultVatBusPostingGroup;
  @MapTo('default_vat_prod_posting_group')
  late String? defaultVatProdPostingGroup;
  @MapTo('default_payment_term')
  late String? defaultPaymentTerm;
  @MapTo('default_stock_unit_measure')
  late String? defaultStockUnitMeasure;
  @MapTo('default_item_price_include_vat')
  late String? defaultItemPriceIncludeVat;
  @MapTo('accept_eorder_order_status')
  late String? acceptEorderOrderStatus;
  @MapTo('auto_accept_incoming_eorder')
  late String? autoAcceptIncomingEorder;
  @MapTo('ctrl_item_tracking')
  String? ctrlItemTracking = kStatusNo;
}

@MapTo("LOGIN_SESSION")
@RealmModel()
class _LoginSession {
  @PrimaryKey()
  late String id;
  String? username;
  @MapTo('phone_no')
  String? phoneNo;
  String? email;
  @MapTo('access_token')
  String? accessToken;
  @MapTo('last_login_datetime')
  String? lastLoginDateTime;
  @MapTo('avatar_128')
  String? avatar128;
  @MapTo('locale')
  String? locale;
  @MapTo('time_zone')
  String? timeZone;
  @MapTo('account_id')
  int? accountId;
  @MapTo('is_login')
  String? isLogin = "No";
}

@MapTo('APP_SETTING')
@RealmModel()
class _AppSetting {
  @PrimaryKey()
  late String key;
  late String value;
}

@MapTo('GPS_ROUTE_TRACKING')
@RealmModel()
class _GpsRouteTracking {
  @MapTo('saleperson_code')
  late String salepersonCode;
  late double latitude;
  late double longitude;
  @MapTo('created_date')
  late String createdDate;
  @MapTo('created_time')
  late String createdTime;
  @MapTo('is_sync')
  String isSync = "No";
}

@MapTo('ITEM_LEDGER_ENTRY')
@RealmModel()
class _ItemLedgerEntry {
  @MapTo('item_no')
  late String itemNo;
  @MapTo('lot_no')
  late String lotNo;
  @MapTo('serail_no')
  late String serailNo;
  late double quantity;
  late String date;
}
