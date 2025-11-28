import 'package:realm/realm.dart';
part 'schemas.realm.dart';

@MapTo('APP_SERVER')
@RealmModel()
class _AppServer {
  @PrimaryKey()
  late String id;
  late String name;
  late String icon;
  late int hide;
  late String url;
  @MapTo('backend_url')
  late String backendUrl;
}

@MapTo('COMPANY_INFORMATION')
@RealmModel()
class _CompanyInformation {
  @PrimaryKey()
  late String id;
  late String? name;
  @MapTo('phone_no')
  late String? phoneNo;
  @MapTo('name_2')
  late String? name2;
  late String? address;
  @MapTo('address_2')
  late String? address2;
  @MapTo('logo_128')
  late String? logo128;
  late String? email;
}

@MapTo('DISTRIBUTION_SETUP')
@RealmModel()
class _DistributionSetUp {
  @PrimaryKey()
  late String key;
  late String value;
}

@MapTo('ORGANIZATION')
@RealmModel()
class _Organization {
  @MapTo('user_id')
  @PrimaryKey()
  late String userId;
  @MapTo('orgnaization_name')
  late String? organizationName;
  @MapTo('database_name')
  late String? databaseName;
  late String? logo;
  @MapTo('type_of_industry')
  late String? typeOfIndustry;
  @MapTo('business_industry')
  late String? businessIndustry;
  @MapTo('contact_name')
  late String? contactName;
  @MapTo('phone_no')
  late String? phoneNo;
  late String? email;
  late String? website;
  late String? address;
  @MapTo('address_2')
  late String? address2;
  late String? status;
  @MapTo('register_date')
  late String? registerDate;
  @MapTo('in_maintenance_mode')
  late String? inMaintenanceMode;
}

@MapTo('PERMISSION')
@RealmModel()
class _Permission {
  @PrimaryKey()
  late String key;
  late String value;
}

@MapTo('APP_SYNC_LOG')
@RealmModel()
class _AppSyncLog {
  @PrimaryKey()
  @MapTo('table_name')
  late String tableName;
  @MapTo('display_name')
  late String? displayName;
  @MapTo('user_agent')
  late String? userAgent;
  late String? type;
  @MapTo('last_synched_datetime')
  late String? lastSynchedDatetime;
  @MapTo('last_local_query_datetime')
  late String? lastLocalQueryDatetime;
  late String? total;
  @MapTo('set_record_after_download')
  late String? setRecordAfterDownload = 'No';
}

@MapTo('BANK_ACCOUNT')
@RealmModel()
class _BankAccount {
  @PrimaryKey()
  late String no;
  String? name;
  @MapTo('name_2')
  late String? name2;
  late String? address;
  @MapTo('address_2')
  late String? address2;
  @MapTo('post_code')
  String? postCode;
  String? village;
  String? commune;
  String? district;
  String? province;
  @MapTo('country_code')
  String? countryCode;
  @MapTo('phone_no')
  String? phoneNo;
  @MapTo('phone_no_2')
  String? phoneNo2;
  String? email;
  String? contactName;
  @MapTo('transit_no')
  String? transitNo;
  @MapTo('bank_account_no')
  String? bankAccountNo;
  @MapTo('currency_code')
  String? currencyCode;
  @MapTo('swift_code')
  String? swiftCode;
  @MapTo('last_check_no')
  String? lastCheckNo;
  @MapTo('last_statement_no')
  String? lastStatementNo;
  @MapTo('last_payment_statement_no')
  String? lastPaymentStatementNo;
  @MapTo('bank_acc_posting_group')
  String? bankAccPostingGroup;
  @MapTo('division_code')
  String? divisionCode;
  @MapTo('branch_code')
  String? branchCode;
  @MapTo('mobile_payment')
  String? mobilePayment;
  @MapTo('inctived')
  late String inctived = 'No';
  @MapTo('is_sync')
  late String isSync = 'Yes';
  @MapTo('created_at')
  String? createdAt;
  @MapTo('updated_at')
  String? updatedAt;
}

