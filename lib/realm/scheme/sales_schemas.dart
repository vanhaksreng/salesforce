import 'package:realm/realm.dart';
part 'sales_schemas.realm.dart';

@MapTo('POS_SALES_HEADER')
@RealmModel()
class _PosSalesHeader {
  @PrimaryKey()
  late int id;
  @MapTo('document_type')
  String? documentType;
  @MapTo('no')
  String? no;
  @MapTo('customer_no')
  String? customerNo;
  @MapTo('customer_name')
  String? customerName;
  @MapTo('customer_name_2')
  String? customerName2;
  @MapTo('address')
  String? address;
  @MapTo('address_2')
  String? address2;
  @MapTo('location_code')
  String? locationCode;
  @MapTo('ship_to_code')
  String? shipToCode;
  @MapTo('ship_to_name')
  String? shipToName;
  @MapTo('ship_to_name_2')
  String? shipToName2;
  @MapTo('ship_to_address')
  String? shipToAddress;
  @MapTo('ship_to_address_2')
  String? shipToAddress2;
  @MapTo('ship_to_contact_name')
  String? shipToContactName;
  @MapTo('ship_to_phone_no')
  String? shipToPhoneNo;
  @MapTo('ship_to_phone_no_2')
  String? shipToPhoneNo2;
  @MapTo('document_date')
  String? documentDate;
  @MapTo('posting_date')
  String? postingDate;
  @MapTo('request_shipment_date')
  String? requestShipmentDate;
  @MapTo('posting_description')
  String? postingDescription;
  @MapTo('payment_term_code')
  String? paymentTermCode;
  @MapTo('payment_method_code')
  String? paymentMethodCode;
  @MapTo('shipment_method_code')
  String? shipmentMethodCode;
  @MapTo('shipment_agent_code')
  String? shipmentAgentCode;
  @MapTo('ar_posting_group_code')
  String? arPostingGroupCode;
  @MapTo('gen_bus_posting_group_code')
  String? genBusPostingGroupCode;
  @MapTo('vat_bus_posting_group_code')
  String? vatBusPostingGroupCode;
  @MapTo('currency_code')
  String? currencyCode;
  @MapTo('currency_factor')
  double? currencyFactor;
  @MapTo('price_include_vat')
  String? priceIncludeVat;
  @MapTo('salesperson_code')
  String? salespersonCode;
  @MapTo('distributor_code')
  String? distributorCode;
  @MapTo('store_code')
  String? storeCode;
  @MapTo('division_code')
  String? divisionCode;
  @MapTo('business_unit_code')
  String? businessUnitCode;
  @MapTo('department_code')
  String? departmentCode;
  @MapTo('project_code')
  String? projectCode;
  @MapTo('customer_group_code')
  String? customerGroupCode;
  @MapTo('external_document_no')
  String? externalDocumentNo;
  @MapTo('source_type')
  String? sourceType;
  @MapTo('source_no')
  String? sourceNo;
  @MapTo('return_reason_code')
  String? returnReasonCode;
  @MapTo('reason_code')
  String? reasonCode;
  @MapTo('assign_to_user_id')
  String? assignToUserId;
  @MapTo('status')
  String? status;
  @MapTo('remark')
  String? remark;
  @MapTo('amount')
  double? amount;
  @MapTo('is_sync')
  String isSync = "Yes";
  @MapTo('order_date')
  String? orderDate;
}

