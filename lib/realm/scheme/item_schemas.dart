import 'package:realm/realm.dart';

part 'item_schemas.realm.dart';

@MapTo("ITEM")
@RealmModel()
class _Item {
  @PrimaryKey()
  late String no;
  @MapTo("no_2")
  String? no2;
  @MapTo("identifier_code")
  String? identifierCode;
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("stock_uom_code")
  String? stockUomCode;
  @MapTo("auto_insert_specification")
  String? autoInsertSpecification;
  @MapTo("is_service_item")
  String? isServiceItem;
  @MapTo("inv_posting_group_code")
  String? invPostingGroupCode;
  @MapTo("item_discount_group_code")
  String? itemDiscountGroupCode;
  @MapTo("commission_group_code")
  String? commissionGroupCode;
  @MapTo("item_brand_code")
  String? itemBrandCode;
  @MapTo("item_group_code")
  String? itemGroupCode;
  @MapTo("item_category_code")
  String? itemCategoryCode;
  @MapTo("item_menu_group_code")
  String? itemMenuGroupCode;
  @MapTo("business_unit_code")
  String? businessUnitCode;
  @MapTo("division_code")
  String? divisionCode;
  @MapTo("department_code")
  String? departmentCode;
  @MapTo("project_code")
  String? projectCode;
  @MapTo("unit_price")
  double? unitPrice;
  @MapTo("unit_cost")
  double? unitCost;
  @MapTo("standard_cost")
  double? standardCost;
  @MapTo("last_direct_cost")
  double? lastDirectCost;
  @MapTo("prevent_negative_inventory")
  String preventNegativeInventory = "Yes";
  @MapTo("gen_prod_posting_group_code")
  String? genProdPostingGroupCode;
  @MapTo("vat_prod_posting_group_code")
  String? vatProdPostingGroupCode;
  @MapTo("replenishment_system")
  String? replenishmentSystem;
  @MapTo("assembly_policy")
  String assemblyPolicy = "Assemble-to-Stock";
  @MapTo("sales_uom_code")
  String? salesUomCode;
  @MapTo("item_tracking_code")
  String? itemTrackingCode;
  String? picture;
  @MapTo("avatar_128")
  String? avatar128;
  String? inactived = "No";
  double? inventory = 0;
  @MapTo("is_sync")
  String isSync = "Yes";
  @MapTo("created_at")
  String? createdAt;
  @MapTo("updated_at")
  String? updatedAt;
}

@MapTo("ITEM_GROUP")
@RealmModel()
class _ItemGroup {
  @PrimaryKey()
  late String code;
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("item_brand_code")
  String? itemBrandCode;
  @MapTo("item_category_code")
  String? itemCategoryCode;
  String? picture;
  String? inactived = "No";
  @MapTo("created_at")
  String? createdAt;
  @MapTo("updated_at")
  String? updatedAt;
}

@MapTo("ITEM_UNIT_OF_MEASURE")
@RealmModel()
class _ItemUnitOfMeasure {
  @PrimaryKey()
  late String id;
  @MapTo("item_no")
  String? itemNo;
  @MapTo("unit_of_measure_code")
  String? unitOfMeasureCode;
  @MapTo("unit_option")
  String? unitOption;
  @MapTo("identifier_code")
  String? identifierCode;
  String? description;
  @MapTo("description_2")
  String? description2;
  @MapTo("qty_per_unit")
  double? qtyPerUnit = 1.0;
  @MapTo("quantity_decimal")
  String? quantityDecimal;
  double? price = 0.0;
  @MapTo("price_option")
  String? priceOption;
  String? inactived = "No";
}

@MapTo("ITEM_SALES_LINE_PRICES")
@RealmModel()
class _ItemSalesLinePrices {
  @PrimaryKey()
  late String id;
  @MapTo("sales_type")
  String? salesType;
  @MapTo("sales_code")
  String? salesCode;
  @MapTo("item_no")
  String? itemNo;
  @MapTo("variant_code")
  String? variantCode;
  @MapTo("uom_code")
  String? uomCode;
  @MapTo("customer_price_level_code")
  String? customerPriceLevelCode;
  @MapTo("currency_code")
  String? currencyCode;
  @MapTo("minimum_quantity")
  double? minimumQuantity;
  @MapTo("unit_price")
  double? unitPrice;
  @MapTo("discount_percentage")
  double? discountPercentage;
  @MapTo("discount_amount")
  double? discountAmount;
  @MapTo("starting_date")
  String? startingDate;
  @MapTo("ending_date")
  String? endingDate;
}