@MapTo('CUSTOMER')
@RealmModel()
class _Customer {
  @PrimaryKey()
  late String no;
  late String? name;
  @MapTo('name_2')
  late String? name2;
  late String? address;
  @MapTo('address_2')
  late String? address2;
  @MapTo('post_code')
  late String? postCode;
  late String? village;
  late String? commune;
  late String? district;
  late String? province;
  @MapTo('country_code')
  late String? countryCode;
  @MapTo('phone_no')
  late String? phoneNo;
  @MapTo('phone_no_2')
  late String? phoneNo2;
  @MapTo('fax_no')
  late String? faxNo;
  late String? email;
  late String? website;
  @MapTo('primary_contact_no')
  late String? primaryContactNo;
  late String? contactName;
  @MapTo('territory_code')
  late String? territoryCode;
  @MapTo('customer_group_code')
  late String? customerGroupCode;
  @MapTo('payment_term_code')
  late String? paymentTermCode;
  @MapTo('shipment_method_code')
  late String? shipmentMethodCode;
  @MapTo('shipment_agent_code')
  late String? shipmentAgentCode;
  @MapTo('ship_to_code')
  late String? shipToCode;
  @MapTo('store_code')
  late String? storeCode;
  @MapTo('division_code')
  late String? divisionCode;
  @MapTo('business_unit_code')
  late String? businessUnitCode;
  @MapTo('department_code')
  late String? departmentCode;
  @MapTo('project_code')
  late String? projectCode;
  @MapTo('salesperson_code')
  late String? salespersonCode;
  @MapTo('distributor_code')
  late String? distributorCode;
  @MapTo('location_code')
  late String? locationCode;
  @MapTo('customer_discount_code')
  late String? customerDiscountCode;
  @MapTo('customer_price_group_code')
  late String? customerPriceGroupCode;
  @MapTo('currency_code')
  late String? currencyCode;
  @MapTo('rec_posting_group_code')
  late String? recPostingGroupCode;
  @MapTo('vat_posting_group_code')
  late String? vatPostingGroupCode;
  @MapTo('gen_bus_posting_group_code')
  late String? genBusPostingGroupCode;
  @MapTo('sales_kpi_analysis_code')
  late String? salesKpiAnalysisCode;
  @MapTo('price_include_vat')
  late String? priceIncludeVat = 'No';
  @MapTo('tax_registration_no')
  late String? taxRegistrationNo;
  @MapTo('credit_limited_type')
  late String? creditLimitedType;
  @MapTo('credit_limited_amount')
  late double? creditLimitedAmount;
  late String? tag;
  late String? passcode;
  late String? logo;
  @MapTo('avatar_32')
  late String? avatar32;
  @MapTo('avatar_128')
  late String? avatar128;
  late String? inactived = 'No';
  @MapTo('frequency_visit_peroid')
  late String? frequencyVisitPeroid = '1W';
  late String? monday = 'No';
  late String? tuesday = 'No';
  late String? wednesday = 'No';
  late String? thursday = 'No';
  late String? friday = 'No';
  late String? saturday = 'No';
  late String? sunday = 'No';
  late double? latitude;
  late double? longitude;
  @MapTo('registered_date')
  late String? registeredDate;
  @MapTo('approved_date')
  late String? approvedDate;
  late String? status = 'Open';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;

  @Ignored()
  double? distance;
}