@MapTo('POS_SALES_LINE')
@RealmModel()
class _PosSalesLine {
  @PrimaryKey()
  late int id;
  @MapTo('document_type')
  String? documentType;
  @MapTo('document_no')
  String? documentNo;
  @MapTo('line_no')
  int? lineNo;
  @MapTo('refer_line_no')
  int? referLineNo;
  @MapTo('customer_no')
  String? customerNo;
  @MapTo('special_type')
  String? specialType;
  @MapTo('special_type_no')
  String? specialTypeNo;
  @MapTo('type')
  String? type;
  @MapTo('no')
  String? no;
  @MapTo('description')
  String? description;
  @MapTo('description_2')
  String? description2;
  @MapTo('variant_code')
  String? variantCode;
  @MapTo('location_code')
  String? locationCode;
  @MapTo('posting_group')
  String? postingGroup;
  @MapTo('lot_no')
  String? lotNo;
  @MapTo('serial_no')
  String? serialNo;
  @MapTo('expiry_date')
  String? expiryDate;
  @MapTo('warrenty_date')
  String? warrentyDate;
  @MapTo('request_shipment_date')
  String? requestShipmentDate;
  @MapTo('unit_of_measure')
  String? unitOfMeasure;
  @MapTo('qty_per_unit_of_measure')
  double? qtyPerUnitOfMeasure = 1;
  @MapTo('header_quantity')
  double? headerQuantity;
  @MapTo('quantity')
  double? quantity;
  @MapTo('outstanding_quantity')
  double? outstandingQuantity;
  @MapTo('outstanding_quantity_base')
  double? outstandingQuantityBase;
  @MapTo('quantity_to_ship')
  double? quantityToShip;
  @MapTo('quantity_to_invoice')
  double? quantityToInvoice;
  @MapTo('unit_price')
  double? unitPrice;
  @MapTo('manual_unit_price')
  double? manualUnitPrice;
  @MapTo('unit_price_lcy')
  double? unitPriceLcy;
  @MapTo('unit_price_ori')
  double? unitPriceOri;
  @MapTo('vat_percentage')
  double? vatPercentage;
  @MapTo('vat_base_amount')
  double? vatBaseAmount;
  @MapTo('vat_amount')
  double? vatAmount;
  @MapTo('discount_percentage')
  double? discountPercentage;
  @MapTo('discount_amount')
  double? discountAmount;
  @MapTo('amount')
  double? amount;
  @MapTo('amount_lcy')
  double? amountLcy;
  @MapTo('amount_including_vat')
  double? amountIncludingVat;
  @MapTo('amount_including_vat_lcy')
  double? amountIncludingVatLcy;
  @MapTo('gross_weight')
  double? grossWeight;
  @MapTo('net_weight')
  double? netWeight;
  @MapTo('quantity_shipped')
  double? quantityShipped;
  @MapTo('quantity_invoiced')
  double? quantityInvoiced;
  @MapTo('gen_bus_posting_group_code')
  String? genBusPostingGroupCode;
  @MapTo('gen_prod_posting_group_code')
  String? genProdPostingGroupCode;
  @MapTo('vat_bus_posting_group_code')
  String? vatBusPostingGroupCode;
  @MapTo('vat_prod_posting_group_code')
  String? vatProdPostingGroupCode;
  @MapTo('vat_calculation_type')
  String? vatCalculationType;
  @MapTo('currency_code')
  String? currencyCode;
  @MapTo('currency_factor')
  double? currencyFactor;
  @MapTo('item_category_code')
  String? itemCategoryCode;
  @MapTo('item_group_code')
  String? itemGroupCode;
  @MapTo('item_disc_group_code')
  String? itemDiscGroupCode;
  @MapTo('item_brand_code')
  String? itemBrandCode;
  @MapTo('store_code')
  String? storeCode;
  @MapTo('division_code')
  String? divisionCode;
  @MapTo('business_unit_code')
  String? businessUnitCode;
  @MapTo('department_code')
  String? departmentCode;
  @MapTo('project_code')
  String? projectCode;
  @MapTo('salesperson_code')
  String? salespersonCode;
  @MapTo('distributor_code')
  String? distributorCode;
  @MapTo('customer_group_code')
  String? customerGroupCode;
  @MapTo('return_reason_code')
  String? returnReasonCode;
  @MapTo('reason_code')
  String? reasonCode;

  String? sourceNo;
  @MapTo('source_no')
  String? imgUrl;
  @MapTo('header_id')
  int? headerId;
  @MapTo('document_date')
  String? documentDate;
  @MapTo('is_manual_edit')
  String? isManualEdit = "No";
  @MapTo('is_sync')
  String? isSync = "Yes";
}

