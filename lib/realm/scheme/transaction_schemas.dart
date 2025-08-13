import 'package:realm/realm.dart';

part 'transaction_schemas.realm.dart';

@MapTo("COMPETITOR_ITEM_LEDGER_ENTRY")
@RealmModel()
class _CompetitorItemLedgerEntry {
  @MapTo("entry_no")
  @PrimaryKey()
  late String entryNo;
  @MapTo("app_id")
  String? appId;
  @MapTo("schedule_id")
  String? scheduleId;
  @MapTo("ship_to_code")
  String? shipToCode;
  @MapTo("item_no")
  String? itemNo;
  @MapTo("competitor_no")
  String? competitorNo;
  @MapTo("competitor_name")
  String? competitorName;
  @MapTo("competitor_name_2")
  String? competitorName2;
  @MapTo("customer_no")
  String? customerNo;
  @MapTo("customer_name")
  String? customerName;
  @MapTo("customer_name_2")
  String? customerName2;
  @MapTo("variant_code")
  String? variantCode;
  @MapTo("item_description")
  String? itemDescription;
  @MapTo("item_description_2")
  String? itemDescription2;
  @MapTo("counting_date")
  String? countingDate;
  @MapTo("description")
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("quantity")
  double? quantity;
  @MapTo("quantity_base")
  double? quantityBase;
  @MapTo("planned_quantity")
  double? plannedQuantity;
  @MapTo("planned_quantity_base")
  double? plannedQuantityBase;
  @MapTo("volume_sales_quantity")
  double? volumeSalesQuantity;
  @MapTo("volume_sales_quantity_base")
  double? volumeSalesQuantityBase;
  @MapTo("volume_sales_quantity_uom")
  double? volumeSalesQuantityUom;
  @MapTo("volume_sales_quantity_measure")
  double? volumeSalesQuantityMeasure;
  @MapTo("unit_of_measure_code")
  String? unitOfMeasureCode;
  @MapTo("qty_per_unit_of_measure")
  double? qtyPerUnitOfMeasure;
  @MapTo("serial_no")
  String? serialNo;
  @MapTo("lot_no")
  String? lotNo;
  @MapTo("warranty_date")
  String? warrantyDate;
  @MapTo("expiration_date")
  String? expirationDate;
  @MapTo("status")
  String? status;
  @MapTo("unit_cost")
  double? unitCost;
  @MapTo("unit_price")
  double? unitPrice;
  @MapTo("unit_price_lcy")
  double? unitPriceLcy;
  @MapTo("vat_calculation_type")
  String? vatCalculationType;
  @MapTo("vat_percentage")
  double? vatPercentage;
  @MapTo("vat_base_amount")
  double? vatBaseAmount;
  @MapTo("vat_amount")
  double? vatAmount;
  @MapTo("discount_percentage")
  double? discountPercentage;
  @MapTo("discount_amount")
  double? discountAmount;
  @MapTo("amount")
  double? amount;
  @MapTo("amount_lcy")
  double? amountLcy;
  @MapTo("amount_including_vat")
  double? amountIncludingVat;
  @MapTo("amount_including_vat_lcy")
  double? amountIncludingVatLcy;
  @MapTo("currency_code")
  String? currencyCode;
  @MapTo("currency_factor")
  double? currencyFactor;
  @MapTo("price_include_vat")
  double? priceIncludeVat;
  @MapTo("remark")
  String? remark;
  @MapTo("is_sync")
  String? isSync = "No";
}

