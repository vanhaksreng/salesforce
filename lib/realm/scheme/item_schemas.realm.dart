// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'item_schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class Item extends _Item with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Item(
    String no, {
    String? no2,
    String? identifierCode,
    String? description,
    String? description2,
    String? stockUomCode,
    String? autoInsertSpecification,
    String? isServiceItem,
    String? invPostingGroupCode,
    String? itemDiscountGroupCode,
    String? commissionGroupCode,
    String? itemBrandCode,
    String? itemGroupCode,
    String? itemCategoryCode,
    String? itemMenuGroupCode,
    String? businessUnitCode,
    String? divisionCode,
    String? departmentCode,
    String? projectCode,
    double? unitPrice,
    double? unitCost,
    double? standardCost,
    double? lastDirectCost,
    String preventNegativeInventory = "Yes",
    String? genProdPostingGroupCode,
    String? vatProdPostingGroupCode,
    String? replenishmentSystem,
    String assemblyPolicy = "Assemble-to-Stock",
    String? salesUomCode,
    String? itemTrackingCode,
    String? picture,
    String? avatar128,
    String? inactived = "No",
    double? inventory = 0,
    String isSync = "Yes",
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Item>({
        'prevent_negative_inventory': "Yes",
        'assembly_policy': "Assemble-to-Stock",
        'inactived': "No",
        'inventory': 0,
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'no_2', no2);
    RealmObjectBase.set(this, 'identifier_code', identifierCode);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'stock_uom_code', stockUomCode);
    RealmObjectBase.set(
        this, 'auto_insert_specification', autoInsertSpecification);
    RealmObjectBase.set(this, 'is_service_item', isServiceItem);
    RealmObjectBase.set(this, 'inv_posting_group_code', invPostingGroupCode);
    RealmObjectBase.set(
        this, 'item_discount_group_code', itemDiscountGroupCode);
    RealmObjectBase.set(this, 'commission_group_code', commissionGroupCode);
    RealmObjectBase.set(this, 'item_brand_code', itemBrandCode);
    RealmObjectBase.set(this, 'item_group_code', itemGroupCode);
    RealmObjectBase.set(this, 'item_category_code', itemCategoryCode);
    RealmObjectBase.set(this, 'item_menu_group_code', itemMenuGroupCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'unit_price', unitPrice);
    RealmObjectBase.set(this, 'unit_cost', unitCost);
    RealmObjectBase.set(this, 'standard_cost', standardCost);
    RealmObjectBase.set(this, 'last_direct_cost', lastDirectCost);
    RealmObjectBase.set(
        this, 'prevent_negative_inventory', preventNegativeInventory);
    RealmObjectBase.set(
        this, 'gen_prod_posting_group_code', genProdPostingGroupCode);
    RealmObjectBase.set(
        this, 'vat_prod_posting_group_code', vatProdPostingGroupCode);
    RealmObjectBase.set(this, 'replenishment_system', replenishmentSystem);
    RealmObjectBase.set(this, 'assembly_policy', assemblyPolicy);
    RealmObjectBase.set(this, 'sales_uom_code', salesUomCode);
    RealmObjectBase.set(this, 'item_tracking_code', itemTrackingCode);
    RealmObjectBase.set(this, 'picture', picture);
    RealmObjectBase.set(this, 'avatar_128', avatar128);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'inventory', inventory);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  Item._();

  @override
  String get no => RealmObjectBase.get<String>(this, 'no') as String;
  @override
  set no(String value) => RealmObjectBase.set(this, 'no', value);

  @override
  String? get no2 => RealmObjectBase.get<String>(this, 'no_2') as String?;
  @override
  set no2(String? value) => RealmObjectBase.set(this, 'no_2', value);

  @override
  String? get identifierCode =>
      RealmObjectBase.get<String>(this, 'identifier_code') as String?;
  @override
  set identifierCode(String? value) =>
      RealmObjectBase.set(this, 'identifier_code', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get description2 =>
      RealmObjectBase.get<String>(this, 'description_2') as String?;
  @override
  set description2(String? value) =>
      RealmObjectBase.set(this, 'description_2', value);

  @override
  String? get stockUomCode =>
      RealmObjectBase.get<String>(this, 'stock_uom_code') as String?;
  @override
  set stockUomCode(String? value) =>
      RealmObjectBase.set(this, 'stock_uom_code', value);

  @override
  String? get autoInsertSpecification =>
      RealmObjectBase.get<String>(this, 'auto_insert_specification') as String?;
  @override
  set autoInsertSpecification(String? value) =>
      RealmObjectBase.set(this, 'auto_insert_specification', value);

  @override
  String? get isServiceItem =>
      RealmObjectBase.get<String>(this, 'is_service_item') as String?;
  @override
  set isServiceItem(String? value) =>
      RealmObjectBase.set(this, 'is_service_item', value);

  @override
  String? get invPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'inv_posting_group_code') as String?;
  @override
  set invPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'inv_posting_group_code', value);

  @override
  String? get itemDiscountGroupCode =>
      RealmObjectBase.get<String>(this, 'item_discount_group_code') as String?;
  @override
  set itemDiscountGroupCode(String? value) =>
      RealmObjectBase.set(this, 'item_discount_group_code', value);

  @override
  String? get commissionGroupCode =>
      RealmObjectBase.get<String>(this, 'commission_group_code') as String?;
  @override
  set commissionGroupCode(String? value) =>
      RealmObjectBase.set(this, 'commission_group_code', value);

  @override
  String? get itemBrandCode =>
      RealmObjectBase.get<String>(this, 'item_brand_code') as String?;
  @override
  set itemBrandCode(String? value) =>
      RealmObjectBase.set(this, 'item_brand_code', value);

  @override
  String? get itemGroupCode =>
      RealmObjectBase.get<String>(this, 'item_group_code') as String?;
  @override
  set itemGroupCode(String? value) =>
      RealmObjectBase.set(this, 'item_group_code', value);

  @override
  String? get itemCategoryCode =>
      RealmObjectBase.get<String>(this, 'item_category_code') as String?;
  @override
  set itemCategoryCode(String? value) =>
      RealmObjectBase.set(this, 'item_category_code', value);

  @override
  String? get itemMenuGroupCode =>
      RealmObjectBase.get<String>(this, 'item_menu_group_code') as String?;
  @override
  set itemMenuGroupCode(String? value) =>
      RealmObjectBase.set(this, 'item_menu_group_code', value);

  @override
  String? get businessUnitCode =>
      RealmObjectBase.get<String>(this, 'business_unit_code') as String?;
  @override
  set businessUnitCode(String? value) =>
      RealmObjectBase.set(this, 'business_unit_code', value);

  @override
  String? get divisionCode =>
      RealmObjectBase.get<String>(this, 'division_code') as String?;
  @override
  set divisionCode(String? value) =>
      RealmObjectBase.set(this, 'division_code', value);

  @override
  String? get departmentCode =>
      RealmObjectBase.get<String>(this, 'department_code') as String?;
  @override
  set departmentCode(String? value) =>
      RealmObjectBase.set(this, 'department_code', value);

  @override
  String? get projectCode =>
      RealmObjectBase.get<String>(this, 'project_code') as String?;
  @override
  set projectCode(String? value) =>
      RealmObjectBase.set(this, 'project_code', value);

  @override
  double? get unitPrice =>
      RealmObjectBase.get<double>(this, 'unit_price') as double?;
  @override
  set unitPrice(double? value) =>
      RealmObjectBase.set(this, 'unit_price', value);

  @override
  double? get unitCost =>
      RealmObjectBase.get<double>(this, 'unit_cost') as double?;
  @override
  set unitCost(double? value) => RealmObjectBase.set(this, 'unit_cost', value);

  @override
  double? get standardCost =>
      RealmObjectBase.get<double>(this, 'standard_cost') as double?;
  @override
  set standardCost(double? value) =>
      RealmObjectBase.set(this, 'standard_cost', value);

  @override
  double? get lastDirectCost =>
      RealmObjectBase.get<double>(this, 'last_direct_cost') as double?;
  @override
  set lastDirectCost(double? value) =>
      RealmObjectBase.set(this, 'last_direct_cost', value);

  @override
  String get preventNegativeInventory =>
      RealmObjectBase.get<String>(this, 'prevent_negative_inventory') as String;
  @override
  set preventNegativeInventory(String value) =>
      RealmObjectBase.set(this, 'prevent_negative_inventory', value);

  @override
  String? get genProdPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'gen_prod_posting_group_code')
          as String?;
  @override
  set genProdPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'gen_prod_posting_group_code', value);

  @override
  String? get vatProdPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'vat_prod_posting_group_code')
          as String?;
  @override
  set vatProdPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'vat_prod_posting_group_code', value);

  @override
  String? get replenishmentSystem =>
      RealmObjectBase.get<String>(this, 'replenishment_system') as String?;
  @override
  set replenishmentSystem(String? value) =>
      RealmObjectBase.set(this, 'replenishment_system', value);

  @override
  String get assemblyPolicy =>
      RealmObjectBase.get<String>(this, 'assembly_policy') as String;
  @override
  set assemblyPolicy(String value) =>
      RealmObjectBase.set(this, 'assembly_policy', value);

  @override
  String? get salesUomCode =>
      RealmObjectBase.get<String>(this, 'sales_uom_code') as String?;
  @override
  set salesUomCode(String? value) =>
      RealmObjectBase.set(this, 'sales_uom_code', value);

  @override
  String? get itemTrackingCode =>
      RealmObjectBase.get<String>(this, 'item_tracking_code') as String?;
  @override
  set itemTrackingCode(String? value) =>
      RealmObjectBase.set(this, 'item_tracking_code', value);

  @override
  String? get picture =>
      RealmObjectBase.get<String>(this, 'picture') as String?;
  @override
  set picture(String? value) => RealmObjectBase.set(this, 'picture', value);

  @override
  String? get avatar128 =>
      RealmObjectBase.get<String>(this, 'avatar_128') as String?;
  @override
  set avatar128(String? value) =>
      RealmObjectBase.set(this, 'avatar_128', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  double? get inventory =>
      RealmObjectBase.get<double>(this, 'inventory') as double?;
  @override
  set inventory(double? value) => RealmObjectBase.set(this, 'inventory', value);

  @override
  String get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String;
  @override
  set isSync(String value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  String? get createdAt =>
      RealmObjectBase.get<String>(this, 'created_at') as String?;
  @override
  set createdAt(String? value) =>
      RealmObjectBase.set(this, 'created_at', value);

  @override
  String? get updatedAt =>
      RealmObjectBase.get<String>(this, 'updated_at') as String?;
  @override
  set updatedAt(String? value) =>
      RealmObjectBase.set(this, 'updated_at', value);

  @override
  Stream<RealmObjectChanges<Item>> get changes =>
      RealmObjectBase.getChanges<Item>(this);

  @override
  Stream<RealmObjectChanges<Item>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Item>(this, keyPaths);

  @override
  Item freeze() => RealmObjectBase.freezeObject<Item>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'no': no.toEJson(),
      'no_2': no2.toEJson(),
      'identifier_code': identifierCode.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'stock_uom_code': stockUomCode.toEJson(),
      'auto_insert_specification': autoInsertSpecification.toEJson(),
      'is_service_item': isServiceItem.toEJson(),
      'inv_posting_group_code': invPostingGroupCode.toEJson(),
      'item_discount_group_code': itemDiscountGroupCode.toEJson(),
      'commission_group_code': commissionGroupCode.toEJson(),
      'item_brand_code': itemBrandCode.toEJson(),
      'item_group_code': itemGroupCode.toEJson(),
      'item_category_code': itemCategoryCode.toEJson(),
      'item_menu_group_code': itemMenuGroupCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'unit_price': unitPrice.toEJson(),
      'unit_cost': unitCost.toEJson(),
      'standard_cost': standardCost.toEJson(),
      'last_direct_cost': lastDirectCost.toEJson(),
      'prevent_negative_inventory': preventNegativeInventory.toEJson(),
      'gen_prod_posting_group_code': genProdPostingGroupCode.toEJson(),
      'vat_prod_posting_group_code': vatProdPostingGroupCode.toEJson(),
      'replenishment_system': replenishmentSystem.toEJson(),
      'assembly_policy': assemblyPolicy.toEJson(),
      'sales_uom_code': salesUomCode.toEJson(),
      'item_tracking_code': itemTrackingCode.toEJson(),
      'picture': picture.toEJson(),
      'avatar_128': avatar128.toEJson(),
      'inactived': inactived.toEJson(),
      'inventory': inventory.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Item value) => value.toEJson();
  static Item _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'no': EJsonValue no,
      } =>
        Item(
          fromEJson(no),
          no2: fromEJson(ejson['no_2']),
          identifierCode: fromEJson(ejson['identifier_code']),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          stockUomCode: fromEJson(ejson['stock_uom_code']),
          autoInsertSpecification:
              fromEJson(ejson['auto_insert_specification']),
          isServiceItem: fromEJson(ejson['is_service_item']),
          invPostingGroupCode: fromEJson(ejson['inv_posting_group_code']),
          itemDiscountGroupCode: fromEJson(ejson['item_discount_group_code']),
          commissionGroupCode: fromEJson(ejson['commission_group_code']),
          itemBrandCode: fromEJson(ejson['item_brand_code']),
          itemGroupCode: fromEJson(ejson['item_group_code']),
          itemCategoryCode: fromEJson(ejson['item_category_code']),
          itemMenuGroupCode: fromEJson(ejson['item_menu_group_code']),
          businessUnitCode: fromEJson(ejson['business_unit_code']),
          divisionCode: fromEJson(ejson['division_code']),
          departmentCode: fromEJson(ejson['department_code']),
          projectCode: fromEJson(ejson['project_code']),
          unitPrice: fromEJson(ejson['unit_price']),
          unitCost: fromEJson(ejson['unit_cost']),
          standardCost: fromEJson(ejson['standard_cost']),
          lastDirectCost: fromEJson(ejson['last_direct_cost']),
          preventNegativeInventory: fromEJson(
              ejson['prevent_negative_inventory'],
              defaultValue: "Yes"),
          genProdPostingGroupCode:
              fromEJson(ejson['gen_prod_posting_group_code']),
          vatProdPostingGroupCode:
              fromEJson(ejson['vat_prod_posting_group_code']),
          replenishmentSystem: fromEJson(ejson['replenishment_system']),
          assemblyPolicy: fromEJson(ejson['assembly_policy'],
              defaultValue: "Assemble-to-Stock"),
          salesUomCode: fromEJson(ejson['sales_uom_code']),
          itemTrackingCode: fromEJson(ejson['item_tracking_code']),
          picture: fromEJson(ejson['picture']),
          avatar128: fromEJson(ejson['avatar_128']),
          inactived: fromEJson(ejson['inactived'], defaultValue: "No"),
          inventory: fromEJson(ejson['inventory'], defaultValue: 0),
          isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
          createdAt: fromEJson(ejson['created_at']),
          updatedAt: fromEJson(ejson['updated_at']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Item._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Item, 'ITEM', [
      SchemaProperty('no', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('no2', RealmPropertyType.string,
          mapTo: 'no_2', optional: true),
      SchemaProperty('identifierCode', RealmPropertyType.string,
          mapTo: 'identifier_code', optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('description2', RealmPropertyType.string,
          mapTo: 'description_2', optional: true),
      SchemaProperty('stockUomCode', RealmPropertyType.string,
          mapTo: 'stock_uom_code', optional: true),
      SchemaProperty('autoInsertSpecification', RealmPropertyType.string,
          mapTo: 'auto_insert_specification', optional: true),
      SchemaProperty('isServiceItem', RealmPropertyType.string,
          mapTo: 'is_service_item', optional: true),
      SchemaProperty('invPostingGroupCode', RealmPropertyType.string,
          mapTo: 'inv_posting_group_code', optional: true),
      SchemaProperty('itemDiscountGroupCode', RealmPropertyType.string,
          mapTo: 'item_discount_group_code', optional: true),
      SchemaProperty('commissionGroupCode', RealmPropertyType.string,
          mapTo: 'commission_group_code', optional: true),
      SchemaProperty('itemBrandCode', RealmPropertyType.string,
          mapTo: 'item_brand_code', optional: true),
      SchemaProperty('itemGroupCode', RealmPropertyType.string,
          mapTo: 'item_group_code', optional: true),
      SchemaProperty('itemCategoryCode', RealmPropertyType.string,
          mapTo: 'item_category_code', optional: true),
      SchemaProperty('itemMenuGroupCode', RealmPropertyType.string,
          mapTo: 'item_menu_group_code', optional: true),
      SchemaProperty('businessUnitCode', RealmPropertyType.string,
          mapTo: 'business_unit_code', optional: true),
      SchemaProperty('divisionCode', RealmPropertyType.string,
          mapTo: 'division_code', optional: true),
      SchemaProperty('departmentCode', RealmPropertyType.string,
          mapTo: 'department_code', optional: true),
      SchemaProperty('projectCode', RealmPropertyType.string,
          mapTo: 'project_code', optional: true),
      SchemaProperty('unitPrice', RealmPropertyType.double,
          mapTo: 'unit_price', optional: true),
      SchemaProperty('unitCost', RealmPropertyType.double,
          mapTo: 'unit_cost', optional: true),
      SchemaProperty('standardCost', RealmPropertyType.double,
          mapTo: 'standard_cost', optional: true),
      SchemaProperty('lastDirectCost', RealmPropertyType.double,
          mapTo: 'last_direct_cost', optional: true),
      SchemaProperty('preventNegativeInventory', RealmPropertyType.string,
          mapTo: 'prevent_negative_inventory'),
      SchemaProperty('genProdPostingGroupCode', RealmPropertyType.string,
          mapTo: 'gen_prod_posting_group_code', optional: true),
      SchemaProperty('vatProdPostingGroupCode', RealmPropertyType.string,
          mapTo: 'vat_prod_posting_group_code', optional: true),
      SchemaProperty('replenishmentSystem', RealmPropertyType.string,
          mapTo: 'replenishment_system', optional: true),
      SchemaProperty('assemblyPolicy', RealmPropertyType.string,
          mapTo: 'assembly_policy'),
      SchemaProperty('salesUomCode', RealmPropertyType.string,
          mapTo: 'sales_uom_code', optional: true),
      SchemaProperty('itemTrackingCode', RealmPropertyType.string,
          mapTo: 'item_tracking_code', optional: true),
      SchemaProperty('picture', RealmPropertyType.string, optional: true),
      SchemaProperty('avatar128', RealmPropertyType.string,
          mapTo: 'avatar_128', optional: true),
      SchemaProperty('inactived', RealmPropertyType.string, optional: true),
      SchemaProperty('inventory', RealmPropertyType.double, optional: true),
      SchemaProperty('isSync', RealmPropertyType.string, mapTo: 'is_sync'),
      SchemaProperty('createdAt', RealmPropertyType.string,
          mapTo: 'created_at', optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.string,
          mapTo: 'updated_at', optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemGroup extends _ItemGroup
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ItemGroup(
    String code, {
    String? description,
    String? description2,
    String? itemBrandCode,
    String? itemCategoryCode,
    String? picture,
    String? inactived = "No",
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ItemGroup>({
        'inactived': "No",
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'item_brand_code', itemBrandCode);
    RealmObjectBase.set(this, 'item_category_code', itemCategoryCode);
    RealmObjectBase.set(this, 'picture', picture);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  ItemGroup._();

  @override
  String get code => RealmObjectBase.get<String>(this, 'code') as String;
  @override
  set code(String value) => RealmObjectBase.set(this, 'code', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get description2 =>
      RealmObjectBase.get<String>(this, 'description_2') as String?;
  @override
  set description2(String? value) =>
      RealmObjectBase.set(this, 'description_2', value);

  @override
  String? get itemBrandCode =>
      RealmObjectBase.get<String>(this, 'item_brand_code') as String?;
  @override
  set itemBrandCode(String? value) =>
      RealmObjectBase.set(this, 'item_brand_code', value);

  @override
  String? get itemCategoryCode =>
      RealmObjectBase.get<String>(this, 'item_category_code') as String?;
  @override
  set itemCategoryCode(String? value) =>
      RealmObjectBase.set(this, 'item_category_code', value);

  @override
  String? get picture =>
      RealmObjectBase.get<String>(this, 'picture') as String?;
  @override
  set picture(String? value) => RealmObjectBase.set(this, 'picture', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get createdAt =>
      RealmObjectBase.get<String>(this, 'created_at') as String?;
  @override
  set createdAt(String? value) =>
      RealmObjectBase.set(this, 'created_at', value);

  @override
  String? get updatedAt =>
      RealmObjectBase.get<String>(this, 'updated_at') as String?;
  @override
  set updatedAt(String? value) =>
      RealmObjectBase.set(this, 'updated_at', value);

  @override
  Stream<RealmObjectChanges<ItemGroup>> get changes =>
      RealmObjectBase.getChanges<ItemGroup>(this);

  @override
  Stream<RealmObjectChanges<ItemGroup>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemGroup>(this, keyPaths);

  @override
  ItemGroup freeze() => RealmObjectBase.freezeObject<ItemGroup>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'item_brand_code': itemBrandCode.toEJson(),
      'item_category_code': itemCategoryCode.toEJson(),
      'picture': picture.toEJson(),
      'inactived': inactived.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemGroup value) => value.toEJson();
  static ItemGroup _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'code': EJsonValue code,
      } =>
        ItemGroup(
          fromEJson(code),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          itemBrandCode: fromEJson(ejson['item_brand_code']),
          itemCategoryCode: fromEJson(ejson['item_category_code']),
          picture: fromEJson(ejson['picture']),
          inactived: fromEJson(ejson['inactived'], defaultValue: "No"),
          createdAt: fromEJson(ejson['created_at']),
          updatedAt: fromEJson(ejson['updated_at']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemGroup._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, ItemGroup, 'ITEM_GROUP', [
      SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('description2', RealmPropertyType.string,
          mapTo: 'description_2', optional: true),
      SchemaProperty('itemBrandCode', RealmPropertyType.string,
          mapTo: 'item_brand_code', optional: true),
      SchemaProperty('itemCategoryCode', RealmPropertyType.string,
          mapTo: 'item_category_code', optional: true),
      SchemaProperty('picture', RealmPropertyType.string, optional: true),
      SchemaProperty('inactived', RealmPropertyType.string, optional: true),
      SchemaProperty('createdAt', RealmPropertyType.string,
          mapTo: 'created_at', optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.string,
          mapTo: 'updated_at', optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemUnitOfMeasure extends _ItemUnitOfMeasure
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ItemUnitOfMeasure(
    String id, {
    String? itemNo,
    String? unitOfMeasureCode,
    String? unitOption,
    String? identifierCode,
    String? description,
    String? description2,
    double? qtyPerUnit = 1.0,
    String? quantityDecimal,
    double? price = 0.0,
    String? priceOption,
    String? inactived = "No",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ItemUnitOfMeasure>({
        'qty_per_unit': 1.0,
        'price': 0.0,
        'inactived': "No",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'unit_of_measure_code', unitOfMeasureCode);
    RealmObjectBase.set(this, 'unit_option', unitOption);
    RealmObjectBase.set(this, 'identifier_code', identifierCode);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'qty_per_unit', qtyPerUnit);
    RealmObjectBase.set(this, 'quantity_decimal', quantityDecimal);
    RealmObjectBase.set(this, 'price', price);
    RealmObjectBase.set(this, 'price_option', priceOption);
    RealmObjectBase.set(this, 'inactived', inactived);
  }

  ItemUnitOfMeasure._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get itemNo => RealmObjectBase.get<String>(this, 'item_no') as String?;
  @override
  set itemNo(String? value) => RealmObjectBase.set(this, 'item_no', value);

  @override
  String? get unitOfMeasureCode =>
      RealmObjectBase.get<String>(this, 'unit_of_measure_code') as String?;
  @override
  set unitOfMeasureCode(String? value) =>
      RealmObjectBase.set(this, 'unit_of_measure_code', value);

  @override
  String? get unitOption =>
      RealmObjectBase.get<String>(this, 'unit_option') as String?;
  @override
  set unitOption(String? value) =>
      RealmObjectBase.set(this, 'unit_option', value);

  @override
  String? get identifierCode =>
      RealmObjectBase.get<String>(this, 'identifier_code') as String?;
  @override
  set identifierCode(String? value) =>
      RealmObjectBase.set(this, 'identifier_code', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get description2 =>
      RealmObjectBase.get<String>(this, 'description_2') as String?;
  @override
  set description2(String? value) =>
      RealmObjectBase.set(this, 'description_2', value);

  @override
  double? get qtyPerUnit =>
      RealmObjectBase.get<double>(this, 'qty_per_unit') as double?;
  @override
  set qtyPerUnit(double? value) =>
      RealmObjectBase.set(this, 'qty_per_unit', value);

  @override
  String? get quantityDecimal =>
      RealmObjectBase.get<String>(this, 'quantity_decimal') as String?;
  @override
  set quantityDecimal(String? value) =>
      RealmObjectBase.set(this, 'quantity_decimal', value);

  @override
  double? get price => RealmObjectBase.get<double>(this, 'price') as double?;
  @override
  set price(double? value) => RealmObjectBase.set(this, 'price', value);

  @override
  String? get priceOption =>
      RealmObjectBase.get<String>(this, 'price_option') as String?;
  @override
  set priceOption(String? value) =>
      RealmObjectBase.set(this, 'price_option', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  Stream<RealmObjectChanges<ItemUnitOfMeasure>> get changes =>
      RealmObjectBase.getChanges<ItemUnitOfMeasure>(this);

  @override
  Stream<RealmObjectChanges<ItemUnitOfMeasure>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemUnitOfMeasure>(this, keyPaths);

  @override
  ItemUnitOfMeasure freeze() =>
      RealmObjectBase.freezeObject<ItemUnitOfMeasure>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'item_no': itemNo.toEJson(),
      'unit_of_measure_code': unitOfMeasureCode.toEJson(),
      'unit_option': unitOption.toEJson(),
      'identifier_code': identifierCode.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'qty_per_unit': qtyPerUnit.toEJson(),
      'quantity_decimal': quantityDecimal.toEJson(),
      'price': price.toEJson(),
      'price_option': priceOption.toEJson(),
      'inactived': inactived.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemUnitOfMeasure value) => value.toEJson();
  static ItemUnitOfMeasure _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        ItemUnitOfMeasure(
          fromEJson(id),
          itemNo: fromEJson(ejson['item_no']),
          unitOfMeasureCode: fromEJson(ejson['unit_of_measure_code']),
          unitOption: fromEJson(ejson['unit_option']),
          identifierCode: fromEJson(ejson['identifier_code']),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          qtyPerUnit: fromEJson(ejson['qty_per_unit'], defaultValue: 1.0),
          quantityDecimal: fromEJson(ejson['quantity_decimal']),
          price: fromEJson(ejson['price'], defaultValue: 0.0),
          priceOption: fromEJson(ejson['price_option']),
          inactived: fromEJson(ejson['inactived'], defaultValue: "No"),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemUnitOfMeasure._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ItemUnitOfMeasure, 'ITEM_UNIT_OF_MEASURE', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('itemNo', RealmPropertyType.string,
          mapTo: 'item_no', optional: true),
      SchemaProperty('unitOfMeasureCode', RealmPropertyType.string,
          mapTo: 'unit_of_measure_code', optional: true),
      SchemaProperty('unitOption', RealmPropertyType.string,
          mapTo: 'unit_option', optional: true),
      SchemaProperty('identifierCode', RealmPropertyType.string,
          mapTo: 'identifier_code', optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('description2', RealmPropertyType.string,
          mapTo: 'description_2', optional: true),
      SchemaProperty('qtyPerUnit', RealmPropertyType.double,
          mapTo: 'qty_per_unit', optional: true),
      SchemaProperty('quantityDecimal', RealmPropertyType.string,
          mapTo: 'quantity_decimal', optional: true),
      SchemaProperty('price', RealmPropertyType.double, optional: true),
      SchemaProperty('priceOption', RealmPropertyType.string,
          mapTo: 'price_option', optional: true),
      SchemaProperty('inactived', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemSalesLinePrices extends _ItemSalesLinePrices
    with RealmEntity, RealmObjectBase, RealmObject {
  ItemSalesLinePrices(
    String id, {
    String? salesType,
    String? salesCode,
    String? itemNo,
    String? variantCode,
    String? uomCode,
    String? customerPriceLevelCode,
    String? currencyCode,
    double? minimumQuantity,
    double? unitPrice,
    double? discountPercentage,
    double? discountAmount,
    String? startingDate,
    String? endingDate,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'sales_type', salesType);
    RealmObjectBase.set(this, 'sales_code', salesCode);
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'uom_code', uomCode);
    RealmObjectBase.set(
        this, 'customer_price_level_code', customerPriceLevelCode);
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'minimum_quantity', minimumQuantity);
    RealmObjectBase.set(this, 'unit_price', unitPrice);
    RealmObjectBase.set(this, 'discount_percentage', discountPercentage);
    RealmObjectBase.set(this, 'discount_amount', discountAmount);
    RealmObjectBase.set(this, 'starting_date', startingDate);
    RealmObjectBase.set(this, 'ending_date', endingDate);
  }

  ItemSalesLinePrices._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get salesType =>
      RealmObjectBase.get<String>(this, 'sales_type') as String?;
  @override
  set salesType(String? value) =>
      RealmObjectBase.set(this, 'sales_type', value);

  @override
  String? get salesCode =>
      RealmObjectBase.get<String>(this, 'sales_code') as String?;
  @override
  set salesCode(String? value) =>
      RealmObjectBase.set(this, 'sales_code', value);

  @override
  String? get itemNo => RealmObjectBase.get<String>(this, 'item_no') as String?;
  @override
  set itemNo(String? value) => RealmObjectBase.set(this, 'item_no', value);

  @override
  String? get variantCode =>
      RealmObjectBase.get<String>(this, 'variant_code') as String?;
  @override
  set variantCode(String? value) =>
      RealmObjectBase.set(this, 'variant_code', value);

  @override
  String? get uomCode =>
      RealmObjectBase.get<String>(this, 'uom_code') as String?;
  @override
  set uomCode(String? value) => RealmObjectBase.set(this, 'uom_code', value);

  @override
  String? get customerPriceLevelCode =>
      RealmObjectBase.get<String>(this, 'customer_price_level_code') as String?;
  @override
  set customerPriceLevelCode(String? value) =>
      RealmObjectBase.set(this, 'customer_price_level_code', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currency_code') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currency_code', value);

  @override
  double? get minimumQuantity =>
      RealmObjectBase.get<double>(this, 'minimum_quantity') as double?;
  @override
  set minimumQuantity(double? value) =>
      RealmObjectBase.set(this, 'minimum_quantity', value);

  @override
  double? get unitPrice =>
      RealmObjectBase.get<double>(this, 'unit_price') as double?;
  @override
  set unitPrice(double? value) =>
      RealmObjectBase.set(this, 'unit_price', value);

  @override
  double? get discountPercentage =>
      RealmObjectBase.get<double>(this, 'discount_percentage') as double?;
  @override
  set discountPercentage(double? value) =>
      RealmObjectBase.set(this, 'discount_percentage', value);

  @override
  double? get discountAmount =>
      RealmObjectBase.get<double>(this, 'discount_amount') as double?;
  @override
  set discountAmount(double? value) =>
      RealmObjectBase.set(this, 'discount_amount', value);

  @override
  String? get startingDate =>
      RealmObjectBase.get<String>(this, 'starting_date') as String?;
  @override
  set startingDate(String? value) =>
      RealmObjectBase.set(this, 'starting_date', value);

  @override
  String? get endingDate =>
      RealmObjectBase.get<String>(this, 'ending_date') as String?;
  @override
  set endingDate(String? value) =>
      RealmObjectBase.set(this, 'ending_date', value);

  @override
  Stream<RealmObjectChanges<ItemSalesLinePrices>> get changes =>
      RealmObjectBase.getChanges<ItemSalesLinePrices>(this);

  @override
  Stream<RealmObjectChanges<ItemSalesLinePrices>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemSalesLinePrices>(this, keyPaths);

  @override
  ItemSalesLinePrices freeze() =>
      RealmObjectBase.freezeObject<ItemSalesLinePrices>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'sales_type': salesType.toEJson(),
      'sales_code': salesCode.toEJson(),
      'item_no': itemNo.toEJson(),
      'variant_code': variantCode.toEJson(),
      'uom_code': uomCode.toEJson(),
      'customer_price_level_code': customerPriceLevelCode.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'minimum_quantity': minimumQuantity.toEJson(),
      'unit_price': unitPrice.toEJson(),
      'discount_percentage': discountPercentage.toEJson(),
      'discount_amount': discountAmount.toEJson(),
      'starting_date': startingDate.toEJson(),
      'ending_date': endingDate.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemSalesLinePrices value) => value.toEJson();
  static ItemSalesLinePrices _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        ItemSalesLinePrices(
          fromEJson(id),
          salesType: fromEJson(ejson['sales_type']),
          salesCode: fromEJson(ejson['sales_code']),
          itemNo: fromEJson(ejson['item_no']),
          variantCode: fromEJson(ejson['variant_code']),
          uomCode: fromEJson(ejson['uom_code']),
          customerPriceLevelCode: fromEJson(ejson['customer_price_level_code']),
          currencyCode: fromEJson(ejson['currency_code']),
          minimumQuantity: fromEJson(ejson['minimum_quantity']),
          unitPrice: fromEJson(ejson['unit_price']),
          discountPercentage: fromEJson(ejson['discount_percentage']),
          discountAmount: fromEJson(ejson['discount_amount']),
          startingDate: fromEJson(ejson['starting_date']),
          endingDate: fromEJson(ejson['ending_date']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemSalesLinePrices._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ItemSalesLinePrices, 'ITEM_SALES_LINE_PRICES', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('salesType', RealmPropertyType.string,
          mapTo: 'sales_type', optional: true),
      SchemaProperty('salesCode', RealmPropertyType.string,
          mapTo: 'sales_code', optional: true),
      SchemaProperty('itemNo', RealmPropertyType.string,
          mapTo: 'item_no', optional: true),
      SchemaProperty('variantCode', RealmPropertyType.string,
          mapTo: 'variant_code', optional: true),
      SchemaProperty('uomCode', RealmPropertyType.string,
          mapTo: 'uom_code', optional: true),
      SchemaProperty('customerPriceLevelCode', RealmPropertyType.string,
          mapTo: 'customer_price_level_code', optional: true),
      SchemaProperty('currencyCode', RealmPropertyType.string,
          mapTo: 'currency_code', optional: true),
      SchemaProperty('minimumQuantity', RealmPropertyType.double,
          mapTo: 'minimum_quantity', optional: true),
      SchemaProperty('unitPrice', RealmPropertyType.double,
          mapTo: 'unit_price', optional: true),
      SchemaProperty('discountPercentage', RealmPropertyType.double,
          mapTo: 'discount_percentage', optional: true),
      SchemaProperty('discountAmount', RealmPropertyType.double,
          mapTo: 'discount_amount', optional: true),
      SchemaProperty('startingDate', RealmPropertyType.string,
          mapTo: 'starting_date', optional: true),
      SchemaProperty('endingDate', RealmPropertyType.string,
          mapTo: 'ending_date', optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemSalesLineDiscount extends _ItemSalesLineDiscount
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ItemSalesLineDiscount(
    String id, {
    String? type,
    String? code,
    String? saleType,
    String? salesCode,
    String? variantCode,
    String? uomCode,
    String? currencyCode,
    String? offerType,
    double? minimumAmount,
    double? minimumQuantity,
    double? lineDiscountPercent = 0,
    double? lineDiscountPercentBirthday = 0,
    double? discAmount = 0,
    String? startingDate,
    String? endingDate,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ItemSalesLineDiscount>({
        'line_discount_percent': 0,
        'line_discount_percent_birthday': 0,
        'disc_amount': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'sale_type', saleType);
    RealmObjectBase.set(this, 'sales_code', salesCode);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'uom_code', uomCode);
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'offer_type', offerType);
    RealmObjectBase.set(this, 'minimum_amount', minimumAmount);
    RealmObjectBase.set(this, 'minimum_quantity', minimumQuantity);
    RealmObjectBase.set(this, 'line_discount_percent', lineDiscountPercent);
    RealmObjectBase.set(
        this, 'line_discount_percent_birthday', lineDiscountPercentBirthday);
    RealmObjectBase.set(this, 'disc_amount', discAmount);
    RealmObjectBase.set(this, 'starting_date', startingDate);
    RealmObjectBase.set(this, 'ending_date', endingDate);
  }

  ItemSalesLineDiscount._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get code => RealmObjectBase.get<String>(this, 'code') as String?;
  @override
  set code(String? value) => RealmObjectBase.set(this, 'code', value);

  @override
  String? get saleType =>
      RealmObjectBase.get<String>(this, 'sale_type') as String?;
  @override
  set saleType(String? value) => RealmObjectBase.set(this, 'sale_type', value);

  @override
  String? get salesCode =>
      RealmObjectBase.get<String>(this, 'sales_code') as String?;
  @override
  set salesCode(String? value) =>
      RealmObjectBase.set(this, 'sales_code', value);

  @override
  String? get variantCode =>
      RealmObjectBase.get<String>(this, 'variant_code') as String?;
  @override
  set variantCode(String? value) =>
      RealmObjectBase.set(this, 'variant_code', value);

  @override
  String? get uomCode =>
      RealmObjectBase.get<String>(this, 'uom_code') as String?;
  @override
  set uomCode(String? value) => RealmObjectBase.set(this, 'uom_code', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currency_code') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currency_code', value);

  @override
  String? get offerType =>
      RealmObjectBase.get<String>(this, 'offer_type') as String?;
  @override
  set offerType(String? value) =>
      RealmObjectBase.set(this, 'offer_type', value);

  @override
  double? get minimumAmount =>
      RealmObjectBase.get<double>(this, 'minimum_amount') as double?;
  @override
  set minimumAmount(double? value) =>
      RealmObjectBase.set(this, 'minimum_amount', value);

  @override
  double? get minimumQuantity =>
      RealmObjectBase.get<double>(this, 'minimum_quantity') as double?;
  @override
  set minimumQuantity(double? value) =>
      RealmObjectBase.set(this, 'minimum_quantity', value);

  @override
  double? get lineDiscountPercent =>
      RealmObjectBase.get<double>(this, 'line_discount_percent') as double?;
  @override
  set lineDiscountPercent(double? value) =>
      RealmObjectBase.set(this, 'line_discount_percent', value);

  @override
  double? get lineDiscountPercentBirthday =>
      RealmObjectBase.get<double>(this, 'line_discount_percent_birthday')
          as double?;
  @override
  set lineDiscountPercentBirthday(double? value) =>
      RealmObjectBase.set(this, 'line_discount_percent_birthday', value);

  @override
  double? get discAmount =>
      RealmObjectBase.get<double>(this, 'disc_amount') as double?;
  @override
  set discAmount(double? value) =>
      RealmObjectBase.set(this, 'disc_amount', value);

  @override
  String? get startingDate =>
      RealmObjectBase.get<String>(this, 'starting_date') as String?;
  @override
  set startingDate(String? value) =>
      RealmObjectBase.set(this, 'starting_date', value);

  @override
  String? get endingDate =>
      RealmObjectBase.get<String>(this, 'ending_date') as String?;
  @override
  set endingDate(String? value) =>
      RealmObjectBase.set(this, 'ending_date', value);

  @override
  Stream<RealmObjectChanges<ItemSalesLineDiscount>> get changes =>
      RealmObjectBase.getChanges<ItemSalesLineDiscount>(this);

  @override
  Stream<RealmObjectChanges<ItemSalesLineDiscount>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemSalesLineDiscount>(this, keyPaths);

  @override
  ItemSalesLineDiscount freeze() =>
      RealmObjectBase.freezeObject<ItemSalesLineDiscount>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'type': type.toEJson(),
      'code': code.toEJson(),
      'sale_type': saleType.toEJson(),
      'sales_code': salesCode.toEJson(),
      'variant_code': variantCode.toEJson(),
      'uom_code': uomCode.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'offer_type': offerType.toEJson(),
      'minimum_amount': minimumAmount.toEJson(),
      'minimum_quantity': minimumQuantity.toEJson(),
      'line_discount_percent': lineDiscountPercent.toEJson(),
      'line_discount_percent_birthday': lineDiscountPercentBirthday.toEJson(),
      'disc_amount': discAmount.toEJson(),
      'starting_date': startingDate.toEJson(),
      'ending_date': endingDate.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemSalesLineDiscount value) => value.toEJson();
  static ItemSalesLineDiscount _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        ItemSalesLineDiscount(
          fromEJson(id),
          type: fromEJson(ejson['type']),
          code: fromEJson(ejson['code']),
          saleType: fromEJson(ejson['sale_type']),
          salesCode: fromEJson(ejson['sales_code']),
          variantCode: fromEJson(ejson['variant_code']),
          uomCode: fromEJson(ejson['uom_code']),
          currencyCode: fromEJson(ejson['currency_code']),
          offerType: fromEJson(ejson['offer_type']),
          minimumAmount: fromEJson(ejson['minimum_amount']),
          minimumQuantity: fromEJson(ejson['minimum_quantity']),
          lineDiscountPercent:
              fromEJson(ejson['line_discount_percent'], defaultValue: 0),
          lineDiscountPercentBirthday: fromEJson(
              ejson['line_discount_percent_birthday'],
              defaultValue: 0),
          discAmount: fromEJson(ejson['disc_amount'], defaultValue: 0),
          startingDate: fromEJson(ejson['starting_date']),
          endingDate: fromEJson(ejson['ending_date']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemSalesLineDiscount._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, ItemSalesLineDiscount,
        'ITEM_SALES_LINE_DISCOUNT', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('type', RealmPropertyType.string, optional: true),
      SchemaProperty('code', RealmPropertyType.string, optional: true),
      SchemaProperty('saleType', RealmPropertyType.string,
          mapTo: 'sale_type', optional: true),
      SchemaProperty('salesCode', RealmPropertyType.string,
          mapTo: 'sales_code', optional: true),
      SchemaProperty('variantCode', RealmPropertyType.string,
          mapTo: 'variant_code', optional: true),
      SchemaProperty('uomCode', RealmPropertyType.string,
          mapTo: 'uom_code', optional: true),
      SchemaProperty('currencyCode', RealmPropertyType.string,
          mapTo: 'currency_code', optional: true),
      SchemaProperty('offerType', RealmPropertyType.string,
          mapTo: 'offer_type', optional: true),
      SchemaProperty('minimumAmount', RealmPropertyType.double,
          mapTo: 'minimum_amount', optional: true),
      SchemaProperty('minimumQuantity', RealmPropertyType.double,
          mapTo: 'minimum_quantity', optional: true),
      SchemaProperty('lineDiscountPercent', RealmPropertyType.double,
          mapTo: 'line_discount_percent', optional: true),
      SchemaProperty('lineDiscountPercentBirthday', RealmPropertyType.double,
          mapTo: 'line_discount_percent_birthday', optional: true),
      SchemaProperty('discAmount', RealmPropertyType.double,
          mapTo: 'disc_amount', optional: true),
      SchemaProperty('startingDate', RealmPropertyType.string,
          mapTo: 'starting_date', optional: true),
      SchemaProperty('endingDate', RealmPropertyType.string,
          mapTo: 'ending_date', optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemPromotionScheme extends _ItemPromotionScheme
    with RealmEntity, RealmObjectBase, RealmObject {
  ItemPromotionScheme(
    String code, {
    String? description,
    String? description2,
    String? itemsNos,
    String? inactived,
  }) {
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'items_nos', itemsNos);
    RealmObjectBase.set(this, 'inactived', inactived);
  }

  ItemPromotionScheme._();

  @override
  String get code => RealmObjectBase.get<String>(this, 'code') as String;
  @override
  set code(String value) => RealmObjectBase.set(this, 'code', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get description2 =>
      RealmObjectBase.get<String>(this, 'description_2') as String?;
  @override
  set description2(String? value) =>
      RealmObjectBase.set(this, 'description_2', value);

  @override
  String? get itemsNos =>
      RealmObjectBase.get<String>(this, 'items_nos') as String?;
  @override
  set itemsNos(String? value) => RealmObjectBase.set(this, 'items_nos', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  Stream<RealmObjectChanges<ItemPromotionScheme>> get changes =>
      RealmObjectBase.getChanges<ItemPromotionScheme>(this);

  @override
  Stream<RealmObjectChanges<ItemPromotionScheme>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemPromotionScheme>(this, keyPaths);

  @override
  ItemPromotionScheme freeze() =>
      RealmObjectBase.freezeObject<ItemPromotionScheme>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'items_nos': itemsNos.toEJson(),
      'inactived': inactived.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemPromotionScheme value) => value.toEJson();
  static ItemPromotionScheme _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'code': EJsonValue code,
      } =>
        ItemPromotionScheme(
          fromEJson(code),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          itemsNos: fromEJson(ejson['items_nos']),
          inactived: fromEJson(ejson['inactived']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemPromotionScheme._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ItemPromotionScheme, 'ITEM_PROMOTION_SCHEME', [
      SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('description2', RealmPropertyType.string,
          mapTo: 'description_2', optional: true),
      SchemaProperty('itemsNos', RealmPropertyType.string,
          mapTo: 'items_nos', optional: true),
      SchemaProperty('inactived', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemPromotionHeader extends _ItemPromotionHeader
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ItemPromotionHeader(
    String id,
    String createdAt,
    String updatedAt, {
    String? no,
    String? fromDate,
    String? toDate,
    String? description,
    String? description2,
    String? remark,
    String? promotionType,
    String status = "Open",
    String? picture,
    String? avatar32,
    String? avatar128,
    double maximumOfferCustomer = 0.0,
    double maximumOfferSalesperson = 0.0,
    String isSync = "Yes",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ItemPromotionHeader>({
        'status': "Open",
        'maximum_offer_customer': 0.0,
        'maximum_offer_salesperson': 0.0,
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'from_date', fromDate);
    RealmObjectBase.set(this, 'to_date', toDate);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'remark', remark);
    RealmObjectBase.set(this, 'promotion_type', promotionType);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'picture', picture);
    RealmObjectBase.set(this, 'avatar_32', avatar32);
    RealmObjectBase.set(this, 'avatar_128', avatar128);
    RealmObjectBase.set(this, 'maximum_offer_customer', maximumOfferCustomer);
    RealmObjectBase.set(
        this, 'maximum_offer_salesperson', maximumOfferSalesperson);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  ItemPromotionHeader._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get no => RealmObjectBase.get<String>(this, 'no') as String?;
  @override
  set no(String? value) => RealmObjectBase.set(this, 'no', value);

  @override
  String? get fromDate =>
      RealmObjectBase.get<String>(this, 'from_date') as String?;
  @override
  set fromDate(String? value) => RealmObjectBase.set(this, 'from_date', value);

  @override
  String? get toDate => RealmObjectBase.get<String>(this, 'to_date') as String?;
  @override
  set toDate(String? value) => RealmObjectBase.set(this, 'to_date', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get description2 =>
      RealmObjectBase.get<String>(this, 'description_2') as String?;
  @override
  set description2(String? value) =>
      RealmObjectBase.set(this, 'description_2', value);

  @override
  String? get remark => RealmObjectBase.get<String>(this, 'remark') as String?;
  @override
  set remark(String? value) => RealmObjectBase.set(this, 'remark', value);

  @override
  String? get promotionType =>
      RealmObjectBase.get<String>(this, 'promotion_type') as String?;
  @override
  set promotionType(String? value) =>
      RealmObjectBase.set(this, 'promotion_type', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get picture =>
      RealmObjectBase.get<String>(this, 'picture') as String?;
  @override
  set picture(String? value) => RealmObjectBase.set(this, 'picture', value);

  @override
  String? get avatar32 =>
      RealmObjectBase.get<String>(this, 'avatar_32') as String?;
  @override
  set avatar32(String? value) => RealmObjectBase.set(this, 'avatar_32', value);

  @override
  String? get avatar128 =>
      RealmObjectBase.get<String>(this, 'avatar_128') as String?;
  @override
  set avatar128(String? value) =>
      RealmObjectBase.set(this, 'avatar_128', value);

  @override
  double get maximumOfferCustomer =>
      RealmObjectBase.get<double>(this, 'maximum_offer_customer') as double;
  @override
  set maximumOfferCustomer(double value) =>
      RealmObjectBase.set(this, 'maximum_offer_customer', value);

  @override
  double get maximumOfferSalesperson =>
      RealmObjectBase.get<double>(this, 'maximum_offer_salesperson') as double;
  @override
  set maximumOfferSalesperson(double value) =>
      RealmObjectBase.set(this, 'maximum_offer_salesperson', value);

  @override
  String get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String;
  @override
  set isSync(String value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  String get createdAt =>
      RealmObjectBase.get<String>(this, 'created_at') as String;
  @override
  set createdAt(String value) => RealmObjectBase.set(this, 'created_at', value);

  @override
  String get updatedAt =>
      RealmObjectBase.get<String>(this, 'updated_at') as String;
  @override
  set updatedAt(String value) => RealmObjectBase.set(this, 'updated_at', value);

  @override
  Stream<RealmObjectChanges<ItemPromotionHeader>> get changes =>
      RealmObjectBase.getChanges<ItemPromotionHeader>(this);

  @override
  Stream<RealmObjectChanges<ItemPromotionHeader>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemPromotionHeader>(this, keyPaths);

  @override
  ItemPromotionHeader freeze() =>
      RealmObjectBase.freezeObject<ItemPromotionHeader>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'no': no.toEJson(),
      'from_date': fromDate.toEJson(),
      'to_date': toDate.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'remark': remark.toEJson(),
      'promotion_type': promotionType.toEJson(),
      'status': status.toEJson(),
      'picture': picture.toEJson(),
      'avatar_32': avatar32.toEJson(),
      'avatar_128': avatar128.toEJson(),
      'maximum_offer_customer': maximumOfferCustomer.toEJson(),
      'maximum_offer_salesperson': maximumOfferSalesperson.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemPromotionHeader value) => value.toEJson();
  static ItemPromotionHeader _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'created_at': EJsonValue createdAt,
        'updated_at': EJsonValue updatedAt,
      } =>
        ItemPromotionHeader(
          fromEJson(id),
          fromEJson(createdAt),
          fromEJson(updatedAt),
          no: fromEJson(ejson['no']),
          fromDate: fromEJson(ejson['from_date']),
          toDate: fromEJson(ejson['to_date']),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          remark: fromEJson(ejson['remark']),
          promotionType: fromEJson(ejson['promotion_type']),
          status: fromEJson(ejson['status'], defaultValue: "Open"),
          picture: fromEJson(ejson['picture']),
          avatar32: fromEJson(ejson['avatar_32']),
          avatar128: fromEJson(ejson['avatar_128']),
          maximumOfferCustomer:
              fromEJson(ejson['maximum_offer_customer'], defaultValue: 0.0),
          maximumOfferSalesperson:
              fromEJson(ejson['maximum_offer_salesperson'], defaultValue: 0.0),
          isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemPromotionHeader._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ItemPromotionHeader, 'ITEM_PROMOTION_HEADER', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('no', RealmPropertyType.string, optional: true),
      SchemaProperty('fromDate', RealmPropertyType.string,
          mapTo: 'from_date', optional: true),
      SchemaProperty('toDate', RealmPropertyType.string,
          mapTo: 'to_date', optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('description2', RealmPropertyType.string,
          mapTo: 'description_2', optional: true),
      SchemaProperty('remark', RealmPropertyType.string, optional: true),
      SchemaProperty('promotionType', RealmPropertyType.string,
          mapTo: 'promotion_type', optional: true),
      SchemaProperty('status', RealmPropertyType.string),
      SchemaProperty('picture', RealmPropertyType.string, optional: true),
      SchemaProperty('avatar32', RealmPropertyType.string,
          mapTo: 'avatar_32', optional: true),
      SchemaProperty('avatar128', RealmPropertyType.string,
          mapTo: 'avatar_128', optional: true),
      SchemaProperty('maximumOfferCustomer', RealmPropertyType.double,
          mapTo: 'maximum_offer_customer'),
      SchemaProperty('maximumOfferSalesperson', RealmPropertyType.double,
          mapTo: 'maximum_offer_salesperson'),
      SchemaProperty('isSync', RealmPropertyType.string, mapTo: 'is_sync'),
      SchemaProperty('createdAt', RealmPropertyType.string,
          mapTo: 'created_at'),
      SchemaProperty('updatedAt', RealmPropertyType.string,
          mapTo: 'updated_at'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemPromotionLine extends _ItemPromotionLine
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ItemPromotionLine(
    String id, {
    int? lineNo,
    String? promotionNo,
    String? type,
    String? itemNo,
    String? variantCode,
    String? description,
    String? description2,
    String? promotionType,
    String? unitOfMeasureCode,
    double? qtyPerUnitOfMeasure = 1.0,
    double? quantity = 0.0,
    double? maximumOfferQuantity = 0.0,
    double? unitPrice = 0.0,
    double? discountPercentage = 0.0,
    double? discountAmount = 0.0,
    double? amount = 0.0,
    String sellingPriceOption = "Fixed Price",
    String isSync = "Yes",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ItemPromotionLine>({
        'qty_per_unit_of_measure': 1.0,
        'quantity': 0.0,
        'maximum_offer_quantity': 0.0,
        'unit_price': 0.0,
        'discount_percentage': 0.0,
        'discount_amount': 0.0,
        'amount': 0.0,
        'selling_price_option': "Fixed Price",
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'line_no', lineNo);
    RealmObjectBase.set(this, 'promotion_no', promotionNo);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'promotion_type', promotionType);
    RealmObjectBase.set(this, 'unit_of_measure_code', unitOfMeasureCode);
    RealmObjectBase.set(this, 'qty_per_unit_of_measure', qtyPerUnitOfMeasure);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'maximum_offer_quantity', maximumOfferQuantity);
    RealmObjectBase.set(this, 'unit_price', unitPrice);
    RealmObjectBase.set(this, 'discount_percentage', discountPercentage);
    RealmObjectBase.set(this, 'discount_amount', discountAmount);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'selling_price_option', sellingPriceOption);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  ItemPromotionLine._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  int? get lineNo => RealmObjectBase.get<int>(this, 'line_no') as int?;
  @override
  set lineNo(int? value) => RealmObjectBase.set(this, 'line_no', value);

  @override
  String? get promotionNo =>
      RealmObjectBase.get<String>(this, 'promotion_no') as String?;
  @override
  set promotionNo(String? value) =>
      RealmObjectBase.set(this, 'promotion_no', value);

  @override
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get itemNo => RealmObjectBase.get<String>(this, 'item_no') as String?;
  @override
  set itemNo(String? value) => RealmObjectBase.set(this, 'item_no', value);

  @override
  String? get variantCode =>
      RealmObjectBase.get<String>(this, 'variant_code') as String?;
  @override
  set variantCode(String? value) =>
      RealmObjectBase.set(this, 'variant_code', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get description2 =>
      RealmObjectBase.get<String>(this, 'description_2') as String?;
  @override
  set description2(String? value) =>
      RealmObjectBase.set(this, 'description_2', value);

  @override
  String? get promotionType =>
      RealmObjectBase.get<String>(this, 'promotion_type') as String?;
  @override
  set promotionType(String? value) =>
      RealmObjectBase.set(this, 'promotion_type', value);

  @override
  String? get unitOfMeasureCode =>
      RealmObjectBase.get<String>(this, 'unit_of_measure_code') as String?;
  @override
  set unitOfMeasureCode(String? value) =>
      RealmObjectBase.set(this, 'unit_of_measure_code', value);

  @override
  double? get qtyPerUnitOfMeasure =>
      RealmObjectBase.get<double>(this, 'qty_per_unit_of_measure') as double?;
  @override
  set qtyPerUnitOfMeasure(double? value) =>
      RealmObjectBase.set(this, 'qty_per_unit_of_measure', value);

  @override
  double? get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double?;
  @override
  set quantity(double? value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  double? get maximumOfferQuantity =>
      RealmObjectBase.get<double>(this, 'maximum_offer_quantity') as double?;
  @override
  set maximumOfferQuantity(double? value) =>
      RealmObjectBase.set(this, 'maximum_offer_quantity', value);

  @override
  double? get unitPrice =>
      RealmObjectBase.get<double>(this, 'unit_price') as double?;
  @override
  set unitPrice(double? value) =>
      RealmObjectBase.set(this, 'unit_price', value);

  @override
  double? get discountPercentage =>
      RealmObjectBase.get<double>(this, 'discount_percentage') as double?;
  @override
  set discountPercentage(double? value) =>
      RealmObjectBase.set(this, 'discount_percentage', value);

  @override
  double? get discountAmount =>
      RealmObjectBase.get<double>(this, 'discount_amount') as double?;
  @override
  set discountAmount(double? value) =>
      RealmObjectBase.set(this, 'discount_amount', value);

  @override
  double? get amount => RealmObjectBase.get<double>(this, 'amount') as double?;
  @override
  set amount(double? value) => RealmObjectBase.set(this, 'amount', value);

  @override
  String get sellingPriceOption =>
      RealmObjectBase.get<String>(this, 'selling_price_option') as String;
  @override
  set sellingPriceOption(String value) =>
      RealmObjectBase.set(this, 'selling_price_option', value);

  @override
  String get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String;
  @override
  set isSync(String value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<ItemPromotionLine>> get changes =>
      RealmObjectBase.getChanges<ItemPromotionLine>(this);

  @override
  Stream<RealmObjectChanges<ItemPromotionLine>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemPromotionLine>(this, keyPaths);

  @override
  ItemPromotionLine freeze() =>
      RealmObjectBase.freezeObject<ItemPromotionLine>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'line_no': lineNo.toEJson(),
      'promotion_no': promotionNo.toEJson(),
      'type': type.toEJson(),
      'item_no': itemNo.toEJson(),
      'variant_code': variantCode.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'promotion_type': promotionType.toEJson(),
      'unit_of_measure_code': unitOfMeasureCode.toEJson(),
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure.toEJson(),
      'quantity': quantity.toEJson(),
      'maximum_offer_quantity': maximumOfferQuantity.toEJson(),
      'unit_price': unitPrice.toEJson(),
      'discount_percentage': discountPercentage.toEJson(),
      'discount_amount': discountAmount.toEJson(),
      'amount': amount.toEJson(),
      'selling_price_option': sellingPriceOption.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemPromotionLine value) => value.toEJson();
  static ItemPromotionLine _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        ItemPromotionLine(
          fromEJson(id),
          lineNo: fromEJson(ejson['line_no']),
          promotionNo: fromEJson(ejson['promotion_no']),
          type: fromEJson(ejson['type']),
          itemNo: fromEJson(ejson['item_no']),
          variantCode: fromEJson(ejson['variant_code']),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          promotionType: fromEJson(ejson['promotion_type']),
          unitOfMeasureCode: fromEJson(ejson['unit_of_measure_code']),
          qtyPerUnitOfMeasure:
              fromEJson(ejson['qty_per_unit_of_measure'], defaultValue: 1.0),
          quantity: fromEJson(ejson['quantity'], defaultValue: 0.0),
          maximumOfferQuantity:
              fromEJson(ejson['maximum_offer_quantity'], defaultValue: 0.0),
          unitPrice: fromEJson(ejson['unit_price'], defaultValue: 0.0),
          discountPercentage:
              fromEJson(ejson['discount_percentage'], defaultValue: 0.0),
          discountAmount:
              fromEJson(ejson['discount_amount'], defaultValue: 0.0),
          amount: fromEJson(ejson['amount'], defaultValue: 0.0),
          sellingPriceOption: fromEJson(ejson['selling_price_option'],
              defaultValue: "Fixed Price"),
          isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemPromotionLine._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ItemPromotionLine, 'ITEM_PROMOTION_LINE', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('lineNo', RealmPropertyType.int,
          mapTo: 'line_no', optional: true),
      SchemaProperty('promotionNo', RealmPropertyType.string,
          mapTo: 'promotion_no', optional: true),
      SchemaProperty('type', RealmPropertyType.string, optional: true),
      SchemaProperty('itemNo', RealmPropertyType.string,
          mapTo: 'item_no', optional: true),
      SchemaProperty('variantCode', RealmPropertyType.string,
          mapTo: 'variant_code', optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('description2', RealmPropertyType.string,
          mapTo: 'description_2', optional: true),
      SchemaProperty('promotionType', RealmPropertyType.string,
          mapTo: 'promotion_type', optional: true),
      SchemaProperty('unitOfMeasureCode', RealmPropertyType.string,
          mapTo: 'unit_of_measure_code', optional: true),
      SchemaProperty('qtyPerUnitOfMeasure', RealmPropertyType.double,
          mapTo: 'qty_per_unit_of_measure', optional: true),
      SchemaProperty('quantity', RealmPropertyType.double, optional: true),
      SchemaProperty('maximumOfferQuantity', RealmPropertyType.double,
          mapTo: 'maximum_offer_quantity', optional: true),
      SchemaProperty('unitPrice', RealmPropertyType.double,
          mapTo: 'unit_price', optional: true),
      SchemaProperty('discountPercentage', RealmPropertyType.double,
          mapTo: 'discount_percentage', optional: true),
      SchemaProperty('discountAmount', RealmPropertyType.double,
          mapTo: 'discount_amount', optional: true),
      SchemaProperty('amount', RealmPropertyType.double, optional: true),
      SchemaProperty('sellingPriceOption', RealmPropertyType.string,
          mapTo: 'selling_price_option'),
      SchemaProperty('isSync', RealmPropertyType.string, mapTo: 'is_sync'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemJournalBatch extends _ItemJournalBatch
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ItemJournalBatch(
    String id, {
    String? code,
    String? type,
    String? description,
    String? description2,
    String? noSeriesCode,
    String? reasonCode,
    String? balAccountType,
    String? inactived = "No",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ItemJournalBatch>({
        'inactived': "No",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'no_series_code', noSeriesCode);
    RealmObjectBase.set(this, 'reason_code', reasonCode);
    RealmObjectBase.set(this, 'bal_account_type', balAccountType);
    RealmObjectBase.set(this, 'inactived', inactived);
  }

  ItemJournalBatch._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get code => RealmObjectBase.get<String>(this, 'code') as String?;
  @override
  set code(String? value) => RealmObjectBase.set(this, 'code', value);

  @override
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get description2 =>
      RealmObjectBase.get<String>(this, 'description_2') as String?;
  @override
  set description2(String? value) =>
      RealmObjectBase.set(this, 'description_2', value);

  @override
  String? get noSeriesCode =>
      RealmObjectBase.get<String>(this, 'no_series_code') as String?;
  @override
  set noSeriesCode(String? value) =>
      RealmObjectBase.set(this, 'no_series_code', value);

  @override
  String? get reasonCode =>
      RealmObjectBase.get<String>(this, 'reason_code') as String?;
  @override
  set reasonCode(String? value) =>
      RealmObjectBase.set(this, 'reason_code', value);

  @override
  String? get balAccountType =>
      RealmObjectBase.get<String>(this, 'bal_account_type') as String?;
  @override
  set balAccountType(String? value) =>
      RealmObjectBase.set(this, 'bal_account_type', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  Stream<RealmObjectChanges<ItemJournalBatch>> get changes =>
      RealmObjectBase.getChanges<ItemJournalBatch>(this);

  @override
  Stream<RealmObjectChanges<ItemJournalBatch>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemJournalBatch>(this, keyPaths);

  @override
  ItemJournalBatch freeze() =>
      RealmObjectBase.freezeObject<ItemJournalBatch>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'code': code.toEJson(),
      'type': type.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'no_series_code': noSeriesCode.toEJson(),
      'reason_code': reasonCode.toEJson(),
      'bal_account_type': balAccountType.toEJson(),
      'inactived': inactived.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemJournalBatch value) => value.toEJson();
  static ItemJournalBatch _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        ItemJournalBatch(
          fromEJson(id),
          code: fromEJson(ejson['code']),
          type: fromEJson(ejson['type']),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          noSeriesCode: fromEJson(ejson['no_series_code']),
          reasonCode: fromEJson(ejson['reason_code']),
          balAccountType: fromEJson(ejson['bal_account_type']),
          inactived: fromEJson(ejson['inactived'], defaultValue: "No"),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemJournalBatch._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ItemJournalBatch, 'ITEM_JOURNAL_BATCH', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('code', RealmPropertyType.string, optional: true),
      SchemaProperty('type', RealmPropertyType.string, optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('description2', RealmPropertyType.string,
          mapTo: 'description_2', optional: true),
      SchemaProperty('noSeriesCode', RealmPropertyType.string,
          mapTo: 'no_series_code', optional: true),
      SchemaProperty('reasonCode', RealmPropertyType.string,
          mapTo: 'reason_code', optional: true),
      SchemaProperty('balAccountType', RealmPropertyType.string,
          mapTo: 'bal_account_type', optional: true),
      SchemaProperty('inactived', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CompetitorItem extends _CompetitorItem
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  CompetitorItem(
    String no, {
    String? no2,
    String? identifierCode,
    String? description,
    String? description2,
    String? itemBrandCode,
    String? itemGroupCode,
    String? itemCategoryCode,
    String? businessUnitCode,
    String? unitPrice,
    String? vendorNo,
    String? competitorNo,
    String? salesUomCode,
    String? purchaseUomCode,
    String? picture,
    String? avatar32,
    String? avatar128,
    String? inactived = "No",
    String? remark,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CompetitorItem>({
        'inactived': "No",
      });
    }
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'no2', no2);
    RealmObjectBase.set(this, 'identifier_code', identifierCode);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'item_brand_code', itemBrandCode);
    RealmObjectBase.set(this, 'item_group_code', itemGroupCode);
    RealmObjectBase.set(this, 'item_category_code', itemCategoryCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'unit_price', unitPrice);
    RealmObjectBase.set(this, 'vendor_no', vendorNo);
    RealmObjectBase.set(this, 'competitor_no', competitorNo);
    RealmObjectBase.set(this, 'sales_uom_code', salesUomCode);
    RealmObjectBase.set(this, 'purchase_uom_code', purchaseUomCode);
    RealmObjectBase.set(this, 'picture', picture);
    RealmObjectBase.set(this, 'avatar_32', avatar32);
    RealmObjectBase.set(this, 'avatar_128', avatar128);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'remark', remark);
  }

  CompetitorItem._();

  @override
  String get no => RealmObjectBase.get<String>(this, 'no') as String;
  @override
  set no(String value) => RealmObjectBase.set(this, 'no', value);

  @override
  String? get no2 => RealmObjectBase.get<String>(this, 'no2') as String?;
  @override
  set no2(String? value) => RealmObjectBase.set(this, 'no2', value);

  @override
  String? get identifierCode =>
      RealmObjectBase.get<String>(this, 'identifier_code') as String?;
  @override
  set identifierCode(String? value) =>
      RealmObjectBase.set(this, 'identifier_code', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get description2 =>
      RealmObjectBase.get<String>(this, 'description_2') as String?;
  @override
  set description2(String? value) =>
      RealmObjectBase.set(this, 'description_2', value);

  @override
  String? get itemBrandCode =>
      RealmObjectBase.get<String>(this, 'item_brand_code') as String?;
  @override
  set itemBrandCode(String? value) =>
      RealmObjectBase.set(this, 'item_brand_code', value);

  @override
  String? get itemGroupCode =>
      RealmObjectBase.get<String>(this, 'item_group_code') as String?;
  @override
  set itemGroupCode(String? value) =>
      RealmObjectBase.set(this, 'item_group_code', value);

  @override
  String? get itemCategoryCode =>
      RealmObjectBase.get<String>(this, 'item_category_code') as String?;
  @override
  set itemCategoryCode(String? value) =>
      RealmObjectBase.set(this, 'item_category_code', value);

  @override
  String? get businessUnitCode =>
      RealmObjectBase.get<String>(this, 'business_unit_code') as String?;
  @override
  set businessUnitCode(String? value) =>
      RealmObjectBase.set(this, 'business_unit_code', value);

  @override
  String? get unitPrice =>
      RealmObjectBase.get<String>(this, 'unit_price') as String?;
  @override
  set unitPrice(String? value) =>
      RealmObjectBase.set(this, 'unit_price', value);

  @override
  String? get vendorNo =>
      RealmObjectBase.get<String>(this, 'vendor_no') as String?;
  @override
  set vendorNo(String? value) => RealmObjectBase.set(this, 'vendor_no', value);

  @override
  String? get competitorNo =>
      RealmObjectBase.get<String>(this, 'competitor_no') as String?;
  @override
  set competitorNo(String? value) =>
      RealmObjectBase.set(this, 'competitor_no', value);

  @override
  String? get salesUomCode =>
      RealmObjectBase.get<String>(this, 'sales_uom_code') as String?;
  @override
  set salesUomCode(String? value) =>
      RealmObjectBase.set(this, 'sales_uom_code', value);

  @override
  String? get purchaseUomCode =>
      RealmObjectBase.get<String>(this, 'purchase_uom_code') as String?;
  @override
  set purchaseUomCode(String? value) =>
      RealmObjectBase.set(this, 'purchase_uom_code', value);

  @override
  String? get picture =>
      RealmObjectBase.get<String>(this, 'picture') as String?;
  @override
  set picture(String? value) => RealmObjectBase.set(this, 'picture', value);

  @override
  String? get avatar32 =>
      RealmObjectBase.get<String>(this, 'avatar_32') as String?;
  @override
  set avatar32(String? value) => RealmObjectBase.set(this, 'avatar_32', value);

  @override
  String? get avatar128 =>
      RealmObjectBase.get<String>(this, 'avatar_128') as String?;
  @override
  set avatar128(String? value) =>
      RealmObjectBase.set(this, 'avatar_128', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get remark => RealmObjectBase.get<String>(this, 'remark') as String?;
  @override
  set remark(String? value) => RealmObjectBase.set(this, 'remark', value);

  @override
  Stream<RealmObjectChanges<CompetitorItem>> get changes =>
      RealmObjectBase.getChanges<CompetitorItem>(this);

  @override
  Stream<RealmObjectChanges<CompetitorItem>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<CompetitorItem>(this, keyPaths);

  @override
  CompetitorItem freeze() => RealmObjectBase.freezeObject<CompetitorItem>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'no': no.toEJson(),
      'no2': no2.toEJson(),
      'identifier_code': identifierCode.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'item_brand_code': itemBrandCode.toEJson(),
      'item_group_code': itemGroupCode.toEJson(),
      'item_category_code': itemCategoryCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'unit_price': unitPrice.toEJson(),
      'vendor_no': vendorNo.toEJson(),
      'competitor_no': competitorNo.toEJson(),
      'sales_uom_code': salesUomCode.toEJson(),
      'purchase_uom_code': purchaseUomCode.toEJson(),
      'picture': picture.toEJson(),
      'avatar_32': avatar32.toEJson(),
      'avatar_128': avatar128.toEJson(),
      'inactived': inactived.toEJson(),
      'remark': remark.toEJson(),
    };
  }

  static EJsonValue _toEJson(CompetitorItem value) => value.toEJson();
  static CompetitorItem _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'no': EJsonValue no,
      } =>
        CompetitorItem(
          fromEJson(no),
          no2: fromEJson(ejson['no2']),
          identifierCode: fromEJson(ejson['identifier_code']),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          itemBrandCode: fromEJson(ejson['item_brand_code']),
          itemGroupCode: fromEJson(ejson['item_group_code']),
          itemCategoryCode: fromEJson(ejson['item_category_code']),
          businessUnitCode: fromEJson(ejson['business_unit_code']),
          unitPrice: fromEJson(ejson['unit_price']),
          vendorNo: fromEJson(ejson['vendor_no']),
          competitorNo: fromEJson(ejson['competitor_no']),
          salesUomCode: fromEJson(ejson['sales_uom_code']),
          purchaseUomCode: fromEJson(ejson['purchase_uom_code']),
          picture: fromEJson(ejson['picture']),
          avatar32: fromEJson(ejson['avatar_32']),
          avatar128: fromEJson(ejson['avatar_128']),
          inactived: fromEJson(ejson['inactived'], defaultValue: "No"),
          remark: fromEJson(ejson['remark']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CompetitorItem._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, CompetitorItem, 'COMPETITOR_ITEM', [
      SchemaProperty('no', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('no2', RealmPropertyType.string, optional: true),
      SchemaProperty('identifierCode', RealmPropertyType.string,
          mapTo: 'identifier_code', optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('description2', RealmPropertyType.string,
          mapTo: 'description_2', optional: true),
      SchemaProperty('itemBrandCode', RealmPropertyType.string,
          mapTo: 'item_brand_code', optional: true),
      SchemaProperty('itemGroupCode', RealmPropertyType.string,
          mapTo: 'item_group_code', optional: true),
      SchemaProperty('itemCategoryCode', RealmPropertyType.string,
          mapTo: 'item_category_code', optional: true),
      SchemaProperty('businessUnitCode', RealmPropertyType.string,
          mapTo: 'business_unit_code', optional: true),
      SchemaProperty('unitPrice', RealmPropertyType.string,
          mapTo: 'unit_price', optional: true),
      SchemaProperty('vendorNo', RealmPropertyType.string,
          mapTo: 'vendor_no', optional: true),
      SchemaProperty('competitorNo', RealmPropertyType.string,
          mapTo: 'competitor_no', optional: true),
      SchemaProperty('salesUomCode', RealmPropertyType.string,
          mapTo: 'sales_uom_code', optional: true),
      SchemaProperty('purchaseUomCode', RealmPropertyType.string,
          mapTo: 'purchase_uom_code', optional: true),
      SchemaProperty('picture', RealmPropertyType.string, optional: true),
      SchemaProperty('avatar32', RealmPropertyType.string,
          mapTo: 'avatar_32', optional: true),
      SchemaProperty('avatar128', RealmPropertyType.string,
          mapTo: 'avatar_128', optional: true),
      SchemaProperty('inactived', RealmPropertyType.string, optional: true),
      SchemaProperty('remark', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemPrizeRedemptionHeader extends _ItemPrizeRedemptionHeader
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ItemPrizeRedemptionHeader(
    int id, {
    String? no,
    String? itemNo,
    String? fromDate,
    String? toDate,
    String? description,
    String? description2,
    String? remark,
    String? customerGroupCodeFilter,
    String? salespersonCodeFilter,
    String? distributorCodeFilter,
    String? storeCodeFilter,
    String? divisionCodeFilter,
    String? businessUnitCodeFilter,
    String? departmentCodeFilter,
    String? projectCodeFilter,
    String? territoryCodeFilter,
    String? unitOfMeasure,
    double? quantity,
    String? status = "Open",
    String? picture,
    String? avatar32,
    String? avatar128,
    String? isSync = "Yes",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ItemPrizeRedemptionHeader>({
        'status': "Open",
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'from_date', fromDate);
    RealmObjectBase.set(this, 'to_date', toDate);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'remark', remark);
    RealmObjectBase.set(
        this, 'customer_group_code_filter', customerGroupCodeFilter);
    RealmObjectBase.set(this, 'salesperson_code_filter', salespersonCodeFilter);
    RealmObjectBase.set(this, 'distributor_code_filter', distributorCodeFilter);
    RealmObjectBase.set(this, 'store_code_filter', storeCodeFilter);
    RealmObjectBase.set(this, 'division_code_filter', divisionCodeFilter);
    RealmObjectBase.set(
        this, 'business_unit_code_filter', businessUnitCodeFilter);
    RealmObjectBase.set(this, 'department_code_filter', departmentCodeFilter);
    RealmObjectBase.set(this, 'project_code_filter', projectCodeFilter);
    RealmObjectBase.set(this, 'territory_code_filter', territoryCodeFilter);
    RealmObjectBase.set(this, 'unit_of_measure', unitOfMeasure);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'picture', picture);
    RealmObjectBase.set(this, 'avatar_32', avatar32);
    RealmObjectBase.set(this, 'avatar_128', avatar128);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  ItemPrizeRedemptionHeader._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get no => RealmObjectBase.get<String>(this, 'no') as String?;
  @override
  set no(String? value) => RealmObjectBase.set(this, 'no', value);

  @override
  String? get itemNo => RealmObjectBase.get<String>(this, 'item_no') as String?;
  @override
  set itemNo(String? value) => RealmObjectBase.set(this, 'item_no', value);

  @override
  String? get fromDate =>
      RealmObjectBase.get<String>(this, 'from_date') as String?;
  @override
  set fromDate(String? value) => RealmObjectBase.set(this, 'from_date', value);

  @override
  String? get toDate => RealmObjectBase.get<String>(this, 'to_date') as String?;
  @override
  set toDate(String? value) => RealmObjectBase.set(this, 'to_date', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get description2 =>
      RealmObjectBase.get<String>(this, 'description_2') as String?;
  @override
  set description2(String? value) =>
      RealmObjectBase.set(this, 'description_2', value);

  @override
  String? get remark => RealmObjectBase.get<String>(this, 'remark') as String?;
  @override
  set remark(String? value) => RealmObjectBase.set(this, 'remark', value);

  @override
  String? get customerGroupCodeFilter =>
      RealmObjectBase.get<String>(this, 'customer_group_code_filter')
          as String?;
  @override
  set customerGroupCodeFilter(String? value) =>
      RealmObjectBase.set(this, 'customer_group_code_filter', value);

  @override
  String? get salespersonCodeFilter =>
      RealmObjectBase.get<String>(this, 'salesperson_code_filter') as String?;
  @override
  set salespersonCodeFilter(String? value) =>
      RealmObjectBase.set(this, 'salesperson_code_filter', value);

  @override
  String? get distributorCodeFilter =>
      RealmObjectBase.get<String>(this, 'distributor_code_filter') as String?;
  @override
  set distributorCodeFilter(String? value) =>
      RealmObjectBase.set(this, 'distributor_code_filter', value);

  @override
  String? get storeCodeFilter =>
      RealmObjectBase.get<String>(this, 'store_code_filter') as String?;
  @override
  set storeCodeFilter(String? value) =>
      RealmObjectBase.set(this, 'store_code_filter', value);

  @override
  String? get divisionCodeFilter =>
      RealmObjectBase.get<String>(this, 'division_code_filter') as String?;
  @override
  set divisionCodeFilter(String? value) =>
      RealmObjectBase.set(this, 'division_code_filter', value);

  @override
  String? get businessUnitCodeFilter =>
      RealmObjectBase.get<String>(this, 'business_unit_code_filter') as String?;
  @override
  set businessUnitCodeFilter(String? value) =>
      RealmObjectBase.set(this, 'business_unit_code_filter', value);

  @override
  String? get departmentCodeFilter =>
      RealmObjectBase.get<String>(this, 'department_code_filter') as String?;
  @override
  set departmentCodeFilter(String? value) =>
      RealmObjectBase.set(this, 'department_code_filter', value);

  @override
  String? get projectCodeFilter =>
      RealmObjectBase.get<String>(this, 'project_code_filter') as String?;
  @override
  set projectCodeFilter(String? value) =>
      RealmObjectBase.set(this, 'project_code_filter', value);

  @override
  String? get territoryCodeFilter =>
      RealmObjectBase.get<String>(this, 'territory_code_filter') as String?;
  @override
  set territoryCodeFilter(String? value) =>
      RealmObjectBase.set(this, 'territory_code_filter', value);

  @override
  String? get unitOfMeasure =>
      RealmObjectBase.get<String>(this, 'unit_of_measure') as String?;
  @override
  set unitOfMeasure(String? value) =>
      RealmObjectBase.set(this, 'unit_of_measure', value);

  @override
  double? get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double?;
  @override
  set quantity(double? value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get picture =>
      RealmObjectBase.get<String>(this, 'picture') as String?;
  @override
  set picture(String? value) => RealmObjectBase.set(this, 'picture', value);

  @override
  String? get avatar32 =>
      RealmObjectBase.get<String>(this, 'avatar_32') as String?;
  @override
  set avatar32(String? value) => RealmObjectBase.set(this, 'avatar_32', value);

  @override
  String? get avatar128 =>
      RealmObjectBase.get<String>(this, 'avatar_128') as String?;
  @override
  set avatar128(String? value) =>
      RealmObjectBase.set(this, 'avatar_128', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<ItemPrizeRedemptionHeader>> get changes =>
      RealmObjectBase.getChanges<ItemPrizeRedemptionHeader>(this);

  @override
  Stream<RealmObjectChanges<ItemPrizeRedemptionHeader>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemPrizeRedemptionHeader>(this, keyPaths);

  @override
  ItemPrizeRedemptionHeader freeze() =>
      RealmObjectBase.freezeObject<ItemPrizeRedemptionHeader>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'no': no.toEJson(),
      'item_no': itemNo.toEJson(),
      'from_date': fromDate.toEJson(),
      'to_date': toDate.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'remark': remark.toEJson(),
      'customer_group_code_filter': customerGroupCodeFilter.toEJson(),
      'salesperson_code_filter': salespersonCodeFilter.toEJson(),
      'distributor_code_filter': distributorCodeFilter.toEJson(),
      'store_code_filter': storeCodeFilter.toEJson(),
      'division_code_filter': divisionCodeFilter.toEJson(),
      'business_unit_code_filter': businessUnitCodeFilter.toEJson(),
      'department_code_filter': departmentCodeFilter.toEJson(),
      'project_code_filter': projectCodeFilter.toEJson(),
      'territory_code_filter': territoryCodeFilter.toEJson(),
      'unit_of_measure': unitOfMeasure.toEJson(),
      'quantity': quantity.toEJson(),
      'status': status.toEJson(),
      'picture': picture.toEJson(),
      'avatar_32': avatar32.toEJson(),
      'avatar_128': avatar128.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemPrizeRedemptionHeader value) =>
      value.toEJson();
  static ItemPrizeRedemptionHeader _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        ItemPrizeRedemptionHeader(
          fromEJson(id),
          no: fromEJson(ejson['no']),
          itemNo: fromEJson(ejson['item_no']),
          fromDate: fromEJson(ejson['from_date']),
          toDate: fromEJson(ejson['to_date']),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          remark: fromEJson(ejson['remark']),
          customerGroupCodeFilter:
              fromEJson(ejson['customer_group_code_filter']),
          salespersonCodeFilter: fromEJson(ejson['salesperson_code_filter']),
          distributorCodeFilter: fromEJson(ejson['distributor_code_filter']),
          storeCodeFilter: fromEJson(ejson['store_code_filter']),
          divisionCodeFilter: fromEJson(ejson['division_code_filter']),
          businessUnitCodeFilter: fromEJson(ejson['business_unit_code_filter']),
          departmentCodeFilter: fromEJson(ejson['department_code_filter']),
          projectCodeFilter: fromEJson(ejson['project_code_filter']),
          territoryCodeFilter: fromEJson(ejson['territory_code_filter']),
          unitOfMeasure: fromEJson(ejson['unit_of_measure']),
          quantity: fromEJson(ejson['quantity']),
          status: fromEJson(ejson['status'], defaultValue: "Open"),
          picture: fromEJson(ejson['picture']),
          avatar32: fromEJson(ejson['avatar_32']),
          avatar128: fromEJson(ejson['avatar_128']),
          isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemPrizeRedemptionHeader._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, ItemPrizeRedemptionHeader,
        'ITEM_PRIZE_REDEMPTION_HEADER', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('no', RealmPropertyType.string, optional: true),
      SchemaProperty('itemNo', RealmPropertyType.string,
          mapTo: 'item_no', optional: true),
      SchemaProperty('fromDate', RealmPropertyType.string,
          mapTo: 'from_date', optional: true),
      SchemaProperty('toDate', RealmPropertyType.string,
          mapTo: 'to_date', optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('description2', RealmPropertyType.string,
          mapTo: 'description_2', optional: true),
      SchemaProperty('remark', RealmPropertyType.string, optional: true),
      SchemaProperty('customerGroupCodeFilter', RealmPropertyType.string,
          mapTo: 'customer_group_code_filter', optional: true),
      SchemaProperty('salespersonCodeFilter', RealmPropertyType.string,
          mapTo: 'salesperson_code_filter', optional: true),
      SchemaProperty('distributorCodeFilter', RealmPropertyType.string,
          mapTo: 'distributor_code_filter', optional: true),
      SchemaProperty('storeCodeFilter', RealmPropertyType.string,
          mapTo: 'store_code_filter', optional: true),
      SchemaProperty('divisionCodeFilter', RealmPropertyType.string,
          mapTo: 'division_code_filter', optional: true),
      SchemaProperty('businessUnitCodeFilter', RealmPropertyType.string,
          mapTo: 'business_unit_code_filter', optional: true),
      SchemaProperty('departmentCodeFilter', RealmPropertyType.string,
          mapTo: 'department_code_filter', optional: true),
      SchemaProperty('projectCodeFilter', RealmPropertyType.string,
          mapTo: 'project_code_filter', optional: true),
      SchemaProperty('territoryCodeFilter', RealmPropertyType.string,
          mapTo: 'territory_code_filter', optional: true),
      SchemaProperty('unitOfMeasure', RealmPropertyType.string,
          mapTo: 'unit_of_measure', optional: true),
      SchemaProperty('quantity', RealmPropertyType.double, optional: true),
      SchemaProperty('status', RealmPropertyType.string, optional: true),
      SchemaProperty('picture', RealmPropertyType.string, optional: true),
      SchemaProperty('avatar32', RealmPropertyType.string,
          mapTo: 'avatar_32', optional: true),
      SchemaProperty('avatar128', RealmPropertyType.string,
          mapTo: 'avatar_128', optional: true),
      SchemaProperty('isSync', RealmPropertyType.string,
          mapTo: 'is_sync', optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemPrizeRedemptionLine extends _ItemPrizeRedemptionLine
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ItemPrizeRedemptionLine(
    int id, {
    int? lineNo,
    String? promotionNo,
    String? itemNo,
    String? variantCode,
    String? redemptionType,
    String? description,
    String? description2,
    String? unitOfMeasureCode,
    double? qtyPerUnitOfMeasure,
    double? quantity,
    double? unitPrice,
    double? discountPercentage,
    double? discountAmount,
    double? amount,
    String? isSync = "Yes",
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ItemPrizeRedemptionLine>({
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'line_no', lineNo);
    RealmObjectBase.set(this, 'promotion_no', promotionNo);
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'redemption_type', redemptionType);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'unit_of_measure_code', unitOfMeasureCode);
    RealmObjectBase.set(this, 'qty_per_unit_of_measure', qtyPerUnitOfMeasure);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'unit_price', unitPrice);
    RealmObjectBase.set(this, 'discount_percentage', discountPercentage);
    RealmObjectBase.set(this, 'discount_amount', discountAmount);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'updatedAt', updatedAt);
  }

  ItemPrizeRedemptionLine._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  int? get lineNo => RealmObjectBase.get<int>(this, 'line_no') as int?;
  @override
  set lineNo(int? value) => RealmObjectBase.set(this, 'line_no', value);

  @override
  String? get promotionNo =>
      RealmObjectBase.get<String>(this, 'promotion_no') as String?;
  @override
  set promotionNo(String? value) =>
      RealmObjectBase.set(this, 'promotion_no', value);

  @override
  String? get itemNo => RealmObjectBase.get<String>(this, 'item_no') as String?;
  @override
  set itemNo(String? value) => RealmObjectBase.set(this, 'item_no', value);

  @override
  String? get variantCode =>
      RealmObjectBase.get<String>(this, 'variant_code') as String?;
  @override
  set variantCode(String? value) =>
      RealmObjectBase.set(this, 'variant_code', value);

  @override
  String? get redemptionType =>
      RealmObjectBase.get<String>(this, 'redemption_type') as String?;
  @override
  set redemptionType(String? value) =>
      RealmObjectBase.set(this, 'redemption_type', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get description2 =>
      RealmObjectBase.get<String>(this, 'description_2') as String?;
  @override
  set description2(String? value) =>
      RealmObjectBase.set(this, 'description_2', value);

  @override
  String? get unitOfMeasureCode =>
      RealmObjectBase.get<String>(this, 'unit_of_measure_code') as String?;
  @override
  set unitOfMeasureCode(String? value) =>
      RealmObjectBase.set(this, 'unit_of_measure_code', value);

  @override
  double? get qtyPerUnitOfMeasure =>
      RealmObjectBase.get<double>(this, 'qty_per_unit_of_measure') as double?;
  @override
  set qtyPerUnitOfMeasure(double? value) =>
      RealmObjectBase.set(this, 'qty_per_unit_of_measure', value);

  @override
  double? get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double?;
  @override
  set quantity(double? value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  double? get unitPrice =>
      RealmObjectBase.get<double>(this, 'unit_price') as double?;
  @override
  set unitPrice(double? value) =>
      RealmObjectBase.set(this, 'unit_price', value);

  @override
  double? get discountPercentage =>
      RealmObjectBase.get<double>(this, 'discount_percentage') as double?;
  @override
  set discountPercentage(double? value) =>
      RealmObjectBase.set(this, 'discount_percentage', value);

  @override
  double? get discountAmount =>
      RealmObjectBase.get<double>(this, 'discount_amount') as double?;
  @override
  set discountAmount(double? value) =>
      RealmObjectBase.set(this, 'discount_amount', value);

  @override
  double? get amount => RealmObjectBase.get<double>(this, 'amount') as double?;
  @override
  set amount(double? value) => RealmObjectBase.set(this, 'amount', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  String? get updatedAt =>
      RealmObjectBase.get<String>(this, 'updatedAt') as String?;
  @override
  set updatedAt(String? value) => RealmObjectBase.set(this, 'updatedAt', value);

  @override
  Stream<RealmObjectChanges<ItemPrizeRedemptionLine>> get changes =>
      RealmObjectBase.getChanges<ItemPrizeRedemptionLine>(this);

  @override
  Stream<RealmObjectChanges<ItemPrizeRedemptionLine>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemPrizeRedemptionLine>(this, keyPaths);

  @override
  ItemPrizeRedemptionLine freeze() =>
      RealmObjectBase.freezeObject<ItemPrizeRedemptionLine>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'line_no': lineNo.toEJson(),
      'promotion_no': promotionNo.toEJson(),
      'item_no': itemNo.toEJson(),
      'variant_code': variantCode.toEJson(),
      'redemption_type': redemptionType.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'unit_of_measure_code': unitOfMeasureCode.toEJson(),
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure.toEJson(),
      'quantity': quantity.toEJson(),
      'unit_price': unitPrice.toEJson(),
      'discount_percentage': discountPercentage.toEJson(),
      'discount_amount': discountAmount.toEJson(),
      'amount': amount.toEJson(),
      'is_sync': isSync.toEJson(),
      'updatedAt': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemPrizeRedemptionLine value) => value.toEJson();
  static ItemPrizeRedemptionLine _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        ItemPrizeRedemptionLine(
          fromEJson(id),
          lineNo: fromEJson(ejson['line_no']),
          promotionNo: fromEJson(ejson['promotion_no']),
          itemNo: fromEJson(ejson['item_no']),
          variantCode: fromEJson(ejson['variant_code']),
          redemptionType: fromEJson(ejson['redemption_type']),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          unitOfMeasureCode: fromEJson(ejson['unit_of_measure_code']),
          qtyPerUnitOfMeasure: fromEJson(ejson['qty_per_unit_of_measure']),
          quantity: fromEJson(ejson['quantity']),
          unitPrice: fromEJson(ejson['unit_price']),
          discountPercentage: fromEJson(ejson['discount_percentage']),
          discountAmount: fromEJson(ejson['discount_amount']),
          amount: fromEJson(ejson['amount']),
          isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
          updatedAt: fromEJson(ejson['updatedAt']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemPrizeRedemptionLine._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, ItemPrizeRedemptionLine,
        'ITEM_PRIZE_REDEMPTION_LINE', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
      SchemaProperty('lineNo', RealmPropertyType.int,
          mapTo: 'line_no', optional: true),
      SchemaProperty('promotionNo', RealmPropertyType.string,
          mapTo: 'promotion_no', optional: true),
      SchemaProperty('itemNo', RealmPropertyType.string,
          mapTo: 'item_no', optional: true),
      SchemaProperty('variantCode', RealmPropertyType.string,
          mapTo: 'variant_code', optional: true),
      SchemaProperty('redemptionType', RealmPropertyType.string,
          mapTo: 'redemption_type', optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty('description2', RealmPropertyType.string,
          mapTo: 'description_2', optional: true),
      SchemaProperty('unitOfMeasureCode', RealmPropertyType.string,
          mapTo: 'unit_of_measure_code', optional: true),
      SchemaProperty('qtyPerUnitOfMeasure', RealmPropertyType.double,
          mapTo: 'qty_per_unit_of_measure', optional: true),
      SchemaProperty('quantity', RealmPropertyType.double, optional: true),
      SchemaProperty('unitPrice', RealmPropertyType.double,
          mapTo: 'unit_price', optional: true),
      SchemaProperty('discountPercentage', RealmPropertyType.double,
          mapTo: 'discount_percentage', optional: true),
      SchemaProperty('discountAmount', RealmPropertyType.double,
          mapTo: 'discount_amount', optional: true),
      SchemaProperty('amount', RealmPropertyType.double, optional: true),
      SchemaProperty('isSync', RealmPropertyType.string,
          mapTo: 'is_sync', optional: true),
      SchemaProperty('updatedAt', RealmPropertyType.string, optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