@MapTo('SALES_HEADER')
@RealmModel()
class _SalesHeader {
  @PrimaryKey()
  late int id;
  @MapTo('document_type')
  String? documentType;
  @MapTo('no')
  String? no;
  @MapTo('app_id')
  String? appId;
  @MapTo('customer_no')
  String? customerNo;
  @MapTo('customer_name')
  String? customerName;
  @MapTo('customer_name_2')
  String? customerName2;
  @MapTo('address')
  String? address;
  @MapTo('address_2')
  String? address2;
  @MapTo('location_code')
  String? locationCode;
  @MapTo('ship_to_code')
  String? shipToCode;
  @MapTo('ship_to_name')
  String? shipToName;
  @MapTo('ship_to_name_2')
  String? shipToName2;
  @MapTo('ship_to_address')
  String? shipToAddress;
  @MapTo('ship_to_address_2')
  String? shipToAddress2;
  @MapTo('ship_to_contact_name')
  String? shipToContactName;
  @MapTo('ship_to_phone_no')
  String? shipToPhoneNo;
  @MapTo('ship_to_phone_no_2')
  String? shipToPhoneNo2;
  @MapTo('document_date')
  String? documentDate;
  @MapTo('posting_date')
  String? postingDate;
  @MapTo('request_shipment_date')
  String? requestShipmentDate;
  @MapTo('posting_description')
  String? postingDescription;
  @MapTo('payment_term_code')
  String? paymentTermCode;
  @MapTo('payment_method_code')
  String? paymentMethodCode;
  @MapTo('shipment_method_code')
  String? shipmentMethodCode;
  @MapTo('shipment_agent_code')
  String? shipmentAgentCode;
  @MapTo('ar_posting_group_code')
  String? arPostingGroupCode;
  @MapTo('gen_bus_posting_group_code')
  String? genBusPostingGroupCode;
  @MapTo('vat_bus_posting_group_code')
  String? vatBusPostingGroupCode;
  @MapTo('currency_code')
  String? currencyCode;
  @MapTo('currency_factor')
  double? currencyFactor;
  @MapTo('price_include_vat')
  String? priceIncludeVat;
  @MapTo('salesperson_code')
  String? salespersonCode;
  @MapTo('distributor_code')
  String? distributorCode;
  @MapTo('store_code')
  String? storeCode;
  @MapTo('division_code')
  String? divisionCode;
  @MapTo('business_unit_code')
  String? businessUnitCode;
  @MapTo('department_code')
  String? departmentCode;
  @MapTo('project_code')
  String? projectCode;
  @MapTo('customer_group_code')
  String? customerGroupCode;
  @MapTo('external_document_no')
  String? externalDocumentNo;
  @MapTo('source_type')
  String? sourceType;
  @MapTo('source_no')
  String? sourceNo;
  @MapTo('return_reason_code')
  String? returnReasonCode;
  @MapTo('reason_code')
  String? reasonCode;
  @MapTo('assign_to_user_id')
  String? assignToUserId;
  @MapTo('status')
  String? status;
  @MapTo('remark')
  String? remark;
  @MapTo('total_amount')
  double? amount;
  @MapTo('is_sync')
  String isSync = "Yes";
  @MapTo('order_date')
  String? orderDate;
  @MapTo('order_datetime')
  String? orderDateTime;

  @Ignored()
  String? totalAmtLine;
}