@MapTo("CUSTOMER_ITEM_LEDGER_ENTRY")
@RealmModel()
class _CustomerItemLedgerEntry {
  @MapTo("entry_no")
  @PrimaryKey()
  late String entryNo;
  @MapTo("app_id")
  String? appId;
  @MapTo("schedule_id")
  String? scheduleId;
  @MapTo("ship_to_code")
  String? shipToCode;
  @MapTo("item_no")
  String? itemNo;
  @MapTo("customer_no")
  String? customerNo;
  @MapTo("customer_name")
  String? customerName;
  @MapTo("customer_name_2")
  String? customerName2;
  @MapTo("competitor_no")
  String? competitorNo;
  @MapTo("competitor_name")
  String? competitorName;
  @MapTo("competitor_name_2")
  String? competitorName2;
  @MapTo("variant_code")
  String? variantCode;
  @MapTo("item_description")
  String? itemDescription;
  @MapTo("item_description_2")
  String? itemDescription2;
  @MapTo("counting_date")
  String? countingDate;
  @MapTo("description")
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("quantity")
  double? quantity;
  @MapTo("quantity_base")
  double? quantityBase;
  @MapTo("quantity_buy_from_other")
  double? quantityBuyFromOther;
  @MapTo("quantity_buy_from_other_base")
  double? quantityBuyFromOtherBase;
  @MapTo("planned_quantity")
  double? plannedQuantity;
  @MapTo("planned_quantity_base")
  double? plannedQuantityBase;
  @MapTo("planned_quantity_return")
  double? plannedQuantityReturn;
  @MapTo("planned_quantity_return_base")
  double? plannedQuantityReturnBase;
  @MapTo("volume_sales_quantity")
  double? volumeSalesQuantity;
  @MapTo("volume_sales_quantity_base")
  double? volumeSalesQuantityBase;
  @MapTo("foc_in_quantity")
  double? focInQuantity;
  @MapTo("foc_in_quantity_base")
  double? focInQuantityBase;
  @MapTo("foc_out_quantity")
  double? focOutQuantity;
  @MapTo("foc_out_quantity_base")
  double? focOutQuantityBase;
  @MapTo("foc_in_uom")
  String? focInuom;
  @MapTo("foc_out_uom")
  String? focOutUom;
  @MapTo("foc_in_measure")
  double? focInMeasure;
  @MapTo("foc_out_measure")
  double? focOutMeasure;
  @MapTo("unit_of_measure_code")
  String? unitOfMeasureCode;
  @MapTo("quantity_buy_from_other_uom")
  String? quantityBuyFromOtherUom;
  @MapTo("planned_quantity_uom")
  String? plannedQuantityUom;
  @MapTo("planned_quantity_return_uom")
  String? plannedQuantityReturnUom;
  @MapTo("volume_sales_quantity_uom")
  String? volumeSalesQuantityUom;
  @MapTo("qty_per_unit_of_measure")
  double? qtyPerUnitOfMeasure;
  @MapTo("quantity_buy_from_other_measure")
  double? quantityBuyFromOtherMeasure;
  @MapTo("planned_quantity_measure")
  double? plannedQuantityMeasure;
  @MapTo("planned_quantity_return_measure")
  double? plannedQuantityReturnMeasure;
  @MapTo("volume_sales_quantity_measure")
  double? volumeSalesQuantityMeasure;
  @MapTo("sales_purchaser_code")
  String? salesPurchaserCode;
  @MapTo("serial_no")
  String? serialNo;
  @MapTo("lot_no")
  String? lotNo;
  @MapTo("warranty_date")
  String? warrantyDate;
  @MapTo("expiration_date")
  String? expirationDate;
  @MapTo("unit_cost")
  double? unitCost;
  @MapTo("status")
  String? status;
  @MapTo("unit_price")
  double? unitPrice;
  @MapTo("unit_price_lcy")
  double? unitPriceLcy;
  @MapTo("vat_calculation_type")
  String? vatCalculationType;
  @MapTo("vat_percentage")
  double? vatpercentage;
  @MapTo("vat_base_amount")
  double? vatBaseAmount;
  @MapTo("vat_amount")
  double? vatAmount;
  @MapTo("discount_percentage")
  double? discountPercentage;
  @MapTo("discount_amount")
  double? discountAmount;
  @MapTo("amount")
  double? amount;
  @MapTo("amount_lcy")
  double? amountLcy;
  @MapTo("amount_including_vat")
  double? amountIncludingVat;
  @MapTo("amount_including_vat_lcy")
  double? amountIncludingVatLcy;
  @MapTo("return_vat_percentage")
  double? returnVatPercentage;
  @MapTo("return_vat_base_amount")
  double? returnVatBaseAmount;
  @MapTo("return_vat_amount")
  double? returnVatAmount;
  @MapTo("return_discount_percentage")
  double? returnDiscountPercentage;
  @MapTo("return_discount_amount")
  double? returnDiscountAmount;
  @MapTo("return_amount")
  double? returnAmount;
  @MapTo("return_amount_lcy")
  double? returnAmountLcy;
  @MapTo("return_amount_including_vat")
  double? returnAmountIncludingVat;
  @MapTo("return_amount_including_vat_lcy")
  double? returnAmountIncludingVatLcy;
  @MapTo("redemption_quantity")
  double? redemptionQuantity;
  @MapTo("redemption_quantity_base")
  double? redemptionQuantityBase;
  @MapTo("redemption_uom")
  double? redemptionUom;
  @MapTo("redemption_measure")
  double? redemptionMeasure;
  @MapTo("inventory")
  double? inventory;
  @MapTo("inventory_base")
  double? inventoryBase;
  @MapTo("currency_code")
  String? currencyCode;
  @MapTo("currency_factor")
  double? currencyFactor;
  @MapTo("price_include_vat")
  double? priceIncludeVat;
  @MapTo("document_type")
  String? documentType;
  @MapTo("document_no")
  String? documentNo;
  @MapTo("item_category_code")
  String? itemCategoryCode;
  @MapTo("item_group_code")
  String? itemGroupCode;
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
  @MapTo("distributor_code")
  String? distributorCode;
  @MapTo("customer_group_code")
  String? customerGroupCode;
  @MapTo("territory_code")
  String? territoryCode;
  @MapTo("remark")
  String? remark;
  @MapTo("is_sync")
  String? isSync = "No";
}