@MapTo("ITEM_SALES_LINE_DISCOUNT")
@RealmModel()
class _ItemSalesLineDiscount {
  @PrimaryKey()
  late String id;
  String? type;
  String? code;
  @MapTo("sale_type")
  String? saleType;
  @MapTo("sales_code")
  String? salesCode;
  @MapTo("variant_code")
  String? variantCode;
  @MapTo("uom_code")
  String? uomCode;
  @MapTo("currency_code")
  String? currencyCode;
  @MapTo("offer_type")
  String? offerType;
  @MapTo("minimum_amount")
  double? minimumAmount;
  @MapTo("minimum_quantity")
  double? minimumQuantity;
  @MapTo("line_discount_percent")
  double? lineDiscountPercent = 0;
  @MapTo("line_discount_percent_birthday")
  double? lineDiscountPercentBirthday = 0;
  @MapTo("disc_amount")
  double? discAmount = 0;
  @MapTo("starting_date")
  String? startingDate;
  @MapTo("ending_date")
  String? endingDate;
}

@MapTo("ITEM_PROMOTION_SCHEME")
@RealmModel()
class _ItemPromotionScheme {
  @PrimaryKey()
  late String code;
  String? description;
  @MapTo('description_2')
  String? description2;
  @MapTo('items_nos')
  String? itemsNos;
  String? inactived;
}

@MapTo("ITEM_PROMOTION_HEADER")
@RealmModel()
class _ItemPromotionHeader {
  @PrimaryKey()
  late String id;
  late String? no;
  @MapTo("from_date")
  late String? fromDate;
  @MapTo("to_date")
  late String? toDate;
  late String? description;
  @MapTo("description_2")
  late String? description2;
  late String? remark;
  @MapTo("promotion_type")
  late String? promotionType;
  @MapTo("status")
  late String status = "Open";
  late String? picture;
  @MapTo("avatar_32")
  late String? avatar32;
  @MapTo("avatar_128")
  late String? avatar128;
  @MapTo("maximum_offer_customer")
  late double maximumOfferCustomer = 0.0;
  @MapTo("maximum_offer_salesperson")
  late double maximumOfferSalesperson = 0.0;
  @MapTo("is_sync")
  late String isSync = "Yes";
  @MapTo("created_at")
  late String createdAt;
  @MapTo("updated_at")
  late String updatedAt;
}

@MapTo("ITEM_PROMOTION_LINE")
@RealmModel()
class _ItemPromotionLine {
  @PrimaryKey()
  late String id;
  @MapTo("line_no")
  late int? lineNo;
  @MapTo("promotion_no")
  late String? promotionNo;
  @MapTo("type")
  late String? type;
  @MapTo("item_no")
  late String? itemNo;
  @MapTo("variant_code")
  late String? variantCode;
  late String? description;
  @MapTo("description_2")
  late String? description2;
  @MapTo("promotion_type")
  late String? promotionType;
  @MapTo("unit_of_measure_code")
  late String? unitOfMeasureCode;
  @MapTo("qty_per_unit_of_measure")
  late double? qtyPerUnitOfMeasure = 1.0;
  late double? quantity = 0.0;
  @MapTo("maximum_offer_quantity")
  late double? maximumOfferQuantity = 0.0;
  @MapTo("unit_price")
  late double? unitPrice = 0.0;
  @MapTo("discount_percentage")
  late double? discountPercentage = 0.0;
  @MapTo("discount_amount")
  late double? discountAmount = 0.0;
  late double? amount = 0.0;
  @MapTo("selling_price_option")
  late String sellingPriceOption = "Fixed Price";
  @MapTo("is_sync")
  late String isSync = "Yes";
}