@MapTo('SALES_LINE')
@RealmModel()
class _SalesLine {
  @PrimaryKey()
  late int id;
  @MapTo('app_id')
  String? appId;
  @MapTo('document_type')
  String? documentType;
  @MapTo('document_no')
  String? documentNo;
  @MapTo('line_no')
  int? lineNo;
  @MapTo('refer_line_no')
  int? referLineNo;
  @MapTo('customer_no')
  String? customerNo;
  @MapTo('special_type')
  String? specialType;
  @MapTo('special_type_no')
  String? specialTypeNo;
  @MapTo('type')
  String? type;
  @MapTo('no')
  String? no;
  @MapTo('description')
  String? description;
  @MapTo('description_2')
  String? description2;
  @MapTo('variant_code')
  String? variantCode;
  @MapTo('location_code')
  String? locationCode;
  @MapTo('posting_group')
  String? postingGroup;
  @MapTo('lot_no')
  String? lotNo;
  @MapTo('serial_no')
  String? serialNo;
  @MapTo('expiry_date')
  String? expiryDate;
  @MapTo('warrenty_date')
  String? warrentyDate;
  @MapTo('request_shipment_date')
  String? requestShipmentDate;
  @MapTo('unit_of_measure')
  String? unitOfMeasure;
  @MapTo('qty_per_unit_of_measure')
  double? qtyPerUnitOfMeasure = 1;
  @MapTo('header_quantity')
  double? headerQuantity;
  @MapTo('quantity')
  double? quantity;
  @MapTo('outstanding_quantity')
  double? outstandingQuantity;
  @MapTo('outstanding_quantity_base')
  double? outstandingQuantityBase;
  @MapTo('quantity_to_ship')
  double? quantityToShip;
  @MapTo('quantity_to_invoice')
  double? quantityToInvoice;
  @MapTo('unit_price')
  double? unitPrice;
  @MapTo('manual_unit_price')
  double? manualUnitPrice;
  @MapTo('unit_price_lcy')
  double? unitPriceLcy;
  @MapTo('unit_price_ori')
  double? unitPriceOri;
  @MapTo('vat_percentage')
  double? vatPercentage;
  @MapTo('vat_base_amount')
  double? vatBaseAmount;
  @MapTo('vat_amount')
  double? vatAmount;
  @MapTo('discount_percentage')
  double? discountPercentage;
  @MapTo('discount_amount')
  double? discountAmount;
  @MapTo('amount')
  double? amount;
  @MapTo('imgUrl')
  String? imgUrl;
  @MapTo('amount_lcy')
  double? amountLcy;
  @MapTo('amount_including_vat')
  double? amountIncludingVat;
  @MapTo('amount_including_vat_lcy')
  double? amountIncludingVatLcy;
  @MapTo('gross_weight')
  double? grossWeight;
  @MapTo('net_weight')
  double? netWeight;
  @MapTo('quantity_shipped')
  double? quantityShipped;
  @MapTo('quantity_invoiced')
  double? quantityInvoiced;
  @MapTo('gen_bus_posting_group_code')
  String? genBusPostingGroupCode;
  @MapTo('gen_prod_posting_group_code')
  String? genProdPostingGroupCode;
  @MapTo('vat_bus_posting_group_code')
  String? vatBusPostingGroupCode;
  @MapTo('vat_prod_posting_group_code')
  String? vatProdPostingGroupCode;
  @MapTo('vat_calculation_type')
  String? vatCalculationType;
  @MapTo('currency_code')
  String? currencyCode;
  @MapTo('currency_factor')
  double? currencyFactor;
  @MapTo('item_category_code')
  String? itemCategoryCode;
  @MapTo('item_group_code')
  String? itemGroupCode;
  @MapTo('item_disc_group_code')
  String? itemDiscGroupCode;
  @MapTo('item_brand_code')
  String? itemBrandCode;
  @MapTo('store_code')
  String? storeCode;
  @MapTo('division_code')
  String? divisionCode;
  @MapTo('business_unit_code')
  String? businessUnitCode;
  @MapTo('department_code')
  String? departmentCode;
  @MapTo('project_code')
  String? projectCode;
  @MapTo('salesperson_code')
  String? salespersonCode;
  @MapTo('distributor_code')
  String? distributorCode;
  @MapTo('customer_group_code')
  String? customerGroupCode;
  @MapTo('return_reason_code')
  String? returnReasonCode;
  @MapTo('reason_code')
  String? reasonCode;
  @MapTo('header_id')
  int? headerId;
  @MapTo('source_no')
  String? sourceNo;
  @MapTo('document_date')
  String? documentDate;
  @MapTo('is_manual_edit')
  String? isManualEdit = "No";
  @MapTo('is_sync')
  String? isSync = "Yes";
}