@MapTo("SALESPERSON_SCHEDULE_MERCHANDISE")
@RealmModel()
class _SalesPersonScheduleMerchandise {
  @MapTo("id")
  @PrimaryKey()
  late String? id;
  @MapTo("app_id")
  String? appId;
  @MapTo("visit_no")
  int? visitNo;
  @MapTo("schedule_date")
  String? scheduleDate;
  @MapTo("customer_no")
  String? customerNo;
  @MapTo("name")
  String? name;
  @MapTo("name_2")
  String? name2;
  @MapTo("salesperson_code")
  String? salespersonCode;
  @MapTo("competitor_no")
  String? competitorNo;
  @MapTo("merchandise_type")
  String? merchandiseType;
  @MapTo("merchandise_option")
  String? merchandiseOption;
  @MapTo("merchandise_code")
  String? merchandiseCode;
  @MapTo("description")
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("remark")
  String? remark;
  @MapTo("picture")
  String? picture;
  @MapTo("status")
  String? status = "Open";
  @MapTo("quantity")
  double? quantity = 0;
  @MapTo("flag")
  String? flag = "No";
  @MapTo("is_sync")
  String? isSync = "Yes";
}

@MapTo("ITEM_PRIZE_REDEMPTION_LINE_ENTRY")
@RealmModel()
class _ItemPrizeRedemptionLineEntry {
  @MapTo("id")
  @PrimaryKey()
  late String id;
  @MapTo("app_id")
  String? appId;
  @MapTo("schedule_id")
  String? scheduleId;
  @MapTo("schedule_date")
  String? scheduleDate;
  @MapTo("line_no")
  int? lineNo;
  @MapTo("promotion_no")
  String? promotionNo;
  @MapTo("customer_no")
  String? customerNo;
  @MapTo("customer_name")
  String? customerName;
  @MapTo("customer_name_2")
  String? customerName2;
  @MapTo("ship_to_code")
  String? shipToCode;
  @MapTo("item_no")
  String? itemNo;
  @MapTo("variant_code")
  String? variantCode;
  @MapTo("redemption_type")
  String? redemptionType;
  @MapTo("description")
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("unit_of_measure_code")
  String? unitOfMeasureCode;
  @MapTo("qty_per_unit_of_measure")
  double? qtyPerUnitOfMeasure;
  @MapTo("quantity")
  double? quantity;
  @MapTo("source_type")
  String? sourceType;
  @MapTo("source_no")
  String? sourceNo;
  @MapTo("salesperson_code")
  String? salespersonCode;
  @MapTo("item_category_code")
  String? itemCategoryCode;
  @MapTo("item_group_code")
  String? itemGroupCode;
  @MapTo("item_brand_code")
  String? itemBrandCode;
  @MapTo("status")
  String? status = "Open";
  @MapTo("is_sync")
  String? isSync = "Yes";
}

@MapTo("COMPETITOR_PROMOTION_HEADER")
@RealmModel()
class _CompetitorPromtionHeader {
  @MapTo("id")
  @PrimaryKey()
  late String id;

  @MapTo("no")
  String? no;

  @MapTo("from_date")
  String? fromDate;

  @MapTo("to_date")
  String? toDate;