@MapTo("ITEM_JOURNAL_BATCH")
@RealmModel()
class _ItemJournalBatch {
  @PrimaryKey()
  late String id;
  late String? code;
  late String? type;
  late String? description;
  @MapTo("description_2")
  late String? description2;
  @MapTo("no_series_code")
  late String? noSeriesCode;
  @MapTo("reason_code")
  late String? reasonCode;
  @MapTo("bal_account_type")
  late String? balAccountType;
  late String? inactived = "No";
}

@MapTo("COMPETITOR_ITEM")
@RealmModel()
class _CompetitorItem {
  @PrimaryKey()
  late String no;
  late String? no2;
  @MapTo("identifier_code")
  late String? identifierCode;
  late String? description;
  @MapTo("description_2")
  late String? description2;
  @MapTo("item_brand_code")
  late String? itemBrandCode;
  @MapTo("item_group_code")
  late String? itemGroupCode;
  @MapTo("item_category_code")
  late String? itemCategoryCode;
  @MapTo("business_unit_code")
  late String? businessUnitCode;
  @MapTo("unit_price")
  late String? unitPrice;
  @MapTo("vendor_no")
  late String? vendorNo;
  @MapTo("competitor_no")
  late String? competitorNo;
  @MapTo("sales_uom_code")
  late String? salesUomCode;
  @MapTo("purchase_uom_code")
  late String? purchaseUomCode;
  late String? picture;
  @MapTo("avatar_32")
  late String? avatar32;
  @MapTo("avatar_128")
  late String? avatar128;
  late String? inactived = "No";
  late String? remark;
}

@MapTo("ITEM_PRIZE_REDEMPTION_HEADER")
@RealmModel()
class _ItemPrizeRedemptionHeader {
  @PrimaryKey()
  late int id;
  @MapTo('no')
  String? no;
  @MapTo('item_no')
  String? itemNo;
  @MapTo('from_date')
  String? fromDate;
  @MapTo('to_date')
  String? toDate;
  String? description;
  @MapTo('description_2')
  String? description2;
  String? remark;
  @MapTo('customer_group_code_filter')
  String? customerGroupCodeFilter;
  @MapTo('salesperson_code_filter')
  String? salespersonCodeFilter;
  @MapTo('distributor_code_filter')
  String? distributorCodeFilter;
  @MapTo('store_code_filter')
  String? storeCodeFilter;
  @MapTo('division_code_filter')
  String? divisionCodeFilter;
  @MapTo('business_unit_code_filter')
  String? businessUnitCodeFilter;
  @MapTo('department_code_filter')
  String? departmentCodeFilter;
  @MapTo('project_code_filter')
  String? projectCodeFilter;
  @MapTo('territory_code_filter')
  String? territoryCodeFilter;
  @MapTo('unit_of_measure')
  String? unitOfMeasure;
  double? quantity;
  String? status = "Open";
  String? picture;
  @MapTo('avatar_32')
  String? avatar32;
  @MapTo('avatar_128')
  String? avatar128;
  @MapTo('is_sync')
  String? isSync = "Yes";
}

@MapTo("ITEM_PRIZE_REDEMPTION_LINE")
@RealmModel()
class _ItemPrizeRedemptionLine {
  @PrimaryKey()
  late int id;
  @MapTo('line_no')
  int? lineNo;
  @MapTo('promotion_no')
  String? promotionNo;
  @MapTo('item_no')
  String? itemNo;
  @MapTo('variant_code')
  String? variantCode;
  @MapTo('redemption_type')
  String? redemptionType;
  String? description;
  @MapTo('description_2')
  String? description2;
  @MapTo('unit_of_measure_code')
  String? unitOfMeasureCode;
  @MapTo('qty_per_unit_of_measure')
  double? qtyPerUnitOfMeasure;
  double? quantity;
  @MapTo('unit_price')
  double? unitPrice;
  @MapTo('discount_percentage')
  double? discountPercentage;
  @MapTo('discount_amount')
  double? discountAmount;
  double? amount;
  @MapTo('is_sync')
  String? isSync = "Yes";
  String? updatedAt;
}
