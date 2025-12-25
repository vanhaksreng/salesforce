// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class CompetitorItemLedgerEntry extends _CompetitorItemLedgerEntry
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  CompetitorItemLedgerEntry(
    String entryNo, {
    String? appId,
    String? scheduleId,
    String? shipToCode,
    String? itemNo,
    String? competitorNo,
    String? competitorName,
    String? competitorName2,
    String? customerNo,
    String? customerName,
    String? customerName2,
    String? variantCode,
    String? itemDescription,
    String? itemDescription2,
    String? countingDate,
    String? description,
    String? description2,
    double? quantity,
    double? quantityBase,
    double? plannedQuantity,
    double? plannedQuantityBase,
    double? volumeSalesQuantity,
    double? volumeSalesQuantityBase,
    double? volumeSalesQuantityUom,
    double? volumeSalesQuantityMeasure,
    String? unitOfMeasureCode,
    double? qtyPerUnitOfMeasure,
    String? serialNo,
    String? lotNo,
    String? warrantyDate,
    String? expirationDate,
    String? status,
    double? unitCost,
    double? unitPrice,
    double? unitPriceLcy,
    String? vatCalculationType,
    double? vatPercentage,
    double? vatBaseAmount,
    double? vatAmount,
    double? discountPercentage,
    double? discountAmount,
    double? amount,
    double? amountLcy,
    double? amountIncludingVat,
    double? amountIncludingVatLcy,
    String? currencyCode,
    double? currencyFactor,
    double? priceIncludeVat,
    String? remark,
    String? isSync = "No",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CompetitorItemLedgerEntry>({
        'is_sync': "No",
      });
    }
    RealmObjectBase.set(this, 'entry_no', entryNo);
    RealmObjectBase.set(this, 'app_id', appId);
    RealmObjectBase.set(this, 'schedule_id', scheduleId);
    RealmObjectBase.set(this, 'ship_to_code', shipToCode);
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'competitor_no', competitorNo);
    RealmObjectBase.set(this, 'competitor_name', competitorName);
    RealmObjectBase.set(this, 'competitor_name_2', competitorName2);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'customer_name', customerName);
    RealmObjectBase.set(this, 'customer_name_2', customerName2);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'item_description', itemDescription);
    RealmObjectBase.set(this, 'item_description_2', itemDescription2);
    RealmObjectBase.set(this, 'counting_date', countingDate);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'quantity_base', quantityBase);
    RealmObjectBase.set(this, 'planned_quantity', plannedQuantity);
    RealmObjectBase.set(this, 'planned_quantity_base', plannedQuantityBase);
    RealmObjectBase.set(this, 'volume_sales_quantity', volumeSalesQuantity);
    RealmObjectBase.set(
      this,
      'volume_sales_quantity_base',
      volumeSalesQuantityBase,
    );
    RealmObjectBase.set(
      this,
      'volume_sales_quantity_uom',
      volumeSalesQuantityUom,
    );
    RealmObjectBase.set(
      this,
      'volume_sales_quantity_measure',
      volumeSalesQuantityMeasure,
    );
    RealmObjectBase.set(this, 'unit_of_measure_code', unitOfMeasureCode);
    RealmObjectBase.set(this, 'qty_per_unit_of_measure', qtyPerUnitOfMeasure);
    RealmObjectBase.set(this, 'serial_no', serialNo);
    RealmObjectBase.set(this, 'lot_no', lotNo);
    RealmObjectBase.set(this, 'warranty_date', warrantyDate);
    RealmObjectBase.set(this, 'expiration_date', expirationDate);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'unit_cost', unitCost);
    RealmObjectBase.set(this, 'unit_price', unitPrice);
    RealmObjectBase.set(this, 'unit_price_lcy', unitPriceLcy);
    RealmObjectBase.set(this, 'vat_calculation_type', vatCalculationType);
    RealmObjectBase.set(this, 'vat_percentage', vatPercentage);
    RealmObjectBase.set(this, 'vat_base_amount', vatBaseAmount);
    RealmObjectBase.set(this, 'vat_amount', vatAmount);
    RealmObjectBase.set(this, 'discount_percentage', discountPercentage);
    RealmObjectBase.set(this, 'discount_amount', discountAmount);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'amount_lcy', amountLcy);
    RealmObjectBase.set(this, 'amount_including_vat', amountIncludingVat);
    RealmObjectBase.set(
      this,
      'amount_including_vat_lcy',
      amountIncludingVatLcy,
    );
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'currency_factor', currencyFactor);
    RealmObjectBase.set(this, 'price_include_vat', priceIncludeVat);
    RealmObjectBase.set(this, 'remark', remark);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  CompetitorItemLedgerEntry._();

  @override
  String get entryNo => RealmObjectBase.get<String>(this, 'entry_no') as String;
  @override
  set entryNo(String value) => RealmObjectBase.set(this, 'entry_no', value);

  @override
  String? get appId => RealmObjectBase.get<String>(this, 'app_id') as String?;
  @override
  set appId(String? value) => RealmObjectBase.set(this, 'app_id', value);

  @override
  String? get scheduleId =>
      RealmObjectBase.get<String>(this, 'schedule_id') as String?;
  @override
  set scheduleId(String? value) =>
      RealmObjectBase.set(this, 'schedule_id', value);

  @override
  String? get shipToCode =>
      RealmObjectBase.get<String>(this, 'ship_to_code') as String?;
  @override
  set shipToCode(String? value) =>
      RealmObjectBase.set(this, 'ship_to_code', value);

  @override
  String? get itemNo => RealmObjectBase.get<String>(this, 'item_no') as String?;
  @override
  set itemNo(String? value) => RealmObjectBase.set(this, 'item_no', value);

  @override
  String? get competitorNo =>
      RealmObjectBase.get<String>(this, 'competitor_no') as String?;
  @override
  set competitorNo(String? value) =>
      RealmObjectBase.set(this, 'competitor_no', value);

  @override
  String? get competitorName =>
      RealmObjectBase.get<String>(this, 'competitor_name') as String?;
  @override
  set competitorName(String? value) =>
      RealmObjectBase.set(this, 'competitor_name', value);

  @override
  String? get competitorName2 =>
      RealmObjectBase.get<String>(this, 'competitor_name_2') as String?;
  @override
  set competitorName2(String? value) =>
      RealmObjectBase.set(this, 'competitor_name_2', value);

  @override
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

  @override
  String? get customerName =>
      RealmObjectBase.get<String>(this, 'customer_name') as String?;
  @override
  set customerName(String? value) =>
      RealmObjectBase.set(this, 'customer_name', value);

  @override
  String? get customerName2 =>
      RealmObjectBase.get<String>(this, 'customer_name_2') as String?;
  @override
  set customerName2(String? value) =>
      RealmObjectBase.set(this, 'customer_name_2', value);

  @override
  String? get variantCode =>
      RealmObjectBase.get<String>(this, 'variant_code') as String?;
  @override
  set variantCode(String? value) =>
      RealmObjectBase.set(this, 'variant_code', value);

  @override
  String? get itemDescription =>
      RealmObjectBase.get<String>(this, 'item_description') as String?;
  @override
  set itemDescription(String? value) =>
      RealmObjectBase.set(this, 'item_description', value);

  @override
  String? get itemDescription2 =>
      RealmObjectBase.get<String>(this, 'item_description_2') as String?;
  @override
  set itemDescription2(String? value) =>
      RealmObjectBase.set(this, 'item_description_2', value);

  @override
  String? get countingDate =>
      RealmObjectBase.get<String>(this, 'counting_date') as String?;
  @override
  set countingDate(String? value) =>
      RealmObjectBase.set(this, 'counting_date', value);

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
  double? get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double?;
  @override
  set quantity(double? value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  double? get quantityBase =>
      RealmObjectBase.get<double>(this, 'quantity_base') as double?;
  @override
  set quantityBase(double? value) =>
      RealmObjectBase.set(this, 'quantity_base', value);

  @override
  double? get plannedQuantity =>
      RealmObjectBase.get<double>(this, 'planned_quantity') as double?;
  @override
  set plannedQuantity(double? value) =>
      RealmObjectBase.set(this, 'planned_quantity', value);

  @override
  double? get plannedQuantityBase =>
      RealmObjectBase.get<double>(this, 'planned_quantity_base') as double?;
  @override
  set plannedQuantityBase(double? value) =>
      RealmObjectBase.set(this, 'planned_quantity_base', value);

  @override
  double? get volumeSalesQuantity =>
      RealmObjectBase.get<double>(this, 'volume_sales_quantity') as double?;
  @override
  set volumeSalesQuantity(double? value) =>
      RealmObjectBase.set(this, 'volume_sales_quantity', value);

  @override
  double? get volumeSalesQuantityBase =>
      RealmObjectBase.get<double>(this, 'volume_sales_quantity_base')
          as double?;
  @override
  set volumeSalesQuantityBase(double? value) =>
      RealmObjectBase.set(this, 'volume_sales_quantity_base', value);

  @override
  double? get volumeSalesQuantityUom =>
      RealmObjectBase.get<double>(this, 'volume_sales_quantity_uom') as double?;
  @override
  set volumeSalesQuantityUom(double? value) =>
      RealmObjectBase.set(this, 'volume_sales_quantity_uom', value);

  @override
  double? get volumeSalesQuantityMeasure =>
      RealmObjectBase.get<double>(this, 'volume_sales_quantity_measure')
          as double?;
  @override
  set volumeSalesQuantityMeasure(double? value) =>
      RealmObjectBase.set(this, 'volume_sales_quantity_measure', value);

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
  String? get serialNo =>
      RealmObjectBase.get<String>(this, 'serial_no') as String?;
  @override
  set serialNo(String? value) => RealmObjectBase.set(this, 'serial_no', value);

  @override
  String? get lotNo => RealmObjectBase.get<String>(this, 'lot_no') as String?;
  @override
  set lotNo(String? value) => RealmObjectBase.set(this, 'lot_no', value);

  @override
  String? get warrantyDate =>
      RealmObjectBase.get<String>(this, 'warranty_date') as String?;
  @override
  set warrantyDate(String? value) =>
      RealmObjectBase.set(this, 'warranty_date', value);

  @override
  String? get expirationDate =>
      RealmObjectBase.get<String>(this, 'expiration_date') as String?;
  @override
  set expirationDate(String? value) =>
      RealmObjectBase.set(this, 'expiration_date', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  double? get unitCost =>
      RealmObjectBase.get<double>(this, 'unit_cost') as double?;
  @override
  set unitCost(double? value) => RealmObjectBase.set(this, 'unit_cost', value);

  @override
  double? get unitPrice =>
      RealmObjectBase.get<double>(this, 'unit_price') as double?;
  @override
  set unitPrice(double? value) =>
      RealmObjectBase.set(this, 'unit_price', value);

  @override
  double? get unitPriceLcy =>
      RealmObjectBase.get<double>(this, 'unit_price_lcy') as double?;
  @override
  set unitPriceLcy(double? value) =>
      RealmObjectBase.set(this, 'unit_price_lcy', value);

  @override
  String? get vatCalculationType =>
      RealmObjectBase.get<String>(this, 'vat_calculation_type') as String?;
  @override
  set vatCalculationType(String? value) =>
      RealmObjectBase.set(this, 'vat_calculation_type', value);

  @override
  double? get vatPercentage =>
      RealmObjectBase.get<double>(this, 'vat_percentage') as double?;
  @override
  set vatPercentage(double? value) =>
      RealmObjectBase.set(this, 'vat_percentage', value);

  @override
  double? get vatBaseAmount =>
      RealmObjectBase.get<double>(this, 'vat_base_amount') as double?;
  @override
  set vatBaseAmount(double? value) =>
      RealmObjectBase.set(this, 'vat_base_amount', value);

  @override
  double? get vatAmount =>
      RealmObjectBase.get<double>(this, 'vat_amount') as double?;
  @override
  set vatAmount(double? value) =>
      RealmObjectBase.set(this, 'vat_amount', value);

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
  double? get amountLcy =>
      RealmObjectBase.get<double>(this, 'amount_lcy') as double?;
  @override
  set amountLcy(double? value) =>
      RealmObjectBase.set(this, 'amount_lcy', value);

  @override
  double? get amountIncludingVat =>
      RealmObjectBase.get<double>(this, 'amount_including_vat') as double?;
  @override
  set amountIncludingVat(double? value) =>
      RealmObjectBase.set(this, 'amount_including_vat', value);

  @override
  double? get amountIncludingVatLcy =>
      RealmObjectBase.get<double>(this, 'amount_including_vat_lcy') as double?;
  @override
  set amountIncludingVatLcy(double? value) =>
      RealmObjectBase.set(this, 'amount_including_vat_lcy', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currency_code') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currency_code', value);

  @override
  double? get currencyFactor =>
      RealmObjectBase.get<double>(this, 'currency_factor') as double?;
  @override
  set currencyFactor(double? value) =>
      RealmObjectBase.set(this, 'currency_factor', value);

  @override
  double? get priceIncludeVat =>
      RealmObjectBase.get<double>(this, 'price_include_vat') as double?;
  @override
  set priceIncludeVat(double? value) =>
      RealmObjectBase.set(this, 'price_include_vat', value);

  @override
  String? get remark => RealmObjectBase.get<String>(this, 'remark') as String?;
  @override
  set remark(String? value) => RealmObjectBase.set(this, 'remark', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<CompetitorItemLedgerEntry>> get changes =>
      RealmObjectBase.getChanges<CompetitorItemLedgerEntry>(this);

  @override
  Stream<RealmObjectChanges<CompetitorItemLedgerEntry>> changesFor([
    List<String>? keyPaths,
  ]) =>
      RealmObjectBase.getChangesFor<CompetitorItemLedgerEntry>(this, keyPaths);

  @override
  CompetitorItemLedgerEntry freeze() =>
      RealmObjectBase.freezeObject<CompetitorItemLedgerEntry>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'entry_no': entryNo.toEJson(),
      'app_id': appId.toEJson(),
      'schedule_id': scheduleId.toEJson(),
      'ship_to_code': shipToCode.toEJson(),
      'item_no': itemNo.toEJson(),
      'competitor_no': competitorNo.toEJson(),
      'competitor_name': competitorName.toEJson(),
      'competitor_name_2': competitorName2.toEJson(),
      'customer_no': customerNo.toEJson(),
      'customer_name': customerName.toEJson(),
      'customer_name_2': customerName2.toEJson(),
      'variant_code': variantCode.toEJson(),
      'item_description': itemDescription.toEJson(),
      'item_description_2': itemDescription2.toEJson(),
      'counting_date': countingDate.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'quantity': quantity.toEJson(),
      'quantity_base': quantityBase.toEJson(),
      'planned_quantity': plannedQuantity.toEJson(),
      'planned_quantity_base': plannedQuantityBase.toEJson(),
      'volume_sales_quantity': volumeSalesQuantity.toEJson(),
      'volume_sales_quantity_base': volumeSalesQuantityBase.toEJson(),
      'volume_sales_quantity_uom': volumeSalesQuantityUom.toEJson(),
      'volume_sales_quantity_measure': volumeSalesQuantityMeasure.toEJson(),
      'unit_of_measure_code': unitOfMeasureCode.toEJson(),
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure.toEJson(),
      'serial_no': serialNo.toEJson(),
      'lot_no': lotNo.toEJson(),
      'warranty_date': warrantyDate.toEJson(),
      'expiration_date': expirationDate.toEJson(),
      'status': status.toEJson(),
      'unit_cost': unitCost.toEJson(),
      'unit_price': unitPrice.toEJson(),
      'unit_price_lcy': unitPriceLcy.toEJson(),
      'vat_calculation_type': vatCalculationType.toEJson(),
      'vat_percentage': vatPercentage.toEJson(),
      'vat_base_amount': vatBaseAmount.toEJson(),
      'vat_amount': vatAmount.toEJson(),
      'discount_percentage': discountPercentage.toEJson(),
      'discount_amount': discountAmount.toEJson(),
      'amount': amount.toEJson(),
      'amount_lcy': amountLcy.toEJson(),
      'amount_including_vat': amountIncludingVat.toEJson(),
      'amount_including_vat_lcy': amountIncludingVatLcy.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'currency_factor': currencyFactor.toEJson(),
      'price_include_vat': priceIncludeVat.toEJson(),
      'remark': remark.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(CompetitorItemLedgerEntry value) =>
      value.toEJson();
  static CompetitorItemLedgerEntry _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'entry_no': EJsonValue entryNo} => CompetitorItemLedgerEntry(
        fromEJson(entryNo),
        appId: fromEJson(ejson['app_id']),
        scheduleId: fromEJson(ejson['schedule_id']),
        shipToCode: fromEJson(ejson['ship_to_code']),
        itemNo: fromEJson(ejson['item_no']),
        competitorNo: fromEJson(ejson['competitor_no']),
        competitorName: fromEJson(ejson['competitor_name']),
        competitorName2: fromEJson(ejson['competitor_name_2']),
        customerNo: fromEJson(ejson['customer_no']),
        customerName: fromEJson(ejson['customer_name']),
        customerName2: fromEJson(ejson['customer_name_2']),
        variantCode: fromEJson(ejson['variant_code']),
        itemDescription: fromEJson(ejson['item_description']),
        itemDescription2: fromEJson(ejson['item_description_2']),
        countingDate: fromEJson(ejson['counting_date']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        quantity: fromEJson(ejson['quantity']),
        quantityBase: fromEJson(ejson['quantity_base']),
        plannedQuantity: fromEJson(ejson['planned_quantity']),
        plannedQuantityBase: fromEJson(ejson['planned_quantity_base']),
        volumeSalesQuantity: fromEJson(ejson['volume_sales_quantity']),
        volumeSalesQuantityBase: fromEJson(ejson['volume_sales_quantity_base']),
        volumeSalesQuantityUom: fromEJson(ejson['volume_sales_quantity_uom']),
        volumeSalesQuantityMeasure: fromEJson(
          ejson['volume_sales_quantity_measure'],
        ),
        unitOfMeasureCode: fromEJson(ejson['unit_of_measure_code']),
        qtyPerUnitOfMeasure: fromEJson(ejson['qty_per_unit_of_measure']),
        serialNo: fromEJson(ejson['serial_no']),
        lotNo: fromEJson(ejson['lot_no']),
        warrantyDate: fromEJson(ejson['warranty_date']),
        expirationDate: fromEJson(ejson['expiration_date']),
        status: fromEJson(ejson['status']),
        unitCost: fromEJson(ejson['unit_cost']),
        unitPrice: fromEJson(ejson['unit_price']),
        unitPriceLcy: fromEJson(ejson['unit_price_lcy']),
        vatCalculationType: fromEJson(ejson['vat_calculation_type']),
        vatPercentage: fromEJson(ejson['vat_percentage']),
        vatBaseAmount: fromEJson(ejson['vat_base_amount']),
        vatAmount: fromEJson(ejson['vat_amount']),
        discountPercentage: fromEJson(ejson['discount_percentage']),
        discountAmount: fromEJson(ejson['discount_amount']),
        amount: fromEJson(ejson['amount']),
        amountLcy: fromEJson(ejson['amount_lcy']),
        amountIncludingVat: fromEJson(ejson['amount_including_vat']),
        amountIncludingVatLcy: fromEJson(ejson['amount_including_vat_lcy']),
        currencyCode: fromEJson(ejson['currency_code']),
        currencyFactor: fromEJson(ejson['currency_factor']),
        priceIncludeVat: fromEJson(ejson['price_include_vat']),
        remark: fromEJson(ejson['remark']),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "No"),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CompetitorItemLedgerEntry._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CompetitorItemLedgerEntry,
      'COMPETITOR_ITEM_LEDGER_ENTRY',
      [
        SchemaProperty(
          'entryNo',
          RealmPropertyType.string,
          mapTo: 'entry_no',
          primaryKey: true,
        ),
        SchemaProperty(
          'appId',
          RealmPropertyType.string,
          mapTo: 'app_id',
          optional: true,
        ),
        SchemaProperty(
          'scheduleId',
          RealmPropertyType.string,
          mapTo: 'schedule_id',
          optional: true,
        ),
        SchemaProperty(
          'shipToCode',
          RealmPropertyType.string,
          mapTo: 'ship_to_code',
          optional: true,
        ),
        SchemaProperty(
          'itemNo',
          RealmPropertyType.string,
          mapTo: 'item_no',
          optional: true,
        ),
        SchemaProperty(
          'competitorNo',
          RealmPropertyType.string,
          mapTo: 'competitor_no',
          optional: true,
        ),
        SchemaProperty(
          'competitorName',
          RealmPropertyType.string,
          mapTo: 'competitor_name',
          optional: true,
        ),
        SchemaProperty(
          'competitorName2',
          RealmPropertyType.string,
          mapTo: 'competitor_name_2',
          optional: true,
        ),
        SchemaProperty(
          'customerNo',
          RealmPropertyType.string,
          mapTo: 'customer_no',
          optional: true,
        ),
        SchemaProperty(
          'customerName',
          RealmPropertyType.string,
          mapTo: 'customer_name',
          optional: true,
        ),
        SchemaProperty(
          'customerName2',
          RealmPropertyType.string,
          mapTo: 'customer_name_2',
          optional: true,
        ),
        SchemaProperty(
          'variantCode',
          RealmPropertyType.string,
          mapTo: 'variant_code',
          optional: true,
        ),
        SchemaProperty(
          'itemDescription',
          RealmPropertyType.string,
          mapTo: 'item_description',
          optional: true,
        ),
        SchemaProperty(
          'itemDescription2',
          RealmPropertyType.string,
          mapTo: 'item_description_2',
          optional: true,
        ),
        SchemaProperty(
          'countingDate',
          RealmPropertyType.string,
          mapTo: 'counting_date',
          optional: true,
        ),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty('quantity', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'quantityBase',
          RealmPropertyType.double,
          mapTo: 'quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'plannedQuantity',
          RealmPropertyType.double,
          mapTo: 'planned_quantity',
          optional: true,
        ),
        SchemaProperty(
          'plannedQuantityBase',
          RealmPropertyType.double,
          mapTo: 'planned_quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'volumeSalesQuantity',
          RealmPropertyType.double,
          mapTo: 'volume_sales_quantity',
          optional: true,
        ),
        SchemaProperty(
          'volumeSalesQuantityBase',
          RealmPropertyType.double,
          mapTo: 'volume_sales_quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'volumeSalesQuantityUom',
          RealmPropertyType.double,
          mapTo: 'volume_sales_quantity_uom',
          optional: true,
        ),
        SchemaProperty(
          'volumeSalesQuantityMeasure',
          RealmPropertyType.double,
          mapTo: 'volume_sales_quantity_measure',
          optional: true,
        ),
        SchemaProperty(
          'unitOfMeasureCode',
          RealmPropertyType.string,
          mapTo: 'unit_of_measure_code',
          optional: true,
        ),
        SchemaProperty(
          'qtyPerUnitOfMeasure',
          RealmPropertyType.double,
          mapTo: 'qty_per_unit_of_measure',
          optional: true,
        ),
        SchemaProperty(
          'serialNo',
          RealmPropertyType.string,
          mapTo: 'serial_no',
          optional: true,
        ),
        SchemaProperty(
          'lotNo',
          RealmPropertyType.string,
          mapTo: 'lot_no',
          optional: true,
        ),
        SchemaProperty(
          'warrantyDate',
          RealmPropertyType.string,
          mapTo: 'warranty_date',
          optional: true,
        ),
        SchemaProperty(
          'expirationDate',
          RealmPropertyType.string,
          mapTo: 'expiration_date',
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'unitCost',
          RealmPropertyType.double,
          mapTo: 'unit_cost',
          optional: true,
        ),
        SchemaProperty(
          'unitPrice',
          RealmPropertyType.double,
          mapTo: 'unit_price',
          optional: true,
        ),
        SchemaProperty(
          'unitPriceLcy',
          RealmPropertyType.double,
          mapTo: 'unit_price_lcy',
          optional: true,
        ),
        SchemaProperty(
          'vatCalculationType',
          RealmPropertyType.string,
          mapTo: 'vat_calculation_type',
          optional: true,
        ),
        SchemaProperty(
          'vatPercentage',
          RealmPropertyType.double,
          mapTo: 'vat_percentage',
          optional: true,
        ),
        SchemaProperty(
          'vatBaseAmount',
          RealmPropertyType.double,
          mapTo: 'vat_base_amount',
          optional: true,
        ),
        SchemaProperty(
          'vatAmount',
          RealmPropertyType.double,
          mapTo: 'vat_amount',
          optional: true,
        ),
        SchemaProperty(
          'discountPercentage',
          RealmPropertyType.double,
          mapTo: 'discount_percentage',
          optional: true,
        ),
        SchemaProperty(
          'discountAmount',
          RealmPropertyType.double,
          mapTo: 'discount_amount',
          optional: true,
        ),
        SchemaProperty('amount', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'amountLcy',
          RealmPropertyType.double,
          mapTo: 'amount_lcy',
          optional: true,
        ),
        SchemaProperty(
          'amountIncludingVat',
          RealmPropertyType.double,
          mapTo: 'amount_including_vat',
          optional: true,
        ),
        SchemaProperty(
          'amountIncludingVatLcy',
          RealmPropertyType.double,
          mapTo: 'amount_including_vat_lcy',
          optional: true,
        ),
        SchemaProperty(
          'currencyCode',
          RealmPropertyType.string,
          mapTo: 'currency_code',
          optional: true,
        ),
        SchemaProperty(
          'currencyFactor',
          RealmPropertyType.double,
          mapTo: 'currency_factor',
          optional: true,
        ),
        SchemaProperty(
          'priceIncludeVat',
          RealmPropertyType.double,
          mapTo: 'price_include_vat',
          optional: true,
        ),
        SchemaProperty('remark', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CustomerItemLedgerEntry extends _CustomerItemLedgerEntry
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  CustomerItemLedgerEntry(
    String entryNo, {
    String? appId,
    String? scheduleId,
    String? shipToCode,
    String? itemNo,
    String? customerNo,
    String? customerName,
    String? customerName2,
    String? competitorNo,
    String? competitorName,
    String? competitorName2,
    String? variantCode,
    String? itemDescription,
    String? itemDescription2,
    String? countingDate,
    String? description,
    String? description2,
    double? quantity,
    double? quantityBase,
    double? quantityBuyFromOther,
    double? quantityBuyFromOtherBase,
    double? plannedQuantity,
    double? plannedQuantityBase,
    double? plannedQuantityReturn,
    double? plannedQuantityReturnBase,
    double? volumeSalesQuantity,
    double? volumeSalesQuantityBase,
    double? focInQuantity,
    double? focInQuantityBase,
    double? focOutQuantity,
    double? focOutQuantityBase,
    String? focInuom,
    String? focOutUom,
    double? focInMeasure,
    double? focOutMeasure,
    String? unitOfMeasureCode,
    String? quantityBuyFromOtherUom,
    String? plannedQuantityUom,
    String? plannedQuantityReturnUom,
    String? volumeSalesQuantityUom,
    double? qtyPerUnitOfMeasure,
    double? quantityBuyFromOtherMeasure,
    double? plannedQuantityMeasure,
    double? plannedQuantityReturnMeasure,
    double? volumeSalesQuantityMeasure,
    String? salesPurchaserCode,
    String? serialNo,
    String? lotNo,
    String? warrantyDate,
    String? expirationDate,
    double? unitCost,
    String? status,
    double? unitPrice,
    double? unitPriceLcy,
    String? vatCalculationType,
    double? vatpercentage,
    double? vatBaseAmount,
    double? vatAmount,
    double? discountPercentage,
    double? discountAmount,
    double? amount,
    double? amountLcy,
    double? amountIncludingVat,
    double? amountIncludingVatLcy,
    double? returnVatPercentage,
    double? returnVatBaseAmount,
    double? returnVatAmount,
    double? returnDiscountPercentage,
    double? returnDiscountAmount,
    double? returnAmount,
    double? returnAmountLcy,
    double? returnAmountIncludingVat,
    double? returnAmountIncludingVatLcy,
    double? redemptionQuantity,
    double? redemptionQuantityBase,
    double? redemptionUom,
    double? redemptionMeasure,
    double? inventory,
    double? inventoryBase,
    String? currencyCode,
    double? currencyFactor,
    double? priceIncludeVat,
    String? documentType,
    String? documentNo,
    String? itemCategoryCode,
    String? itemGroupCode,
    String? itemBrandCode,
    String? storeCode,
    String? divisionCode,
    String? businessUnitCode,
    String? departmentCode,
    String? projectCode,
    String? distributorCode,
    String? customerGroupCode,
    String? territoryCode,
    String? remark,
    String? isSync = "No",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CustomerItemLedgerEntry>({
        'is_sync': "No",
      });
    }
    RealmObjectBase.set(this, 'entry_no', entryNo);
    RealmObjectBase.set(this, 'app_id', appId);
    RealmObjectBase.set(this, 'schedule_id', scheduleId);
    RealmObjectBase.set(this, 'ship_to_code', shipToCode);
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'customer_name', customerName);
    RealmObjectBase.set(this, 'customer_name_2', customerName2);
    RealmObjectBase.set(this, 'competitor_no', competitorNo);
    RealmObjectBase.set(this, 'competitor_name', competitorName);
    RealmObjectBase.set(this, 'competitor_name_2', competitorName2);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'item_description', itemDescription);
    RealmObjectBase.set(this, 'item_description_2', itemDescription2);
    RealmObjectBase.set(this, 'counting_date', countingDate);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'quantity_base', quantityBase);
    RealmObjectBase.set(this, 'quantity_buy_from_other', quantityBuyFromOther);
    RealmObjectBase.set(
      this,
      'quantity_buy_from_other_base',
      quantityBuyFromOtherBase,
    );
    RealmObjectBase.set(this, 'planned_quantity', plannedQuantity);
    RealmObjectBase.set(this, 'planned_quantity_base', plannedQuantityBase);
    RealmObjectBase.set(this, 'planned_quantity_return', plannedQuantityReturn);
    RealmObjectBase.set(
      this,
      'planned_quantity_return_base',
      plannedQuantityReturnBase,
    );
    RealmObjectBase.set(this, 'volume_sales_quantity', volumeSalesQuantity);
    RealmObjectBase.set(
      this,
      'volume_sales_quantity_base',
      volumeSalesQuantityBase,
    );
    RealmObjectBase.set(this, 'foc_in_quantity', focInQuantity);
    RealmObjectBase.set(this, 'foc_in_quantity_base', focInQuantityBase);
    RealmObjectBase.set(this, 'foc_out_quantity', focOutQuantity);
    RealmObjectBase.set(this, 'foc_out_quantity_base', focOutQuantityBase);
    RealmObjectBase.set(this, 'foc_in_uom', focInuom);
    RealmObjectBase.set(this, 'foc_out_uom', focOutUom);
    RealmObjectBase.set(this, 'foc_in_measure', focInMeasure);
    RealmObjectBase.set(this, 'foc_out_measure', focOutMeasure);
    RealmObjectBase.set(this, 'unit_of_measure_code', unitOfMeasureCode);
    RealmObjectBase.set(
      this,
      'quantity_buy_from_other_uom',
      quantityBuyFromOtherUom,
    );
    RealmObjectBase.set(this, 'planned_quantity_uom', plannedQuantityUom);
    RealmObjectBase.set(
      this,
      'planned_quantity_return_uom',
      plannedQuantityReturnUom,
    );
    RealmObjectBase.set(
      this,
      'volume_sales_quantity_uom',
      volumeSalesQuantityUom,
    );
    RealmObjectBase.set(this, 'qty_per_unit_of_measure', qtyPerUnitOfMeasure);
    RealmObjectBase.set(
      this,
      'quantity_buy_from_other_measure',
      quantityBuyFromOtherMeasure,
    );
    RealmObjectBase.set(
      this,
      'planned_quantity_measure',
      plannedQuantityMeasure,
    );
    RealmObjectBase.set(
      this,
      'planned_quantity_return_measure',
      plannedQuantityReturnMeasure,
    );
    RealmObjectBase.set(
      this,
      'volume_sales_quantity_measure',
      volumeSalesQuantityMeasure,
    );
    RealmObjectBase.set(this, 'sales_purchaser_code', salesPurchaserCode);
    RealmObjectBase.set(this, 'serial_no', serialNo);
    RealmObjectBase.set(this, 'lot_no', lotNo);
    RealmObjectBase.set(this, 'warranty_date', warrantyDate);
    RealmObjectBase.set(this, 'expiration_date', expirationDate);
    RealmObjectBase.set(this, 'unit_cost', unitCost);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'unit_price', unitPrice);
    RealmObjectBase.set(this, 'unit_price_lcy', unitPriceLcy);
    RealmObjectBase.set(this, 'vat_calculation_type', vatCalculationType);
    RealmObjectBase.set(this, 'vat_percentage', vatpercentage);
    RealmObjectBase.set(this, 'vat_base_amount', vatBaseAmount);
    RealmObjectBase.set(this, 'vat_amount', vatAmount);
    RealmObjectBase.set(this, 'discount_percentage', discountPercentage);
    RealmObjectBase.set(this, 'discount_amount', discountAmount);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'amount_lcy', amountLcy);
    RealmObjectBase.set(this, 'amount_including_vat', amountIncludingVat);
    RealmObjectBase.set(
      this,
      'amount_including_vat_lcy',
      amountIncludingVatLcy,
    );
    RealmObjectBase.set(this, 'return_vat_percentage', returnVatPercentage);
    RealmObjectBase.set(this, 'return_vat_base_amount', returnVatBaseAmount);
    RealmObjectBase.set(this, 'return_vat_amount', returnVatAmount);
    RealmObjectBase.set(
      this,
      'return_discount_percentage',
      returnDiscountPercentage,
    );
    RealmObjectBase.set(this, 'return_discount_amount', returnDiscountAmount);
    RealmObjectBase.set(this, 'return_amount', returnAmount);
    RealmObjectBase.set(this, 'return_amount_lcy', returnAmountLcy);
    RealmObjectBase.set(
      this,
      'return_amount_including_vat',
      returnAmountIncludingVat,
    );
    RealmObjectBase.set(
      this,
      'return_amount_including_vat_lcy',
      returnAmountIncludingVatLcy,
    );
    RealmObjectBase.set(this, 'redemption_quantity', redemptionQuantity);
    RealmObjectBase.set(
      this,
      'redemption_quantity_base',
      redemptionQuantityBase,
    );
    RealmObjectBase.set(this, 'redemption_uom', redemptionUom);
    RealmObjectBase.set(this, 'redemption_measure', redemptionMeasure);
    RealmObjectBase.set(this, 'inventory', inventory);
    RealmObjectBase.set(this, 'inventory_base', inventoryBase);
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'currency_factor', currencyFactor);
    RealmObjectBase.set(this, 'price_include_vat', priceIncludeVat);
    RealmObjectBase.set(this, 'document_type', documentType);
    RealmObjectBase.set(this, 'document_no', documentNo);
    RealmObjectBase.set(this, 'item_category_code', itemCategoryCode);
    RealmObjectBase.set(this, 'item_group_code', itemGroupCode);
    RealmObjectBase.set(this, 'item_brand_code', itemBrandCode);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'customer_group_code', customerGroupCode);
    RealmObjectBase.set(this, 'territory_code', territoryCode);
    RealmObjectBase.set(this, 'remark', remark);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  CustomerItemLedgerEntry._();

  @override
  String get entryNo => RealmObjectBase.get<String>(this, 'entry_no') as String;
  @override
  set entryNo(String value) => RealmObjectBase.set(this, 'entry_no', value);

  @override
  String? get appId => RealmObjectBase.get<String>(this, 'app_id') as String?;
  @override
  set appId(String? value) => RealmObjectBase.set(this, 'app_id', value);

  @override
  String? get scheduleId =>
      RealmObjectBase.get<String>(this, 'schedule_id') as String?;
  @override
  set scheduleId(String? value) =>
      RealmObjectBase.set(this, 'schedule_id', value);

  @override
  String? get shipToCode =>
      RealmObjectBase.get<String>(this, 'ship_to_code') as String?;
  @override
  set shipToCode(String? value) =>
      RealmObjectBase.set(this, 'ship_to_code', value);

  @override
  String? get itemNo => RealmObjectBase.get<String>(this, 'item_no') as String?;
  @override
  set itemNo(String? value) => RealmObjectBase.set(this, 'item_no', value);

  @override
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

  @override
  String? get customerName =>
      RealmObjectBase.get<String>(this, 'customer_name') as String?;
  @override
  set customerName(String? value) =>
      RealmObjectBase.set(this, 'customer_name', value);

  @override
  String? get customerName2 =>
      RealmObjectBase.get<String>(this, 'customer_name_2') as String?;
  @override
  set customerName2(String? value) =>
      RealmObjectBase.set(this, 'customer_name_2', value);

  @override
  String? get competitorNo =>
      RealmObjectBase.get<String>(this, 'competitor_no') as String?;
  @override
  set competitorNo(String? value) =>
      RealmObjectBase.set(this, 'competitor_no', value);

  @override
  String? get competitorName =>
      RealmObjectBase.get<String>(this, 'competitor_name') as String?;
  @override
  set competitorName(String? value) =>
      RealmObjectBase.set(this, 'competitor_name', value);

  @override
  String? get competitorName2 =>
      RealmObjectBase.get<String>(this, 'competitor_name_2') as String?;
  @override
  set competitorName2(String? value) =>
      RealmObjectBase.set(this, 'competitor_name_2', value);

  @override
  String? get variantCode =>
      RealmObjectBase.get<String>(this, 'variant_code') as String?;
  @override
  set variantCode(String? value) =>
      RealmObjectBase.set(this, 'variant_code', value);

  @override
  String? get itemDescription =>
      RealmObjectBase.get<String>(this, 'item_description') as String?;
  @override
  set itemDescription(String? value) =>
      RealmObjectBase.set(this, 'item_description', value);

  @override
  String? get itemDescription2 =>
      RealmObjectBase.get<String>(this, 'item_description_2') as String?;
  @override
  set itemDescription2(String? value) =>
      RealmObjectBase.set(this, 'item_description_2', value);

  @override
  String? get countingDate =>
      RealmObjectBase.get<String>(this, 'counting_date') as String?;
  @override
  set countingDate(String? value) =>
      RealmObjectBase.set(this, 'counting_date', value);

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
  double? get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double?;
  @override
  set quantity(double? value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  double? get quantityBase =>
      RealmObjectBase.get<double>(this, 'quantity_base') as double?;
  @override
  set quantityBase(double? value) =>
      RealmObjectBase.set(this, 'quantity_base', value);

  @override
  double? get quantityBuyFromOther =>
      RealmObjectBase.get<double>(this, 'quantity_buy_from_other') as double?;
  @override
  set quantityBuyFromOther(double? value) =>
      RealmObjectBase.set(this, 'quantity_buy_from_other', value);

  @override
  double? get quantityBuyFromOtherBase =>
      RealmObjectBase.get<double>(this, 'quantity_buy_from_other_base')
          as double?;
  @override
  set quantityBuyFromOtherBase(double? value) =>
      RealmObjectBase.set(this, 'quantity_buy_from_other_base', value);

  @override
  double? get plannedQuantity =>
      RealmObjectBase.get<double>(this, 'planned_quantity') as double?;
  @override
  set plannedQuantity(double? value) =>
      RealmObjectBase.set(this, 'planned_quantity', value);

  @override
  double? get plannedQuantityBase =>
      RealmObjectBase.get<double>(this, 'planned_quantity_base') as double?;
  @override
  set plannedQuantityBase(double? value) =>
      RealmObjectBase.set(this, 'planned_quantity_base', value);

  @override
  double? get plannedQuantityReturn =>
      RealmObjectBase.get<double>(this, 'planned_quantity_return') as double?;
  @override
  set plannedQuantityReturn(double? value) =>
      RealmObjectBase.set(this, 'planned_quantity_return', value);

  @override
  double? get plannedQuantityReturnBase =>
      RealmObjectBase.get<double>(this, 'planned_quantity_return_base')
          as double?;
  @override
  set plannedQuantityReturnBase(double? value) =>
      RealmObjectBase.set(this, 'planned_quantity_return_base', value);

  @override
  double? get volumeSalesQuantity =>
      RealmObjectBase.get<double>(this, 'volume_sales_quantity') as double?;
  @override
  set volumeSalesQuantity(double? value) =>
      RealmObjectBase.set(this, 'volume_sales_quantity', value);

  @override
  double? get volumeSalesQuantityBase =>
      RealmObjectBase.get<double>(this, 'volume_sales_quantity_base')
          as double?;
  @override
  set volumeSalesQuantityBase(double? value) =>
      RealmObjectBase.set(this, 'volume_sales_quantity_base', value);

  @override
  double? get focInQuantity =>
      RealmObjectBase.get<double>(this, 'foc_in_quantity') as double?;
  @override
  set focInQuantity(double? value) =>
      RealmObjectBase.set(this, 'foc_in_quantity', value);

  @override
  double? get focInQuantityBase =>
      RealmObjectBase.get<double>(this, 'foc_in_quantity_base') as double?;
  @override
  set focInQuantityBase(double? value) =>
      RealmObjectBase.set(this, 'foc_in_quantity_base', value);

  @override
  double? get focOutQuantity =>
      RealmObjectBase.get<double>(this, 'foc_out_quantity') as double?;
  @override
  set focOutQuantity(double? value) =>
      RealmObjectBase.set(this, 'foc_out_quantity', value);

  @override
  double? get focOutQuantityBase =>
      RealmObjectBase.get<double>(this, 'foc_out_quantity_base') as double?;
  @override
  set focOutQuantityBase(double? value) =>
      RealmObjectBase.set(this, 'foc_out_quantity_base', value);

  @override
  String? get focInuom =>
      RealmObjectBase.get<String>(this, 'foc_in_uom') as String?;
  @override
  set focInuom(String? value) => RealmObjectBase.set(this, 'foc_in_uom', value);

  @override
  String? get focOutUom =>
      RealmObjectBase.get<String>(this, 'foc_out_uom') as String?;
  @override
  set focOutUom(String? value) =>
      RealmObjectBase.set(this, 'foc_out_uom', value);

  @override
  double? get focInMeasure =>
      RealmObjectBase.get<double>(this, 'foc_in_measure') as double?;
  @override
  set focInMeasure(double? value) =>
      RealmObjectBase.set(this, 'foc_in_measure', value);

  @override
  double? get focOutMeasure =>
      RealmObjectBase.get<double>(this, 'foc_out_measure') as double?;
  @override
  set focOutMeasure(double? value) =>
      RealmObjectBase.set(this, 'foc_out_measure', value);

  @override
  String? get unitOfMeasureCode =>
      RealmObjectBase.get<String>(this, 'unit_of_measure_code') as String?;
  @override
  set unitOfMeasureCode(String? value) =>
      RealmObjectBase.set(this, 'unit_of_measure_code', value);

  @override
  String? get quantityBuyFromOtherUom =>
      RealmObjectBase.get<String>(this, 'quantity_buy_from_other_uom')
          as String?;
  @override
  set quantityBuyFromOtherUom(String? value) =>
      RealmObjectBase.set(this, 'quantity_buy_from_other_uom', value);

  @override
  String? get plannedQuantityUom =>
      RealmObjectBase.get<String>(this, 'planned_quantity_uom') as String?;
  @override
  set plannedQuantityUom(String? value) =>
      RealmObjectBase.set(this, 'planned_quantity_uom', value);

  @override
  String? get plannedQuantityReturnUom =>
      RealmObjectBase.get<String>(this, 'planned_quantity_return_uom')
          as String?;
  @override
  set plannedQuantityReturnUom(String? value) =>
      RealmObjectBase.set(this, 'planned_quantity_return_uom', value);

  @override
  String? get volumeSalesQuantityUom =>
      RealmObjectBase.get<String>(this, 'volume_sales_quantity_uom') as String?;
  @override
  set volumeSalesQuantityUom(String? value) =>
      RealmObjectBase.set(this, 'volume_sales_quantity_uom', value);

  @override
  double? get qtyPerUnitOfMeasure =>
      RealmObjectBase.get<double>(this, 'qty_per_unit_of_measure') as double?;
  @override
  set qtyPerUnitOfMeasure(double? value) =>
      RealmObjectBase.set(this, 'qty_per_unit_of_measure', value);

  @override
  double? get quantityBuyFromOtherMeasure =>
      RealmObjectBase.get<double>(this, 'quantity_buy_from_other_measure')
          as double?;
  @override
  set quantityBuyFromOtherMeasure(double? value) =>
      RealmObjectBase.set(this, 'quantity_buy_from_other_measure', value);

  @override
  double? get plannedQuantityMeasure =>
      RealmObjectBase.get<double>(this, 'planned_quantity_measure') as double?;
  @override
  set plannedQuantityMeasure(double? value) =>
      RealmObjectBase.set(this, 'planned_quantity_measure', value);

  @override
  double? get plannedQuantityReturnMeasure =>
      RealmObjectBase.get<double>(this, 'planned_quantity_return_measure')
          as double?;
  @override
  set plannedQuantityReturnMeasure(double? value) =>
      RealmObjectBase.set(this, 'planned_quantity_return_measure', value);

  @override
  double? get volumeSalesQuantityMeasure =>
      RealmObjectBase.get<double>(this, 'volume_sales_quantity_measure')
          as double?;
  @override
  set volumeSalesQuantityMeasure(double? value) =>
      RealmObjectBase.set(this, 'volume_sales_quantity_measure', value);

  @override
  String? get salesPurchaserCode =>
      RealmObjectBase.get<String>(this, 'sales_purchaser_code') as String?;
  @override
  set salesPurchaserCode(String? value) =>
      RealmObjectBase.set(this, 'sales_purchaser_code', value);

  @override
  String? get serialNo =>
      RealmObjectBase.get<String>(this, 'serial_no') as String?;
  @override
  set serialNo(String? value) => RealmObjectBase.set(this, 'serial_no', value);

  @override
  String? get lotNo => RealmObjectBase.get<String>(this, 'lot_no') as String?;
  @override
  set lotNo(String? value) => RealmObjectBase.set(this, 'lot_no', value);

  @override
  String? get warrantyDate =>
      RealmObjectBase.get<String>(this, 'warranty_date') as String?;
  @override
  set warrantyDate(String? value) =>
      RealmObjectBase.set(this, 'warranty_date', value);

  @override
  String? get expirationDate =>
      RealmObjectBase.get<String>(this, 'expiration_date') as String?;
  @override
  set expirationDate(String? value) =>
      RealmObjectBase.set(this, 'expiration_date', value);

  @override
  double? get unitCost =>
      RealmObjectBase.get<double>(this, 'unit_cost') as double?;
  @override
  set unitCost(double? value) => RealmObjectBase.set(this, 'unit_cost', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  double? get unitPrice =>
      RealmObjectBase.get<double>(this, 'unit_price') as double?;
  @override
  set unitPrice(double? value) =>
      RealmObjectBase.set(this, 'unit_price', value);

  @override
  double? get unitPriceLcy =>
      RealmObjectBase.get<double>(this, 'unit_price_lcy') as double?;
  @override
  set unitPriceLcy(double? value) =>
      RealmObjectBase.set(this, 'unit_price_lcy', value);

  @override
  String? get vatCalculationType =>
      RealmObjectBase.get<String>(this, 'vat_calculation_type') as String?;
  @override
  set vatCalculationType(String? value) =>
      RealmObjectBase.set(this, 'vat_calculation_type', value);

  @override
  double? get vatpercentage =>
      RealmObjectBase.get<double>(this, 'vat_percentage') as double?;
  @override
  set vatpercentage(double? value) =>
      RealmObjectBase.set(this, 'vat_percentage', value);

  @override
  double? get vatBaseAmount =>
      RealmObjectBase.get<double>(this, 'vat_base_amount') as double?;
  @override
  set vatBaseAmount(double? value) =>
      RealmObjectBase.set(this, 'vat_base_amount', value);

  @override
  double? get vatAmount =>
      RealmObjectBase.get<double>(this, 'vat_amount') as double?;
  @override
  set vatAmount(double? value) =>
      RealmObjectBase.set(this, 'vat_amount', value);

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
  double? get amountLcy =>
      RealmObjectBase.get<double>(this, 'amount_lcy') as double?;
  @override
  set amountLcy(double? value) =>
      RealmObjectBase.set(this, 'amount_lcy', value);

  @override
  double? get amountIncludingVat =>
      RealmObjectBase.get<double>(this, 'amount_including_vat') as double?;
  @override
  set amountIncludingVat(double? value) =>
      RealmObjectBase.set(this, 'amount_including_vat', value);

  @override
  double? get amountIncludingVatLcy =>
      RealmObjectBase.get<double>(this, 'amount_including_vat_lcy') as double?;
  @override
  set amountIncludingVatLcy(double? value) =>
      RealmObjectBase.set(this, 'amount_including_vat_lcy', value);

  @override
  double? get returnVatPercentage =>
      RealmObjectBase.get<double>(this, 'return_vat_percentage') as double?;
  @override
  set returnVatPercentage(double? value) =>
      RealmObjectBase.set(this, 'return_vat_percentage', value);

  @override
  double? get returnVatBaseAmount =>
      RealmObjectBase.get<double>(this, 'return_vat_base_amount') as double?;
  @override
  set returnVatBaseAmount(double? value) =>
      RealmObjectBase.set(this, 'return_vat_base_amount', value);

  @override
  double? get returnVatAmount =>
      RealmObjectBase.get<double>(this, 'return_vat_amount') as double?;
  @override
  set returnVatAmount(double? value) =>
      RealmObjectBase.set(this, 'return_vat_amount', value);

  @override
  double? get returnDiscountPercentage =>
      RealmObjectBase.get<double>(this, 'return_discount_percentage')
          as double?;
  @override
  set returnDiscountPercentage(double? value) =>
      RealmObjectBase.set(this, 'return_discount_percentage', value);

  @override
  double? get returnDiscountAmount =>
      RealmObjectBase.get<double>(this, 'return_discount_amount') as double?;
  @override
  set returnDiscountAmount(double? value) =>
      RealmObjectBase.set(this, 'return_discount_amount', value);

  @override
  double? get returnAmount =>
      RealmObjectBase.get<double>(this, 'return_amount') as double?;
  @override
  set returnAmount(double? value) =>
      RealmObjectBase.set(this, 'return_amount', value);

  @override
  double? get returnAmountLcy =>
      RealmObjectBase.get<double>(this, 'return_amount_lcy') as double?;
  @override
  set returnAmountLcy(double? value) =>
      RealmObjectBase.set(this, 'return_amount_lcy', value);

  @override
  double? get returnAmountIncludingVat =>
      RealmObjectBase.get<double>(this, 'return_amount_including_vat')
          as double?;
  @override
  set returnAmountIncludingVat(double? value) =>
      RealmObjectBase.set(this, 'return_amount_including_vat', value);

  @override
  double? get returnAmountIncludingVatLcy =>
      RealmObjectBase.get<double>(this, 'return_amount_including_vat_lcy')
          as double?;
  @override
  set returnAmountIncludingVatLcy(double? value) =>
      RealmObjectBase.set(this, 'return_amount_including_vat_lcy', value);

  @override
  double? get redemptionQuantity =>
      RealmObjectBase.get<double>(this, 'redemption_quantity') as double?;
  @override
  set redemptionQuantity(double? value) =>
      RealmObjectBase.set(this, 'redemption_quantity', value);

  @override
  double? get redemptionQuantityBase =>
      RealmObjectBase.get<double>(this, 'redemption_quantity_base') as double?;
  @override
  set redemptionQuantityBase(double? value) =>
      RealmObjectBase.set(this, 'redemption_quantity_base', value);

  @override
  double? get redemptionUom =>
      RealmObjectBase.get<double>(this, 'redemption_uom') as double?;
  @override
  set redemptionUom(double? value) =>
      RealmObjectBase.set(this, 'redemption_uom', value);

  @override
  double? get redemptionMeasure =>
      RealmObjectBase.get<double>(this, 'redemption_measure') as double?;
  @override
  set redemptionMeasure(double? value) =>
      RealmObjectBase.set(this, 'redemption_measure', value);

  @override
  double? get inventory =>
      RealmObjectBase.get<double>(this, 'inventory') as double?;
  @override
  set inventory(double? value) => RealmObjectBase.set(this, 'inventory', value);

  @override
  double? get inventoryBase =>
      RealmObjectBase.get<double>(this, 'inventory_base') as double?;
  @override
  set inventoryBase(double? value) =>
      RealmObjectBase.set(this, 'inventory_base', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currency_code') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currency_code', value);

  @override
  double? get currencyFactor =>
      RealmObjectBase.get<double>(this, 'currency_factor') as double?;
  @override
  set currencyFactor(double? value) =>
      RealmObjectBase.set(this, 'currency_factor', value);

  @override
  double? get priceIncludeVat =>
      RealmObjectBase.get<double>(this, 'price_include_vat') as double?;
  @override
  set priceIncludeVat(double? value) =>
      RealmObjectBase.set(this, 'price_include_vat', value);

  @override
  String? get documentType =>
      RealmObjectBase.get<String>(this, 'document_type') as String?;
  @override
  set documentType(String? value) =>
      RealmObjectBase.set(this, 'document_type', value);

  @override
  String? get documentNo =>
      RealmObjectBase.get<String>(this, 'document_no') as String?;
  @override
  set documentNo(String? value) =>
      RealmObjectBase.set(this, 'document_no', value);

  @override
  String? get itemCategoryCode =>
      RealmObjectBase.get<String>(this, 'item_category_code') as String?;
  @override
  set itemCategoryCode(String? value) =>
      RealmObjectBase.set(this, 'item_category_code', value);

  @override
  String? get itemGroupCode =>
      RealmObjectBase.get<String>(this, 'item_group_code') as String?;
  @override
  set itemGroupCode(String? value) =>
      RealmObjectBase.set(this, 'item_group_code', value);

  @override
  String? get itemBrandCode =>
      RealmObjectBase.get<String>(this, 'item_brand_code') as String?;
  @override
  set itemBrandCode(String? value) =>
      RealmObjectBase.set(this, 'item_brand_code', value);

  @override
  String? get storeCode =>
      RealmObjectBase.get<String>(this, 'store_code') as String?;
  @override
  set storeCode(String? value) =>
      RealmObjectBase.set(this, 'store_code', value);

  @override
  String? get divisionCode =>
      RealmObjectBase.get<String>(this, 'division_code') as String?;
  @override
  set divisionCode(String? value) =>
      RealmObjectBase.set(this, 'division_code', value);

  @override
  String? get businessUnitCode =>
      RealmObjectBase.get<String>(this, 'business_unit_code') as String?;
  @override
  set businessUnitCode(String? value) =>
      RealmObjectBase.set(this, 'business_unit_code', value);

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
  String? get distributorCode =>
      RealmObjectBase.get<String>(this, 'distributor_code') as String?;
  @override
  set distributorCode(String? value) =>
      RealmObjectBase.set(this, 'distributor_code', value);

  @override
  String? get customerGroupCode =>
      RealmObjectBase.get<String>(this, 'customer_group_code') as String?;
  @override
  set customerGroupCode(String? value) =>
      RealmObjectBase.set(this, 'customer_group_code', value);

  @override
  String? get territoryCode =>
      RealmObjectBase.get<String>(this, 'territory_code') as String?;
  @override
  set territoryCode(String? value) =>
      RealmObjectBase.set(this, 'territory_code', value);

  @override
  String? get remark => RealmObjectBase.get<String>(this, 'remark') as String?;
  @override
  set remark(String? value) => RealmObjectBase.set(this, 'remark', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<CustomerItemLedgerEntry>> get changes =>
      RealmObjectBase.getChanges<CustomerItemLedgerEntry>(this);

  @override
  Stream<RealmObjectChanges<CustomerItemLedgerEntry>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CustomerItemLedgerEntry>(this, keyPaths);

  @override
  CustomerItemLedgerEntry freeze() =>
      RealmObjectBase.freezeObject<CustomerItemLedgerEntry>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'entry_no': entryNo.toEJson(),
      'app_id': appId.toEJson(),
      'schedule_id': scheduleId.toEJson(),
      'ship_to_code': shipToCode.toEJson(),
      'item_no': itemNo.toEJson(),
      'customer_no': customerNo.toEJson(),
      'customer_name': customerName.toEJson(),
      'customer_name_2': customerName2.toEJson(),
      'competitor_no': competitorNo.toEJson(),
      'competitor_name': competitorName.toEJson(),
      'competitor_name_2': competitorName2.toEJson(),
      'variant_code': variantCode.toEJson(),
      'item_description': itemDescription.toEJson(),
      'item_description_2': itemDescription2.toEJson(),
      'counting_date': countingDate.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'quantity': quantity.toEJson(),
      'quantity_base': quantityBase.toEJson(),
      'quantity_buy_from_other': quantityBuyFromOther.toEJson(),
      'quantity_buy_from_other_base': quantityBuyFromOtherBase.toEJson(),
      'planned_quantity': plannedQuantity.toEJson(),
      'planned_quantity_base': plannedQuantityBase.toEJson(),
      'planned_quantity_return': plannedQuantityReturn.toEJson(),
      'planned_quantity_return_base': plannedQuantityReturnBase.toEJson(),
      'volume_sales_quantity': volumeSalesQuantity.toEJson(),
      'volume_sales_quantity_base': volumeSalesQuantityBase.toEJson(),
      'foc_in_quantity': focInQuantity.toEJson(),
      'foc_in_quantity_base': focInQuantityBase.toEJson(),
      'foc_out_quantity': focOutQuantity.toEJson(),
      'foc_out_quantity_base': focOutQuantityBase.toEJson(),
      'foc_in_uom': focInuom.toEJson(),
      'foc_out_uom': focOutUom.toEJson(),
      'foc_in_measure': focInMeasure.toEJson(),
      'foc_out_measure': focOutMeasure.toEJson(),
      'unit_of_measure_code': unitOfMeasureCode.toEJson(),
      'quantity_buy_from_other_uom': quantityBuyFromOtherUom.toEJson(),
      'planned_quantity_uom': plannedQuantityUom.toEJson(),
      'planned_quantity_return_uom': plannedQuantityReturnUom.toEJson(),
      'volume_sales_quantity_uom': volumeSalesQuantityUom.toEJson(),
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure.toEJson(),
      'quantity_buy_from_other_measure': quantityBuyFromOtherMeasure.toEJson(),
      'planned_quantity_measure': plannedQuantityMeasure.toEJson(),
      'planned_quantity_return_measure': plannedQuantityReturnMeasure.toEJson(),
      'volume_sales_quantity_measure': volumeSalesQuantityMeasure.toEJson(),
      'sales_purchaser_code': salesPurchaserCode.toEJson(),
      'serial_no': serialNo.toEJson(),
      'lot_no': lotNo.toEJson(),
      'warranty_date': warrantyDate.toEJson(),
      'expiration_date': expirationDate.toEJson(),
      'unit_cost': unitCost.toEJson(),
      'status': status.toEJson(),
      'unit_price': unitPrice.toEJson(),
      'unit_price_lcy': unitPriceLcy.toEJson(),
      'vat_calculation_type': vatCalculationType.toEJson(),
      'vat_percentage': vatpercentage.toEJson(),
      'vat_base_amount': vatBaseAmount.toEJson(),
      'vat_amount': vatAmount.toEJson(),
      'discount_percentage': discountPercentage.toEJson(),
      'discount_amount': discountAmount.toEJson(),
      'amount': amount.toEJson(),
      'amount_lcy': amountLcy.toEJson(),
      'amount_including_vat': amountIncludingVat.toEJson(),
      'amount_including_vat_lcy': amountIncludingVatLcy.toEJson(),
      'return_vat_percentage': returnVatPercentage.toEJson(),
      'return_vat_base_amount': returnVatBaseAmount.toEJson(),
      'return_vat_amount': returnVatAmount.toEJson(),
      'return_discount_percentage': returnDiscountPercentage.toEJson(),
      'return_discount_amount': returnDiscountAmount.toEJson(),
      'return_amount': returnAmount.toEJson(),
      'return_amount_lcy': returnAmountLcy.toEJson(),
      'return_amount_including_vat': returnAmountIncludingVat.toEJson(),
      'return_amount_including_vat_lcy': returnAmountIncludingVatLcy.toEJson(),
      'redemption_quantity': redemptionQuantity.toEJson(),
      'redemption_quantity_base': redemptionQuantityBase.toEJson(),
      'redemption_uom': redemptionUom.toEJson(),
      'redemption_measure': redemptionMeasure.toEJson(),
      'inventory': inventory.toEJson(),
      'inventory_base': inventoryBase.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'currency_factor': currencyFactor.toEJson(),
      'price_include_vat': priceIncludeVat.toEJson(),
      'document_type': documentType.toEJson(),
      'document_no': documentNo.toEJson(),
      'item_category_code': itemCategoryCode.toEJson(),
      'item_group_code': itemGroupCode.toEJson(),
      'item_brand_code': itemBrandCode.toEJson(),
      'store_code': storeCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'customer_group_code': customerGroupCode.toEJson(),
      'territory_code': territoryCode.toEJson(),
      'remark': remark.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(CustomerItemLedgerEntry value) => value.toEJson();
  static CustomerItemLedgerEntry _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'entry_no': EJsonValue entryNo} => CustomerItemLedgerEntry(
        fromEJson(entryNo),
        appId: fromEJson(ejson['app_id']),
        scheduleId: fromEJson(ejson['schedule_id']),
        shipToCode: fromEJson(ejson['ship_to_code']),
        itemNo: fromEJson(ejson['item_no']),
        customerNo: fromEJson(ejson['customer_no']),
        customerName: fromEJson(ejson['customer_name']),
        customerName2: fromEJson(ejson['customer_name_2']),
        competitorNo: fromEJson(ejson['competitor_no']),
        competitorName: fromEJson(ejson['competitor_name']),
        competitorName2: fromEJson(ejson['competitor_name_2']),
        variantCode: fromEJson(ejson['variant_code']),
        itemDescription: fromEJson(ejson['item_description']),
        itemDescription2: fromEJson(ejson['item_description_2']),
        countingDate: fromEJson(ejson['counting_date']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        quantity: fromEJson(ejson['quantity']),
        quantityBase: fromEJson(ejson['quantity_base']),
        quantityBuyFromOther: fromEJson(ejson['quantity_buy_from_other']),
        quantityBuyFromOtherBase: fromEJson(
          ejson['quantity_buy_from_other_base'],
        ),
        plannedQuantity: fromEJson(ejson['planned_quantity']),
        plannedQuantityBase: fromEJson(ejson['planned_quantity_base']),
        plannedQuantityReturn: fromEJson(ejson['planned_quantity_return']),
        plannedQuantityReturnBase: fromEJson(
          ejson['planned_quantity_return_base'],
        ),
        volumeSalesQuantity: fromEJson(ejson['volume_sales_quantity']),
        volumeSalesQuantityBase: fromEJson(ejson['volume_sales_quantity_base']),
        focInQuantity: fromEJson(ejson['foc_in_quantity']),
        focInQuantityBase: fromEJson(ejson['foc_in_quantity_base']),
        focOutQuantity: fromEJson(ejson['foc_out_quantity']),
        focOutQuantityBase: fromEJson(ejson['foc_out_quantity_base']),
        focInuom: fromEJson(ejson['foc_in_uom']),
        focOutUom: fromEJson(ejson['foc_out_uom']),
        focInMeasure: fromEJson(ejson['foc_in_measure']),
        focOutMeasure: fromEJson(ejson['foc_out_measure']),
        unitOfMeasureCode: fromEJson(ejson['unit_of_measure_code']),
        quantityBuyFromOtherUom: fromEJson(
          ejson['quantity_buy_from_other_uom'],
        ),
        plannedQuantityUom: fromEJson(ejson['planned_quantity_uom']),
        plannedQuantityReturnUom: fromEJson(
          ejson['planned_quantity_return_uom'],
        ),
        volumeSalesQuantityUom: fromEJson(ejson['volume_sales_quantity_uom']),
        qtyPerUnitOfMeasure: fromEJson(ejson['qty_per_unit_of_measure']),
        quantityBuyFromOtherMeasure: fromEJson(
          ejson['quantity_buy_from_other_measure'],
        ),
        plannedQuantityMeasure: fromEJson(ejson['planned_quantity_measure']),
        plannedQuantityReturnMeasure: fromEJson(
          ejson['planned_quantity_return_measure'],
        ),
        volumeSalesQuantityMeasure: fromEJson(
          ejson['volume_sales_quantity_measure'],
        ),
        salesPurchaserCode: fromEJson(ejson['sales_purchaser_code']),
        serialNo: fromEJson(ejson['serial_no']),
        lotNo: fromEJson(ejson['lot_no']),
        warrantyDate: fromEJson(ejson['warranty_date']),
        expirationDate: fromEJson(ejson['expiration_date']),
        unitCost: fromEJson(ejson['unit_cost']),
        status: fromEJson(ejson['status']),
        unitPrice: fromEJson(ejson['unit_price']),
        unitPriceLcy: fromEJson(ejson['unit_price_lcy']),
        vatCalculationType: fromEJson(ejson['vat_calculation_type']),
        vatpercentage: fromEJson(ejson['vat_percentage']),
        vatBaseAmount: fromEJson(ejson['vat_base_amount']),
        vatAmount: fromEJson(ejson['vat_amount']),
        discountPercentage: fromEJson(ejson['discount_percentage']),
        discountAmount: fromEJson(ejson['discount_amount']),
        amount: fromEJson(ejson['amount']),
        amountLcy: fromEJson(ejson['amount_lcy']),
        amountIncludingVat: fromEJson(ejson['amount_including_vat']),
        amountIncludingVatLcy: fromEJson(ejson['amount_including_vat_lcy']),
        returnVatPercentage: fromEJson(ejson['return_vat_percentage']),
        returnVatBaseAmount: fromEJson(ejson['return_vat_base_amount']),
        returnVatAmount: fromEJson(ejson['return_vat_amount']),
        returnDiscountPercentage: fromEJson(
          ejson['return_discount_percentage'],
        ),
        returnDiscountAmount: fromEJson(ejson['return_discount_amount']),
        returnAmount: fromEJson(ejson['return_amount']),
        returnAmountLcy: fromEJson(ejson['return_amount_lcy']),
        returnAmountIncludingVat: fromEJson(
          ejson['return_amount_including_vat'],
        ),
        returnAmountIncludingVatLcy: fromEJson(
          ejson['return_amount_including_vat_lcy'],
        ),
        redemptionQuantity: fromEJson(ejson['redemption_quantity']),
        redemptionQuantityBase: fromEJson(ejson['redemption_quantity_base']),
        redemptionUom: fromEJson(ejson['redemption_uom']),
        redemptionMeasure: fromEJson(ejson['redemption_measure']),
        inventory: fromEJson(ejson['inventory']),
        inventoryBase: fromEJson(ejson['inventory_base']),
        currencyCode: fromEJson(ejson['currency_code']),
        currencyFactor: fromEJson(ejson['currency_factor']),
        priceIncludeVat: fromEJson(ejson['price_include_vat']),
        documentType: fromEJson(ejson['document_type']),
        documentNo: fromEJson(ejson['document_no']),
        itemCategoryCode: fromEJson(ejson['item_category_code']),
        itemGroupCode: fromEJson(ejson['item_group_code']),
        itemBrandCode: fromEJson(ejson['item_brand_code']),
        storeCode: fromEJson(ejson['store_code']),
        divisionCode: fromEJson(ejson['division_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        departmentCode: fromEJson(ejson['department_code']),
        projectCode: fromEJson(ejson['project_code']),
        distributorCode: fromEJson(ejson['distributor_code']),
        customerGroupCode: fromEJson(ejson['customer_group_code']),
        territoryCode: fromEJson(ejson['territory_code']),
        remark: fromEJson(ejson['remark']),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "No"),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CustomerItemLedgerEntry._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CustomerItemLedgerEntry,
      'CUSTOMER_ITEM_LEDGER_ENTRY',
      [
        SchemaProperty(
          'entryNo',
          RealmPropertyType.string,
          mapTo: 'entry_no',
          primaryKey: true,
        ),
        SchemaProperty(
          'appId',
          RealmPropertyType.string,
          mapTo: 'app_id',
          optional: true,
        ),
        SchemaProperty(
          'scheduleId',
          RealmPropertyType.string,
          mapTo: 'schedule_id',
          optional: true,
        ),
        SchemaProperty(
          'shipToCode',
          RealmPropertyType.string,
          mapTo: 'ship_to_code',
          optional: true,
        ),
        SchemaProperty(
          'itemNo',
          RealmPropertyType.string,
          mapTo: 'item_no',
          optional: true,
        ),
        SchemaProperty(
          'customerNo',
          RealmPropertyType.string,
          mapTo: 'customer_no',
          optional: true,
        ),
        SchemaProperty(
          'customerName',
          RealmPropertyType.string,
          mapTo: 'customer_name',
          optional: true,
        ),
        SchemaProperty(
          'customerName2',
          RealmPropertyType.string,
          mapTo: 'customer_name_2',
          optional: true,
        ),
        SchemaProperty(
          'competitorNo',
          RealmPropertyType.string,
          mapTo: 'competitor_no',
          optional: true,
        ),
        SchemaProperty(
          'competitorName',
          RealmPropertyType.string,
          mapTo: 'competitor_name',
          optional: true,
        ),
        SchemaProperty(
          'competitorName2',
          RealmPropertyType.string,
          mapTo: 'competitor_name_2',
          optional: true,
        ),
        SchemaProperty(
          'variantCode',
          RealmPropertyType.string,
          mapTo: 'variant_code',
          optional: true,
        ),
        SchemaProperty(
          'itemDescription',
          RealmPropertyType.string,
          mapTo: 'item_description',
          optional: true,
        ),
        SchemaProperty(
          'itemDescription2',
          RealmPropertyType.string,
          mapTo: 'item_description_2',
          optional: true,
        ),
        SchemaProperty(
          'countingDate',
          RealmPropertyType.string,
          mapTo: 'counting_date',
          optional: true,
        ),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty('quantity', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'quantityBase',
          RealmPropertyType.double,
          mapTo: 'quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'quantityBuyFromOther',
          RealmPropertyType.double,
          mapTo: 'quantity_buy_from_other',
          optional: true,
        ),
        SchemaProperty(
          'quantityBuyFromOtherBase',
          RealmPropertyType.double,
          mapTo: 'quantity_buy_from_other_base',
          optional: true,
        ),
        SchemaProperty(
          'plannedQuantity',
          RealmPropertyType.double,
          mapTo: 'planned_quantity',
          optional: true,
        ),
        SchemaProperty(
          'plannedQuantityBase',
          RealmPropertyType.double,
          mapTo: 'planned_quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'plannedQuantityReturn',
          RealmPropertyType.double,
          mapTo: 'planned_quantity_return',
          optional: true,
        ),
        SchemaProperty(
          'plannedQuantityReturnBase',
          RealmPropertyType.double,
          mapTo: 'planned_quantity_return_base',
          optional: true,
        ),
        SchemaProperty(
          'volumeSalesQuantity',
          RealmPropertyType.double,
          mapTo: 'volume_sales_quantity',
          optional: true,
        ),
        SchemaProperty(
          'volumeSalesQuantityBase',
          RealmPropertyType.double,
          mapTo: 'volume_sales_quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'focInQuantity',
          RealmPropertyType.double,
          mapTo: 'foc_in_quantity',
          optional: true,
        ),
        SchemaProperty(
          'focInQuantityBase',
          RealmPropertyType.double,
          mapTo: 'foc_in_quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'focOutQuantity',
          RealmPropertyType.double,
          mapTo: 'foc_out_quantity',
          optional: true,
        ),
        SchemaProperty(
          'focOutQuantityBase',
          RealmPropertyType.double,
          mapTo: 'foc_out_quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'focInuom',
          RealmPropertyType.string,
          mapTo: 'foc_in_uom',
          optional: true,
        ),
        SchemaProperty(
          'focOutUom',
          RealmPropertyType.string,
          mapTo: 'foc_out_uom',
          optional: true,
        ),
        SchemaProperty(
          'focInMeasure',
          RealmPropertyType.double,
          mapTo: 'foc_in_measure',
          optional: true,
        ),
        SchemaProperty(
          'focOutMeasure',
          RealmPropertyType.double,
          mapTo: 'foc_out_measure',
          optional: true,
        ),
        SchemaProperty(
          'unitOfMeasureCode',
          RealmPropertyType.string,
          mapTo: 'unit_of_measure_code',
          optional: true,
        ),
        SchemaProperty(
          'quantityBuyFromOtherUom',
          RealmPropertyType.string,
          mapTo: 'quantity_buy_from_other_uom',
          optional: true,
        ),
        SchemaProperty(
          'plannedQuantityUom',
          RealmPropertyType.string,
          mapTo: 'planned_quantity_uom',
          optional: true,
        ),
        SchemaProperty(
          'plannedQuantityReturnUom',
          RealmPropertyType.string,
          mapTo: 'planned_quantity_return_uom',
          optional: true,
        ),
        SchemaProperty(
          'volumeSalesQuantityUom',
          RealmPropertyType.string,
          mapTo: 'volume_sales_quantity_uom',
          optional: true,
        ),
        SchemaProperty(
          'qtyPerUnitOfMeasure',
          RealmPropertyType.double,
          mapTo: 'qty_per_unit_of_measure',
          optional: true,
        ),
        SchemaProperty(
          'quantityBuyFromOtherMeasure',
          RealmPropertyType.double,
          mapTo: 'quantity_buy_from_other_measure',
          optional: true,
        ),
        SchemaProperty(
          'plannedQuantityMeasure',
          RealmPropertyType.double,
          mapTo: 'planned_quantity_measure',
          optional: true,
        ),
        SchemaProperty(
          'plannedQuantityReturnMeasure',
          RealmPropertyType.double,
          mapTo: 'planned_quantity_return_measure',
          optional: true,
        ),
        SchemaProperty(
          'volumeSalesQuantityMeasure',
          RealmPropertyType.double,
          mapTo: 'volume_sales_quantity_measure',
          optional: true,
        ),
        SchemaProperty(
          'salesPurchaserCode',
          RealmPropertyType.string,
          mapTo: 'sales_purchaser_code',
          optional: true,
        ),
        SchemaProperty(
          'serialNo',
          RealmPropertyType.string,
          mapTo: 'serial_no',
          optional: true,
        ),
        SchemaProperty(
          'lotNo',
          RealmPropertyType.string,
          mapTo: 'lot_no',
          optional: true,
        ),
        SchemaProperty(
          'warrantyDate',
          RealmPropertyType.string,
          mapTo: 'warranty_date',
          optional: true,
        ),
        SchemaProperty(
          'expirationDate',
          RealmPropertyType.string,
          mapTo: 'expiration_date',
          optional: true,
        ),
        SchemaProperty(
          'unitCost',
          RealmPropertyType.double,
          mapTo: 'unit_cost',
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'unitPrice',
          RealmPropertyType.double,
          mapTo: 'unit_price',
          optional: true,
        ),
        SchemaProperty(
          'unitPriceLcy',
          RealmPropertyType.double,
          mapTo: 'unit_price_lcy',
          optional: true,
        ),
        SchemaProperty(
          'vatCalculationType',
          RealmPropertyType.string,
          mapTo: 'vat_calculation_type',
          optional: true,
        ),
        SchemaProperty(
          'vatpercentage',
          RealmPropertyType.double,
          mapTo: 'vat_percentage',
          optional: true,
        ),
        SchemaProperty(
          'vatBaseAmount',
          RealmPropertyType.double,
          mapTo: 'vat_base_amount',
          optional: true,
        ),
        SchemaProperty(
          'vatAmount',
          RealmPropertyType.double,
          mapTo: 'vat_amount',
          optional: true,
        ),
        SchemaProperty(
          'discountPercentage',
          RealmPropertyType.double,
          mapTo: 'discount_percentage',
          optional: true,
        ),
        SchemaProperty(
          'discountAmount',
          RealmPropertyType.double,
          mapTo: 'discount_amount',
          optional: true,
        ),
        SchemaProperty('amount', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'amountLcy',
          RealmPropertyType.double,
          mapTo: 'amount_lcy',
          optional: true,
        ),
        SchemaProperty(
          'amountIncludingVat',
          RealmPropertyType.double,
          mapTo: 'amount_including_vat',
          optional: true,
        ),
        SchemaProperty(
          'amountIncludingVatLcy',
          RealmPropertyType.double,
          mapTo: 'amount_including_vat_lcy',
          optional: true,
        ),
        SchemaProperty(
          'returnVatPercentage',
          RealmPropertyType.double,
          mapTo: 'return_vat_percentage',
          optional: true,
        ),
        SchemaProperty(
          'returnVatBaseAmount',
          RealmPropertyType.double,
          mapTo: 'return_vat_base_amount',
          optional: true,
        ),
        SchemaProperty(
          'returnVatAmount',
          RealmPropertyType.double,
          mapTo: 'return_vat_amount',
          optional: true,
        ),
        SchemaProperty(
          'returnDiscountPercentage',
          RealmPropertyType.double,
          mapTo: 'return_discount_percentage',
          optional: true,
        ),
        SchemaProperty(
          'returnDiscountAmount',
          RealmPropertyType.double,
          mapTo: 'return_discount_amount',
          optional: true,
        ),
        SchemaProperty(
          'returnAmount',
          RealmPropertyType.double,
          mapTo: 'return_amount',
          optional: true,
        ),
        SchemaProperty(
          'returnAmountLcy',
          RealmPropertyType.double,
          mapTo: 'return_amount_lcy',
          optional: true,
        ),
        SchemaProperty(
          'returnAmountIncludingVat',
          RealmPropertyType.double,
          mapTo: 'return_amount_including_vat',
          optional: true,
        ),
        SchemaProperty(
          'returnAmountIncludingVatLcy',
          RealmPropertyType.double,
          mapTo: 'return_amount_including_vat_lcy',
          optional: true,
        ),
        SchemaProperty(
          'redemptionQuantity',
          RealmPropertyType.double,
          mapTo: 'redemption_quantity',
          optional: true,
        ),
        SchemaProperty(
          'redemptionQuantityBase',
          RealmPropertyType.double,
          mapTo: 'redemption_quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'redemptionUom',
          RealmPropertyType.double,
          mapTo: 'redemption_uom',
          optional: true,
        ),
        SchemaProperty(
          'redemptionMeasure',
          RealmPropertyType.double,
          mapTo: 'redemption_measure',
          optional: true,
        ),
        SchemaProperty('inventory', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'inventoryBase',
          RealmPropertyType.double,
          mapTo: 'inventory_base',
          optional: true,
        ),
        SchemaProperty(
          'currencyCode',
          RealmPropertyType.string,
          mapTo: 'currency_code',
          optional: true,
        ),
        SchemaProperty(
          'currencyFactor',
          RealmPropertyType.double,
          mapTo: 'currency_factor',
          optional: true,
        ),
        SchemaProperty(
          'priceIncludeVat',
          RealmPropertyType.double,
          mapTo: 'price_include_vat',
          optional: true,
        ),
        SchemaProperty(
          'documentType',
          RealmPropertyType.string,
          mapTo: 'document_type',
          optional: true,
        ),
        SchemaProperty(
          'documentNo',
          RealmPropertyType.string,
          mapTo: 'document_no',
          optional: true,
        ),
        SchemaProperty(
          'itemCategoryCode',
          RealmPropertyType.string,
          mapTo: 'item_category_code',
          optional: true,
        ),
        SchemaProperty(
          'itemGroupCode',
          RealmPropertyType.string,
          mapTo: 'item_group_code',
          optional: true,
        ),
        SchemaProperty(
          'itemBrandCode',
          RealmPropertyType.string,
          mapTo: 'item_brand_code',
          optional: true,
        ),
        SchemaProperty(
          'storeCode',
          RealmPropertyType.string,
          mapTo: 'store_code',
          optional: true,
        ),
        SchemaProperty(
          'divisionCode',
          RealmPropertyType.string,
          mapTo: 'division_code',
          optional: true,
        ),
        SchemaProperty(
          'businessUnitCode',
          RealmPropertyType.string,
          mapTo: 'business_unit_code',
          optional: true,
        ),
        SchemaProperty(
          'departmentCode',
          RealmPropertyType.string,
          mapTo: 'department_code',
          optional: true,
        ),
        SchemaProperty(
          'projectCode',
          RealmPropertyType.string,
          mapTo: 'project_code',
          optional: true,
        ),
        SchemaProperty(
          'distributorCode',
          RealmPropertyType.string,
          mapTo: 'distributor_code',
          optional: true,
        ),
        SchemaProperty(
          'customerGroupCode',
          RealmPropertyType.string,
          mapTo: 'customer_group_code',
          optional: true,
        ),
        SchemaProperty(
          'territoryCode',
          RealmPropertyType.string,
          mapTo: 'territory_code',
          optional: true,
        ),
        SchemaProperty('remark', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class SalesPersonScheduleMerchandise extends _SalesPersonScheduleMerchandise
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  SalesPersonScheduleMerchandise(
    String? id, {
    String? appId,
    int? visitNo,
    String? scheduleDate,
    String? customerNo,
    String? name,
    String? name2,
    String? salespersonCode,
    String? competitorNo,
    String? merchandiseType,
    String? merchandiseOption,
    String? merchandiseCode,
    String? description,
    String? description2,
    String? remark,
    String? picture,
    String? status = "Open",
    double? quantity = 0,
    String? flag = "No",
    String? isSync = "Yes",
  }) {
    if (!_defaultsSet) {
      _defaultsSet =
          RealmObjectBase.setDefaults<SalesPersonScheduleMerchandise>({
            'status': "Open",
            'quantity': 0,
            'flag': "No",
            'is_sync': "Yes",
          });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'app_id', appId);
    RealmObjectBase.set(this, 'visit_no', visitNo);
    RealmObjectBase.set(this, 'schedule_date', scheduleDate);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'name_2', name2);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'competitor_no', competitorNo);
    RealmObjectBase.set(this, 'merchandise_type', merchandiseType);
    RealmObjectBase.set(this, 'merchandise_option', merchandiseOption);
    RealmObjectBase.set(this, 'merchandise_code', merchandiseCode);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'remark', remark);
    RealmObjectBase.set(this, 'picture', picture);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'flag', flag);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  SalesPersonScheduleMerchandise._();

  @override
  String? get id => RealmObjectBase.get<String>(this, 'id') as String?;
  @override
  set id(String? value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get appId => RealmObjectBase.get<String>(this, 'app_id') as String?;
  @override
  set appId(String? value) => RealmObjectBase.set(this, 'app_id', value);

  @override
  int? get visitNo => RealmObjectBase.get<int>(this, 'visit_no') as int?;
  @override
  set visitNo(int? value) => RealmObjectBase.set(this, 'visit_no', value);

  @override
  String? get scheduleDate =>
      RealmObjectBase.get<String>(this, 'schedule_date') as String?;
  @override
  set scheduleDate(String? value) =>
      RealmObjectBase.set(this, 'schedule_date', value);

  @override
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get name2 => RealmObjectBase.get<String>(this, 'name_2') as String?;
  @override
  set name2(String? value) => RealmObjectBase.set(this, 'name_2', value);

  @override
  String? get salespersonCode =>
      RealmObjectBase.get<String>(this, 'salesperson_code') as String?;
  @override
  set salespersonCode(String? value) =>
      RealmObjectBase.set(this, 'salesperson_code', value);

  @override
  String? get competitorNo =>
      RealmObjectBase.get<String>(this, 'competitor_no') as String?;
  @override
  set competitorNo(String? value) =>
      RealmObjectBase.set(this, 'competitor_no', value);

  @override
  String? get merchandiseType =>
      RealmObjectBase.get<String>(this, 'merchandise_type') as String?;
  @override
  set merchandiseType(String? value) =>
      RealmObjectBase.set(this, 'merchandise_type', value);

  @override
  String? get merchandiseOption =>
      RealmObjectBase.get<String>(this, 'merchandise_option') as String?;
  @override
  set merchandiseOption(String? value) =>
      RealmObjectBase.set(this, 'merchandise_option', value);

  @override
  String? get merchandiseCode =>
      RealmObjectBase.get<String>(this, 'merchandise_code') as String?;
  @override
  set merchandiseCode(String? value) =>
      RealmObjectBase.set(this, 'merchandise_code', value);

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
  String? get picture =>
      RealmObjectBase.get<String>(this, 'picture') as String?;
  @override
  set picture(String? value) => RealmObjectBase.set(this, 'picture', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  double? get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double?;
  @override
  set quantity(double? value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  String? get flag => RealmObjectBase.get<String>(this, 'flag') as String?;
  @override
  set flag(String? value) => RealmObjectBase.set(this, 'flag', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<SalesPersonScheduleMerchandise>> get changes =>
      RealmObjectBase.getChanges<SalesPersonScheduleMerchandise>(this);

  @override
  Stream<RealmObjectChanges<SalesPersonScheduleMerchandise>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<SalesPersonScheduleMerchandise>(
    this,
    keyPaths,
  );

  @override
  SalesPersonScheduleMerchandise freeze() =>
      RealmObjectBase.freezeObject<SalesPersonScheduleMerchandise>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'app_id': appId.toEJson(),
      'visit_no': visitNo.toEJson(),
      'schedule_date': scheduleDate.toEJson(),
      'customer_no': customerNo.toEJson(),
      'name': name.toEJson(),
      'name_2': name2.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'competitor_no': competitorNo.toEJson(),
      'merchandise_type': merchandiseType.toEJson(),
      'merchandise_option': merchandiseOption.toEJson(),
      'merchandise_code': merchandiseCode.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'remark': remark.toEJson(),
      'picture': picture.toEJson(),
      'status': status.toEJson(),
      'quantity': quantity.toEJson(),
      'flag': flag.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(SalesPersonScheduleMerchandise value) =>
      value.toEJson();
  static SalesPersonScheduleMerchandise _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => SalesPersonScheduleMerchandise(
        fromEJson(ejson['id']),
        appId: fromEJson(ejson['app_id']),
        visitNo: fromEJson(ejson['visit_no']),
        scheduleDate: fromEJson(ejson['schedule_date']),
        customerNo: fromEJson(ejson['customer_no']),
        name: fromEJson(ejson['name']),
        name2: fromEJson(ejson['name_2']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        competitorNo: fromEJson(ejson['competitor_no']),
        merchandiseType: fromEJson(ejson['merchandise_type']),
        merchandiseOption: fromEJson(ejson['merchandise_option']),
        merchandiseCode: fromEJson(ejson['merchandise_code']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        remark: fromEJson(ejson['remark']),
        picture: fromEJson(ejson['picture']),
        status: fromEJson(ejson['status'], defaultValue: "Open"),
        quantity: fromEJson(ejson['quantity'], defaultValue: 0),
        flag: fromEJson(ejson['flag'], defaultValue: "No"),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SalesPersonScheduleMerchandise._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      SalesPersonScheduleMerchandise,
      'SALESPERSON_SCHEDULE_MERCHANDISE',
      [
        SchemaProperty(
          'id',
          RealmPropertyType.string,
          optional: true,
          primaryKey: true,
        ),
        SchemaProperty(
          'appId',
          RealmPropertyType.string,
          mapTo: 'app_id',
          optional: true,
        ),
        SchemaProperty(
          'visitNo',
          RealmPropertyType.int,
          mapTo: 'visit_no',
          optional: true,
        ),
        SchemaProperty(
          'scheduleDate',
          RealmPropertyType.string,
          mapTo: 'schedule_date',
          optional: true,
        ),
        SchemaProperty(
          'customerNo',
          RealmPropertyType.string,
          mapTo: 'customer_no',
          optional: true,
        ),
        SchemaProperty('name', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'name2',
          RealmPropertyType.string,
          mapTo: 'name_2',
          optional: true,
        ),
        SchemaProperty(
          'salespersonCode',
          RealmPropertyType.string,
          mapTo: 'salesperson_code',
          optional: true,
        ),
        SchemaProperty(
          'competitorNo',
          RealmPropertyType.string,
          mapTo: 'competitor_no',
          optional: true,
        ),
        SchemaProperty(
          'merchandiseType',
          RealmPropertyType.string,
          mapTo: 'merchandise_type',
          optional: true,
        ),
        SchemaProperty(
          'merchandiseOption',
          RealmPropertyType.string,
          mapTo: 'merchandise_option',
          optional: true,
        ),
        SchemaProperty(
          'merchandiseCode',
          RealmPropertyType.string,
          mapTo: 'merchandise_code',
          optional: true,
        ),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty('remark', RealmPropertyType.string, optional: true),
        SchemaProperty('picture', RealmPropertyType.string, optional: true),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty('quantity', RealmPropertyType.double, optional: true),
        SchemaProperty('flag', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemPrizeRedemptionLineEntry extends _ItemPrizeRedemptionLineEntry
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ItemPrizeRedemptionLineEntry(
    String id, {
    String? appId,
    String? scheduleId,
    String? scheduleDate,
    int? lineNo,
    String? promotionNo,
    String? customerNo,
    String? customerName,
    String? customerName2,
    String? shipToCode,
    String? itemNo,
    String? variantCode,
    String? redemptionType,
    String? description,
    String? description2,
    String? unitOfMeasureCode,
    double? qtyPerUnitOfMeasure,
    double? quantity,
    String? sourceType,
    String? sourceNo,
    String? salespersonCode,
    String? itemCategoryCode,
    String? itemGroupCode,
    String? itemBrandCode,
    String? status = "Open",
    String? isSync = "Yes",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ItemPrizeRedemptionLineEntry>({
        'status': "Open",
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'app_id', appId);
    RealmObjectBase.set(this, 'schedule_id', scheduleId);
    RealmObjectBase.set(this, 'schedule_date', scheduleDate);
    RealmObjectBase.set(this, 'line_no', lineNo);
    RealmObjectBase.set(this, 'promotion_no', promotionNo);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'customer_name', customerName);
    RealmObjectBase.set(this, 'customer_name_2', customerName2);
    RealmObjectBase.set(this, 'ship_to_code', shipToCode);
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'redemption_type', redemptionType);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'unit_of_measure_code', unitOfMeasureCode);
    RealmObjectBase.set(this, 'qty_per_unit_of_measure', qtyPerUnitOfMeasure);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'source_type', sourceType);
    RealmObjectBase.set(this, 'source_no', sourceNo);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'item_category_code', itemCategoryCode);
    RealmObjectBase.set(this, 'item_group_code', itemGroupCode);
    RealmObjectBase.set(this, 'item_brand_code', itemBrandCode);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  ItemPrizeRedemptionLineEntry._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get appId => RealmObjectBase.get<String>(this, 'app_id') as String?;
  @override
  set appId(String? value) => RealmObjectBase.set(this, 'app_id', value);

  @override
  String? get scheduleId =>
      RealmObjectBase.get<String>(this, 'schedule_id') as String?;
  @override
  set scheduleId(String? value) =>
      RealmObjectBase.set(this, 'schedule_id', value);

  @override
  String? get scheduleDate =>
      RealmObjectBase.get<String>(this, 'schedule_date') as String?;
  @override
  set scheduleDate(String? value) =>
      RealmObjectBase.set(this, 'schedule_date', value);

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
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

  @override
  String? get customerName =>
      RealmObjectBase.get<String>(this, 'customer_name') as String?;
  @override
  set customerName(String? value) =>
      RealmObjectBase.set(this, 'customer_name', value);

  @override
  String? get customerName2 =>
      RealmObjectBase.get<String>(this, 'customer_name_2') as String?;
  @override
  set customerName2(String? value) =>
      RealmObjectBase.set(this, 'customer_name_2', value);

  @override
  String? get shipToCode =>
      RealmObjectBase.get<String>(this, 'ship_to_code') as String?;
  @override
  set shipToCode(String? value) =>
      RealmObjectBase.set(this, 'ship_to_code', value);

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
  String? get sourceType =>
      RealmObjectBase.get<String>(this, 'source_type') as String?;
  @override
  set sourceType(String? value) =>
      RealmObjectBase.set(this, 'source_type', value);

  @override
  String? get sourceNo =>
      RealmObjectBase.get<String>(this, 'source_no') as String?;
  @override
  set sourceNo(String? value) => RealmObjectBase.set(this, 'source_no', value);

  @override
  String? get salespersonCode =>
      RealmObjectBase.get<String>(this, 'salesperson_code') as String?;
  @override
  set salespersonCode(String? value) =>
      RealmObjectBase.set(this, 'salesperson_code', value);

  @override
  String? get itemCategoryCode =>
      RealmObjectBase.get<String>(this, 'item_category_code') as String?;
  @override
  set itemCategoryCode(String? value) =>
      RealmObjectBase.set(this, 'item_category_code', value);

  @override
  String? get itemGroupCode =>
      RealmObjectBase.get<String>(this, 'item_group_code') as String?;
  @override
  set itemGroupCode(String? value) =>
      RealmObjectBase.set(this, 'item_group_code', value);

  @override
  String? get itemBrandCode =>
      RealmObjectBase.get<String>(this, 'item_brand_code') as String?;
  @override
  set itemBrandCode(String? value) =>
      RealmObjectBase.set(this, 'item_brand_code', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<ItemPrizeRedemptionLineEntry>> get changes =>
      RealmObjectBase.getChanges<ItemPrizeRedemptionLineEntry>(this);

  @override
  Stream<RealmObjectChanges<ItemPrizeRedemptionLineEntry>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<ItemPrizeRedemptionLineEntry>(
    this,
    keyPaths,
  );

  @override
  ItemPrizeRedemptionLineEntry freeze() =>
      RealmObjectBase.freezeObject<ItemPrizeRedemptionLineEntry>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'app_id': appId.toEJson(),
      'schedule_id': scheduleId.toEJson(),
      'schedule_date': scheduleDate.toEJson(),
      'line_no': lineNo.toEJson(),
      'promotion_no': promotionNo.toEJson(),
      'customer_no': customerNo.toEJson(),
      'customer_name': customerName.toEJson(),
      'customer_name_2': customerName2.toEJson(),
      'ship_to_code': shipToCode.toEJson(),
      'item_no': itemNo.toEJson(),
      'variant_code': variantCode.toEJson(),
      'redemption_type': redemptionType.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'unit_of_measure_code': unitOfMeasureCode.toEJson(),
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure.toEJson(),
      'quantity': quantity.toEJson(),
      'source_type': sourceType.toEJson(),
      'source_no': sourceNo.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'item_category_code': itemCategoryCode.toEJson(),
      'item_group_code': itemGroupCode.toEJson(),
      'item_brand_code': itemBrandCode.toEJson(),
      'status': status.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemPrizeRedemptionLineEntry value) =>
      value.toEJson();
  static ItemPrizeRedemptionLineEntry _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => ItemPrizeRedemptionLineEntry(
        fromEJson(id),
        appId: fromEJson(ejson['app_id']),
        scheduleId: fromEJson(ejson['schedule_id']),
        scheduleDate: fromEJson(ejson['schedule_date']),
        lineNo: fromEJson(ejson['line_no']),
        promotionNo: fromEJson(ejson['promotion_no']),
        customerNo: fromEJson(ejson['customer_no']),
        customerName: fromEJson(ejson['customer_name']),
        customerName2: fromEJson(ejson['customer_name_2']),
        shipToCode: fromEJson(ejson['ship_to_code']),
        itemNo: fromEJson(ejson['item_no']),
        variantCode: fromEJson(ejson['variant_code']),
        redemptionType: fromEJson(ejson['redemption_type']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        unitOfMeasureCode: fromEJson(ejson['unit_of_measure_code']),
        qtyPerUnitOfMeasure: fromEJson(ejson['qty_per_unit_of_measure']),
        quantity: fromEJson(ejson['quantity']),
        sourceType: fromEJson(ejson['source_type']),
        sourceNo: fromEJson(ejson['source_no']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        itemCategoryCode: fromEJson(ejson['item_category_code']),
        itemGroupCode: fromEJson(ejson['item_group_code']),
        itemBrandCode: fromEJson(ejson['item_brand_code']),
        status: fromEJson(ejson['status'], defaultValue: "Open"),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemPrizeRedemptionLineEntry._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      ItemPrizeRedemptionLineEntry,
      'ITEM_PRIZE_REDEMPTION_LINE_ENTRY',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty(
          'appId',
          RealmPropertyType.string,
          mapTo: 'app_id',
          optional: true,
        ),
        SchemaProperty(
          'scheduleId',
          RealmPropertyType.string,
          mapTo: 'schedule_id',
          optional: true,
        ),
        SchemaProperty(
          'scheduleDate',
          RealmPropertyType.string,
          mapTo: 'schedule_date',
          optional: true,
        ),
        SchemaProperty(
          'lineNo',
          RealmPropertyType.int,
          mapTo: 'line_no',
          optional: true,
        ),
        SchemaProperty(
          'promotionNo',
          RealmPropertyType.string,
          mapTo: 'promotion_no',
          optional: true,
        ),
        SchemaProperty(
          'customerNo',
          RealmPropertyType.string,
          mapTo: 'customer_no',
          optional: true,
        ),
        SchemaProperty(
          'customerName',
          RealmPropertyType.string,
          mapTo: 'customer_name',
          optional: true,
        ),
        SchemaProperty(
          'customerName2',
          RealmPropertyType.string,
          mapTo: 'customer_name_2',
          optional: true,
        ),
        SchemaProperty(
          'shipToCode',
          RealmPropertyType.string,
          mapTo: 'ship_to_code',
          optional: true,
        ),
        SchemaProperty(
          'itemNo',
          RealmPropertyType.string,
          mapTo: 'item_no',
          optional: true,
        ),
        SchemaProperty(
          'variantCode',
          RealmPropertyType.string,
          mapTo: 'variant_code',
          optional: true,
        ),
        SchemaProperty(
          'redemptionType',
          RealmPropertyType.string,
          mapTo: 'redemption_type',
          optional: true,
        ),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty(
          'unitOfMeasureCode',
          RealmPropertyType.string,
          mapTo: 'unit_of_measure_code',
          optional: true,
        ),
        SchemaProperty(
          'qtyPerUnitOfMeasure',
          RealmPropertyType.double,
          mapTo: 'qty_per_unit_of_measure',
          optional: true,
        ),
        SchemaProperty('quantity', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'sourceType',
          RealmPropertyType.string,
          mapTo: 'source_type',
          optional: true,
        ),
        SchemaProperty(
          'sourceNo',
          RealmPropertyType.string,
          mapTo: 'source_no',
          optional: true,
        ),
        SchemaProperty(
          'salespersonCode',
          RealmPropertyType.string,
          mapTo: 'salesperson_code',
          optional: true,
        ),
        SchemaProperty(
          'itemCategoryCode',
          RealmPropertyType.string,
          mapTo: 'item_category_code',
          optional: true,
        ),
        SchemaProperty(
          'itemGroupCode',
          RealmPropertyType.string,
          mapTo: 'item_group_code',
          optional: true,
        ),
        SchemaProperty(
          'itemBrandCode',
          RealmPropertyType.string,
          mapTo: 'item_brand_code',
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CompetitorPromtionHeader extends _CompetitorPromtionHeader
    with RealmEntity, RealmObjectBase, RealmObject {
  CompetitorPromtionHeader(
    String id, {
    String? no,
    String? fromDate,
    String? toDate,
    String? description,
    String? description2,
    String? remark,
    String? promotionType,
    String? salespersonCodeFilter,
    String? distributorCodeFilter,
    String? storeCodeFilter,
    String? divisionCodeFilter,
    String? businessUnitCodeFilter,
    String? departmentCodeFilter,
    String? projectCodeFilter,
    String? firstApproverCode,
    String? secondApproverCode,
    String? competitorNo,
    String? customerNo,
    String? name,
    String? name2,
    String? sourceType,
    String? sourceNo,
    String? status,
    String? picture,
    String? avatar32,
    String? avatar128,
    String? appId,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'from_date', fromDate);
    RealmObjectBase.set(this, 'to_date', toDate);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'remark', remark);
    RealmObjectBase.set(this, 'promotion_type', promotionType);
    RealmObjectBase.set(this, 'salesperson_code_filter', salespersonCodeFilter);
    RealmObjectBase.set(this, 'distributor_code_filter', distributorCodeFilter);
    RealmObjectBase.set(this, 'store_code_filter', storeCodeFilter);
    RealmObjectBase.set(this, 'division_code_filter', divisionCodeFilter);
    RealmObjectBase.set(
      this,
      'business_unit_code_filter',
      businessUnitCodeFilter,
    );
    RealmObjectBase.set(this, 'department_code_filter', departmentCodeFilter);
    RealmObjectBase.set(this, 'project_code_filter', projectCodeFilter);
    RealmObjectBase.set(this, 'first_approver_code', firstApproverCode);
    RealmObjectBase.set(this, 'second_approver_code', secondApproverCode);
    RealmObjectBase.set(this, 'competitor_no', competitorNo);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'name_2', name2);
    RealmObjectBase.set(this, 'source_type', sourceType);
    RealmObjectBase.set(this, 'source_no', sourceNo);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'picture', picture);
    RealmObjectBase.set(this, 'avatar_32', avatar32);
    RealmObjectBase.set(this, 'avatar_128', avatar128);
    RealmObjectBase.set(this, 'app_id', appId);
  }

  CompetitorPromtionHeader._();

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
  String? get firstApproverCode =>
      RealmObjectBase.get<String>(this, 'first_approver_code') as String?;
  @override
  set firstApproverCode(String? value) =>
      RealmObjectBase.set(this, 'first_approver_code', value);

  @override
  String? get secondApproverCode =>
      RealmObjectBase.get<String>(this, 'second_approver_code') as String?;
  @override
  set secondApproverCode(String? value) =>
      RealmObjectBase.set(this, 'second_approver_code', value);

  @override
  String? get competitorNo =>
      RealmObjectBase.get<String>(this, 'competitor_no') as String?;
  @override
  set competitorNo(String? value) =>
      RealmObjectBase.set(this, 'competitor_no', value);

  @override
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get name2 => RealmObjectBase.get<String>(this, 'name_2') as String?;
  @override
  set name2(String? value) => RealmObjectBase.set(this, 'name_2', value);

  @override
  String? get sourceType =>
      RealmObjectBase.get<String>(this, 'source_type') as String?;
  @override
  set sourceType(String? value) =>
      RealmObjectBase.set(this, 'source_type', value);

  @override
  String? get sourceNo =>
      RealmObjectBase.get<String>(this, 'source_no') as String?;
  @override
  set sourceNo(String? value) => RealmObjectBase.set(this, 'source_no', value);

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
  String? get appId => RealmObjectBase.get<String>(this, 'app_id') as String?;
  @override
  set appId(String? value) => RealmObjectBase.set(this, 'app_id', value);

  @override
  Stream<RealmObjectChanges<CompetitorPromtionHeader>> get changes =>
      RealmObjectBase.getChanges<CompetitorPromtionHeader>(this);

  @override
  Stream<RealmObjectChanges<CompetitorPromtionHeader>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CompetitorPromtionHeader>(this, keyPaths);

  @override
  CompetitorPromtionHeader freeze() =>
      RealmObjectBase.freezeObject<CompetitorPromtionHeader>(this);

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
      'salesperson_code_filter': salespersonCodeFilter.toEJson(),
      'distributor_code_filter': distributorCodeFilter.toEJson(),
      'store_code_filter': storeCodeFilter.toEJson(),
      'division_code_filter': divisionCodeFilter.toEJson(),
      'business_unit_code_filter': businessUnitCodeFilter.toEJson(),
      'department_code_filter': departmentCodeFilter.toEJson(),
      'project_code_filter': projectCodeFilter.toEJson(),
      'first_approver_code': firstApproverCode.toEJson(),
      'second_approver_code': secondApproverCode.toEJson(),
      'competitor_no': competitorNo.toEJson(),
      'customer_no': customerNo.toEJson(),
      'name': name.toEJson(),
      'name_2': name2.toEJson(),
      'source_type': sourceType.toEJson(),
      'source_no': sourceNo.toEJson(),
      'status': status.toEJson(),
      'picture': picture.toEJson(),
      'avatar_32': avatar32.toEJson(),
      'avatar_128': avatar128.toEJson(),
      'app_id': appId.toEJson(),
    };
  }

  static EJsonValue _toEJson(CompetitorPromtionHeader value) => value.toEJson();
  static CompetitorPromtionHeader _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => CompetitorPromtionHeader(
        fromEJson(id),
        no: fromEJson(ejson['no']),
        fromDate: fromEJson(ejson['from_date']),
        toDate: fromEJson(ejson['to_date']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        remark: fromEJson(ejson['remark']),
        promotionType: fromEJson(ejson['promotion_type']),
        salespersonCodeFilter: fromEJson(ejson['salesperson_code_filter']),
        distributorCodeFilter: fromEJson(ejson['distributor_code_filter']),
        storeCodeFilter: fromEJson(ejson['store_code_filter']),
        divisionCodeFilter: fromEJson(ejson['division_code_filter']),
        businessUnitCodeFilter: fromEJson(ejson['business_unit_code_filter']),
        departmentCodeFilter: fromEJson(ejson['department_code_filter']),
        projectCodeFilter: fromEJson(ejson['project_code_filter']),
        firstApproverCode: fromEJson(ejson['first_approver_code']),
        secondApproverCode: fromEJson(ejson['second_approver_code']),
        competitorNo: fromEJson(ejson['competitor_no']),
        customerNo: fromEJson(ejson['customer_no']),
        name: fromEJson(ejson['name']),
        name2: fromEJson(ejson['name_2']),
        sourceType: fromEJson(ejson['source_type']),
        sourceNo: fromEJson(ejson['source_no']),
        status: fromEJson(ejson['status']),
        picture: fromEJson(ejson['picture']),
        avatar32: fromEJson(ejson['avatar_32']),
        avatar128: fromEJson(ejson['avatar_128']),
        appId: fromEJson(ejson['app_id']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CompetitorPromtionHeader._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CompetitorPromtionHeader,
      'COMPETITOR_PROMOTION_HEADER',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('no', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'fromDate',
          RealmPropertyType.string,
          mapTo: 'from_date',
          optional: true,
        ),
        SchemaProperty(
          'toDate',
          RealmPropertyType.string,
          mapTo: 'to_date',
          optional: true,
        ),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty('remark', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'promotionType',
          RealmPropertyType.string,
          mapTo: 'promotion_type',
          optional: true,
        ),
        SchemaProperty(
          'salespersonCodeFilter',
          RealmPropertyType.string,
          mapTo: 'salesperson_code_filter',
          optional: true,
        ),
        SchemaProperty(
          'distributorCodeFilter',
          RealmPropertyType.string,
          mapTo: 'distributor_code_filter',
          optional: true,
        ),
        SchemaProperty(
          'storeCodeFilter',
          RealmPropertyType.string,
          mapTo: 'store_code_filter',
          optional: true,
        ),
        SchemaProperty(
          'divisionCodeFilter',
          RealmPropertyType.string,
          mapTo: 'division_code_filter',
          optional: true,
        ),
        SchemaProperty(
          'businessUnitCodeFilter',
          RealmPropertyType.string,
          mapTo: 'business_unit_code_filter',
          optional: true,
        ),
        SchemaProperty(
          'departmentCodeFilter',
          RealmPropertyType.string,
          mapTo: 'department_code_filter',
          optional: true,
        ),
        SchemaProperty(
          'projectCodeFilter',
          RealmPropertyType.string,
          mapTo: 'project_code_filter',
          optional: true,
        ),
        SchemaProperty(
          'firstApproverCode',
          RealmPropertyType.string,
          mapTo: 'first_approver_code',
          optional: true,
        ),
        SchemaProperty(
          'secondApproverCode',
          RealmPropertyType.string,
          mapTo: 'second_approver_code',
          optional: true,
        ),
        SchemaProperty(
          'competitorNo',
          RealmPropertyType.string,
          mapTo: 'competitor_no',
          optional: true,
        ),
        SchemaProperty(
          'customerNo',
          RealmPropertyType.string,
          mapTo: 'customer_no',
          optional: true,
        ),
        SchemaProperty('name', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'name2',
          RealmPropertyType.string,
          mapTo: 'name_2',
          optional: true,
        ),
        SchemaProperty(
          'sourceType',
          RealmPropertyType.string,
          mapTo: 'source_type',
          optional: true,
        ),
        SchemaProperty(
          'sourceNo',
          RealmPropertyType.string,
          mapTo: 'source_no',
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty('picture', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'avatar32',
          RealmPropertyType.string,
          mapTo: 'avatar_32',
          optional: true,
        ),
        SchemaProperty(
          'avatar128',
          RealmPropertyType.string,
          mapTo: 'avatar_128',
          optional: true,
        ),
        SchemaProperty(
          'appId',
          RealmPropertyType.string,
          mapTo: 'app_id',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CompetitorPromotionLine extends _CompetitorPromotionLine
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  CompetitorPromotionLine(
    String id, {
    String? lineNo,
    String? promotionNo,
    String? itemNo,
    String? variantCode,
    String? description,
    String? description2,
    String? promotionType,
    String? unitOfMeasureCode,
    double? qtyPerUnitOfMeasure = 1,
    double? quantity = 0,
    double? unitPrice = 0,
    double? discountPercentage = 0,
    double? discountAmount = 0,
    double? amount = 0,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CompetitorPromotionLine>({
        'qty_per_unit_of_measure': 1,
        'quantity': 0,
        'unit_price': 0,
        'discount_percentage': 0,
        'discount_amount': 0,
        'amount': 0,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'line_no', lineNo);
    RealmObjectBase.set(this, 'promotion_no', promotionNo);
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'promotion_type', promotionType);
    RealmObjectBase.set(this, 'unit_of_measure_code', unitOfMeasureCode);
    RealmObjectBase.set(this, 'qty_per_unit_of_measure', qtyPerUnitOfMeasure);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'unit_price', unitPrice);
    RealmObjectBase.set(this, 'discount_percentage', discountPercentage);
    RealmObjectBase.set(this, 'discount_amount', discountAmount);
    RealmObjectBase.set(this, 'amount', amount);
  }

  CompetitorPromotionLine._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get lineNo => RealmObjectBase.get<String>(this, 'line_no') as String?;
  @override
  set lineNo(String? value) => RealmObjectBase.set(this, 'line_no', value);

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
  Stream<RealmObjectChanges<CompetitorPromotionLine>> get changes =>
      RealmObjectBase.getChanges<CompetitorPromotionLine>(this);

  @override
  Stream<RealmObjectChanges<CompetitorPromotionLine>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CompetitorPromotionLine>(this, keyPaths);

  @override
  CompetitorPromotionLine freeze() =>
      RealmObjectBase.freezeObject<CompetitorPromotionLine>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'line_no': lineNo.toEJson(),
      'promotion_no': promotionNo.toEJson(),
      'item_no': itemNo.toEJson(),
      'variant_code': variantCode.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'promotion_type': promotionType.toEJson(),
      'unit_of_measure_code': unitOfMeasureCode.toEJson(),
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure.toEJson(),
      'quantity': quantity.toEJson(),
      'unit_price': unitPrice.toEJson(),
      'discount_percentage': discountPercentage.toEJson(),
      'discount_amount': discountAmount.toEJson(),
      'amount': amount.toEJson(),
    };
  }

  static EJsonValue _toEJson(CompetitorPromotionLine value) => value.toEJson();
  static CompetitorPromotionLine _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => CompetitorPromotionLine(
        fromEJson(id),
        lineNo: fromEJson(ejson['line_no']),
        promotionNo: fromEJson(ejson['promotion_no']),
        itemNo: fromEJson(ejson['item_no']),
        variantCode: fromEJson(ejson['variant_code']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        promotionType: fromEJson(ejson['promotion_type']),
        unitOfMeasureCode: fromEJson(ejson['unit_of_measure_code']),
        qtyPerUnitOfMeasure: fromEJson(
          ejson['qty_per_unit_of_measure'],
          defaultValue: 1,
        ),
        quantity: fromEJson(ejson['quantity'], defaultValue: 0),
        unitPrice: fromEJson(ejson['unit_price'], defaultValue: 0),
        discountPercentage: fromEJson(
          ejson['discount_percentage'],
          defaultValue: 0,
        ),
        discountAmount: fromEJson(ejson['discount_amount'], defaultValue: 0),
        amount: fromEJson(ejson['amount'], defaultValue: 0),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CompetitorPromotionLine._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CompetitorPromotionLine,
      'COMPETITOR_PROMOTION_LINE',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty(
          'lineNo',
          RealmPropertyType.string,
          mapTo: 'line_no',
          optional: true,
        ),
        SchemaProperty(
          'promotionNo',
          RealmPropertyType.string,
          mapTo: 'promotion_no',
          optional: true,
        ),
        SchemaProperty(
          'itemNo',
          RealmPropertyType.string,
          mapTo: 'item_no',
          optional: true,
        ),
        SchemaProperty(
          'variantCode',
          RealmPropertyType.string,
          mapTo: 'variant_code',
          optional: true,
        ),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty(
          'promotionType',
          RealmPropertyType.string,
          mapTo: 'promotion_type',
          optional: true,
        ),
        SchemaProperty(
          'unitOfMeasureCode',
          RealmPropertyType.string,
          mapTo: 'unit_of_measure_code',
          optional: true,
        ),
        SchemaProperty(
          'qtyPerUnitOfMeasure',
          RealmPropertyType.double,
          mapTo: 'qty_per_unit_of_measure',
          optional: true,
        ),
        SchemaProperty('quantity', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'unitPrice',
          RealmPropertyType.double,
          mapTo: 'unit_price',
          optional: true,
        ),
        SchemaProperty(
          'discountPercentage',
          RealmPropertyType.double,
          mapTo: 'discount_percentage',
          optional: true,
        ),
        SchemaProperty(
          'discountAmount',
          RealmPropertyType.double,
          mapTo: 'discount_amount',
          optional: true,
        ),
        SchemaProperty('amount', RealmPropertyType.double, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CustomerLedgerEntry extends _CustomerLedgerEntry
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  CustomerLedgerEntry(
    String entryNo, {
    String? customerName,
    String? customerName2,
    String? postingDate,
    String? postingDescription,
    String? documentDate,
    String? documentType,
    String? documentNo,
    String? description,
    String? currencyCode,
    double? currencyFactor = 1,
    String? arPostingGroup,
    String? salespersonCode,
    String? distributorCode,
    String? storeCode,
    String? divisionCode,
    String? businessUnitCode,
    String? departmentCode,
    String? territoryCode,
    String? projectCode,
    String? budgetCode,
    String? customerNo,
    String? customerGroupCode,
    String? appliesToDocType,
    String? appliesToDocNo,
    String? dueDate,
    String? pmtDiscountDate,
    double? pmtDiscountPercentage = 0,
    double? pmtDiscountAmount = 0,
    String? appliesToId,
    String? journalBatchName,
    String? externalDocumentNo,
    double? amountToApply = 0,
    double? amountToApplyLcy = 0,
    double? amountToDiscountLcy = 0,
    double? amountToDiscount = 0,
    double? discount = 0,
    double? discountLcy = 0,
    double? amount = 0,
    double? amountLcy = 0,
    double? remainingAmount = 0,
    double? remainingAmountLcy = 0,
    String? balAccountType,
    String? balAccountNo,
    String? reversed,
    String? reversedByEntryNo,
    String? reversedEntryNo,
    String? adjustment,
    String? orderNo,
    String? orderType,
    String? sourceType,
    String? sourceNo,
    String? specialType,
    String? specialTypeNo,
    String? postingDatetime,
    String? paymentMethodCode,
    String? customerAddress,
    String? isCollection,
    String? index,
    String? overAging,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CustomerLedgerEntry>({
        'currency_factor': 1,
        'pmt_discount_percentage': 0,
        'pmt_discount_amount': 0,
        'amount_to_apply': 0,
        'amount_to_apply_lcy': 0,
        'amount_to_discount_lcy': 0,
        'amount_to_discount': 0,
        'discount': 0,
        'discount_lcy': 0,
        'amount': 0,
        'amount_lcy': 0,
        'remaining_amount': 0,
        'remaining_amount_lcy': 0,
      });
    }
    RealmObjectBase.set(this, 'entry_no', entryNo);
    RealmObjectBase.set(this, 'customer_name', customerName);
    RealmObjectBase.set(this, 'customer_name_2', customerName2);
    RealmObjectBase.set(this, 'posting_date', postingDate);
    RealmObjectBase.set(this, 'posting_description', postingDescription);
    RealmObjectBase.set(this, 'document_date', documentDate);
    RealmObjectBase.set(this, 'document_type', documentType);
    RealmObjectBase.set(this, 'document_no', documentNo);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'currency_factor', currencyFactor);
    RealmObjectBase.set(this, 'ar_posting_group', arPostingGroup);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'territory_code', territoryCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'budget_code', budgetCode);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'customer_group_code', customerGroupCode);
    RealmObjectBase.set(this, 'applies_to_doc_type', appliesToDocType);
    RealmObjectBase.set(this, 'applies_to_doc_no', appliesToDocNo);
    RealmObjectBase.set(this, 'due_date', dueDate);
    RealmObjectBase.set(this, 'pmt_discount_date', pmtDiscountDate);
    RealmObjectBase.set(this, 'pmt_discount_percentage', pmtDiscountPercentage);
    RealmObjectBase.set(this, 'pmt_discount_amount', pmtDiscountAmount);
    RealmObjectBase.set(this, 'applies_to_id', appliesToId);
    RealmObjectBase.set(this, 'journal_batch_name', journalBatchName);
    RealmObjectBase.set(this, 'external_document_no', externalDocumentNo);
    RealmObjectBase.set(this, 'amount_to_apply', amountToApply);
    RealmObjectBase.set(this, 'amount_to_apply_lcy', amountToApplyLcy);
    RealmObjectBase.set(this, 'amount_to_discount_lcy', amountToDiscountLcy);
    RealmObjectBase.set(this, 'amount_to_discount', amountToDiscount);
    RealmObjectBase.set(this, 'discount', discount);
    RealmObjectBase.set(this, 'discount_lcy', discountLcy);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'amount_lcy', amountLcy);
    RealmObjectBase.set(this, 'remaining_amount', remainingAmount);
    RealmObjectBase.set(this, 'remaining_amount_lcy', remainingAmountLcy);
    RealmObjectBase.set(this, 'bal_account_type', balAccountType);
    RealmObjectBase.set(this, 'bal_account_no', balAccountNo);
    RealmObjectBase.set(this, 'reversed', reversed);
    RealmObjectBase.set(this, 'reversed_by_entry_no', reversedByEntryNo);
    RealmObjectBase.set(this, 'reversed_entry_no', reversedEntryNo);
    RealmObjectBase.set(this, 'adjustment', adjustment);
    RealmObjectBase.set(this, 'order_no', orderNo);
    RealmObjectBase.set(this, 'order_type', orderType);
    RealmObjectBase.set(this, 'source_type', sourceType);
    RealmObjectBase.set(this, 'source_no', sourceNo);
    RealmObjectBase.set(this, 'special_type', specialType);
    RealmObjectBase.set(this, 'special_type_no', specialTypeNo);
    RealmObjectBase.set(this, 'posting_datetime', postingDatetime);
    RealmObjectBase.set(this, 'payment_method_code', paymentMethodCode);
    RealmObjectBase.set(this, 'customer_address', customerAddress);
    RealmObjectBase.set(this, 'is_collection', isCollection);
    RealmObjectBase.set(this, 'index', index);
    RealmObjectBase.set(this, 'over_aging', overAging);
  }

  CustomerLedgerEntry._();

  @override
  String get entryNo => RealmObjectBase.get<String>(this, 'entry_no') as String;
  @override
  set entryNo(String value) => RealmObjectBase.set(this, 'entry_no', value);

  @override
  String? get customerName =>
      RealmObjectBase.get<String>(this, 'customer_name') as String?;
  @override
  set customerName(String? value) =>
      RealmObjectBase.set(this, 'customer_name', value);

  @override
  String? get customerName2 =>
      RealmObjectBase.get<String>(this, 'customer_name_2') as String?;
  @override
  set customerName2(String? value) =>
      RealmObjectBase.set(this, 'customer_name_2', value);

  @override
  String? get postingDate =>
      RealmObjectBase.get<String>(this, 'posting_date') as String?;
  @override
  set postingDate(String? value) =>
      RealmObjectBase.set(this, 'posting_date', value);

  @override
  String? get postingDescription =>
      RealmObjectBase.get<String>(this, 'posting_description') as String?;
  @override
  set postingDescription(String? value) =>
      RealmObjectBase.set(this, 'posting_description', value);

  @override
  String? get documentDate =>
      RealmObjectBase.get<String>(this, 'document_date') as String?;
  @override
  set documentDate(String? value) =>
      RealmObjectBase.set(this, 'document_date', value);

  @override
  String? get documentType =>
      RealmObjectBase.get<String>(this, 'document_type') as String?;
  @override
  set documentType(String? value) =>
      RealmObjectBase.set(this, 'document_type', value);

  @override
  String? get documentNo =>
      RealmObjectBase.get<String>(this, 'document_no') as String?;
  @override
  set documentNo(String? value) =>
      RealmObjectBase.set(this, 'document_no', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currency_code') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currency_code', value);

  @override
  double? get currencyFactor =>
      RealmObjectBase.get<double>(this, 'currency_factor') as double?;
  @override
  set currencyFactor(double? value) =>
      RealmObjectBase.set(this, 'currency_factor', value);

  @override
  String? get arPostingGroup =>
      RealmObjectBase.get<String>(this, 'ar_posting_group') as String?;
  @override
  set arPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'ar_posting_group', value);

  @override
  String? get salespersonCode =>
      RealmObjectBase.get<String>(this, 'salesperson_code') as String?;
  @override
  set salespersonCode(String? value) =>
      RealmObjectBase.set(this, 'salesperson_code', value);

  @override
  String? get distributorCode =>
      RealmObjectBase.get<String>(this, 'distributor_code') as String?;
  @override
  set distributorCode(String? value) =>
      RealmObjectBase.set(this, 'distributor_code', value);

  @override
  String? get storeCode =>
      RealmObjectBase.get<String>(this, 'store_code') as String?;
  @override
  set storeCode(String? value) =>
      RealmObjectBase.set(this, 'store_code', value);

  @override
  String? get divisionCode =>
      RealmObjectBase.get<String>(this, 'division_code') as String?;
  @override
  set divisionCode(String? value) =>
      RealmObjectBase.set(this, 'division_code', value);

  @override
  String? get businessUnitCode =>
      RealmObjectBase.get<String>(this, 'business_unit_code') as String?;
  @override
  set businessUnitCode(String? value) =>
      RealmObjectBase.set(this, 'business_unit_code', value);

  @override
  String? get departmentCode =>
      RealmObjectBase.get<String>(this, 'department_code') as String?;
  @override
  set departmentCode(String? value) =>
      RealmObjectBase.set(this, 'department_code', value);

  @override
  String? get territoryCode =>
      RealmObjectBase.get<String>(this, 'territory_code') as String?;
  @override
  set territoryCode(String? value) =>
      RealmObjectBase.set(this, 'territory_code', value);

  @override
  String? get projectCode =>
      RealmObjectBase.get<String>(this, 'project_code') as String?;
  @override
  set projectCode(String? value) =>
      RealmObjectBase.set(this, 'project_code', value);

  @override
  String? get budgetCode =>
      RealmObjectBase.get<String>(this, 'budget_code') as String?;
  @override
  set budgetCode(String? value) =>
      RealmObjectBase.set(this, 'budget_code', value);

  @override
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

  @override
  String? get customerGroupCode =>
      RealmObjectBase.get<String>(this, 'customer_group_code') as String?;
  @override
  set customerGroupCode(String? value) =>
      RealmObjectBase.set(this, 'customer_group_code', value);

  @override
  String? get appliesToDocType =>
      RealmObjectBase.get<String>(this, 'applies_to_doc_type') as String?;
  @override
  set appliesToDocType(String? value) =>
      RealmObjectBase.set(this, 'applies_to_doc_type', value);

  @override
  String? get appliesToDocNo =>
      RealmObjectBase.get<String>(this, 'applies_to_doc_no') as String?;
  @override
  set appliesToDocNo(String? value) =>
      RealmObjectBase.set(this, 'applies_to_doc_no', value);

  @override
  String? get dueDate =>
      RealmObjectBase.get<String>(this, 'due_date') as String?;
  @override
  set dueDate(String? value) => RealmObjectBase.set(this, 'due_date', value);

  @override
  String? get pmtDiscountDate =>
      RealmObjectBase.get<String>(this, 'pmt_discount_date') as String?;
  @override
  set pmtDiscountDate(String? value) =>
      RealmObjectBase.set(this, 'pmt_discount_date', value);

  @override
  double? get pmtDiscountPercentage =>
      RealmObjectBase.get<double>(this, 'pmt_discount_percentage') as double?;
  @override
  set pmtDiscountPercentage(double? value) =>
      RealmObjectBase.set(this, 'pmt_discount_percentage', value);

  @override
  double? get pmtDiscountAmount =>
      RealmObjectBase.get<double>(this, 'pmt_discount_amount') as double?;
  @override
  set pmtDiscountAmount(double? value) =>
      RealmObjectBase.set(this, 'pmt_discount_amount', value);

  @override
  String? get appliesToId =>
      RealmObjectBase.get<String>(this, 'applies_to_id') as String?;
  @override
  set appliesToId(String? value) =>
      RealmObjectBase.set(this, 'applies_to_id', value);

  @override
  String? get journalBatchName =>
      RealmObjectBase.get<String>(this, 'journal_batch_name') as String?;
  @override
  set journalBatchName(String? value) =>
      RealmObjectBase.set(this, 'journal_batch_name', value);

  @override
  String? get externalDocumentNo =>
      RealmObjectBase.get<String>(this, 'external_document_no') as String?;
  @override
  set externalDocumentNo(String? value) =>
      RealmObjectBase.set(this, 'external_document_no', value);

  @override
  double? get amountToApply =>
      RealmObjectBase.get<double>(this, 'amount_to_apply') as double?;
  @override
  set amountToApply(double? value) =>
      RealmObjectBase.set(this, 'amount_to_apply', value);

  @override
  double? get amountToApplyLcy =>
      RealmObjectBase.get<double>(this, 'amount_to_apply_lcy') as double?;
  @override
  set amountToApplyLcy(double? value) =>
      RealmObjectBase.set(this, 'amount_to_apply_lcy', value);

  @override
  double? get amountToDiscountLcy =>
      RealmObjectBase.get<double>(this, 'amount_to_discount_lcy') as double?;
  @override
  set amountToDiscountLcy(double? value) =>
      RealmObjectBase.set(this, 'amount_to_discount_lcy', value);

  @override
  double? get amountToDiscount =>
      RealmObjectBase.get<double>(this, 'amount_to_discount') as double?;
  @override
  set amountToDiscount(double? value) =>
      RealmObjectBase.set(this, 'amount_to_discount', value);

  @override
  double? get discount =>
      RealmObjectBase.get<double>(this, 'discount') as double?;
  @override
  set discount(double? value) => RealmObjectBase.set(this, 'discount', value);

  @override
  double? get discountLcy =>
      RealmObjectBase.get<double>(this, 'discount_lcy') as double?;
  @override
  set discountLcy(double? value) =>
      RealmObjectBase.set(this, 'discount_lcy', value);

  @override
  double? get amount => RealmObjectBase.get<double>(this, 'amount') as double?;
  @override
  set amount(double? value) => RealmObjectBase.set(this, 'amount', value);

  @override
  double? get amountLcy =>
      RealmObjectBase.get<double>(this, 'amount_lcy') as double?;
  @override
  set amountLcy(double? value) =>
      RealmObjectBase.set(this, 'amount_lcy', value);

  @override
  double? get remainingAmount =>
      RealmObjectBase.get<double>(this, 'remaining_amount') as double?;
  @override
  set remainingAmount(double? value) =>
      RealmObjectBase.set(this, 'remaining_amount', value);

  @override
  double? get remainingAmountLcy =>
      RealmObjectBase.get<double>(this, 'remaining_amount_lcy') as double?;
  @override
  set remainingAmountLcy(double? value) =>
      RealmObjectBase.set(this, 'remaining_amount_lcy', value);

  @override
  String? get balAccountType =>
      RealmObjectBase.get<String>(this, 'bal_account_type') as String?;
  @override
  set balAccountType(String? value) =>
      RealmObjectBase.set(this, 'bal_account_type', value);

  @override
  String? get balAccountNo =>
      RealmObjectBase.get<String>(this, 'bal_account_no') as String?;
  @override
  set balAccountNo(String? value) =>
      RealmObjectBase.set(this, 'bal_account_no', value);

  @override
  String? get reversed =>
      RealmObjectBase.get<String>(this, 'reversed') as String?;
  @override
  set reversed(String? value) => RealmObjectBase.set(this, 'reversed', value);

  @override
  String? get reversedByEntryNo =>
      RealmObjectBase.get<String>(this, 'reversed_by_entry_no') as String?;
  @override
  set reversedByEntryNo(String? value) =>
      RealmObjectBase.set(this, 'reversed_by_entry_no', value);

  @override
  String? get reversedEntryNo =>
      RealmObjectBase.get<String>(this, 'reversed_entry_no') as String?;
  @override
  set reversedEntryNo(String? value) =>
      RealmObjectBase.set(this, 'reversed_entry_no', value);

  @override
  String? get adjustment =>
      RealmObjectBase.get<String>(this, 'adjustment') as String?;
  @override
  set adjustment(String? value) =>
      RealmObjectBase.set(this, 'adjustment', value);

  @override
  String? get orderNo =>
      RealmObjectBase.get<String>(this, 'order_no') as String?;
  @override
  set orderNo(String? value) => RealmObjectBase.set(this, 'order_no', value);

  @override
  String? get orderType =>
      RealmObjectBase.get<String>(this, 'order_type') as String?;
  @override
  set orderType(String? value) =>
      RealmObjectBase.set(this, 'order_type', value);

  @override
  String? get sourceType =>
      RealmObjectBase.get<String>(this, 'source_type') as String?;
  @override
  set sourceType(String? value) =>
      RealmObjectBase.set(this, 'source_type', value);

  @override
  String? get sourceNo =>
      RealmObjectBase.get<String>(this, 'source_no') as String?;
  @override
  set sourceNo(String? value) => RealmObjectBase.set(this, 'source_no', value);

  @override
  String? get specialType =>
      RealmObjectBase.get<String>(this, 'special_type') as String?;
  @override
  set specialType(String? value) =>
      RealmObjectBase.set(this, 'special_type', value);

  @override
  String? get specialTypeNo =>
      RealmObjectBase.get<String>(this, 'special_type_no') as String?;
  @override
  set specialTypeNo(String? value) =>
      RealmObjectBase.set(this, 'special_type_no', value);

  @override
  String? get postingDatetime =>
      RealmObjectBase.get<String>(this, 'posting_datetime') as String?;
  @override
  set postingDatetime(String? value) =>
      RealmObjectBase.set(this, 'posting_datetime', value);

  @override
  String? get paymentMethodCode =>
      RealmObjectBase.get<String>(this, 'payment_method_code') as String?;
  @override
  set paymentMethodCode(String? value) =>
      RealmObjectBase.set(this, 'payment_method_code', value);

  @override
  String? get customerAddress =>
      RealmObjectBase.get<String>(this, 'customer_address') as String?;
  @override
  set customerAddress(String? value) =>
      RealmObjectBase.set(this, 'customer_address', value);

  @override
  String? get isCollection =>
      RealmObjectBase.get<String>(this, 'is_collection') as String?;
  @override
  set isCollection(String? value) =>
      RealmObjectBase.set(this, 'is_collection', value);

  @override
  String? get index => RealmObjectBase.get<String>(this, 'index') as String?;
  @override
  set index(String? value) => RealmObjectBase.set(this, 'index', value);

  @override
  String? get overAging =>
      RealmObjectBase.get<String>(this, 'over_aging') as String?;
  @override
  set overAging(String? value) =>
      RealmObjectBase.set(this, 'over_aging', value);

  @override
  Stream<RealmObjectChanges<CustomerLedgerEntry>> get changes =>
      RealmObjectBase.getChanges<CustomerLedgerEntry>(this);

  @override
  Stream<RealmObjectChanges<CustomerLedgerEntry>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CustomerLedgerEntry>(this, keyPaths);

  @override
  CustomerLedgerEntry freeze() =>
      RealmObjectBase.freezeObject<CustomerLedgerEntry>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'entry_no': entryNo.toEJson(),
      'customer_name': customerName.toEJson(),
      'customer_name_2': customerName2.toEJson(),
      'posting_date': postingDate.toEJson(),
      'posting_description': postingDescription.toEJson(),
      'document_date': documentDate.toEJson(),
      'document_type': documentType.toEJson(),
      'document_no': documentNo.toEJson(),
      'description': description.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'currency_factor': currencyFactor.toEJson(),
      'ar_posting_group': arPostingGroup.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'store_code': storeCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'territory_code': territoryCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'budget_code': budgetCode.toEJson(),
      'customer_no': customerNo.toEJson(),
      'customer_group_code': customerGroupCode.toEJson(),
      'applies_to_doc_type': appliesToDocType.toEJson(),
      'applies_to_doc_no': appliesToDocNo.toEJson(),
      'due_date': dueDate.toEJson(),
      'pmt_discount_date': pmtDiscountDate.toEJson(),
      'pmt_discount_percentage': pmtDiscountPercentage.toEJson(),
      'pmt_discount_amount': pmtDiscountAmount.toEJson(),
      'applies_to_id': appliesToId.toEJson(),
      'journal_batch_name': journalBatchName.toEJson(),
      'external_document_no': externalDocumentNo.toEJson(),
      'amount_to_apply': amountToApply.toEJson(),
      'amount_to_apply_lcy': amountToApplyLcy.toEJson(),
      'amount_to_discount_lcy': amountToDiscountLcy.toEJson(),
      'amount_to_discount': amountToDiscount.toEJson(),
      'discount': discount.toEJson(),
      'discount_lcy': discountLcy.toEJson(),
      'amount': amount.toEJson(),
      'amount_lcy': amountLcy.toEJson(),
      'remaining_amount': remainingAmount.toEJson(),
      'remaining_amount_lcy': remainingAmountLcy.toEJson(),
      'bal_account_type': balAccountType.toEJson(),
      'bal_account_no': balAccountNo.toEJson(),
      'reversed': reversed.toEJson(),
      'reversed_by_entry_no': reversedByEntryNo.toEJson(),
      'reversed_entry_no': reversedEntryNo.toEJson(),
      'adjustment': adjustment.toEJson(),
      'order_no': orderNo.toEJson(),
      'order_type': orderType.toEJson(),
      'source_type': sourceType.toEJson(),
      'source_no': sourceNo.toEJson(),
      'special_type': specialType.toEJson(),
      'special_type_no': specialTypeNo.toEJson(),
      'posting_datetime': postingDatetime.toEJson(),
      'payment_method_code': paymentMethodCode.toEJson(),
      'customer_address': customerAddress.toEJson(),
      'is_collection': isCollection.toEJson(),
      'index': index.toEJson(),
      'over_aging': overAging.toEJson(),
    };
  }

  static EJsonValue _toEJson(CustomerLedgerEntry value) => value.toEJson();
  static CustomerLedgerEntry _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'entry_no': EJsonValue entryNo} => CustomerLedgerEntry(
        fromEJson(entryNo),
        customerName: fromEJson(ejson['customer_name']),
        customerName2: fromEJson(ejson['customer_name_2']),
        postingDate: fromEJson(ejson['posting_date']),
        postingDescription: fromEJson(ejson['posting_description']),
        documentDate: fromEJson(ejson['document_date']),
        documentType: fromEJson(ejson['document_type']),
        documentNo: fromEJson(ejson['document_no']),
        description: fromEJson(ejson['description']),
        currencyCode: fromEJson(ejson['currency_code']),
        currencyFactor: fromEJson(ejson['currency_factor'], defaultValue: 1),
        arPostingGroup: fromEJson(ejson['ar_posting_group']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        distributorCode: fromEJson(ejson['distributor_code']),
        storeCode: fromEJson(ejson['store_code']),
        divisionCode: fromEJson(ejson['division_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        departmentCode: fromEJson(ejson['department_code']),
        territoryCode: fromEJson(ejson['territory_code']),
        projectCode: fromEJson(ejson['project_code']),
        budgetCode: fromEJson(ejson['budget_code']),
        customerNo: fromEJson(ejson['customer_no']),
        customerGroupCode: fromEJson(ejson['customer_group_code']),
        appliesToDocType: fromEJson(ejson['applies_to_doc_type']),
        appliesToDocNo: fromEJson(ejson['applies_to_doc_no']),
        dueDate: fromEJson(ejson['due_date']),
        pmtDiscountDate: fromEJson(ejson['pmt_discount_date']),
        pmtDiscountPercentage: fromEJson(
          ejson['pmt_discount_percentage'],
          defaultValue: 0,
        ),
        pmtDiscountAmount: fromEJson(
          ejson['pmt_discount_amount'],
          defaultValue: 0,
        ),
        appliesToId: fromEJson(ejson['applies_to_id']),
        journalBatchName: fromEJson(ejson['journal_batch_name']),
        externalDocumentNo: fromEJson(ejson['external_document_no']),
        amountToApply: fromEJson(ejson['amount_to_apply'], defaultValue: 0),
        amountToApplyLcy: fromEJson(
          ejson['amount_to_apply_lcy'],
          defaultValue: 0,
        ),
        amountToDiscountLcy: fromEJson(
          ejson['amount_to_discount_lcy'],
          defaultValue: 0,
        ),
        amountToDiscount: fromEJson(
          ejson['amount_to_discount'],
          defaultValue: 0,
        ),
        discount: fromEJson(ejson['discount'], defaultValue: 0),
        discountLcy: fromEJson(ejson['discount_lcy'], defaultValue: 0),
        amount: fromEJson(ejson['amount'], defaultValue: 0),
        amountLcy: fromEJson(ejson['amount_lcy'], defaultValue: 0),
        remainingAmount: fromEJson(ejson['remaining_amount'], defaultValue: 0),
        remainingAmountLcy: fromEJson(
          ejson['remaining_amount_lcy'],
          defaultValue: 0,
        ),
        balAccountType: fromEJson(ejson['bal_account_type']),
        balAccountNo: fromEJson(ejson['bal_account_no']),
        reversed: fromEJson(ejson['reversed']),
        reversedByEntryNo: fromEJson(ejson['reversed_by_entry_no']),
        reversedEntryNo: fromEJson(ejson['reversed_entry_no']),
        adjustment: fromEJson(ejson['adjustment']),
        orderNo: fromEJson(ejson['order_no']),
        orderType: fromEJson(ejson['order_type']),
        sourceType: fromEJson(ejson['source_type']),
        sourceNo: fromEJson(ejson['source_no']),
        specialType: fromEJson(ejson['special_type']),
        specialTypeNo: fromEJson(ejson['special_type_no']),
        postingDatetime: fromEJson(ejson['posting_datetime']),
        paymentMethodCode: fromEJson(ejson['payment_method_code']),
        customerAddress: fromEJson(ejson['customer_address']),
        isCollection: fromEJson(ejson['is_collection']),
        index: fromEJson(ejson['index']),
        overAging: fromEJson(ejson['over_aging']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CustomerLedgerEntry._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CustomerLedgerEntry,
      'CUSTOMER_LEDGER_ENTRY',
      [
        SchemaProperty(
          'entryNo',
          RealmPropertyType.string,
          mapTo: 'entry_no',
          primaryKey: true,
        ),
        SchemaProperty(
          'customerName',
          RealmPropertyType.string,
          mapTo: 'customer_name',
          optional: true,
        ),
        SchemaProperty(
          'customerName2',
          RealmPropertyType.string,
          mapTo: 'customer_name_2',
          optional: true,
        ),
        SchemaProperty(
          'postingDate',
          RealmPropertyType.string,
          mapTo: 'posting_date',
          optional: true,
        ),
        SchemaProperty(
          'postingDescription',
          RealmPropertyType.string,
          mapTo: 'posting_description',
          optional: true,
        ),
        SchemaProperty(
          'documentDate',
          RealmPropertyType.string,
          mapTo: 'document_date',
          optional: true,
        ),
        SchemaProperty(
          'documentType',
          RealmPropertyType.string,
          mapTo: 'document_type',
          optional: true,
        ),
        SchemaProperty(
          'documentNo',
          RealmPropertyType.string,
          mapTo: 'document_no',
          optional: true,
        ),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'currencyCode',
          RealmPropertyType.string,
          mapTo: 'currency_code',
          optional: true,
        ),
        SchemaProperty(
          'currencyFactor',
          RealmPropertyType.double,
          mapTo: 'currency_factor',
          optional: true,
        ),
        SchemaProperty(
          'arPostingGroup',
          RealmPropertyType.string,
          mapTo: 'ar_posting_group',
          optional: true,
        ),
        SchemaProperty(
          'salespersonCode',
          RealmPropertyType.string,
          mapTo: 'salesperson_code',
          optional: true,
        ),
        SchemaProperty(
          'distributorCode',
          RealmPropertyType.string,
          mapTo: 'distributor_code',
          optional: true,
        ),
        SchemaProperty(
          'storeCode',
          RealmPropertyType.string,
          mapTo: 'store_code',
          optional: true,
        ),
        SchemaProperty(
          'divisionCode',
          RealmPropertyType.string,
          mapTo: 'division_code',
          optional: true,
        ),
        SchemaProperty(
          'businessUnitCode',
          RealmPropertyType.string,
          mapTo: 'business_unit_code',
          optional: true,
        ),
        SchemaProperty(
          'departmentCode',
          RealmPropertyType.string,
          mapTo: 'department_code',
          optional: true,
        ),
        SchemaProperty(
          'territoryCode',
          RealmPropertyType.string,
          mapTo: 'territory_code',
          optional: true,
        ),
        SchemaProperty(
          'projectCode',
          RealmPropertyType.string,
          mapTo: 'project_code',
          optional: true,
        ),
        SchemaProperty(
          'budgetCode',
          RealmPropertyType.string,
          mapTo: 'budget_code',
          optional: true,
        ),
        SchemaProperty(
          'customerNo',
          RealmPropertyType.string,
          mapTo: 'customer_no',
          optional: true,
        ),
        SchemaProperty(
          'customerGroupCode',
          RealmPropertyType.string,
          mapTo: 'customer_group_code',
          optional: true,
        ),
        SchemaProperty(
          'appliesToDocType',
          RealmPropertyType.string,
          mapTo: 'applies_to_doc_type',
          optional: true,
        ),
        SchemaProperty(
          'appliesToDocNo',
          RealmPropertyType.string,
          mapTo: 'applies_to_doc_no',
          optional: true,
        ),
        SchemaProperty(
          'dueDate',
          RealmPropertyType.string,
          mapTo: 'due_date',
          optional: true,
        ),
        SchemaProperty(
          'pmtDiscountDate',
          RealmPropertyType.string,
          mapTo: 'pmt_discount_date',
          optional: true,
        ),
        SchemaProperty(
          'pmtDiscountPercentage',
          RealmPropertyType.double,
          mapTo: 'pmt_discount_percentage',
          optional: true,
        ),
        SchemaProperty(
          'pmtDiscountAmount',
          RealmPropertyType.double,
          mapTo: 'pmt_discount_amount',
          optional: true,
        ),
        SchemaProperty(
          'appliesToId',
          RealmPropertyType.string,
          mapTo: 'applies_to_id',
          optional: true,
        ),
        SchemaProperty(
          'journalBatchName',
          RealmPropertyType.string,
          mapTo: 'journal_batch_name',
          optional: true,
        ),
        SchemaProperty(
          'externalDocumentNo',
          RealmPropertyType.string,
          mapTo: 'external_document_no',
          optional: true,
        ),
        SchemaProperty(
          'amountToApply',
          RealmPropertyType.double,
          mapTo: 'amount_to_apply',
          optional: true,
        ),
        SchemaProperty(
          'amountToApplyLcy',
          RealmPropertyType.double,
          mapTo: 'amount_to_apply_lcy',
          optional: true,
        ),
        SchemaProperty(
          'amountToDiscountLcy',
          RealmPropertyType.double,
          mapTo: 'amount_to_discount_lcy',
          optional: true,
        ),
        SchemaProperty(
          'amountToDiscount',
          RealmPropertyType.double,
          mapTo: 'amount_to_discount',
          optional: true,
        ),
        SchemaProperty('discount', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'discountLcy',
          RealmPropertyType.double,
          mapTo: 'discount_lcy',
          optional: true,
        ),
        SchemaProperty('amount', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'amountLcy',
          RealmPropertyType.double,
          mapTo: 'amount_lcy',
          optional: true,
        ),
        SchemaProperty(
          'remainingAmount',
          RealmPropertyType.double,
          mapTo: 'remaining_amount',
          optional: true,
        ),
        SchemaProperty(
          'remainingAmountLcy',
          RealmPropertyType.double,
          mapTo: 'remaining_amount_lcy',
          optional: true,
        ),
        SchemaProperty(
          'balAccountType',
          RealmPropertyType.string,
          mapTo: 'bal_account_type',
          optional: true,
        ),
        SchemaProperty(
          'balAccountNo',
          RealmPropertyType.string,
          mapTo: 'bal_account_no',
          optional: true,
        ),
        SchemaProperty('reversed', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'reversedByEntryNo',
          RealmPropertyType.string,
          mapTo: 'reversed_by_entry_no',
          optional: true,
        ),
        SchemaProperty(
          'reversedEntryNo',
          RealmPropertyType.string,
          mapTo: 'reversed_entry_no',
          optional: true,
        ),
        SchemaProperty('adjustment', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'orderNo',
          RealmPropertyType.string,
          mapTo: 'order_no',
          optional: true,
        ),
        SchemaProperty(
          'orderType',
          RealmPropertyType.string,
          mapTo: 'order_type',
          optional: true,
        ),
        SchemaProperty(
          'sourceType',
          RealmPropertyType.string,
          mapTo: 'source_type',
          optional: true,
        ),
        SchemaProperty(
          'sourceNo',
          RealmPropertyType.string,
          mapTo: 'source_no',
          optional: true,
        ),
        SchemaProperty(
          'specialType',
          RealmPropertyType.string,
          mapTo: 'special_type',
          optional: true,
        ),
        SchemaProperty(
          'specialTypeNo',
          RealmPropertyType.string,
          mapTo: 'special_type_no',
          optional: true,
        ),
        SchemaProperty(
          'postingDatetime',
          RealmPropertyType.string,
          mapTo: 'posting_datetime',
          optional: true,
        ),
        SchemaProperty(
          'paymentMethodCode',
          RealmPropertyType.string,
          mapTo: 'payment_method_code',
          optional: true,
        ),
        SchemaProperty(
          'customerAddress',
          RealmPropertyType.string,
          mapTo: 'customer_address',
          optional: true,
        ),
        SchemaProperty(
          'isCollection',
          RealmPropertyType.string,
          mapTo: 'is_collection',
          optional: true,
        ),
        SchemaProperty('index', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'overAging',
          RealmPropertyType.string,
          mapTo: 'over_aging',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CashReceiptJournals extends _CashReceiptJournals
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  CashReceiptJournals(
    String id, {
    String? journalType,
    String? documentDate,
    String? postingDate,
    String? documentType,
    String? documentNo,
    String? customerNo,
    String? description,
    String? description2,
    String? postingGroup,
    String? paymentMethodCode,
    double? amount = 0,
    double? amountLcy = 0,
    double? discountAmount = 0,
    double? discountAmountLcy = 0,
    String? balAccountType,
    String? balAccountNo,
    String? currencyCode,
    double? currencyFactor = 1,
    String? genBusPostingGroup,
    String? genProdPostingGroup,
    String? noSeries,
    String? externalDocumentNo,
    String? postingDescription,
    String? storeCode,
    String? divisionCode,
    String? businessUnitCode,
    String? departmentCode,
    String? projectCode,
    String? budgetCode,
    String? salespersonCode,
    String? distributorCode,
    String? customerGroupCode,
    String? applyToDocType,
    String? applyToDocNo,
    String? journalBatchName,
    String? assignToUserId,
    String? sourceType,
    String? sourceNo,
    String? status,
    String? appId,
    String? isSync = "Yes",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CashReceiptJournals>({
        'amount': 0,
        'amount_lcy': 0,
        'discount_amount': 0,
        'discount_amount_lcy': 0,
        'currency_factor': 1,
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'journal_type', journalType);
    RealmObjectBase.set(this, 'document_date', documentDate);
    RealmObjectBase.set(this, 'posting_date', postingDate);
    RealmObjectBase.set(this, 'document_type', documentType);
    RealmObjectBase.set(this, 'document_no', documentNo);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'posting_group', postingGroup);
    RealmObjectBase.set(this, 'payment_method_code', paymentMethodCode);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'amount_lcy', amountLcy);
    RealmObjectBase.set(this, 'discount_amount', discountAmount);
    RealmObjectBase.set(this, 'discount_amount_lcy', discountAmountLcy);
    RealmObjectBase.set(this, 'bal_account_type', balAccountType);
    RealmObjectBase.set(this, 'bal_account_no', balAccountNo);
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'currency_factor', currencyFactor);
    RealmObjectBase.set(this, 'gen_bus_posting_group', genBusPostingGroup);
    RealmObjectBase.set(this, 'gen_prod_posting_group', genProdPostingGroup);
    RealmObjectBase.set(this, 'no_series', noSeries);
    RealmObjectBase.set(this, 'external_document_no', externalDocumentNo);
    RealmObjectBase.set(this, 'posting_description', postingDescription);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'budget_code', budgetCode);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'customer_group_code', customerGroupCode);
    RealmObjectBase.set(this, 'apply_to_doc_type', applyToDocType);
    RealmObjectBase.set(this, 'apply_to_doc_no', applyToDocNo);
    RealmObjectBase.set(this, 'journal_batch_name', journalBatchName);
    RealmObjectBase.set(this, 'assign_to_userid', assignToUserId);
    RealmObjectBase.set(this, 'source_type', sourceType);
    RealmObjectBase.set(this, 'source_no', sourceNo);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'app_id', appId);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  CashReceiptJournals._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get journalType =>
      RealmObjectBase.get<String>(this, 'journal_type') as String?;
  @override
  set journalType(String? value) =>
      RealmObjectBase.set(this, 'journal_type', value);

  @override
  String? get documentDate =>
      RealmObjectBase.get<String>(this, 'document_date') as String?;
  @override
  set documentDate(String? value) =>
      RealmObjectBase.set(this, 'document_date', value);

  @override
  String? get postingDate =>
      RealmObjectBase.get<String>(this, 'posting_date') as String?;
  @override
  set postingDate(String? value) =>
      RealmObjectBase.set(this, 'posting_date', value);

  @override
  String? get documentType =>
      RealmObjectBase.get<String>(this, 'document_type') as String?;
  @override
  set documentType(String? value) =>
      RealmObjectBase.set(this, 'document_type', value);

  @override
  String? get documentNo =>
      RealmObjectBase.get<String>(this, 'document_no') as String?;
  @override
  set documentNo(String? value) =>
      RealmObjectBase.set(this, 'document_no', value);

  @override
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

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
  String? get postingGroup =>
      RealmObjectBase.get<String>(this, 'posting_group') as String?;
  @override
  set postingGroup(String? value) =>
      RealmObjectBase.set(this, 'posting_group', value);

  @override
  String? get paymentMethodCode =>
      RealmObjectBase.get<String>(this, 'payment_method_code') as String?;
  @override
  set paymentMethodCode(String? value) =>
      RealmObjectBase.set(this, 'payment_method_code', value);

  @override
  double? get amount => RealmObjectBase.get<double>(this, 'amount') as double?;
  @override
  set amount(double? value) => RealmObjectBase.set(this, 'amount', value);

  @override
  double? get amountLcy =>
      RealmObjectBase.get<double>(this, 'amount_lcy') as double?;
  @override
  set amountLcy(double? value) =>
      RealmObjectBase.set(this, 'amount_lcy', value);

  @override
  double? get discountAmount =>
      RealmObjectBase.get<double>(this, 'discount_amount') as double?;
  @override
  set discountAmount(double? value) =>
      RealmObjectBase.set(this, 'discount_amount', value);

  @override
  double? get discountAmountLcy =>
      RealmObjectBase.get<double>(this, 'discount_amount_lcy') as double?;
  @override
  set discountAmountLcy(double? value) =>
      RealmObjectBase.set(this, 'discount_amount_lcy', value);

  @override
  String? get balAccountType =>
      RealmObjectBase.get<String>(this, 'bal_account_type') as String?;
  @override
  set balAccountType(String? value) =>
      RealmObjectBase.set(this, 'bal_account_type', value);

  @override
  String? get balAccountNo =>
      RealmObjectBase.get<String>(this, 'bal_account_no') as String?;
  @override
  set balAccountNo(String? value) =>
      RealmObjectBase.set(this, 'bal_account_no', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currency_code') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currency_code', value);

  @override
  double? get currencyFactor =>
      RealmObjectBase.get<double>(this, 'currency_factor') as double?;
  @override
  set currencyFactor(double? value) =>
      RealmObjectBase.set(this, 'currency_factor', value);

  @override
  String? get genBusPostingGroup =>
      RealmObjectBase.get<String>(this, 'gen_bus_posting_group') as String?;
  @override
  set genBusPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'gen_bus_posting_group', value);

  @override
  String? get genProdPostingGroup =>
      RealmObjectBase.get<String>(this, 'gen_prod_posting_group') as String?;
  @override
  set genProdPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'gen_prod_posting_group', value);

  @override
  String? get noSeries =>
      RealmObjectBase.get<String>(this, 'no_series') as String?;
  @override
  set noSeries(String? value) => RealmObjectBase.set(this, 'no_series', value);

  @override
  String? get externalDocumentNo =>
      RealmObjectBase.get<String>(this, 'external_document_no') as String?;
  @override
  set externalDocumentNo(String? value) =>
      RealmObjectBase.set(this, 'external_document_no', value);

  @override
  String? get postingDescription =>
      RealmObjectBase.get<String>(this, 'posting_description') as String?;
  @override
  set postingDescription(String? value) =>
      RealmObjectBase.set(this, 'posting_description', value);

  @override
  String? get storeCode =>
      RealmObjectBase.get<String>(this, 'store_code') as String?;
  @override
  set storeCode(String? value) =>
      RealmObjectBase.set(this, 'store_code', value);

  @override
  String? get divisionCode =>
      RealmObjectBase.get<String>(this, 'division_code') as String?;
  @override
  set divisionCode(String? value) =>
      RealmObjectBase.set(this, 'division_code', value);

  @override
  String? get businessUnitCode =>
      RealmObjectBase.get<String>(this, 'business_unit_code') as String?;
  @override
  set businessUnitCode(String? value) =>
      RealmObjectBase.set(this, 'business_unit_code', value);

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
  String? get budgetCode =>
      RealmObjectBase.get<String>(this, 'budget_code') as String?;
  @override
  set budgetCode(String? value) =>
      RealmObjectBase.set(this, 'budget_code', value);

  @override
  String? get salespersonCode =>
      RealmObjectBase.get<String>(this, 'salesperson_code') as String?;
  @override
  set salespersonCode(String? value) =>
      RealmObjectBase.set(this, 'salesperson_code', value);

  @override
  String? get distributorCode =>
      RealmObjectBase.get<String>(this, 'distributor_code') as String?;
  @override
  set distributorCode(String? value) =>
      RealmObjectBase.set(this, 'distributor_code', value);

  @override
  String? get customerGroupCode =>
      RealmObjectBase.get<String>(this, 'customer_group_code') as String?;
  @override
  set customerGroupCode(String? value) =>
      RealmObjectBase.set(this, 'customer_group_code', value);

  @override
  String? get applyToDocType =>
      RealmObjectBase.get<String>(this, 'apply_to_doc_type') as String?;
  @override
  set applyToDocType(String? value) =>
      RealmObjectBase.set(this, 'apply_to_doc_type', value);

  @override
  String? get applyToDocNo =>
      RealmObjectBase.get<String>(this, 'apply_to_doc_no') as String?;
  @override
  set applyToDocNo(String? value) =>
      RealmObjectBase.set(this, 'apply_to_doc_no', value);

  @override
  String? get journalBatchName =>
      RealmObjectBase.get<String>(this, 'journal_batch_name') as String?;
  @override
  set journalBatchName(String? value) =>
      RealmObjectBase.set(this, 'journal_batch_name', value);

  @override
  String? get assignToUserId =>
      RealmObjectBase.get<String>(this, 'assign_to_userid') as String?;
  @override
  set assignToUserId(String? value) =>
      RealmObjectBase.set(this, 'assign_to_userid', value);

  @override
  String? get sourceType =>
      RealmObjectBase.get<String>(this, 'source_type') as String?;
  @override
  set sourceType(String? value) =>
      RealmObjectBase.set(this, 'source_type', value);

  @override
  String? get sourceNo =>
      RealmObjectBase.get<String>(this, 'source_no') as String?;
  @override
  set sourceNo(String? value) => RealmObjectBase.set(this, 'source_no', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get appId => RealmObjectBase.get<String>(this, 'app_id') as String?;
  @override
  set appId(String? value) => RealmObjectBase.set(this, 'app_id', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<CashReceiptJournals>> get changes =>
      RealmObjectBase.getChanges<CashReceiptJournals>(this);

  @override
  Stream<RealmObjectChanges<CashReceiptJournals>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CashReceiptJournals>(this, keyPaths);

  @override
  CashReceiptJournals freeze() =>
      RealmObjectBase.freezeObject<CashReceiptJournals>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'journal_type': journalType.toEJson(),
      'document_date': documentDate.toEJson(),
      'posting_date': postingDate.toEJson(),
      'document_type': documentType.toEJson(),
      'document_no': documentNo.toEJson(),
      'customer_no': customerNo.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'posting_group': postingGroup.toEJson(),
      'payment_method_code': paymentMethodCode.toEJson(),
      'amount': amount.toEJson(),
      'amount_lcy': amountLcy.toEJson(),
      'discount_amount': discountAmount.toEJson(),
      'discount_amount_lcy': discountAmountLcy.toEJson(),
      'bal_account_type': balAccountType.toEJson(),
      'bal_account_no': balAccountNo.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'currency_factor': currencyFactor.toEJson(),
      'gen_bus_posting_group': genBusPostingGroup.toEJson(),
      'gen_prod_posting_group': genProdPostingGroup.toEJson(),
      'no_series': noSeries.toEJson(),
      'external_document_no': externalDocumentNo.toEJson(),
      'posting_description': postingDescription.toEJson(),
      'store_code': storeCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'budget_code': budgetCode.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'customer_group_code': customerGroupCode.toEJson(),
      'apply_to_doc_type': applyToDocType.toEJson(),
      'apply_to_doc_no': applyToDocNo.toEJson(),
      'journal_batch_name': journalBatchName.toEJson(),
      'assign_to_userid': assignToUserId.toEJson(),
      'source_type': sourceType.toEJson(),
      'source_no': sourceNo.toEJson(),
      'status': status.toEJson(),
      'app_id': appId.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(CashReceiptJournals value) => value.toEJson();
  static CashReceiptJournals _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => CashReceiptJournals(
        fromEJson(id),
        journalType: fromEJson(ejson['journal_type']),
        documentDate: fromEJson(ejson['document_date']),
        postingDate: fromEJson(ejson['posting_date']),
        documentType: fromEJson(ejson['document_type']),
        documentNo: fromEJson(ejson['document_no']),
        customerNo: fromEJson(ejson['customer_no']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        postingGroup: fromEJson(ejson['posting_group']),
        paymentMethodCode: fromEJson(ejson['payment_method_code']),
        amount: fromEJson(ejson['amount'], defaultValue: 0),
        amountLcy: fromEJson(ejson['amount_lcy'], defaultValue: 0),
        discountAmount: fromEJson(ejson['discount_amount'], defaultValue: 0),
        discountAmountLcy: fromEJson(
          ejson['discount_amount_lcy'],
          defaultValue: 0,
        ),
        balAccountType: fromEJson(ejson['bal_account_type']),
        balAccountNo: fromEJson(ejson['bal_account_no']),
        currencyCode: fromEJson(ejson['currency_code']),
        currencyFactor: fromEJson(ejson['currency_factor'], defaultValue: 1),
        genBusPostingGroup: fromEJson(ejson['gen_bus_posting_group']),
        genProdPostingGroup: fromEJson(ejson['gen_prod_posting_group']),
        noSeries: fromEJson(ejson['no_series']),
        externalDocumentNo: fromEJson(ejson['external_document_no']),
        postingDescription: fromEJson(ejson['posting_description']),
        storeCode: fromEJson(ejson['store_code']),
        divisionCode: fromEJson(ejson['division_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        departmentCode: fromEJson(ejson['department_code']),
        projectCode: fromEJson(ejson['project_code']),
        budgetCode: fromEJson(ejson['budget_code']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        distributorCode: fromEJson(ejson['distributor_code']),
        customerGroupCode: fromEJson(ejson['customer_group_code']),
        applyToDocType: fromEJson(ejson['apply_to_doc_type']),
        applyToDocNo: fromEJson(ejson['apply_to_doc_no']),
        journalBatchName: fromEJson(ejson['journal_batch_name']),
        assignToUserId: fromEJson(ejson['assign_to_userid']),
        sourceType: fromEJson(ejson['source_type']),
        sourceNo: fromEJson(ejson['source_no']),
        status: fromEJson(ejson['status']),
        appId: fromEJson(ejson['app_id']),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CashReceiptJournals._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CashReceiptJournals,
      'CASH_RECEIPT_JOURNALS',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty(
          'journalType',
          RealmPropertyType.string,
          mapTo: 'journal_type',
          optional: true,
        ),
        SchemaProperty(
          'documentDate',
          RealmPropertyType.string,
          mapTo: 'document_date',
          optional: true,
        ),
        SchemaProperty(
          'postingDate',
          RealmPropertyType.string,
          mapTo: 'posting_date',
          optional: true,
        ),
        SchemaProperty(
          'documentType',
          RealmPropertyType.string,
          mapTo: 'document_type',
          optional: true,
        ),
        SchemaProperty(
          'documentNo',
          RealmPropertyType.string,
          mapTo: 'document_no',
          optional: true,
        ),
        SchemaProperty(
          'customerNo',
          RealmPropertyType.string,
          mapTo: 'customer_no',
          optional: true,
        ),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty(
          'postingGroup',
          RealmPropertyType.string,
          mapTo: 'posting_group',
          optional: true,
        ),
        SchemaProperty(
          'paymentMethodCode',
          RealmPropertyType.string,
          mapTo: 'payment_method_code',
          optional: true,
        ),
        SchemaProperty('amount', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'amountLcy',
          RealmPropertyType.double,
          mapTo: 'amount_lcy',
          optional: true,
        ),
        SchemaProperty(
          'discountAmount',
          RealmPropertyType.double,
          mapTo: 'discount_amount',
          optional: true,
        ),
        SchemaProperty(
          'discountAmountLcy',
          RealmPropertyType.double,
          mapTo: 'discount_amount_lcy',
          optional: true,
        ),
        SchemaProperty(
          'balAccountType',
          RealmPropertyType.string,
          mapTo: 'bal_account_type',
          optional: true,
        ),
        SchemaProperty(
          'balAccountNo',
          RealmPropertyType.string,
          mapTo: 'bal_account_no',
          optional: true,
        ),
        SchemaProperty(
          'currencyCode',
          RealmPropertyType.string,
          mapTo: 'currency_code',
          optional: true,
        ),
        SchemaProperty(
          'currencyFactor',
          RealmPropertyType.double,
          mapTo: 'currency_factor',
          optional: true,
        ),
        SchemaProperty(
          'genBusPostingGroup',
          RealmPropertyType.string,
          mapTo: 'gen_bus_posting_group',
          optional: true,
        ),
        SchemaProperty(
          'genProdPostingGroup',
          RealmPropertyType.string,
          mapTo: 'gen_prod_posting_group',
          optional: true,
        ),
        SchemaProperty(
          'noSeries',
          RealmPropertyType.string,
          mapTo: 'no_series',
          optional: true,
        ),
        SchemaProperty(
          'externalDocumentNo',
          RealmPropertyType.string,
          mapTo: 'external_document_no',
          optional: true,
        ),
        SchemaProperty(
          'postingDescription',
          RealmPropertyType.string,
          mapTo: 'posting_description',
          optional: true,
        ),
        SchemaProperty(
          'storeCode',
          RealmPropertyType.string,
          mapTo: 'store_code',
          optional: true,
        ),
        SchemaProperty(
          'divisionCode',
          RealmPropertyType.string,
          mapTo: 'division_code',
          optional: true,
        ),
        SchemaProperty(
          'businessUnitCode',
          RealmPropertyType.string,
          mapTo: 'business_unit_code',
          optional: true,
        ),
        SchemaProperty(
          'departmentCode',
          RealmPropertyType.string,
          mapTo: 'department_code',
          optional: true,
        ),
        SchemaProperty(
          'projectCode',
          RealmPropertyType.string,
          mapTo: 'project_code',
          optional: true,
        ),
        SchemaProperty(
          'budgetCode',
          RealmPropertyType.string,
          mapTo: 'budget_code',
          optional: true,
        ),
        SchemaProperty(
          'salespersonCode',
          RealmPropertyType.string,
          mapTo: 'salesperson_code',
          optional: true,
        ),
        SchemaProperty(
          'distributorCode',
          RealmPropertyType.string,
          mapTo: 'distributor_code',
          optional: true,
        ),
        SchemaProperty(
          'customerGroupCode',
          RealmPropertyType.string,
          mapTo: 'customer_group_code',
          optional: true,
        ),
        SchemaProperty(
          'applyToDocType',
          RealmPropertyType.string,
          mapTo: 'apply_to_doc_type',
          optional: true,
        ),
        SchemaProperty(
          'applyToDocNo',
          RealmPropertyType.string,
          mapTo: 'apply_to_doc_no',
          optional: true,
        ),
        SchemaProperty(
          'journalBatchName',
          RealmPropertyType.string,
          mapTo: 'journal_batch_name',
          optional: true,
        ),
        SchemaProperty(
          'assignToUserId',
          RealmPropertyType.string,
          mapTo: 'assign_to_userid',
          optional: true,
        ),
        SchemaProperty(
          'sourceType',
          RealmPropertyType.string,
          mapTo: 'source_type',
          optional: true,
        ),
        SchemaProperty(
          'sourceNo',
          RealmPropertyType.string,
          mapTo: 'source_no',
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'appId',
          RealmPropertyType.string,
          mapTo: 'app_id',
          optional: true,
        ),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