  @MapTo("description")
  String? description;

  @MapTo("description_2")
  String? description2;

  @MapTo("remark")
  String? remark;

  @MapTo("promotion_type")
  String? promotionType;

  @MapTo("salesperson_code_filter")
  String? salespersonCodeFilter;

  @MapTo("distributor_code_filter")
  String? distributorCodeFilter;

  @MapTo("store_code_filter")
  String? storeCodeFilter;

  @MapTo("division_code_filter")
  String? divisionCodeFilter;

  @MapTo("business_unit_code_filter")
  String? businessUnitCodeFilter;

  @MapTo("department_code_filter")
  String? departmentCodeFilter;

  @MapTo("project_code_filter")
  String? projectCodeFilter;

  @MapTo("first_approver_code")
  String? firstApproverCode;

  @MapTo("second_approver_code")
  String? secondApproverCode;

  @MapTo("competitor_no")
  String? competitorNo;

  @MapTo("customer_no")
  String? customerNo;

  @MapTo("name")
  String? name;

  @MapTo("name_2")
  String? name2;

  @MapTo("source_type")
  String? sourceType;

  @MapTo("source_no")
  String? sourceNo;

  @MapTo("status")
  String? status;

  @MapTo("picture")
  String? picture;

  @MapTo("avatar_32")
  String? avatar32;

  @MapTo("avatar_128")
  String? avatar128;

  @MapTo("app_id")
  String? appId;
}

@MapTo("COMPETITOR_PROMOTION_LINE")
@RealmModel()
class _CompetitorPromotionLine {
  @MapTo("id")
  @PrimaryKey()
  late String id;

  @MapTo("line_no")
  String? lineNo;
  @MapTo("promotion_no")
  String? promotionNo;
  @MapTo("item_no")
  String? itemNo;
  @MapTo("variant_code")
  String? variantCode;
  @MapTo("description")
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("promotion_type")
  String? promotionType;
  @MapTo("unit_of_measure_code")
  String? unitOfMeasureCode;
  @MapTo("qty_per_unit_of_measure")
  double? qtyPerUnitOfMeasure = 1;
  @MapTo("quantity")
  double? quantity = 0;
  @MapTo("unit_price")
  double? unitPrice = 0;
  @MapTo("discount_percentage")
  double? discountPercentage = 0;
  @MapTo("discount_amount")
  double? discountAmount = 0;
  @MapTo("amount")
  double? amount = 0;
}