@MapTo('CUSTOMER_ADDRESS')
@RealmModel()
class _CustomerAddress {
  @PrimaryKey()
  late String id;
  @MapTo('customer_no')
  late String? customerNo;
  late String? code;
  late String? name;
  @MapTo('name_2')
  late String? name2;
  late String? address;
  @MapTo('address_2')
  late String? address2;
  @MapTo('post_code')
  late String? postCode;
  late String? village;
  late String? commune;
  late String? district;
  late String? province;
  @MapTo('country_code')
  late String? countryCode;
  @MapTo('phone_no')
  late String? phoneNo;
  @MapTo('phone_no_2')
  late String? phoneNo2;
  late String? email;
  @MapTo('contact_name')
  late String? contactName;
  late double? latitude;
  late double? longitude;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('is_default')
  late String? isDefault = 'No';
  @MapTo('is_deleted')
  late String? isDeleted = 'No';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('COMPETITOR')
@RealmModel()
class _Competitor {
  @PrimaryKey()
  late String no;
  late String? name;
  @MapTo('name_2')
  late String? name2;
  late String? address;
  @MapTo('address_2')
  late String? address2;
  @MapTo('post_code')
  late String? postCode;
  late String? village;
  late String? commune;
  late String? district;
  late String? province;
  @MapTo('country_code')
  late String? countryCode;
  @MapTo('phone_no')
  late String? phoneNo;
  @MapTo('phone_no_2')
  late String? phoneNo2;
  @MapTo('fax_no')
  late String? faxNo;
  late String? email;
  late String? website;
  @MapTo('primary_contact_no')
  late String? primaryContactNo;
  late String? contactName;
  @MapTo('territory_code')
  late String? territoryCode;
  @MapTo('payment_term_code')
  late String? paymentTermCode;
  @MapTo('payment_method_code')
  late String? paymentMethodCode;
  @MapTo('shipment_method_code')
  late String? shipmentMethodCode;
  @MapTo('shipment_agent_code')
  late String? shipmentAgentCode;
  @MapTo('store_code')
  late String? storeCode;
  @MapTo('division_code')
  late String? divisionCode;
  @MapTo('business_unit_code')
  late String? businessUnitCode;
  @MapTo('department_code')
  late String? departmentCode;
  @MapTo('project_code')
  late String? projectCode;
  @MapTo('purchaser_code')
  late String? purchaserCode;
  @MapTo('distributor_code')
  late String? distributorCode;
  @MapTo('location_code')
  late String? locationCode;
  @MapTo('currency_code')
  late String? currencyCode;
  @MapTo('ap_posting_group_code')
  late String? apPostingGroupCode;
  @MapTo('gen_bus_posting_group_code')
  late String? genBusPostingGroupCode;
  @MapTo('vat_bus_posting_group_code')
  late String? vatBusPostingGroupCode;
  @MapTo('price_include_vat')
  late String? priceIncludeVat = 'No';
  @MapTo('tax_registration_no')
  late String? taxRegistrationNo;
  late String? logo;
  @MapTo('avatar_32')
  late String? avatar32;
  @MapTo('avatar_128')
  late String? avatar128;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('CURRENCY')
@RealmModel()
class _Currency {
  @PrimaryKey()
  late String code;
  late String? description;
  @MapTo('description_2')
  late String? description2;
  @MapTo('realized_gains_account_no')
  late String? realizedGainsAccountNo;
  @MapTo('realised_losses_account_no')
  late String? realisedLossesAccountNo;
  @MapTo('unrealized_gains_account_no')
  late String? unrealizedGainsAccountNo;
  @MapTo('unrealised_losses_account_no')
  late String? unrealisedLossesAccountNo;
  @MapTo('unit_amount_decimal')
  late double? unitAmountDecimal;
  @MapTo('amount_decimal')
  late double? amountDecimal;
  late String? symbol;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('CURRENCY_EXCHANGE_RATE')
@RealmModel()
class _CurrencyExchangeRate {
  @PrimaryKey()
  late String id;
  @MapTo('starting_date')
  late String? startingDate;
  @MapTo('currency_code')
  late String? currencyCode;
  @MapTo('exchange_amount')
  late double? exchangeAmount;
  @MapTo('exchange_rate')
  late double? exchangeRate;
  @MapTo('currency_factor')
  late double? currencyFactor;
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('DISTRIBUTOR')
@RealmModel()
class _Distributor {
  @PrimaryKey()
  late String code;
  late String? name;
  @MapTo('name_2')
  late String? name2;
  late String? address;
  @MapTo('address_2')
  late String? address2;
  @MapTo('post_code')
  late String? postCode;
  late String? village;
  late String? commune;
  late String? district;
  late String? province;
  @MapTo('country_code')
  late String? countryCode;
  @MapTo('location_code')
  late String? locationCode;
  @MapTo('phone_no')
  late String? phoneNo;
  @MapTo('phone_no_2')
  late String? phoneNo2;
  late String? email;
  late String? contactName;
  @MapTo('inactived')
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('LOCATION')
@RealmModel()
class _Location {
  @PrimaryKey()
  late String code;
  late String? description;
  @MapTo('description_2')
  late String? description2;
  late String? address;
  @MapTo('address_2')
  late String? address2;
  @MapTo('is_intransit')
  late String? isIntransit;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
}

@MapTo('MERCHANDISE')
@RealmModel()
class _Merchandise {
  @PrimaryKey()
  late String code;
  late String? description;
  @MapTo('description_2')
  late String? description2;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('PAYMENT_METHOD')
@RealmModel()
class _PaymentMethod {
  @PrimaryKey()
  late String code;
  @MapTo('code_2')
  late String? code2;
  late String? description;
  @MapTo('description_2')
  late String? description2;
  @MapTo('balance_account_type')
  late String? balanceAccountType;
  @MapTo('balance_account_no')
  late String? balanceAccountNo;
  @MapTo('app_icon')
  late String? appIcon;
  @MapTo('app_icon_32')
  late String? appIcon32;
  @MapTo('app_icon_128')
  late String? appIcon128;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('PAYMENT_TERM')
@RealmModel()
class _PaymentTerm {
  @PrimaryKey()
  late String code;
  late String? description;
  @MapTo('description_2')
  late String? description2;
  @MapTo('due_date_calculation')
  late String? dueDateCalculation;
  @MapTo('discount_date_calculation')
  late String? discountDateCalculation;
  @MapTo('discount_percentage')
  late double? discountPercentage;
  @MapTo('discount_amount')
  late double? discountAmount;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
}

@MapTo('GENERAL_JOURNAL_BATCH')
@RealmModel()
class _GeneralJournalBatch {
  @PrimaryKey()
  late String id;
  late String? code;
  late String? description;
  @MapTo('description_2')
  late String? description2;
  late String? type;
  @MapTo('no_series_code')
  late String? noSeriesCode;
  @MapTo('bal_account_type')
  late String? balAccountType;
  @MapTo('bal_account_no')
  late String? balAccountNo;
  @MapTo('bal_account_type_value')
  late String? balAccountTypeValue;
  @MapTo('bal_account_no_value')
  late String? balAccountNoValue;
  @MapTo('reason_code')
  late String? reasonCode;
  @MapTo('is_cheque_control')
  late String? isChequeControl;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('PROMOTION_TYPE')
@RealmModel()
class _PromotionType {
  @PrimaryKey()
  late String code;
  late String? description;
  @MapTo('description_2')
  late String? description2;
  @MapTo('allow_manual')
  late String? allowManual;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('POINT_OF_SALES_MATERIAL')
@RealmModel()
class _PointOfSalesMaterial {
  @PrimaryKey()
  late String code;
  late String? description;
  @MapTo('description_2')
  late String? description2;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('SALESPERSON')
@RealmModel()
class _Salesperson {
  @PrimaryKey()
  late String code;
  late String? name;
  @MapTo('name_2')
  late String? name2;
  late String? title;
  @MapTo('division_code')
  late String? divisionCode;
  @MapTo('branch_code')
  late String? branchCode;
  @MapTo('business_unit_code')
  late String? businessUnitCode;
  @MapTo('salesperson_group_code')
  late String? salespersonGroupCode;
  late String? email;
  @MapTo('phone_no')
  late String? phoneNo;
  late String? avatar;
  @MapTo('avatar_32')
  late String? avatar32;
  @MapTo('avatar_128')
  late String? avatar128;
  @MapTo('stock_check_option')
  late String? stockCheckOption;
  late String? level;
  @MapTo('level_index')
  late String? levelIndex;
  @MapTo('joined_date')
  late String? joinedDate;
  late String? inactived = 'No';
  @MapTo('customer_stock_check')
  late String? customerStockCheck;
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('downline_data')
  late String? downLineData;
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

@MapTo('SUB_CONTRACT_TYPE')
@RealmModel()
class _SubContractType {
  @PrimaryKey()
  late String code;
  late String? description;
  @MapTo('description_2')
  late String? description2;
  @MapTo('contract_code')
  late String? contractCode;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}

// @MapTo('UNIT_OF_MEASURE')
// @RealmModel()
// class _UnitOfMeasure {
//   @PrimaryKey()
//   late String code;
//   late String? description;
//   @MapTo('description_2')
//   late String? description2;
//   @MapTo('quantity_decimal')
//   late String? quantityDecimal;
//   late double? factor = 1;
//   late String? inactived = 'No';
//   @MapTo('is_sync')
//   late String? isSync = 'Yes';
//   @MapTo('created_at')
//   late String? createdAt;
//   @MapTo('updated_at')
//   late String? updatedAt;
// }

@MapTo("VAT_POSTING_SETUP")
@RealmModel()
class _VatPostingSetup {
  @PrimaryKey()
  late String id;
  @MapTo('vat_bus_posting_group')
  late String? vatBusPostingGroup;
  @MapTo('vat_prod_posting_group')
  late String? vatProdPostingGroup;
  @MapTo('vat_calculation_type')
  late String? vatCalculationType;
  @MapTo('vat_amount')
  late String? vatAmount;
  late String? inactived = 'No';
  @MapTo('is_sync')
  late String? isSync = 'Yes';
  @MapTo('created_at')
  late String? createdAt;
  @MapTo('updated_at')
  late String? updatedAt;
}