@MapTo("TMP_SALES_SHIPMENT_PLANING")
@RealmModel()
class _TmpSalesShipmentPlaning {
  @PrimaryKey()
  late int id;
  @MapTo("app_id")
  int? appId;
  @MapTo("document_type")
  String? documentType;
  @MapTo("document_no")
  String? documentNo;
  @MapTo("line_no")
  int? lineNo;
  @MapTo("cart_line_id")
  int? cartLineId;
  @MapTo("type")
  String? type;
  @MapTo("no")
  String? no;
  @MapTo("special_type")
  String? specialType;
  @MapTo("special_type_no")
  String? specialTypeNo;
  @MapTo("variant_code")
  String? variantCode;
  @MapTo("location_code")
  String? locationCode;
  @MapTo("lot_no")
  String? lotNo;
  @MapTo("serial_no")
  String? serialNo;
  @MapTo("shipment_date")
  String? shipmentDate;
  @MapTo("description")
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("unit_of_measure")
  String? unitOfMeasure;
  @MapTo("qty_per_unit_of_measure")
  double? qtyPerUnitOfMeasure;
  @MapTo("quantity")
  double? quantity = 0;
  @MapTo("quantity_base")
  double? quantityBase = 0;
  @MapTo("apply_to_item_entry_no")
  int? applyToItemEntryNo;
  @MapTo("assign_to_userid")
  String? assignToUserid;
  @MapTo("assign_to_username")
  String? assignToUsername;
  @MapTo("item_category_code")
  String? itemCategoryCode;
  @MapTo("item_group_code")
  String? itemGroupCode;
  @MapTo("item_disc_group_code")
  String? itemDiscGroupCode;
  @MapTo("item_brand_code")
  String? itemBrandCode;
  @MapTo("store_code")
  String? storeCode;
  @MapTo("division_code")
  String? divisionCode;
  @MapTo("business_unit_code")
  String? businessUnitCode;
  @MapTo("department_code")
  String? departmentCode;
  @MapTo("project_code")
  String? projectCode;
  @MapTo("salesperson_code")
  String? salespersonCode;
  @MapTo("distributor_code")
  String? distributorCode;
  @MapTo("customer_group_code")
  String? customerGroupCode;
  @MapTo("is_sync")
  String? isSync = "Yes";
  @MapTo("app_created_at")
  String? appCreatedAt;
  @MapTo("created_at")
  String? createdAt;
  @MapTo("updated_at")
  String? updatedAt;
}

@MapTo("ITEM_STOCK_REQUEST_WORKSHEET")
@RealmModel()
class _ItemStockRequestWorkSheet {
  @PrimaryKey()
  late String id;
  @MapTo("app_id")
  String? appId;
  @MapTo("from_location_code")
  String? fromLocationCode;
  @MapTo("location_code")
  String? locationCode;
  @MapTo("purchaser_code")
  String? purchaserCode;
  @MapTo("item_no")
  late String itemNo;
  @MapTo("variant_code")
  String? variantCode;
  @MapTo("description")
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("unit_of_measure_code")
  String? unitOfMeasureCode;
  @MapTo("qty_per_unit_of_measure")
  double qtyPerUnitOfMeasure = 1.0;
  @MapTo("org_quantity")
  double orgQuantity = 0;
  @MapTo("quantity")
  double quantity = 0;
  @MapTo("quantity_base")
  double quantityBase = 0;
  @MapTo("quantity_to_ship")
  double quantityToShip = 0;
  @MapTo("quantity_to_receive")
  double quantityToReceive = 0;
  @MapTo("quantity_shipped")
  double quantityShipped = 0;
  @MapTo("quantity_received")
  double quantityReceived = 0;
  @MapTo("posting_date")
  String? postingDate;
  @MapTo("document_type")
  String? documentType;
  @MapTo("document_no")
  String? documentNo;
  @MapTo("document_line_no")
  String? documentLineNo;
  @MapTo("status")
  String status = "New"; //New, Requested , Approved, Rejected ,Posted
  @MapTo("backend_status")
  String? backendStatus;
  @MapTo("transfer_document_no")
  String? transferDocumentNo;
  @MapTo("is_sync")
  String isSync = "Yes";
  @MapTo("created_at")
  String? createdAt;
  @MapTo("updated_at")
  String? updatedAt;
}