@MapTo("CUSTOMER_LEDGER_ENTRY")
@RealmModel()
class _CustomerLedgerEntry {
  @MapTo("entry_no")
  @PrimaryKey()
  late String entryNo;
  @MapTo("customer_name")
  String? customerName;
  @MapTo("customer_name_2")
  String? customerName2;
  @MapTo("posting_date")
  String? postingDate;
  @MapTo("posting_description")
  String? postingDescription;
  @MapTo("document_date")
  String? documentDate;
  @MapTo("document_type")
  String? documentType;
  @MapTo("document_no")
  String? documentNo;
  @MapTo("description")
  String? description;
  @MapTo("currency_code")
  String? currencyCode;
  @MapTo("currency_factor")
  double? currencyFactor = 1;
  @MapTo("ar_posting_group")
  String? arPostingGroup;
  @MapTo("salesperson_code")
  String? salespersonCode;
  @MapTo("distributor_code")
  String? distributorCode;
  @MapTo("store_code")
  String? storeCode;
  @MapTo("division_code")
  String? divisionCode;
  @MapTo("business_unit_code")
  String? businessUnitCode;
  @MapTo("department_code")
  String? departmentCode;
  @MapTo("territory_code")
  String? territoryCode;
  @MapTo("project_code")
  String? projectCode;
  @MapTo("budget_code")
  String? budgetCode;
  @MapTo("customer_no")
  String? customerNo;
  @MapTo("customer_group_code")
  String? customerGroupCode;
  @MapTo("applies_to_doc_type")
  String? appliesToDocType;
  @MapTo("applies_to_doc_no")
  String? appliesToDocNo;
  @MapTo("due_date")
  String? dueDate;
  @MapTo("pmt_discount_date")
  String? pmtDiscountDate;
  @MapTo("pmt_discount_percentage")
  double? pmtDiscountPercentage = 0;
  @MapTo("pmt_discount_amount")
  double? pmtDiscountAmount = 0;
  @MapTo("applies_to_id")
  String? appliesToId;
  @MapTo("journal_batch_name")
  String? journalBatchName;
  @MapTo("external_document_no")
  String? externalDocumentNo;
  @MapTo("amount_to_apply")
  double? amountToApply = 0;
  @MapTo("amount_to_apply_lcy")
  double? amountToApplyLcy = 0;
  @MapTo("amount_to_discount_lcy")
  double? amountToDiscountLcy = 0;
  @MapTo("amount_to_discount")
  double? amountToDiscount = 0;
  @MapTo("discount")
  double? discount = 0;
  @MapTo("discount_lcy")
  double? discountLcy = 0;
  @MapTo("amount")
  double? amount = 0;
  @MapTo("amount_lcy")
  double? amountLcy = 0;
  @MapTo("remaining_amount")
  double? remainingAmount = 0;
  @MapTo("remaining_amount_lcy")
  double? remainingAmountLcy = 0;
  @MapTo("bal_account_type")
  String? balAccountType;
  @MapTo("bal_account_no")
  String? balAccountNo;
  @MapTo("reversed")
  String? reversed;
  @MapTo("reversed_by_entry_no")
  String? reversedByEntryNo;
  @MapTo("reversed_entry_no")
  String? reversedEntryNo;
  @MapTo("adjustment")
  String? adjustment;
  @MapTo("order_no")
  String? orderNo;
  @MapTo("order_type")
  String? orderType;
  @MapTo("source_type")
  String? sourceType;
  @MapTo("source_no")
  String? sourceNo;
  @MapTo("special_type")
  String? specialType;
  @MapTo("special_type_no")
  String? specialTypeNo;
  @MapTo("posting_datetime")
  String? postingDatetime;
  @MapTo("payment_method_code")
  String? paymentMethodCode;
  @MapTo("customer_address")
  String? customerAddress;
  @MapTo("is_collection")
  String? isCollection;
  @MapTo("index")
  String? index;
  @MapTo("over_aging")
  String? overAging;
}

@MapTo("CASH_RECEIPT_JOURNALS")
@RealmModel()
class _CashReceiptJournals {
  @MapTo("id")
  @PrimaryKey()
  late String id;
  @MapTo("journal_type")
  String? journalType;
  @MapTo("document_date")
  String? documentDate;
  @MapTo("posting_date")
  String? postingDate;
  @MapTo("document_type")
  String? documentType;
  @MapTo("document_no")
  String? documentNo;
  @MapTo("customer_no")
  String? customerNo;
  @MapTo("description")
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("posting_group")
  String? postingGroup;
  @MapTo("payment_method_code")
  String? paymentMethodCode;
  double? amount = 0;
  @MapTo("amount_lcy")
  double? amountLcy = 0;
  @MapTo("discount_amount")
  double? discountAmount = 0;
  @MapTo("discount_amount_lcy")
  double? discountAmountLcy = 0;
  @MapTo("bal_account_type")
  String? balAccountType;
  @MapTo("bal_account_no")
  String? balAccountNo;
  @MapTo("currency_code")
  String? currencyCode;
  @MapTo("currency_factor")
  double? currencyFactor = 1;
  @MapTo("gen_bus_posting_group")
  String? genBusPostingGroup;
  @MapTo("gen_prod_posting_group")
  String? genProdPostingGroup;
  @MapTo("no_series")
  String? noSeries;
  @MapTo("external_document_no")
  String? externalDocumentNo;
  @MapTo("posting_description")
  String? postingDescription;
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
  @MapTo("budget_code")
  String? budgetCode;
  @MapTo("salesperson_code")
  String? salespersonCode;
  @MapTo("distributor_code")
  String? distributorCode;
  @MapTo("customer_group_code")
  String? customerGroupCode;
  @MapTo("apply_to_doc_type")
  String? applyToDocType;
  @MapTo("apply_to_doc_no")
  String? applyToDocNo;
  @MapTo("journal_batch_name")
  String? journalBatchName;
  @MapTo("assign_to_userid")
  String? assignToUserId;
  @MapTo("source_type")
  String? sourceType;
  @MapTo("source_no")
  String? sourceNo;
  @MapTo("status")
  String? status;
  @MapTo("app_id")
  String? appId;
  @MapTo("is_sync")
  String? isSync = "Yes";
}
