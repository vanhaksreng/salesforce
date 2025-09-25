// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class PosSalesHeader extends _PosSalesHeader
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  PosSalesHeader(
    int id, {
    String? documentType,
    String? no,
    String? customerNo,
    String? customerName,
    String? customerName2,
    String? address,
    String? address2,
    String? locationCode,
    String? shipToCode,
    String? shipToName,
    String? shipToName2,
    String? shipToAddress,
    String? shipToAddress2,
    String? shipToContactName,
    String? shipToPhoneNo,
    String? shipToPhoneNo2,
    String? documentDate,
    String? postingDate,
    String? requestShipmentDate,
    String? postingDescription,
    String? paymentTermCode,
    String? paymentMethodCode,
    String? shipmentMethodCode,
    String? shipmentAgentCode,
    String? arPostingGroupCode,
    String? genBusPostingGroupCode,
    String? vatBusPostingGroupCode,
    String? currencyCode,
    double? currencyFactor,
    String? priceIncludeVat,
    String? salespersonCode,
    String? distributorCode,
    String? storeCode,
    String? divisionCode,
    String? businessUnitCode,
    String? departmentCode,
    String? projectCode,
    String? customerGroupCode,
    String? externalDocumentNo,
    String? sourceType,
    String? sourceNo,
    String? returnReasonCode,
    String? reasonCode,
    String? assignToUserId,
    String? status,
    String? remark,
    double? amount,
    String isSync = "Yes",
    String? orderDate,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<PosSalesHeader>({
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'document_type', documentType);
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'customer_name', customerName);
    RealmObjectBase.set(this, 'customer_name_2', customerName2);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'location_code', locationCode);
    RealmObjectBase.set(this, 'ship_to_code', shipToCode);
    RealmObjectBase.set(this, 'ship_to_name', shipToName);
    RealmObjectBase.set(this, 'ship_to_name_2', shipToName2);
    RealmObjectBase.set(this, 'ship_to_address', shipToAddress);
    RealmObjectBase.set(this, 'ship_to_address_2', shipToAddress2);
    RealmObjectBase.set(this, 'ship_to_contact_name', shipToContactName);
    RealmObjectBase.set(this, 'ship_to_phone_no', shipToPhoneNo);
    RealmObjectBase.set(this, 'ship_to_phone_no_2', shipToPhoneNo2);
    RealmObjectBase.set(this, 'document_date', documentDate);
    RealmObjectBase.set(this, 'posting_date', postingDate);
    RealmObjectBase.set(this, 'request_shipment_date', requestShipmentDate);
    RealmObjectBase.set(this, 'posting_description', postingDescription);
    RealmObjectBase.set(this, 'payment_term_code', paymentTermCode);
    RealmObjectBase.set(this, 'payment_method_code', paymentMethodCode);
    RealmObjectBase.set(this, 'shipment_method_code', shipmentMethodCode);
    RealmObjectBase.set(this, 'shipment_agent_code', shipmentAgentCode);
    RealmObjectBase.set(this, 'ar_posting_group_code', arPostingGroupCode);
    RealmObjectBase.set(
      this,
      'gen_bus_posting_group_code',
      genBusPostingGroupCode,
    );
    RealmObjectBase.set(
      this,
      'vat_bus_posting_group_code',
      vatBusPostingGroupCode,
    );
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'currency_factor', currencyFactor);
    RealmObjectBase.set(this, 'price_include_vat', priceIncludeVat);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'customer_group_code', customerGroupCode);
    RealmObjectBase.set(this, 'external_document_no', externalDocumentNo);
    RealmObjectBase.set(this, 'source_type', sourceType);
    RealmObjectBase.set(this, 'source_no', sourceNo);
    RealmObjectBase.set(this, 'return_reason_code', returnReasonCode);
    RealmObjectBase.set(this, 'reason_code', reasonCode);
    RealmObjectBase.set(this, 'assign_to_user_id', assignToUserId);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'remark', remark);
    RealmObjectBase.set(this, 'amount', amount);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'order_date', orderDate);
  }

  PosSalesHeader._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get documentType =>
      RealmObjectBase.get<String>(this, 'document_type') as String?;
  @override
  set documentType(String? value) =>
      RealmObjectBase.set(this, 'document_type', value);

  @override
  String? get no => RealmObjectBase.get<String>(this, 'no') as String?;
  @override
  set no(String? value) => RealmObjectBase.set(this, 'no', value);

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
  String? get address =>
      RealmObjectBase.get<String>(this, 'address') as String?;
  @override
  set address(String? value) => RealmObjectBase.set(this, 'address', value);

  @override
  String? get address2 =>
      RealmObjectBase.get<String>(this, 'address_2') as String?;
  @override
  set address2(String? value) => RealmObjectBase.set(this, 'address_2', value);

  @override
  String? get locationCode =>
      RealmObjectBase.get<String>(this, 'location_code') as String?;
  @override
  set locationCode(String? value) =>
      RealmObjectBase.set(this, 'location_code', value);

  @override
  String? get shipToCode =>
      RealmObjectBase.get<String>(this, 'ship_to_code') as String?;
  @override
  set shipToCode(String? value) =>
      RealmObjectBase.set(this, 'ship_to_code', value);

  @override
  String? get shipToName =>
      RealmObjectBase.get<String>(this, 'ship_to_name') as String?;
  @override
  set shipToName(String? value) =>
      RealmObjectBase.set(this, 'ship_to_name', value);

  @override
  String? get shipToName2 =>
      RealmObjectBase.get<String>(this, 'ship_to_name_2') as String?;
  @override
  set shipToName2(String? value) =>
      RealmObjectBase.set(this, 'ship_to_name_2', value);

  @override
  String? get shipToAddress =>
      RealmObjectBase.get<String>(this, 'ship_to_address') as String?;
  @override
  set shipToAddress(String? value) =>
      RealmObjectBase.set(this, 'ship_to_address', value);

  @override
  String? get shipToAddress2 =>
      RealmObjectBase.get<String>(this, 'ship_to_address_2') as String?;
  @override
  set shipToAddress2(String? value) =>
      RealmObjectBase.set(this, 'ship_to_address_2', value);

  @override
  String? get shipToContactName =>
      RealmObjectBase.get<String>(this, 'ship_to_contact_name') as String?;
  @override
  set shipToContactName(String? value) =>
      RealmObjectBase.set(this, 'ship_to_contact_name', value);

  @override
  String? get shipToPhoneNo =>
      RealmObjectBase.get<String>(this, 'ship_to_phone_no') as String?;
  @override
  set shipToPhoneNo(String? value) =>
      RealmObjectBase.set(this, 'ship_to_phone_no', value);

  @override
  String? get shipToPhoneNo2 =>
      RealmObjectBase.get<String>(this, 'ship_to_phone_no_2') as String?;
  @override
  set shipToPhoneNo2(String? value) =>
      RealmObjectBase.set(this, 'ship_to_phone_no_2', value);

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
  String? get requestShipmentDate =>
      RealmObjectBase.get<String>(this, 'request_shipment_date') as String?;
  @override
  set requestShipmentDate(String? value) =>
      RealmObjectBase.set(this, 'request_shipment_date', value);

  @override
  String? get postingDescription =>
      RealmObjectBase.get<String>(this, 'posting_description') as String?;
  @override
  set postingDescription(String? value) =>
      RealmObjectBase.set(this, 'posting_description', value);

  @override
  String? get paymentTermCode =>
      RealmObjectBase.get<String>(this, 'payment_term_code') as String?;
  @override
  set paymentTermCode(String? value) =>
      RealmObjectBase.set(this, 'payment_term_code', value);

  @override
  String? get paymentMethodCode =>
      RealmObjectBase.get<String>(this, 'payment_method_code') as String?;
  @override
  set paymentMethodCode(String? value) =>
      RealmObjectBase.set(this, 'payment_method_code', value);

  @override
  String? get shipmentMethodCode =>
      RealmObjectBase.get<String>(this, 'shipment_method_code') as String?;
  @override
  set shipmentMethodCode(String? value) =>
      RealmObjectBase.set(this, 'shipment_method_code', value);

  @override
  String? get shipmentAgentCode =>
      RealmObjectBase.get<String>(this, 'shipment_agent_code') as String?;
  @override
  set shipmentAgentCode(String? value) =>
      RealmObjectBase.set(this, 'shipment_agent_code', value);

  @override
  String? get arPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'ar_posting_group_code') as String?;
  @override
  set arPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'ar_posting_group_code', value);

  @override
  String? get genBusPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'gen_bus_posting_group_code')
          as String?;
  @override
  set genBusPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'gen_bus_posting_group_code', value);

  @override
  String? get vatBusPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'vat_bus_posting_group_code')
          as String?;
  @override
  set vatBusPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'vat_bus_posting_group_code', value);

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
  String? get priceIncludeVat =>
      RealmObjectBase.get<String>(this, 'price_include_vat') as String?;
  @override
  set priceIncludeVat(String? value) =>
      RealmObjectBase.set(this, 'price_include_vat', value);

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
  String? get projectCode =>
      RealmObjectBase.get<String>(this, 'project_code') as String?;
  @override
  set projectCode(String? value) =>
      RealmObjectBase.set(this, 'project_code', value);

  @override
  String? get customerGroupCode =>
      RealmObjectBase.get<String>(this, 'customer_group_code') as String?;
  @override
  set customerGroupCode(String? value) =>
      RealmObjectBase.set(this, 'customer_group_code', value);

  @override
  String? get externalDocumentNo =>
      RealmObjectBase.get<String>(this, 'external_document_no') as String?;
  @override
  set externalDocumentNo(String? value) =>
      RealmObjectBase.set(this, 'external_document_no', value);

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
  String? get returnReasonCode =>
      RealmObjectBase.get<String>(this, 'return_reason_code') as String?;
  @override
  set returnReasonCode(String? value) =>
      RealmObjectBase.set(this, 'return_reason_code', value);

  @override
  String? get reasonCode =>
      RealmObjectBase.get<String>(this, 'reason_code') as String?;
  @override
  set reasonCode(String? value) =>
      RealmObjectBase.set(this, 'reason_code', value);

  @override
  String? get assignToUserId =>
      RealmObjectBase.get<String>(this, 'assign_to_user_id') as String?;
  @override
  set assignToUserId(String? value) =>
      RealmObjectBase.set(this, 'assign_to_user_id', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get remark => RealmObjectBase.get<String>(this, 'remark') as String?;
  @override
  set remark(String? value) => RealmObjectBase.set(this, 'remark', value);

  @override
  double? get amount => RealmObjectBase.get<double>(this, 'amount') as double?;
  @override
  set amount(double? value) => RealmObjectBase.set(this, 'amount', value);

  @override
  String get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String;
  @override
  set isSync(String value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  String? get orderDate =>
      RealmObjectBase.get<String>(this, 'order_date') as String?;
  @override
  set orderDate(String? value) =>
      RealmObjectBase.set(this, 'order_date', value);

  @override
  Stream<RealmObjectChanges<PosSalesHeader>> get changes =>
      RealmObjectBase.getChanges<PosSalesHeader>(this);

  @override
  Stream<RealmObjectChanges<PosSalesHeader>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<PosSalesHeader>(this, keyPaths);

  @override
  PosSalesHeader freeze() => RealmObjectBase.freezeObject<PosSalesHeader>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'document_type': documentType.toEJson(),
      'no': no.toEJson(),
      'customer_no': customerNo.toEJson(),
      'customer_name': customerName.toEJson(),
      'customer_name_2': customerName2.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'location_code': locationCode.toEJson(),
      'ship_to_code': shipToCode.toEJson(),
      'ship_to_name': shipToName.toEJson(),
      'ship_to_name_2': shipToName2.toEJson(),
      'ship_to_address': shipToAddress.toEJson(),
      'ship_to_address_2': shipToAddress2.toEJson(),
      'ship_to_contact_name': shipToContactName.toEJson(),
      'ship_to_phone_no': shipToPhoneNo.toEJson(),
      'ship_to_phone_no_2': shipToPhoneNo2.toEJson(),
      'document_date': documentDate.toEJson(),
      'posting_date': postingDate.toEJson(),
      'request_shipment_date': requestShipmentDate.toEJson(),
      'posting_description': postingDescription.toEJson(),
      'payment_term_code': paymentTermCode.toEJson(),
      'payment_method_code': paymentMethodCode.toEJson(),
      'shipment_method_code': shipmentMethodCode.toEJson(),
      'shipment_agent_code': shipmentAgentCode.toEJson(),
      'ar_posting_group_code': arPostingGroupCode.toEJson(),
      'gen_bus_posting_group_code': genBusPostingGroupCode.toEJson(),
      'vat_bus_posting_group_code': vatBusPostingGroupCode.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'currency_factor': currencyFactor.toEJson(),
      'price_include_vat': priceIncludeVat.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'store_code': storeCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'customer_group_code': customerGroupCode.toEJson(),
      'external_document_no': externalDocumentNo.toEJson(),
      'source_type': sourceType.toEJson(),
      'source_no': sourceNo.toEJson(),
      'return_reason_code': returnReasonCode.toEJson(),
      'reason_code': reasonCode.toEJson(),
      'assign_to_user_id': assignToUserId.toEJson(),
      'status': status.toEJson(),
      'remark': remark.toEJson(),
      'amount': amount.toEJson(),
      'is_sync': isSync.toEJson(),
      'order_date': orderDate.toEJson(),
    };
  }

  static EJsonValue _toEJson(PosSalesHeader value) => value.toEJson();
  static PosSalesHeader _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => PosSalesHeader(
        fromEJson(id),
        documentType: fromEJson(ejson['document_type']),
        no: fromEJson(ejson['no']),
        customerNo: fromEJson(ejson['customer_no']),
        customerName: fromEJson(ejson['customer_name']),
        customerName2: fromEJson(ejson['customer_name_2']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        locationCode: fromEJson(ejson['location_code']),
        shipToCode: fromEJson(ejson['ship_to_code']),
        shipToName: fromEJson(ejson['ship_to_name']),
        shipToName2: fromEJson(ejson['ship_to_name_2']),
        shipToAddress: fromEJson(ejson['ship_to_address']),
        shipToAddress2: fromEJson(ejson['ship_to_address_2']),
        shipToContactName: fromEJson(ejson['ship_to_contact_name']),
        shipToPhoneNo: fromEJson(ejson['ship_to_phone_no']),
        shipToPhoneNo2: fromEJson(ejson['ship_to_phone_no_2']),
        documentDate: fromEJson(ejson['document_date']),
        postingDate: fromEJson(ejson['posting_date']),
        requestShipmentDate: fromEJson(ejson['request_shipment_date']),
        postingDescription: fromEJson(ejson['posting_description']),
        paymentTermCode: fromEJson(ejson['payment_term_code']),
        paymentMethodCode: fromEJson(ejson['payment_method_code']),
        shipmentMethodCode: fromEJson(ejson['shipment_method_code']),
        shipmentAgentCode: fromEJson(ejson['shipment_agent_code']),
        arPostingGroupCode: fromEJson(ejson['ar_posting_group_code']),
        genBusPostingGroupCode: fromEJson(ejson['gen_bus_posting_group_code']),
        vatBusPostingGroupCode: fromEJson(ejson['vat_bus_posting_group_code']),
        currencyCode: fromEJson(ejson['currency_code']),
        currencyFactor: fromEJson(ejson['currency_factor']),
        priceIncludeVat: fromEJson(ejson['price_include_vat']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        distributorCode: fromEJson(ejson['distributor_code']),
        storeCode: fromEJson(ejson['store_code']),
        divisionCode: fromEJson(ejson['division_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        departmentCode: fromEJson(ejson['department_code']),
        projectCode: fromEJson(ejson['project_code']),
        customerGroupCode: fromEJson(ejson['customer_group_code']),
        externalDocumentNo: fromEJson(ejson['external_document_no']),
        sourceType: fromEJson(ejson['source_type']),
        sourceNo: fromEJson(ejson['source_no']),
        returnReasonCode: fromEJson(ejson['return_reason_code']),
        reasonCode: fromEJson(ejson['reason_code']),
        assignToUserId: fromEJson(ejson['assign_to_user_id']),
        status: fromEJson(ejson['status']),
        remark: fromEJson(ejson['remark']),
        amount: fromEJson(ejson['amount']),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
        orderDate: fromEJson(ejson['order_date']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PosSalesHeader._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      PosSalesHeader,
      'POS_SALES_HEADER',
      [
        SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
        SchemaProperty(
          'documentType',
          RealmPropertyType.string,
          mapTo: 'document_type',
          optional: true,
        ),
        SchemaProperty('no', RealmPropertyType.string, optional: true),
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
        SchemaProperty('address', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'address2',
          RealmPropertyType.string,
          mapTo: 'address_2',
          optional: true,
        ),
        SchemaProperty(
          'locationCode',
          RealmPropertyType.string,
          mapTo: 'location_code',
          optional: true,
        ),
        SchemaProperty(
          'shipToCode',
          RealmPropertyType.string,
          mapTo: 'ship_to_code',
          optional: true,
        ),
        SchemaProperty(
          'shipToName',
          RealmPropertyType.string,
          mapTo: 'ship_to_name',
          optional: true,
        ),
        SchemaProperty(
          'shipToName2',
          RealmPropertyType.string,
          mapTo: 'ship_to_name_2',
          optional: true,
        ),
        SchemaProperty(
          'shipToAddress',
          RealmPropertyType.string,
          mapTo: 'ship_to_address',
          optional: true,
        ),
        SchemaProperty(
          'shipToAddress2',
          RealmPropertyType.string,
          mapTo: 'ship_to_address_2',
          optional: true,
        ),
        SchemaProperty(
          'shipToContactName',
          RealmPropertyType.string,
          mapTo: 'ship_to_contact_name',
          optional: true,
        ),
        SchemaProperty(
          'shipToPhoneNo',
          RealmPropertyType.string,
          mapTo: 'ship_to_phone_no',
          optional: true,
        ),
        SchemaProperty(
          'shipToPhoneNo2',
          RealmPropertyType.string,
          mapTo: 'ship_to_phone_no_2',
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
          'requestShipmentDate',
          RealmPropertyType.string,
          mapTo: 'request_shipment_date',
          optional: true,
        ),
        SchemaProperty(
          'postingDescription',
          RealmPropertyType.string,
          mapTo: 'posting_description',
          optional: true,
        ),
        SchemaProperty(
          'paymentTermCode',
          RealmPropertyType.string,
          mapTo: 'payment_term_code',
          optional: true,
        ),
        SchemaProperty(
          'paymentMethodCode',
          RealmPropertyType.string,
          mapTo: 'payment_method_code',
          optional: true,
        ),
        SchemaProperty(
          'shipmentMethodCode',
          RealmPropertyType.string,
          mapTo: 'shipment_method_code',
          optional: true,
        ),
        SchemaProperty(
          'shipmentAgentCode',
          RealmPropertyType.string,
          mapTo: 'shipment_agent_code',
          optional: true,
        ),
        SchemaProperty(
          'arPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'ar_posting_group_code',
          optional: true,
        ),
        SchemaProperty(
          'genBusPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'gen_bus_posting_group_code',
          optional: true,
        ),
        SchemaProperty(
          'vatBusPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'vat_bus_posting_group_code',
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
          RealmPropertyType.string,
          mapTo: 'price_include_vat',
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
          'projectCode',
          RealmPropertyType.string,
          mapTo: 'project_code',
          optional: true,
        ),
        SchemaProperty(
          'customerGroupCode',
          RealmPropertyType.string,
          mapTo: 'customer_group_code',
          optional: true,
        ),
        SchemaProperty(
          'externalDocumentNo',
          RealmPropertyType.string,
          mapTo: 'external_document_no',
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
          'returnReasonCode',
          RealmPropertyType.string,
          mapTo: 'return_reason_code',
          optional: true,
        ),
        SchemaProperty(
          'reasonCode',
          RealmPropertyType.string,
          mapTo: 'reason_code',
          optional: true,
        ),
        SchemaProperty(
          'assignToUserId',
          RealmPropertyType.string,
          mapTo: 'assign_to_user_id',
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty('remark', RealmPropertyType.string, optional: true),
        SchemaProperty('amount', RealmPropertyType.double, optional: true),
        SchemaProperty('isSync', RealmPropertyType.string, mapTo: 'is_sync'),
        SchemaProperty(
          'orderDate',
          RealmPropertyType.string,
          mapTo: 'order_date',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class PosSalesLine extends _PosSalesLine
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  PosSalesLine(
    int id, {
    String? documentType,
    String? documentNo,
    int? lineNo,
    int? referLineNo,
    String? customerNo,
    String? specialType,
    String? specialTypeNo,
    String? type,
    String? no,
    String? description,
    String? description2,
    String? variantCode,
    String? locationCode,
    String? postingGroup,
    String? lotNo,
    String? serialNo,
    String? expiryDate,
    String? warrentyDate,
    String? requestShipmentDate,
    String? unitOfMeasure,
    double? qtyPerUnitOfMeasure = 1,
    double? headerQuantity,
    double? quantity,
    double? outstandingQuantity,
    double? outstandingQuantityBase,
    double? quantityToShip,
    double? quantityToInvoice,
    double? unitPrice,
    double? manualUnitPrice,
    double? unitPriceLcy,
    double? unitPriceOri,
    double? vatPercentage,
    double? vatBaseAmount,
    double? vatAmount,
    double? discountPercentage,
    double? discountAmount,
    double? amount,
    double? amountLcy,
    double? amountIncludingVat,
    double? amountIncludingVatLcy,
    double? grossWeight,
    double? netWeight,
    double? quantityShipped,
    double? quantityInvoiced,
    String? genBusPostingGroupCode,
    String? genProdPostingGroupCode,
    String? vatBusPostingGroupCode,
    String? vatProdPostingGroupCode,
    String? vatCalculationType,
    String? currencyCode,
    double? currencyFactor,
    String? itemCategoryCode,
    String? itemGroupCode,
    String? itemDiscGroupCode,
    String? itemBrandCode,
    String? storeCode,
    String? divisionCode,
    String? businessUnitCode,
    String? departmentCode,
    String? projectCode,
    String? salespersonCode,
    String? distributorCode,
    String? customerGroupCode,
    String? returnReasonCode,
    String? reasonCode,
    String? sourceNo,
    String? imgUrl,
    int? headerId,
    String? documentDate,
    String? isManualEdit = "No",
    String? isSync = "Yes",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<PosSalesLine>({
        'qty_per_unit_of_measure': 1,
        'is_manual_edit': "No",
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'document_type', documentType);
    RealmObjectBase.set(this, 'document_no', documentNo);
    RealmObjectBase.set(this, 'line_no', lineNo);
    RealmObjectBase.set(this, 'refer_line_no', referLineNo);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'special_type', specialType);
    RealmObjectBase.set(this, 'special_type_no', specialTypeNo);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'location_code', locationCode);
    RealmObjectBase.set(this, 'posting_group', postingGroup);
    RealmObjectBase.set(this, 'lot_no', lotNo);
    RealmObjectBase.set(this, 'serial_no', serialNo);
    RealmObjectBase.set(this, 'expiry_date', expiryDate);
    RealmObjectBase.set(this, 'warrenty_date', warrentyDate);
    RealmObjectBase.set(this, 'request_shipment_date', requestShipmentDate);
    RealmObjectBase.set(this, 'unit_of_measure', unitOfMeasure);
    RealmObjectBase.set(this, 'qty_per_unit_of_measure', qtyPerUnitOfMeasure);
    RealmObjectBase.set(this, 'header_quantity', headerQuantity);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'outstanding_quantity', outstandingQuantity);
    RealmObjectBase.set(
      this,
      'outstanding_quantity_base',
      outstandingQuantityBase,
    );
    RealmObjectBase.set(this, 'quantity_to_ship', quantityToShip);
    RealmObjectBase.set(this, 'quantity_to_invoice', quantityToInvoice);
    RealmObjectBase.set(this, 'unit_price', unitPrice);
    RealmObjectBase.set(this, 'manual_unit_price', manualUnitPrice);
    RealmObjectBase.set(this, 'unit_price_lcy', unitPriceLcy);
    RealmObjectBase.set(this, 'unit_price_ori', unitPriceOri);
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
    RealmObjectBase.set(this, 'gross_weight', grossWeight);
    RealmObjectBase.set(this, 'net_weight', netWeight);
    RealmObjectBase.set(this, 'quantity_shipped', quantityShipped);
    RealmObjectBase.set(this, 'quantity_invoiced', quantityInvoiced);
    RealmObjectBase.set(
      this,
      'gen_bus_posting_group_code',
      genBusPostingGroupCode,
    );
    RealmObjectBase.set(
      this,
      'gen_prod_posting_group_code',
      genProdPostingGroupCode,
    );
    RealmObjectBase.set(
      this,
      'vat_bus_posting_group_code',
      vatBusPostingGroupCode,
    );
    RealmObjectBase.set(
      this,
      'vat_prod_posting_group_code',
      vatProdPostingGroupCode,
    );
    RealmObjectBase.set(this, 'vat_calculation_type', vatCalculationType);
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'currency_factor', currencyFactor);
    RealmObjectBase.set(this, 'item_category_code', itemCategoryCode);
    RealmObjectBase.set(this, 'item_group_code', itemGroupCode);
    RealmObjectBase.set(this, 'item_disc_group_code', itemDiscGroupCode);
    RealmObjectBase.set(this, 'item_brand_code', itemBrandCode);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'customer_group_code', customerGroupCode);
    RealmObjectBase.set(this, 'return_reason_code', returnReasonCode);
    RealmObjectBase.set(this, 'reason_code', reasonCode);
    RealmObjectBase.set(this, 'sourceNo', sourceNo);
    RealmObjectBase.set(this, 'source_no', imgUrl);
    RealmObjectBase.set(this, 'header_id', headerId);
    RealmObjectBase.set(this, 'document_date', documentDate);
    RealmObjectBase.set(this, 'is_manual_edit', isManualEdit);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  PosSalesLine._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

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
  int? get lineNo => RealmObjectBase.get<int>(this, 'line_no') as int?;
  @override
  set lineNo(int? value) => RealmObjectBase.set(this, 'line_no', value);

  @override
  int? get referLineNo =>
      RealmObjectBase.get<int>(this, 'refer_line_no') as int?;
  @override
  set referLineNo(int? value) =>
      RealmObjectBase.set(this, 'refer_line_no', value);

  @override
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

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
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get no => RealmObjectBase.get<String>(this, 'no') as String?;
  @override
  set no(String? value) => RealmObjectBase.set(this, 'no', value);

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
  String? get variantCode =>
      RealmObjectBase.get<String>(this, 'variant_code') as String?;
  @override
  set variantCode(String? value) =>
      RealmObjectBase.set(this, 'variant_code', value);

  @override
  String? get locationCode =>
      RealmObjectBase.get<String>(this, 'location_code') as String?;
  @override
  set locationCode(String? value) =>
      RealmObjectBase.set(this, 'location_code', value);

  @override
  String? get postingGroup =>
      RealmObjectBase.get<String>(this, 'posting_group') as String?;
  @override
  set postingGroup(String? value) =>
      RealmObjectBase.set(this, 'posting_group', value);

  @override
  String? get lotNo => RealmObjectBase.get<String>(this, 'lot_no') as String?;
  @override
  set lotNo(String? value) => RealmObjectBase.set(this, 'lot_no', value);

  @override
  String? get serialNo =>
      RealmObjectBase.get<String>(this, 'serial_no') as String?;
  @override
  set serialNo(String? value) => RealmObjectBase.set(this, 'serial_no', value);

  @override
  String? get expiryDate =>
      RealmObjectBase.get<String>(this, 'expiry_date') as String?;
  @override
  set expiryDate(String? value) =>
      RealmObjectBase.set(this, 'expiry_date', value);

  @override
  String? get warrentyDate =>
      RealmObjectBase.get<String>(this, 'warrenty_date') as String?;
  @override
  set warrentyDate(String? value) =>
      RealmObjectBase.set(this, 'warrenty_date', value);

  @override
  String? get requestShipmentDate =>
      RealmObjectBase.get<String>(this, 'request_shipment_date') as String?;
  @override
  set requestShipmentDate(String? value) =>
      RealmObjectBase.set(this, 'request_shipment_date', value);

  @override
  String? get unitOfMeasure =>
      RealmObjectBase.get<String>(this, 'unit_of_measure') as String?;
  @override
  set unitOfMeasure(String? value) =>
      RealmObjectBase.set(this, 'unit_of_measure', value);

  @override
  double? get qtyPerUnitOfMeasure =>
      RealmObjectBase.get<double>(this, 'qty_per_unit_of_measure') as double?;
  @override
  set qtyPerUnitOfMeasure(double? value) =>
      RealmObjectBase.set(this, 'qty_per_unit_of_measure', value);

  @override
  double? get headerQuantity =>
      RealmObjectBase.get<double>(this, 'header_quantity') as double?;
  @override
  set headerQuantity(double? value) =>
      RealmObjectBase.set(this, 'header_quantity', value);

  @override
  double? get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double?;
  @override
  set quantity(double? value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  double? get outstandingQuantity =>
      RealmObjectBase.get<double>(this, 'outstanding_quantity') as double?;
  @override
  set outstandingQuantity(double? value) =>
      RealmObjectBase.set(this, 'outstanding_quantity', value);

  @override
  double? get outstandingQuantityBase =>
      RealmObjectBase.get<double>(this, 'outstanding_quantity_base') as double?;
  @override
  set outstandingQuantityBase(double? value) =>
      RealmObjectBase.set(this, 'outstanding_quantity_base', value);

  @override
  double? get quantityToShip =>
      RealmObjectBase.get<double>(this, 'quantity_to_ship') as double?;
  @override
  set quantityToShip(double? value) =>
      RealmObjectBase.set(this, 'quantity_to_ship', value);

  @override
  double? get quantityToInvoice =>
      RealmObjectBase.get<double>(this, 'quantity_to_invoice') as double?;
  @override
  set quantityToInvoice(double? value) =>
      RealmObjectBase.set(this, 'quantity_to_invoice', value);

  @override
  double? get unitPrice =>
      RealmObjectBase.get<double>(this, 'unit_price') as double?;
  @override
  set unitPrice(double? value) =>
      RealmObjectBase.set(this, 'unit_price', value);

  @override
  double? get manualUnitPrice =>
      RealmObjectBase.get<double>(this, 'manual_unit_price') as double?;
  @override
  set manualUnitPrice(double? value) =>
      RealmObjectBase.set(this, 'manual_unit_price', value);

  @override
  double? get unitPriceLcy =>
      RealmObjectBase.get<double>(this, 'unit_price_lcy') as double?;
  @override
  set unitPriceLcy(double? value) =>
      RealmObjectBase.set(this, 'unit_price_lcy', value);

  @override
  double? get unitPriceOri =>
      RealmObjectBase.get<double>(this, 'unit_price_ori') as double?;
  @override
  set unitPriceOri(double? value) =>
      RealmObjectBase.set(this, 'unit_price_ori', value);

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
  double? get grossWeight =>
      RealmObjectBase.get<double>(this, 'gross_weight') as double?;
  @override
  set grossWeight(double? value) =>
      RealmObjectBase.set(this, 'gross_weight', value);

  @override
  double? get netWeight =>
      RealmObjectBase.get<double>(this, 'net_weight') as double?;
  @override
  set netWeight(double? value) =>
      RealmObjectBase.set(this, 'net_weight', value);

  @override
  double? get quantityShipped =>
      RealmObjectBase.get<double>(this, 'quantity_shipped') as double?;
  @override
  set quantityShipped(double? value) =>
      RealmObjectBase.set(this, 'quantity_shipped', value);

  @override
  double? get quantityInvoiced =>
      RealmObjectBase.get<double>(this, 'quantity_invoiced') as double?;
  @override
  set quantityInvoiced(double? value) =>
      RealmObjectBase.set(this, 'quantity_invoiced', value);

  @override
  String? get genBusPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'gen_bus_posting_group_code')
          as String?;
  @override
  set genBusPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'gen_bus_posting_group_code', value);

  @override
  String? get genProdPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'gen_prod_posting_group_code')
          as String?;
  @override
  set genProdPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'gen_prod_posting_group_code', value);

  @override
  String? get vatBusPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'vat_bus_posting_group_code')
          as String?;
  @override
  set vatBusPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'vat_bus_posting_group_code', value);

  @override
  String? get vatProdPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'vat_prod_posting_group_code')
          as String?;
  @override
  set vatProdPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'vat_prod_posting_group_code', value);

  @override
  String? get vatCalculationType =>
      RealmObjectBase.get<String>(this, 'vat_calculation_type') as String?;
  @override
  set vatCalculationType(String? value) =>
      RealmObjectBase.set(this, 'vat_calculation_type', value);

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
  String? get itemDiscGroupCode =>
      RealmObjectBase.get<String>(this, 'item_disc_group_code') as String?;
  @override
  set itemDiscGroupCode(String? value) =>
      RealmObjectBase.set(this, 'item_disc_group_code', value);

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
  String? get returnReasonCode =>
      RealmObjectBase.get<String>(this, 'return_reason_code') as String?;
  @override
  set returnReasonCode(String? value) =>
      RealmObjectBase.set(this, 'return_reason_code', value);

  @override
  String? get reasonCode =>
      RealmObjectBase.get<String>(this, 'reason_code') as String?;
  @override
  set reasonCode(String? value) =>
      RealmObjectBase.set(this, 'reason_code', value);

  @override
  String? get sourceNo =>
      RealmObjectBase.get<String>(this, 'sourceNo') as String?;
  @override
  set sourceNo(String? value) => RealmObjectBase.set(this, 'sourceNo', value);

  @override
  String? get imgUrl =>
      RealmObjectBase.get<String>(this, 'source_no') as String?;
  @override
  set imgUrl(String? value) => RealmObjectBase.set(this, 'source_no', value);

  @override
  int? get headerId => RealmObjectBase.get<int>(this, 'header_id') as int?;
  @override
  set headerId(int? value) => RealmObjectBase.set(this, 'header_id', value);

  @override
  String? get documentDate =>
      RealmObjectBase.get<String>(this, 'document_date') as String?;
  @override
  set documentDate(String? value) =>
      RealmObjectBase.set(this, 'document_date', value);

  @override
  String? get isManualEdit =>
      RealmObjectBase.get<String>(this, 'is_manual_edit') as String?;
  @override
  set isManualEdit(String? value) =>
      RealmObjectBase.set(this, 'is_manual_edit', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<PosSalesLine>> get changes =>
      RealmObjectBase.getChanges<PosSalesLine>(this);

  @override
  Stream<RealmObjectChanges<PosSalesLine>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<PosSalesLine>(this, keyPaths);

  @override
  PosSalesLine freeze() => RealmObjectBase.freezeObject<PosSalesLine>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'document_type': documentType.toEJson(),
      'document_no': documentNo.toEJson(),
      'line_no': lineNo.toEJson(),
      'refer_line_no': referLineNo.toEJson(),
      'customer_no': customerNo.toEJson(),
      'special_type': specialType.toEJson(),
      'special_type_no': specialTypeNo.toEJson(),
      'type': type.toEJson(),
      'no': no.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'variant_code': variantCode.toEJson(),
      'location_code': locationCode.toEJson(),
      'posting_group': postingGroup.toEJson(),
      'lot_no': lotNo.toEJson(),
      'serial_no': serialNo.toEJson(),
      'expiry_date': expiryDate.toEJson(),
      'warrenty_date': warrentyDate.toEJson(),
      'request_shipment_date': requestShipmentDate.toEJson(),
      'unit_of_measure': unitOfMeasure.toEJson(),
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure.toEJson(),
      'header_quantity': headerQuantity.toEJson(),
      'quantity': quantity.toEJson(),
      'outstanding_quantity': outstandingQuantity.toEJson(),
      'outstanding_quantity_base': outstandingQuantityBase.toEJson(),
      'quantity_to_ship': quantityToShip.toEJson(),
      'quantity_to_invoice': quantityToInvoice.toEJson(),
      'unit_price': unitPrice.toEJson(),
      'manual_unit_price': manualUnitPrice.toEJson(),
      'unit_price_lcy': unitPriceLcy.toEJson(),
      'unit_price_ori': unitPriceOri.toEJson(),
      'vat_percentage': vatPercentage.toEJson(),
      'vat_base_amount': vatBaseAmount.toEJson(),
      'vat_amount': vatAmount.toEJson(),
      'discount_percentage': discountPercentage.toEJson(),
      'discount_amount': discountAmount.toEJson(),
      'amount': amount.toEJson(),
      'amount_lcy': amountLcy.toEJson(),
      'amount_including_vat': amountIncludingVat.toEJson(),
      'amount_including_vat_lcy': amountIncludingVatLcy.toEJson(),
      'gross_weight': grossWeight.toEJson(),
      'net_weight': netWeight.toEJson(),
      'quantity_shipped': quantityShipped.toEJson(),
      'quantity_invoiced': quantityInvoiced.toEJson(),
      'gen_bus_posting_group_code': genBusPostingGroupCode.toEJson(),
      'gen_prod_posting_group_code': genProdPostingGroupCode.toEJson(),
      'vat_bus_posting_group_code': vatBusPostingGroupCode.toEJson(),
      'vat_prod_posting_group_code': vatProdPostingGroupCode.toEJson(),
      'vat_calculation_type': vatCalculationType.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'currency_factor': currencyFactor.toEJson(),
      'item_category_code': itemCategoryCode.toEJson(),
      'item_group_code': itemGroupCode.toEJson(),
      'item_disc_group_code': itemDiscGroupCode.toEJson(),
      'item_brand_code': itemBrandCode.toEJson(),
      'store_code': storeCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'customer_group_code': customerGroupCode.toEJson(),
      'return_reason_code': returnReasonCode.toEJson(),
      'reason_code': reasonCode.toEJson(),
      'sourceNo': sourceNo.toEJson(),
      'source_no': imgUrl.toEJson(),
      'header_id': headerId.toEJson(),
      'document_date': documentDate.toEJson(),
      'is_manual_edit': isManualEdit.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(PosSalesLine value) => value.toEJson();
  static PosSalesLine _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => PosSalesLine(
        fromEJson(id),
        documentType: fromEJson(ejson['document_type']),
        documentNo: fromEJson(ejson['document_no']),
        lineNo: fromEJson(ejson['line_no']),
        referLineNo: fromEJson(ejson['refer_line_no']),
        customerNo: fromEJson(ejson['customer_no']),
        specialType: fromEJson(ejson['special_type']),
        specialTypeNo: fromEJson(ejson['special_type_no']),
        type: fromEJson(ejson['type']),
        no: fromEJson(ejson['no']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        variantCode: fromEJson(ejson['variant_code']),
        locationCode: fromEJson(ejson['location_code']),
        postingGroup: fromEJson(ejson['posting_group']),
        lotNo: fromEJson(ejson['lot_no']),
        serialNo: fromEJson(ejson['serial_no']),
        expiryDate: fromEJson(ejson['expiry_date']),
        warrentyDate: fromEJson(ejson['warrenty_date']),
        requestShipmentDate: fromEJson(ejson['request_shipment_date']),
        unitOfMeasure: fromEJson(ejson['unit_of_measure']),
        qtyPerUnitOfMeasure: fromEJson(
          ejson['qty_per_unit_of_measure'],
          defaultValue: 1,
        ),
        headerQuantity: fromEJson(ejson['header_quantity']),
        quantity: fromEJson(ejson['quantity']),
        outstandingQuantity: fromEJson(ejson['outstanding_quantity']),
        outstandingQuantityBase: fromEJson(ejson['outstanding_quantity_base']),
        quantityToShip: fromEJson(ejson['quantity_to_ship']),
        quantityToInvoice: fromEJson(ejson['quantity_to_invoice']),
        unitPrice: fromEJson(ejson['unit_price']),
        manualUnitPrice: fromEJson(ejson['manual_unit_price']),
        unitPriceLcy: fromEJson(ejson['unit_price_lcy']),
        unitPriceOri: fromEJson(ejson['unit_price_ori']),
        vatPercentage: fromEJson(ejson['vat_percentage']),
        vatBaseAmount: fromEJson(ejson['vat_base_amount']),
        vatAmount: fromEJson(ejson['vat_amount']),
        discountPercentage: fromEJson(ejson['discount_percentage']),
        discountAmount: fromEJson(ejson['discount_amount']),
        amount: fromEJson(ejson['amount']),
        amountLcy: fromEJson(ejson['amount_lcy']),
        amountIncludingVat: fromEJson(ejson['amount_including_vat']),
        amountIncludingVatLcy: fromEJson(ejson['amount_including_vat_lcy']),
        grossWeight: fromEJson(ejson['gross_weight']),
        netWeight: fromEJson(ejson['net_weight']),
        quantityShipped: fromEJson(ejson['quantity_shipped']),
        quantityInvoiced: fromEJson(ejson['quantity_invoiced']),
        genBusPostingGroupCode: fromEJson(ejson['gen_bus_posting_group_code']),
        genProdPostingGroupCode: fromEJson(
          ejson['gen_prod_posting_group_code'],
        ),
        vatBusPostingGroupCode: fromEJson(ejson['vat_bus_posting_group_code']),
        vatProdPostingGroupCode: fromEJson(
          ejson['vat_prod_posting_group_code'],
        ),
        vatCalculationType: fromEJson(ejson['vat_calculation_type']),
        currencyCode: fromEJson(ejson['currency_code']),
        currencyFactor: fromEJson(ejson['currency_factor']),
        itemCategoryCode: fromEJson(ejson['item_category_code']),
        itemGroupCode: fromEJson(ejson['item_group_code']),
        itemDiscGroupCode: fromEJson(ejson['item_disc_group_code']),
        itemBrandCode: fromEJson(ejson['item_brand_code']),
        storeCode: fromEJson(ejson['store_code']),
        divisionCode: fromEJson(ejson['division_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        departmentCode: fromEJson(ejson['department_code']),
        projectCode: fromEJson(ejson['project_code']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        distributorCode: fromEJson(ejson['distributor_code']),
        customerGroupCode: fromEJson(ejson['customer_group_code']),
        returnReasonCode: fromEJson(ejson['return_reason_code']),
        reasonCode: fromEJson(ejson['reason_code']),
        sourceNo: fromEJson(ejson['sourceNo']),
        imgUrl: fromEJson(ejson['source_no']),
        headerId: fromEJson(ejson['header_id']),
        documentDate: fromEJson(ejson['document_date']),
        isManualEdit: fromEJson(ejson['is_manual_edit'], defaultValue: "No"),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PosSalesLine._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      PosSalesLine,
      'POS_SALES_LINE',
      [
        SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
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
          'lineNo',
          RealmPropertyType.int,
          mapTo: 'line_no',
          optional: true,
        ),
        SchemaProperty(
          'referLineNo',
          RealmPropertyType.int,
          mapTo: 'refer_line_no',
          optional: true,
        ),
        SchemaProperty(
          'customerNo',
          RealmPropertyType.string,
          mapTo: 'customer_no',
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
        SchemaProperty('type', RealmPropertyType.string, optional: true),
        SchemaProperty('no', RealmPropertyType.string, optional: true),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty(
          'variantCode',
          RealmPropertyType.string,
          mapTo: 'variant_code',
          optional: true,
        ),
        SchemaProperty(
          'locationCode',
          RealmPropertyType.string,
          mapTo: 'location_code',
          optional: true,
        ),
        SchemaProperty(
          'postingGroup',
          RealmPropertyType.string,
          mapTo: 'posting_group',
          optional: true,
        ),
        SchemaProperty(
          'lotNo',
          RealmPropertyType.string,
          mapTo: 'lot_no',
          optional: true,
        ),
        SchemaProperty(
          'serialNo',
          RealmPropertyType.string,
          mapTo: 'serial_no',
          optional: true,
        ),
        SchemaProperty(
          'expiryDate',
          RealmPropertyType.string,
          mapTo: 'expiry_date',
          optional: true,
        ),
        SchemaProperty(
          'warrentyDate',
          RealmPropertyType.string,
          mapTo: 'warrenty_date',
          optional: true,
        ),
        SchemaProperty(
          'requestShipmentDate',
          RealmPropertyType.string,
          mapTo: 'request_shipment_date',
          optional: true,
        ),
        SchemaProperty(
          'unitOfMeasure',
          RealmPropertyType.string,
          mapTo: 'unit_of_measure',
          optional: true,
        ),
        SchemaProperty(
          'qtyPerUnitOfMeasure',
          RealmPropertyType.double,
          mapTo: 'qty_per_unit_of_measure',
          optional: true,
        ),
        SchemaProperty(
          'headerQuantity',
          RealmPropertyType.double,
          mapTo: 'header_quantity',
          optional: true,
        ),
        SchemaProperty('quantity', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'outstandingQuantity',
          RealmPropertyType.double,
          mapTo: 'outstanding_quantity',
          optional: true,
        ),
        SchemaProperty(
          'outstandingQuantityBase',
          RealmPropertyType.double,
          mapTo: 'outstanding_quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'quantityToShip',
          RealmPropertyType.double,
          mapTo: 'quantity_to_ship',
          optional: true,
        ),
        SchemaProperty(
          'quantityToInvoice',
          RealmPropertyType.double,
          mapTo: 'quantity_to_invoice',
          optional: true,
        ),
        SchemaProperty(
          'unitPrice',
          RealmPropertyType.double,
          mapTo: 'unit_price',
          optional: true,
        ),
        SchemaProperty(
          'manualUnitPrice',
          RealmPropertyType.double,
          mapTo: 'manual_unit_price',
          optional: true,
        ),
        SchemaProperty(
          'unitPriceLcy',
          RealmPropertyType.double,
          mapTo: 'unit_price_lcy',
          optional: true,
        ),
        SchemaProperty(
          'unitPriceOri',
          RealmPropertyType.double,
          mapTo: 'unit_price_ori',
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
          'grossWeight',
          RealmPropertyType.double,
          mapTo: 'gross_weight',
          optional: true,
        ),
        SchemaProperty(
          'netWeight',
          RealmPropertyType.double,
          mapTo: 'net_weight',
          optional: true,
        ),
        SchemaProperty(
          'quantityShipped',
          RealmPropertyType.double,
          mapTo: 'quantity_shipped',
          optional: true,
        ),
        SchemaProperty(
          'quantityInvoiced',
          RealmPropertyType.double,
          mapTo: 'quantity_invoiced',
          optional: true,
        ),
        SchemaProperty(
          'genBusPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'gen_bus_posting_group_code',
          optional: true,
        ),
        SchemaProperty(
          'genProdPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'gen_prod_posting_group_code',
          optional: true,
        ),
        SchemaProperty(
          'vatBusPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'vat_bus_posting_group_code',
          optional: true,
        ),
        SchemaProperty(
          'vatProdPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'vat_prod_posting_group_code',
          optional: true,
        ),
        SchemaProperty(
          'vatCalculationType',
          RealmPropertyType.string,
          mapTo: 'vat_calculation_type',
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
          'itemDiscGroupCode',
          RealmPropertyType.string,
          mapTo: 'item_disc_group_code',
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
          'returnReasonCode',
          RealmPropertyType.string,
          mapTo: 'return_reason_code',
          optional: true,
        ),
        SchemaProperty(
          'reasonCode',
          RealmPropertyType.string,
          mapTo: 'reason_code',
          optional: true,
        ),
        SchemaProperty('sourceNo', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'imgUrl',
          RealmPropertyType.string,
          mapTo: 'source_no',
          optional: true,
        ),
        SchemaProperty(
          'headerId',
          RealmPropertyType.int,
          mapTo: 'header_id',
          optional: true,
        ),
        SchemaProperty(
          'documentDate',
          RealmPropertyType.string,
          mapTo: 'document_date',
          optional: true,
        ),
        SchemaProperty(
          'isManualEdit',
          RealmPropertyType.string,
          mapTo: 'is_manual_edit',
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

class SalesHeader extends _SalesHeader
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  SalesHeader(
    int id, {
    String? documentType,
    String? no,
    String? appId,
    String? customerNo,
    String? customerName,
    String? customerName2,
    String? address,
    String? address2,
    String? locationCode,
    String? shipToCode,
    String? shipToName,
    String? shipToName2,
    String? shipToAddress,
    String? shipToAddress2,
    String? shipToContactName,
    String? shipToPhoneNo,
    String? shipToPhoneNo2,
    String? documentDate,
    String? postingDate,
    String? requestShipmentDate,
    String? postingDescription,
    String? paymentTermCode,
    String? paymentMethodCode,
    String? shipmentMethodCode,
    String? shipmentAgentCode,
    String? arPostingGroupCode,
    String? genBusPostingGroupCode,
    String? vatBusPostingGroupCode,
    String? currencyCode,
    double? currencyFactor,
    String? priceIncludeVat,
    String? salespersonCode,
    String? distributorCode,
    String? storeCode,
    String? divisionCode,
    String? businessUnitCode,
    String? departmentCode,
    String? projectCode,
    String? customerGroupCode,
    String? externalDocumentNo,
    String? sourceType,
    String? sourceNo,
    String? returnReasonCode,
    String? reasonCode,
    String? assignToUserId,
    String? status,
    String? remark,
    double? amount,
    String isSync = "Yes",
    String? orderDate,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<SalesHeader>({
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'document_type', documentType);
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'app_id', appId);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'customer_name', customerName);
    RealmObjectBase.set(this, 'customer_name_2', customerName2);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'location_code', locationCode);
    RealmObjectBase.set(this, 'ship_to_code', shipToCode);
    RealmObjectBase.set(this, 'ship_to_name', shipToName);
    RealmObjectBase.set(this, 'ship_to_name_2', shipToName2);
    RealmObjectBase.set(this, 'ship_to_address', shipToAddress);
    RealmObjectBase.set(this, 'ship_to_address_2', shipToAddress2);
    RealmObjectBase.set(this, 'ship_to_contact_name', shipToContactName);
    RealmObjectBase.set(this, 'ship_to_phone_no', shipToPhoneNo);
    RealmObjectBase.set(this, 'ship_to_phone_no_2', shipToPhoneNo2);
    RealmObjectBase.set(this, 'document_date', documentDate);
    RealmObjectBase.set(this, 'posting_date', postingDate);
    RealmObjectBase.set(this, 'request_shipment_date', requestShipmentDate);
    RealmObjectBase.set(this, 'posting_description', postingDescription);
    RealmObjectBase.set(this, 'payment_term_code', paymentTermCode);
    RealmObjectBase.set(this, 'payment_method_code', paymentMethodCode);
    RealmObjectBase.set(this, 'shipment_method_code', shipmentMethodCode);
    RealmObjectBase.set(this, 'shipment_agent_code', shipmentAgentCode);
    RealmObjectBase.set(this, 'ar_posting_group_code', arPostingGroupCode);
    RealmObjectBase.set(
      this,
      'gen_bus_posting_group_code',
      genBusPostingGroupCode,
    );
    RealmObjectBase.set(
      this,
      'vat_bus_posting_group_code',
      vatBusPostingGroupCode,
    );
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'currency_factor', currencyFactor);
    RealmObjectBase.set(this, 'price_include_vat', priceIncludeVat);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'customer_group_code', customerGroupCode);
    RealmObjectBase.set(this, 'external_document_no', externalDocumentNo);
    RealmObjectBase.set(this, 'source_type', sourceType);
    RealmObjectBase.set(this, 'source_no', sourceNo);
    RealmObjectBase.set(this, 'return_reason_code', returnReasonCode);
    RealmObjectBase.set(this, 'reason_code', reasonCode);
    RealmObjectBase.set(this, 'assign_to_user_id', assignToUserId);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'remark', remark);
    RealmObjectBase.set(this, 'total_amount', amount);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'order_date', orderDate);
  }

  SalesHeader._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get documentType =>
      RealmObjectBase.get<String>(this, 'document_type') as String?;
  @override
  set documentType(String? value) =>
      RealmObjectBase.set(this, 'document_type', value);

  @override
  String? get no => RealmObjectBase.get<String>(this, 'no') as String?;
  @override
  set no(String? value) => RealmObjectBase.set(this, 'no', value);

  @override
  String? get appId => RealmObjectBase.get<String>(this, 'app_id') as String?;
  @override
  set appId(String? value) => RealmObjectBase.set(this, 'app_id', value);

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
  String? get address =>
      RealmObjectBase.get<String>(this, 'address') as String?;
  @override
  set address(String? value) => RealmObjectBase.set(this, 'address', value);

  @override
  String? get address2 =>
      RealmObjectBase.get<String>(this, 'address_2') as String?;
  @override
  set address2(String? value) => RealmObjectBase.set(this, 'address_2', value);

  @override
  String? get locationCode =>
      RealmObjectBase.get<String>(this, 'location_code') as String?;
  @override
  set locationCode(String? value) =>
      RealmObjectBase.set(this, 'location_code', value);

  @override
  String? get shipToCode =>
      RealmObjectBase.get<String>(this, 'ship_to_code') as String?;
  @override
  set shipToCode(String? value) =>
      RealmObjectBase.set(this, 'ship_to_code', value);

  @override
  String? get shipToName =>
      RealmObjectBase.get<String>(this, 'ship_to_name') as String?;
  @override
  set shipToName(String? value) =>
      RealmObjectBase.set(this, 'ship_to_name', value);

  @override
  String? get shipToName2 =>
      RealmObjectBase.get<String>(this, 'ship_to_name_2') as String?;
  @override
  set shipToName2(String? value) =>
      RealmObjectBase.set(this, 'ship_to_name_2', value);

  @override
  String? get shipToAddress =>
      RealmObjectBase.get<String>(this, 'ship_to_address') as String?;
  @override
  set shipToAddress(String? value) =>
      RealmObjectBase.set(this, 'ship_to_address', value);

  @override
  String? get shipToAddress2 =>
      RealmObjectBase.get<String>(this, 'ship_to_address_2') as String?;
  @override
  set shipToAddress2(String? value) =>
      RealmObjectBase.set(this, 'ship_to_address_2', value);

  @override
  String? get shipToContactName =>
      RealmObjectBase.get<String>(this, 'ship_to_contact_name') as String?;
  @override
  set shipToContactName(String? value) =>
      RealmObjectBase.set(this, 'ship_to_contact_name', value);

  @override
  String? get shipToPhoneNo =>
      RealmObjectBase.get<String>(this, 'ship_to_phone_no') as String?;
  @override
  set shipToPhoneNo(String? value) =>
      RealmObjectBase.set(this, 'ship_to_phone_no', value);

  @override
  String? get shipToPhoneNo2 =>
      RealmObjectBase.get<String>(this, 'ship_to_phone_no_2') as String?;
  @override
  set shipToPhoneNo2(String? value) =>
      RealmObjectBase.set(this, 'ship_to_phone_no_2', value);

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
  String? get requestShipmentDate =>
      RealmObjectBase.get<String>(this, 'request_shipment_date') as String?;
  @override
  set requestShipmentDate(String? value) =>
      RealmObjectBase.set(this, 'request_shipment_date', value);

  @override
  String? get postingDescription =>
      RealmObjectBase.get<String>(this, 'posting_description') as String?;
  @override
  set postingDescription(String? value) =>
      RealmObjectBase.set(this, 'posting_description', value);

  @override
  String? get paymentTermCode =>
      RealmObjectBase.get<String>(this, 'payment_term_code') as String?;
  @override
  set paymentTermCode(String? value) =>
      RealmObjectBase.set(this, 'payment_term_code', value);

  @override
  String? get paymentMethodCode =>
      RealmObjectBase.get<String>(this, 'payment_method_code') as String?;
  @override
  set paymentMethodCode(String? value) =>
      RealmObjectBase.set(this, 'payment_method_code', value);

  @override
  String? get shipmentMethodCode =>
      RealmObjectBase.get<String>(this, 'shipment_method_code') as String?;
  @override
  set shipmentMethodCode(String? value) =>
      RealmObjectBase.set(this, 'shipment_method_code', value);

  @override
  String? get shipmentAgentCode =>
      RealmObjectBase.get<String>(this, 'shipment_agent_code') as String?;
  @override
  set shipmentAgentCode(String? value) =>
      RealmObjectBase.set(this, 'shipment_agent_code', value);

  @override
  String? get arPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'ar_posting_group_code') as String?;
  @override
  set arPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'ar_posting_group_code', value);

  @override
  String? get genBusPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'gen_bus_posting_group_code')
          as String?;
  @override
  set genBusPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'gen_bus_posting_group_code', value);

  @override
  String? get vatBusPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'vat_bus_posting_group_code')
          as String?;
  @override
  set vatBusPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'vat_bus_posting_group_code', value);

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
  String? get priceIncludeVat =>
      RealmObjectBase.get<String>(this, 'price_include_vat') as String?;
  @override
  set priceIncludeVat(String? value) =>
      RealmObjectBase.set(this, 'price_include_vat', value);

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
  String? get projectCode =>
      RealmObjectBase.get<String>(this, 'project_code') as String?;
  @override
  set projectCode(String? value) =>
      RealmObjectBase.set(this, 'project_code', value);

  @override
  String? get customerGroupCode =>
      RealmObjectBase.get<String>(this, 'customer_group_code') as String?;
  @override
  set customerGroupCode(String? value) =>
      RealmObjectBase.set(this, 'customer_group_code', value);

  @override
  String? get externalDocumentNo =>
      RealmObjectBase.get<String>(this, 'external_document_no') as String?;
  @override
  set externalDocumentNo(String? value) =>
      RealmObjectBase.set(this, 'external_document_no', value);

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
  String? get returnReasonCode =>
      RealmObjectBase.get<String>(this, 'return_reason_code') as String?;
  @override
  set returnReasonCode(String? value) =>
      RealmObjectBase.set(this, 'return_reason_code', value);

  @override
  String? get reasonCode =>
      RealmObjectBase.get<String>(this, 'reason_code') as String?;
  @override
  set reasonCode(String? value) =>
      RealmObjectBase.set(this, 'reason_code', value);

  @override
  String? get assignToUserId =>
      RealmObjectBase.get<String>(this, 'assign_to_user_id') as String?;
  @override
  set assignToUserId(String? value) =>
      RealmObjectBase.set(this, 'assign_to_user_id', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get remark => RealmObjectBase.get<String>(this, 'remark') as String?;
  @override
  set remark(String? value) => RealmObjectBase.set(this, 'remark', value);

  @override
  double? get amount =>
      RealmObjectBase.get<double>(this, 'total_amount') as double?;
  @override
  set amount(double? value) => RealmObjectBase.set(this, 'total_amount', value);

  @override
  String get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String;
  @override
  set isSync(String value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  String? get orderDate =>
      RealmObjectBase.get<String>(this, 'order_date') as String?;
  @override
  set orderDate(String? value) =>
      RealmObjectBase.set(this, 'order_date', value);

  @override
  Stream<RealmObjectChanges<SalesHeader>> get changes =>
      RealmObjectBase.getChanges<SalesHeader>(this);

  @override
  Stream<RealmObjectChanges<SalesHeader>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<SalesHeader>(this, keyPaths);

  @override
  SalesHeader freeze() => RealmObjectBase.freezeObject<SalesHeader>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'document_type': documentType.toEJson(),
      'no': no.toEJson(),
      'app_id': appId.toEJson(),
      'customer_no': customerNo.toEJson(),
      'customer_name': customerName.toEJson(),
      'customer_name_2': customerName2.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'location_code': locationCode.toEJson(),
      'ship_to_code': shipToCode.toEJson(),
      'ship_to_name': shipToName.toEJson(),
      'ship_to_name_2': shipToName2.toEJson(),
      'ship_to_address': shipToAddress.toEJson(),
      'ship_to_address_2': shipToAddress2.toEJson(),
      'ship_to_contact_name': shipToContactName.toEJson(),
      'ship_to_phone_no': shipToPhoneNo.toEJson(),
      'ship_to_phone_no_2': shipToPhoneNo2.toEJson(),
      'document_date': documentDate.toEJson(),
      'posting_date': postingDate.toEJson(),
      'request_shipment_date': requestShipmentDate.toEJson(),
      'posting_description': postingDescription.toEJson(),
      'payment_term_code': paymentTermCode.toEJson(),
      'payment_method_code': paymentMethodCode.toEJson(),
      'shipment_method_code': shipmentMethodCode.toEJson(),
      'shipment_agent_code': shipmentAgentCode.toEJson(),
      'ar_posting_group_code': arPostingGroupCode.toEJson(),
      'gen_bus_posting_group_code': genBusPostingGroupCode.toEJson(),
      'vat_bus_posting_group_code': vatBusPostingGroupCode.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'currency_factor': currencyFactor.toEJson(),
      'price_include_vat': priceIncludeVat.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'store_code': storeCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'customer_group_code': customerGroupCode.toEJson(),
      'external_document_no': externalDocumentNo.toEJson(),
      'source_type': sourceType.toEJson(),
      'source_no': sourceNo.toEJson(),
      'return_reason_code': returnReasonCode.toEJson(),
      'reason_code': reasonCode.toEJson(),
      'assign_to_user_id': assignToUserId.toEJson(),
      'status': status.toEJson(),
      'remark': remark.toEJson(),
      'total_amount': amount.toEJson(),
      'is_sync': isSync.toEJson(),
      'order_date': orderDate.toEJson(),
    };
  }

  static EJsonValue _toEJson(SalesHeader value) => value.toEJson();
  static SalesHeader _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => SalesHeader(
        fromEJson(id),
        documentType: fromEJson(ejson['document_type']),
        no: fromEJson(ejson['no']),
        appId: fromEJson(ejson['app_id']),
        customerNo: fromEJson(ejson['customer_no']),
        customerName: fromEJson(ejson['customer_name']),
        customerName2: fromEJson(ejson['customer_name_2']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        locationCode: fromEJson(ejson['location_code']),
        shipToCode: fromEJson(ejson['ship_to_code']),
        shipToName: fromEJson(ejson['ship_to_name']),
        shipToName2: fromEJson(ejson['ship_to_name_2']),
        shipToAddress: fromEJson(ejson['ship_to_address']),
        shipToAddress2: fromEJson(ejson['ship_to_address_2']),
        shipToContactName: fromEJson(ejson['ship_to_contact_name']),
        shipToPhoneNo: fromEJson(ejson['ship_to_phone_no']),
        shipToPhoneNo2: fromEJson(ejson['ship_to_phone_no_2']),
        documentDate: fromEJson(ejson['document_date']),
        postingDate: fromEJson(ejson['posting_date']),
        requestShipmentDate: fromEJson(ejson['request_shipment_date']),
        postingDescription: fromEJson(ejson['posting_description']),
        paymentTermCode: fromEJson(ejson['payment_term_code']),
        paymentMethodCode: fromEJson(ejson['payment_method_code']),
        shipmentMethodCode: fromEJson(ejson['shipment_method_code']),
        shipmentAgentCode: fromEJson(ejson['shipment_agent_code']),
        arPostingGroupCode: fromEJson(ejson['ar_posting_group_code']),
        genBusPostingGroupCode: fromEJson(ejson['gen_bus_posting_group_code']),
        vatBusPostingGroupCode: fromEJson(ejson['vat_bus_posting_group_code']),
        currencyCode: fromEJson(ejson['currency_code']),
        currencyFactor: fromEJson(ejson['currency_factor']),
        priceIncludeVat: fromEJson(ejson['price_include_vat']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        distributorCode: fromEJson(ejson['distributor_code']),
        storeCode: fromEJson(ejson['store_code']),
        divisionCode: fromEJson(ejson['division_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        departmentCode: fromEJson(ejson['department_code']),
        projectCode: fromEJson(ejson['project_code']),
        customerGroupCode: fromEJson(ejson['customer_group_code']),
        externalDocumentNo: fromEJson(ejson['external_document_no']),
        sourceType: fromEJson(ejson['source_type']),
        sourceNo: fromEJson(ejson['source_no']),
        returnReasonCode: fromEJson(ejson['return_reason_code']),
        reasonCode: fromEJson(ejson['reason_code']),
        assignToUserId: fromEJson(ejson['assign_to_user_id']),
        status: fromEJson(ejson['status']),
        remark: fromEJson(ejson['remark']),
        amount: fromEJson(ejson['total_amount']),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
        orderDate: fromEJson(ejson['order_date']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SalesHeader._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      SalesHeader,
      'SALES_HEADER',
      [
        SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
        SchemaProperty(
          'documentType',
          RealmPropertyType.string,
          mapTo: 'document_type',
          optional: true,
        ),
        SchemaProperty('no', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'appId',
          RealmPropertyType.string,
          mapTo: 'app_id',
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
        SchemaProperty('address', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'address2',
          RealmPropertyType.string,
          mapTo: 'address_2',
          optional: true,
        ),
        SchemaProperty(
          'locationCode',
          RealmPropertyType.string,
          mapTo: 'location_code',
          optional: true,
        ),
        SchemaProperty(
          'shipToCode',
          RealmPropertyType.string,
          mapTo: 'ship_to_code',
          optional: true,
        ),
        SchemaProperty(
          'shipToName',
          RealmPropertyType.string,
          mapTo: 'ship_to_name',
          optional: true,
        ),
        SchemaProperty(
          'shipToName2',
          RealmPropertyType.string,
          mapTo: 'ship_to_name_2',
          optional: true,
        ),
        SchemaProperty(
          'shipToAddress',
          RealmPropertyType.string,
          mapTo: 'ship_to_address',
          optional: true,
        ),
        SchemaProperty(
          'shipToAddress2',
          RealmPropertyType.string,
          mapTo: 'ship_to_address_2',
          optional: true,
        ),
        SchemaProperty(
          'shipToContactName',
          RealmPropertyType.string,
          mapTo: 'ship_to_contact_name',
          optional: true,
        ),
        SchemaProperty(
          'shipToPhoneNo',
          RealmPropertyType.string,
          mapTo: 'ship_to_phone_no',
          optional: true,
        ),
        SchemaProperty(
          'shipToPhoneNo2',
          RealmPropertyType.string,
          mapTo: 'ship_to_phone_no_2',
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
          'requestShipmentDate',
          RealmPropertyType.string,
          mapTo: 'request_shipment_date',
          optional: true,
        ),
        SchemaProperty(
          'postingDescription',
          RealmPropertyType.string,
          mapTo: 'posting_description',
          optional: true,
        ),
        SchemaProperty(
          'paymentTermCode',
          RealmPropertyType.string,
          mapTo: 'payment_term_code',
          optional: true,
        ),
        SchemaProperty(
          'paymentMethodCode',
          RealmPropertyType.string,
          mapTo: 'payment_method_code',
          optional: true,
        ),
        SchemaProperty(
          'shipmentMethodCode',
          RealmPropertyType.string,
          mapTo: 'shipment_method_code',
          optional: true,
        ),
        SchemaProperty(
          'shipmentAgentCode',
          RealmPropertyType.string,
          mapTo: 'shipment_agent_code',
          optional: true,
        ),
        SchemaProperty(
          'arPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'ar_posting_group_code',
          optional: true,
        ),
        SchemaProperty(
          'genBusPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'gen_bus_posting_group_code',
          optional: true,
        ),
        SchemaProperty(
          'vatBusPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'vat_bus_posting_group_code',
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
          RealmPropertyType.string,
          mapTo: 'price_include_vat',
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
          'projectCode',
          RealmPropertyType.string,
          mapTo: 'project_code',
          optional: true,
        ),
        SchemaProperty(
          'customerGroupCode',
          RealmPropertyType.string,
          mapTo: 'customer_group_code',
          optional: true,
        ),
        SchemaProperty(
          'externalDocumentNo',
          RealmPropertyType.string,
          mapTo: 'external_document_no',
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
          'returnReasonCode',
          RealmPropertyType.string,
          mapTo: 'return_reason_code',
          optional: true,
        ),
        SchemaProperty(
          'reasonCode',
          RealmPropertyType.string,
          mapTo: 'reason_code',
          optional: true,
        ),
        SchemaProperty(
          'assignToUserId',
          RealmPropertyType.string,
          mapTo: 'assign_to_user_id',
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty('remark', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'amount',
          RealmPropertyType.double,
          mapTo: 'total_amount',
          optional: true,
        ),
        SchemaProperty('isSync', RealmPropertyType.string, mapTo: 'is_sync'),
        SchemaProperty(
          'orderDate',
          RealmPropertyType.string,
          mapTo: 'order_date',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class SalesLine extends _SalesLine
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  SalesLine(
    int id, {
    String? documentType,
    String? documentNo,
    int? lineNo,
    int? referLineNo,
    String? customerNo,
    String? specialType,
    String? specialTypeNo,
    String? type,
    String? no,
    String? description,
    String? description2,
    String? variantCode,
    String? locationCode,
    String? postingGroup,
    String? lotNo,
    String? serialNo,
    String? expiryDate,
    String? warrentyDate,
    String? requestShipmentDate,
    String? unitOfMeasure,
    double? qtyPerUnitOfMeasure = 1,
    double? headerQuantity,
    double? quantity,
    double? outstandingQuantity,
    double? outstandingQuantityBase,
    double? quantityToShip,
    double? quantityToInvoice,
    double? unitPrice,
    double? manualUnitPrice,
    double? unitPriceLcy,
    double? unitPriceOri,
    double? vatPercentage,
    double? vatBaseAmount,
    double? vatAmount,
    double? discountPercentage,
    double? discountAmount,
    double? amount,
    double? amountLcy,
    double? amountIncludingVat,
    double? amountIncludingVatLcy,
    double? grossWeight,
    double? netWeight,
    double? quantityShipped,
    double? quantityInvoiced,
    String? genBusPostingGroupCode,
    String? genProdPostingGroupCode,
    String? vatBusPostingGroupCode,
    String? vatProdPostingGroupCode,
    String? vatCalculationType,
    String? currencyCode,
    double? currencyFactor,
    String? itemCategoryCode,
    String? itemGroupCode,
    String? itemDiscGroupCode,
    String? itemBrandCode,
    String? storeCode,
    String? divisionCode,
    String? businessUnitCode,
    String? departmentCode,
    String? projectCode,
    String? salespersonCode,
    String? distributorCode,
    String? customerGroupCode,
    String? returnReasonCode,
    String? reasonCode,
    int? headerId,
    String? sourceNo,
    String? documentDate,
    String? isManualEdit = "No",
    String? isSync = "Yes",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<SalesLine>({
        'qty_per_unit_of_measure': 1,
        'is_manual_edit': "No",
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'document_type', documentType);
    RealmObjectBase.set(this, 'document_no', documentNo);
    RealmObjectBase.set(this, 'line_no', lineNo);
    RealmObjectBase.set(this, 'refer_line_no', referLineNo);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'special_type', specialType);
    RealmObjectBase.set(this, 'special_type_no', specialTypeNo);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'location_code', locationCode);
    RealmObjectBase.set(this, 'posting_group', postingGroup);
    RealmObjectBase.set(this, 'lot_no', lotNo);
    RealmObjectBase.set(this, 'serial_no', serialNo);
    RealmObjectBase.set(this, 'expiry_date', expiryDate);
    RealmObjectBase.set(this, 'warrenty_date', warrentyDate);
    RealmObjectBase.set(this, 'request_shipment_date', requestShipmentDate);
    RealmObjectBase.set(this, 'unit_of_measure', unitOfMeasure);
    RealmObjectBase.set(this, 'qty_per_unit_of_measure', qtyPerUnitOfMeasure);
    RealmObjectBase.set(this, 'header_quantity', headerQuantity);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'outstanding_quantity', outstandingQuantity);
    RealmObjectBase.set(
      this,
      'outstanding_quantity_base',
      outstandingQuantityBase,
    );
    RealmObjectBase.set(this, 'quantity_to_ship', quantityToShip);
    RealmObjectBase.set(this, 'quantity_to_invoice', quantityToInvoice);
    RealmObjectBase.set(this, 'unit_price', unitPrice);
    RealmObjectBase.set(this, 'manual_unit_price', manualUnitPrice);
    RealmObjectBase.set(this, 'unit_price_lcy', unitPriceLcy);
    RealmObjectBase.set(this, 'unit_price_ori', unitPriceOri);
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
    RealmObjectBase.set(this, 'gross_weight', grossWeight);
    RealmObjectBase.set(this, 'net_weight', netWeight);
    RealmObjectBase.set(this, 'quantity_shipped', quantityShipped);
    RealmObjectBase.set(this, 'quantity_invoiced', quantityInvoiced);
    RealmObjectBase.set(
      this,
      'gen_bus_posting_group_code',
      genBusPostingGroupCode,
    );
    RealmObjectBase.set(
      this,
      'gen_prod_posting_group_code',
      genProdPostingGroupCode,
    );
    RealmObjectBase.set(
      this,
      'vat_bus_posting_group_code',
      vatBusPostingGroupCode,
    );
    RealmObjectBase.set(
      this,
      'vat_prod_posting_group_code',
      vatProdPostingGroupCode,
    );
    RealmObjectBase.set(this, 'vat_calculation_type', vatCalculationType);
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'currency_factor', currencyFactor);
    RealmObjectBase.set(this, 'item_category_code', itemCategoryCode);
    RealmObjectBase.set(this, 'item_group_code', itemGroupCode);
    RealmObjectBase.set(this, 'item_disc_group_code', itemDiscGroupCode);
    RealmObjectBase.set(this, 'item_brand_code', itemBrandCode);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'customer_group_code', customerGroupCode);
    RealmObjectBase.set(this, 'return_reason_code', returnReasonCode);
    RealmObjectBase.set(this, 'reason_code', reasonCode);
    RealmObjectBase.set(this, 'header_id', headerId);
    RealmObjectBase.set(this, 'source_no', sourceNo);
    RealmObjectBase.set(this, 'document_date', documentDate);
    RealmObjectBase.set(this, 'is_manual_edit', isManualEdit);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  SalesLine._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

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
  int? get lineNo => RealmObjectBase.get<int>(this, 'line_no') as int?;
  @override
  set lineNo(int? value) => RealmObjectBase.set(this, 'line_no', value);

  @override
  int? get referLineNo =>
      RealmObjectBase.get<int>(this, 'refer_line_no') as int?;
  @override
  set referLineNo(int? value) =>
      RealmObjectBase.set(this, 'refer_line_no', value);

  @override
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

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
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get no => RealmObjectBase.get<String>(this, 'no') as String?;
  @override
  set no(String? value) => RealmObjectBase.set(this, 'no', value);

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
  String? get variantCode =>
      RealmObjectBase.get<String>(this, 'variant_code') as String?;
  @override
  set variantCode(String? value) =>
      RealmObjectBase.set(this, 'variant_code', value);

  @override
  String? get locationCode =>
      RealmObjectBase.get<String>(this, 'location_code') as String?;
  @override
  set locationCode(String? value) =>
      RealmObjectBase.set(this, 'location_code', value);

  @override
  String? get postingGroup =>
      RealmObjectBase.get<String>(this, 'posting_group') as String?;
  @override
  set postingGroup(String? value) =>
      RealmObjectBase.set(this, 'posting_group', value);

  @override
  String? get lotNo => RealmObjectBase.get<String>(this, 'lot_no') as String?;
  @override
  set lotNo(String? value) => RealmObjectBase.set(this, 'lot_no', value);

  @override
  String? get serialNo =>
      RealmObjectBase.get<String>(this, 'serial_no') as String?;
  @override
  set serialNo(String? value) => RealmObjectBase.set(this, 'serial_no', value);

  @override
  String? get expiryDate =>
      RealmObjectBase.get<String>(this, 'expiry_date') as String?;
  @override
  set expiryDate(String? value) =>
      RealmObjectBase.set(this, 'expiry_date', value);

  @override
  String? get warrentyDate =>
      RealmObjectBase.get<String>(this, 'warrenty_date') as String?;
  @override
  set warrentyDate(String? value) =>
      RealmObjectBase.set(this, 'warrenty_date', value);

  @override
  String? get requestShipmentDate =>
      RealmObjectBase.get<String>(this, 'request_shipment_date') as String?;
  @override
  set requestShipmentDate(String? value) =>
      RealmObjectBase.set(this, 'request_shipment_date', value);

  @override
  String? get unitOfMeasure =>
      RealmObjectBase.get<String>(this, 'unit_of_measure') as String?;
  @override
  set unitOfMeasure(String? value) =>
      RealmObjectBase.set(this, 'unit_of_measure', value);

  @override
  double? get qtyPerUnitOfMeasure =>
      RealmObjectBase.get<double>(this, 'qty_per_unit_of_measure') as double?;
  @override
  set qtyPerUnitOfMeasure(double? value) =>
      RealmObjectBase.set(this, 'qty_per_unit_of_measure', value);

  @override
  double? get headerQuantity =>
      RealmObjectBase.get<double>(this, 'header_quantity') as double?;
  @override
  set headerQuantity(double? value) =>
      RealmObjectBase.set(this, 'header_quantity', value);

  @override
  double? get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double?;
  @override
  set quantity(double? value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  double? get outstandingQuantity =>
      RealmObjectBase.get<double>(this, 'outstanding_quantity') as double?;
  @override
  set outstandingQuantity(double? value) =>
      RealmObjectBase.set(this, 'outstanding_quantity', value);

  @override
  double? get outstandingQuantityBase =>
      RealmObjectBase.get<double>(this, 'outstanding_quantity_base') as double?;
  @override
  set outstandingQuantityBase(double? value) =>
      RealmObjectBase.set(this, 'outstanding_quantity_base', value);

  @override
  double? get quantityToShip =>
      RealmObjectBase.get<double>(this, 'quantity_to_ship') as double?;
  @override
  set quantityToShip(double? value) =>
      RealmObjectBase.set(this, 'quantity_to_ship', value);

  @override
  double? get quantityToInvoice =>
      RealmObjectBase.get<double>(this, 'quantity_to_invoice') as double?;
  @override
  set quantityToInvoice(double? value) =>
      RealmObjectBase.set(this, 'quantity_to_invoice', value);

  @override
  double? get unitPrice =>
      RealmObjectBase.get<double>(this, 'unit_price') as double?;
  @override
  set unitPrice(double? value) =>
      RealmObjectBase.set(this, 'unit_price', value);

  @override
  double? get manualUnitPrice =>
      RealmObjectBase.get<double>(this, 'manual_unit_price') as double?;
  @override
  set manualUnitPrice(double? value) =>
      RealmObjectBase.set(this, 'manual_unit_price', value);

  @override
  double? get unitPriceLcy =>
      RealmObjectBase.get<double>(this, 'unit_price_lcy') as double?;
  @override
  set unitPriceLcy(double? value) =>
      RealmObjectBase.set(this, 'unit_price_lcy', value);

  @override
  double? get unitPriceOri =>
      RealmObjectBase.get<double>(this, 'unit_price_ori') as double?;
  @override
  set unitPriceOri(double? value) =>
      RealmObjectBase.set(this, 'unit_price_ori', value);

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
  double? get grossWeight =>
      RealmObjectBase.get<double>(this, 'gross_weight') as double?;
  @override
  set grossWeight(double? value) =>
      RealmObjectBase.set(this, 'gross_weight', value);

  @override
  double? get netWeight =>
      RealmObjectBase.get<double>(this, 'net_weight') as double?;
  @override
  set netWeight(double? value) =>
      RealmObjectBase.set(this, 'net_weight', value);

  @override
  double? get quantityShipped =>
      RealmObjectBase.get<double>(this, 'quantity_shipped') as double?;
  @override
  set quantityShipped(double? value) =>
      RealmObjectBase.set(this, 'quantity_shipped', value);

  @override
  double? get quantityInvoiced =>
      RealmObjectBase.get<double>(this, 'quantity_invoiced') as double?;
  @override
  set quantityInvoiced(double? value) =>
      RealmObjectBase.set(this, 'quantity_invoiced', value);

  @override
  String? get genBusPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'gen_bus_posting_group_code')
          as String?;
  @override
  set genBusPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'gen_bus_posting_group_code', value);

  @override
  String? get genProdPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'gen_prod_posting_group_code')
          as String?;
  @override
  set genProdPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'gen_prod_posting_group_code', value);

  @override
  String? get vatBusPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'vat_bus_posting_group_code')
          as String?;
  @override
  set vatBusPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'vat_bus_posting_group_code', value);

  @override
  String? get vatProdPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'vat_prod_posting_group_code')
          as String?;
  @override
  set vatProdPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'vat_prod_posting_group_code', value);

  @override
  String? get vatCalculationType =>
      RealmObjectBase.get<String>(this, 'vat_calculation_type') as String?;
  @override
  set vatCalculationType(String? value) =>
      RealmObjectBase.set(this, 'vat_calculation_type', value);

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
  String? get itemDiscGroupCode =>
      RealmObjectBase.get<String>(this, 'item_disc_group_code') as String?;
  @override
  set itemDiscGroupCode(String? value) =>
      RealmObjectBase.set(this, 'item_disc_group_code', value);

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
  String? get returnReasonCode =>
      RealmObjectBase.get<String>(this, 'return_reason_code') as String?;
  @override
  set returnReasonCode(String? value) =>
      RealmObjectBase.set(this, 'return_reason_code', value);

  @override
  String? get reasonCode =>
      RealmObjectBase.get<String>(this, 'reason_code') as String?;
  @override
  set reasonCode(String? value) =>
      RealmObjectBase.set(this, 'reason_code', value);

  @override
  int? get headerId => RealmObjectBase.get<int>(this, 'header_id') as int?;
  @override
  set headerId(int? value) => RealmObjectBase.set(this, 'header_id', value);

  @override
  String? get sourceNo =>
      RealmObjectBase.get<String>(this, 'source_no') as String?;
  @override
  set sourceNo(String? value) => RealmObjectBase.set(this, 'source_no', value);

  @override
  String? get documentDate =>
      RealmObjectBase.get<String>(this, 'document_date') as String?;
  @override
  set documentDate(String? value) =>
      RealmObjectBase.set(this, 'document_date', value);

  @override
  String? get isManualEdit =>
      RealmObjectBase.get<String>(this, 'is_manual_edit') as String?;
  @override
  set isManualEdit(String? value) =>
      RealmObjectBase.set(this, 'is_manual_edit', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<SalesLine>> get changes =>
      RealmObjectBase.getChanges<SalesLine>(this);

  @override
  Stream<RealmObjectChanges<SalesLine>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<SalesLine>(this, keyPaths);

  @override
  SalesLine freeze() => RealmObjectBase.freezeObject<SalesLine>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'document_type': documentType.toEJson(),
      'document_no': documentNo.toEJson(),
      'line_no': lineNo.toEJson(),
      'refer_line_no': referLineNo.toEJson(),
      'customer_no': customerNo.toEJson(),
      'special_type': specialType.toEJson(),
      'special_type_no': specialTypeNo.toEJson(),
      'type': type.toEJson(),
      'no': no.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'variant_code': variantCode.toEJson(),
      'location_code': locationCode.toEJson(),
      'posting_group': postingGroup.toEJson(),
      'lot_no': lotNo.toEJson(),
      'serial_no': serialNo.toEJson(),
      'expiry_date': expiryDate.toEJson(),
      'warrenty_date': warrentyDate.toEJson(),
      'request_shipment_date': requestShipmentDate.toEJson(),
      'unit_of_measure': unitOfMeasure.toEJson(),
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure.toEJson(),
      'header_quantity': headerQuantity.toEJson(),
      'quantity': quantity.toEJson(),
      'outstanding_quantity': outstandingQuantity.toEJson(),
      'outstanding_quantity_base': outstandingQuantityBase.toEJson(),
      'quantity_to_ship': quantityToShip.toEJson(),
      'quantity_to_invoice': quantityToInvoice.toEJson(),
      'unit_price': unitPrice.toEJson(),
      'manual_unit_price': manualUnitPrice.toEJson(),
      'unit_price_lcy': unitPriceLcy.toEJson(),
      'unit_price_ori': unitPriceOri.toEJson(),
      'vat_percentage': vatPercentage.toEJson(),
      'vat_base_amount': vatBaseAmount.toEJson(),
      'vat_amount': vatAmount.toEJson(),
      'discount_percentage': discountPercentage.toEJson(),
      'discount_amount': discountAmount.toEJson(),
      'amount': amount.toEJson(),
      'amount_lcy': amountLcy.toEJson(),
      'amount_including_vat': amountIncludingVat.toEJson(),
      'amount_including_vat_lcy': amountIncludingVatLcy.toEJson(),
      'gross_weight': grossWeight.toEJson(),
      'net_weight': netWeight.toEJson(),
      'quantity_shipped': quantityShipped.toEJson(),
      'quantity_invoiced': quantityInvoiced.toEJson(),
      'gen_bus_posting_group_code': genBusPostingGroupCode.toEJson(),
      'gen_prod_posting_group_code': genProdPostingGroupCode.toEJson(),
      'vat_bus_posting_group_code': vatBusPostingGroupCode.toEJson(),
      'vat_prod_posting_group_code': vatProdPostingGroupCode.toEJson(),
      'vat_calculation_type': vatCalculationType.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'currency_factor': currencyFactor.toEJson(),
      'item_category_code': itemCategoryCode.toEJson(),
      'item_group_code': itemGroupCode.toEJson(),
      'item_disc_group_code': itemDiscGroupCode.toEJson(),
      'item_brand_code': itemBrandCode.toEJson(),
      'store_code': storeCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'customer_group_code': customerGroupCode.toEJson(),
      'return_reason_code': returnReasonCode.toEJson(),
      'reason_code': reasonCode.toEJson(),
      'header_id': headerId.toEJson(),
      'source_no': sourceNo.toEJson(),
      'document_date': documentDate.toEJson(),
      'is_manual_edit': isManualEdit.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(SalesLine value) => value.toEJson();
  static SalesLine _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => SalesLine(
        fromEJson(id),
        documentType: fromEJson(ejson['document_type']),
        documentNo: fromEJson(ejson['document_no']),
        lineNo: fromEJson(ejson['line_no']),
        referLineNo: fromEJson(ejson['refer_line_no']),
        customerNo: fromEJson(ejson['customer_no']),
        specialType: fromEJson(ejson['special_type']),
        specialTypeNo: fromEJson(ejson['special_type_no']),
        type: fromEJson(ejson['type']),
        no: fromEJson(ejson['no']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        variantCode: fromEJson(ejson['variant_code']),
        locationCode: fromEJson(ejson['location_code']),
        postingGroup: fromEJson(ejson['posting_group']),
        lotNo: fromEJson(ejson['lot_no']),
        serialNo: fromEJson(ejson['serial_no']),
        expiryDate: fromEJson(ejson['expiry_date']),
        warrentyDate: fromEJson(ejson['warrenty_date']),
        requestShipmentDate: fromEJson(ejson['request_shipment_date']),
        unitOfMeasure: fromEJson(ejson['unit_of_measure']),
        qtyPerUnitOfMeasure: fromEJson(
          ejson['qty_per_unit_of_measure'],
          defaultValue: 1,
        ),
        headerQuantity: fromEJson(ejson['header_quantity']),
        quantity: fromEJson(ejson['quantity']),
        outstandingQuantity: fromEJson(ejson['outstanding_quantity']),
        outstandingQuantityBase: fromEJson(ejson['outstanding_quantity_base']),
        quantityToShip: fromEJson(ejson['quantity_to_ship']),
        quantityToInvoice: fromEJson(ejson['quantity_to_invoice']),
        unitPrice: fromEJson(ejson['unit_price']),
        manualUnitPrice: fromEJson(ejson['manual_unit_price']),
        unitPriceLcy: fromEJson(ejson['unit_price_lcy']),
        unitPriceOri: fromEJson(ejson['unit_price_ori']),
        vatPercentage: fromEJson(ejson['vat_percentage']),
        vatBaseAmount: fromEJson(ejson['vat_base_amount']),
        vatAmount: fromEJson(ejson['vat_amount']),
        discountPercentage: fromEJson(ejson['discount_percentage']),
        discountAmount: fromEJson(ejson['discount_amount']),
        amount: fromEJson(ejson['amount']),
        amountLcy: fromEJson(ejson['amount_lcy']),
        amountIncludingVat: fromEJson(ejson['amount_including_vat']),
        amountIncludingVatLcy: fromEJson(ejson['amount_including_vat_lcy']),
        grossWeight: fromEJson(ejson['gross_weight']),
        netWeight: fromEJson(ejson['net_weight']),
        quantityShipped: fromEJson(ejson['quantity_shipped']),
        quantityInvoiced: fromEJson(ejson['quantity_invoiced']),
        genBusPostingGroupCode: fromEJson(ejson['gen_bus_posting_group_code']),
        genProdPostingGroupCode: fromEJson(
          ejson['gen_prod_posting_group_code'],
        ),
        vatBusPostingGroupCode: fromEJson(ejson['vat_bus_posting_group_code']),
        vatProdPostingGroupCode: fromEJson(
          ejson['vat_prod_posting_group_code'],
        ),
        vatCalculationType: fromEJson(ejson['vat_calculation_type']),
        currencyCode: fromEJson(ejson['currency_code']),
        currencyFactor: fromEJson(ejson['currency_factor']),
        itemCategoryCode: fromEJson(ejson['item_category_code']),
        itemGroupCode: fromEJson(ejson['item_group_code']),
        itemDiscGroupCode: fromEJson(ejson['item_disc_group_code']),
        itemBrandCode: fromEJson(ejson['item_brand_code']),
        storeCode: fromEJson(ejson['store_code']),
        divisionCode: fromEJson(ejson['division_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        departmentCode: fromEJson(ejson['department_code']),
        projectCode: fromEJson(ejson['project_code']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        distributorCode: fromEJson(ejson['distributor_code']),
        customerGroupCode: fromEJson(ejson['customer_group_code']),
        returnReasonCode: fromEJson(ejson['return_reason_code']),
        reasonCode: fromEJson(ejson['reason_code']),
        headerId: fromEJson(ejson['header_id']),
        sourceNo: fromEJson(ejson['source_no']),
        documentDate: fromEJson(ejson['document_date']),
        isManualEdit: fromEJson(ejson['is_manual_edit'], defaultValue: "No"),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SalesLine._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, SalesLine, 'SALES_LINE', [
      SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
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
        'lineNo',
        RealmPropertyType.int,
        mapTo: 'line_no',
        optional: true,
      ),
      SchemaProperty(
        'referLineNo',
        RealmPropertyType.int,
        mapTo: 'refer_line_no',
        optional: true,
      ),
      SchemaProperty(
        'customerNo',
        RealmPropertyType.string,
        mapTo: 'customer_no',
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
      SchemaProperty('type', RealmPropertyType.string, optional: true),
      SchemaProperty('no', RealmPropertyType.string, optional: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'description2',
        RealmPropertyType.string,
        mapTo: 'description_2',
        optional: true,
      ),
      SchemaProperty(
        'variantCode',
        RealmPropertyType.string,
        mapTo: 'variant_code',
        optional: true,
      ),
      SchemaProperty(
        'locationCode',
        RealmPropertyType.string,
        mapTo: 'location_code',
        optional: true,
      ),
      SchemaProperty(
        'postingGroup',
        RealmPropertyType.string,
        mapTo: 'posting_group',
        optional: true,
      ),
      SchemaProperty(
        'lotNo',
        RealmPropertyType.string,
        mapTo: 'lot_no',
        optional: true,
      ),
      SchemaProperty(
        'serialNo',
        RealmPropertyType.string,
        mapTo: 'serial_no',
        optional: true,
      ),
      SchemaProperty(
        'expiryDate',
        RealmPropertyType.string,
        mapTo: 'expiry_date',
        optional: true,
      ),
      SchemaProperty(
        'warrentyDate',
        RealmPropertyType.string,
        mapTo: 'warrenty_date',
        optional: true,
      ),
      SchemaProperty(
        'requestShipmentDate',
        RealmPropertyType.string,
        mapTo: 'request_shipment_date',
        optional: true,
      ),
      SchemaProperty(
        'unitOfMeasure',
        RealmPropertyType.string,
        mapTo: 'unit_of_measure',
        optional: true,
      ),
      SchemaProperty(
        'qtyPerUnitOfMeasure',
        RealmPropertyType.double,
        mapTo: 'qty_per_unit_of_measure',
        optional: true,
      ),
      SchemaProperty(
        'headerQuantity',
        RealmPropertyType.double,
        mapTo: 'header_quantity',
        optional: true,
      ),
      SchemaProperty('quantity', RealmPropertyType.double, optional: true),
      SchemaProperty(
        'outstandingQuantity',
        RealmPropertyType.double,
        mapTo: 'outstanding_quantity',
        optional: true,
      ),
      SchemaProperty(
        'outstandingQuantityBase',
        RealmPropertyType.double,
        mapTo: 'outstanding_quantity_base',
        optional: true,
      ),
      SchemaProperty(
        'quantityToShip',
        RealmPropertyType.double,
        mapTo: 'quantity_to_ship',
        optional: true,
      ),
      SchemaProperty(
        'quantityToInvoice',
        RealmPropertyType.double,
        mapTo: 'quantity_to_invoice',
        optional: true,
      ),
      SchemaProperty(
        'unitPrice',
        RealmPropertyType.double,
        mapTo: 'unit_price',
        optional: true,
      ),
      SchemaProperty(
        'manualUnitPrice',
        RealmPropertyType.double,
        mapTo: 'manual_unit_price',
        optional: true,
      ),
      SchemaProperty(
        'unitPriceLcy',
        RealmPropertyType.double,
        mapTo: 'unit_price_lcy',
        optional: true,
      ),
      SchemaProperty(
        'unitPriceOri',
        RealmPropertyType.double,
        mapTo: 'unit_price_ori',
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
        'grossWeight',
        RealmPropertyType.double,
        mapTo: 'gross_weight',
        optional: true,
      ),
      SchemaProperty(
        'netWeight',
        RealmPropertyType.double,
        mapTo: 'net_weight',
        optional: true,
      ),
      SchemaProperty(
        'quantityShipped',
        RealmPropertyType.double,
        mapTo: 'quantity_shipped',
        optional: true,
      ),
      SchemaProperty(
        'quantityInvoiced',
        RealmPropertyType.double,
        mapTo: 'quantity_invoiced',
        optional: true,
      ),
      SchemaProperty(
        'genBusPostingGroupCode',
        RealmPropertyType.string,
        mapTo: 'gen_bus_posting_group_code',
        optional: true,
      ),
      SchemaProperty(
        'genProdPostingGroupCode',
        RealmPropertyType.string,
        mapTo: 'gen_prod_posting_group_code',
        optional: true,
      ),
      SchemaProperty(
        'vatBusPostingGroupCode',
        RealmPropertyType.string,
        mapTo: 'vat_bus_posting_group_code',
        optional: true,
      ),
      SchemaProperty(
        'vatProdPostingGroupCode',
        RealmPropertyType.string,
        mapTo: 'vat_prod_posting_group_code',
        optional: true,
      ),
      SchemaProperty(
        'vatCalculationType',
        RealmPropertyType.string,
        mapTo: 'vat_calculation_type',
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
        'itemDiscGroupCode',
        RealmPropertyType.string,
        mapTo: 'item_disc_group_code',
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
        'returnReasonCode',
        RealmPropertyType.string,
        mapTo: 'return_reason_code',
        optional: true,
      ),
      SchemaProperty(
        'reasonCode',
        RealmPropertyType.string,
        mapTo: 'reason_code',
        optional: true,
      ),
      SchemaProperty(
        'headerId',
        RealmPropertyType.int,
        mapTo: 'header_id',
        optional: true,
      ),
      SchemaProperty(
        'sourceNo',
        RealmPropertyType.string,
        mapTo: 'source_no',
        optional: true,
      ),
      SchemaProperty(
        'documentDate',
        RealmPropertyType.string,
        mapTo: 'document_date',
        optional: true,
      ),
      SchemaProperty(
        'isManualEdit',
        RealmPropertyType.string,
        mapTo: 'is_manual_edit',
        optional: true,
      ),
      SchemaProperty(
        'isSync',
        RealmPropertyType.string,
        mapTo: 'is_sync',
        optional: true,
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class TmpSalesShipmentPlaning extends _TmpSalesShipmentPlaning
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  TmpSalesShipmentPlaning(
    int id, {
    int? appId,
    String? documentType,
    String? documentNo,
    int? lineNo,
    int? cartLineId,
    String? type,
    String? no,
    String? specialType,
    String? specialTypeNo,
    String? variantCode,
    String? locationCode,
    String? lotNo,
    String? serialNo,
    String? shipmentDate,
    String? description,
    String? description2,
    String? unitOfMeasure,
    double? qtyPerUnitOfMeasure,
    double? quantity = 0,
    double? quantityBase = 0,
    int? applyToItemEntryNo,
    String? assignToUserid,
    String? assignToUsername,
    String? itemCategoryCode,
    String? itemGroupCode,
    String? itemDiscGroupCode,
    String? itemBrandCode,
    String? storeCode,
    String? divisionCode,
    String? businessUnitCode,
    String? departmentCode,
    String? projectCode,
    String? salespersonCode,
    String? distributorCode,
    String? customerGroupCode,
    String? isSync = "Yes",
    String? appCreatedAt,
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<TmpSalesShipmentPlaning>({
        'quantity': 0,
        'quantity_base': 0,
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'app_id', appId);
    RealmObjectBase.set(this, 'document_type', documentType);
    RealmObjectBase.set(this, 'document_no', documentNo);
    RealmObjectBase.set(this, 'line_no', lineNo);
    RealmObjectBase.set(this, 'cart_line_id', cartLineId);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'special_type', specialType);
    RealmObjectBase.set(this, 'special_type_no', specialTypeNo);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'location_code', locationCode);
    RealmObjectBase.set(this, 'lot_no', lotNo);
    RealmObjectBase.set(this, 'serial_no', serialNo);
    RealmObjectBase.set(this, 'shipment_date', shipmentDate);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'unit_of_measure', unitOfMeasure);
    RealmObjectBase.set(this, 'qty_per_unit_of_measure', qtyPerUnitOfMeasure);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'quantity_base', quantityBase);
    RealmObjectBase.set(this, 'apply_to_item_entry_no', applyToItemEntryNo);
    RealmObjectBase.set(this, 'assign_to_userid', assignToUserid);
    RealmObjectBase.set(this, 'assign_to_username', assignToUsername);
    RealmObjectBase.set(this, 'item_category_code', itemCategoryCode);
    RealmObjectBase.set(this, 'item_group_code', itemGroupCode);
    RealmObjectBase.set(this, 'item_disc_group_code', itemDiscGroupCode);
    RealmObjectBase.set(this, 'item_brand_code', itemBrandCode);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'customer_group_code', customerGroupCode);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'app_created_at', appCreatedAt);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  TmpSalesShipmentPlaning._();

  @override
  int get id => RealmObjectBase.get<int>(this, 'id') as int;
  @override
  set id(int value) => RealmObjectBase.set(this, 'id', value);

  @override
  int? get appId => RealmObjectBase.get<int>(this, 'app_id') as int?;
  @override
  set appId(int? value) => RealmObjectBase.set(this, 'app_id', value);

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
  int? get lineNo => RealmObjectBase.get<int>(this, 'line_no') as int?;
  @override
  set lineNo(int? value) => RealmObjectBase.set(this, 'line_no', value);

  @override
  int? get cartLineId => RealmObjectBase.get<int>(this, 'cart_line_id') as int?;
  @override
  set cartLineId(int? value) =>
      RealmObjectBase.set(this, 'cart_line_id', value);

  @override
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get no => RealmObjectBase.get<String>(this, 'no') as String?;
  @override
  set no(String? value) => RealmObjectBase.set(this, 'no', value);

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
  String? get variantCode =>
      RealmObjectBase.get<String>(this, 'variant_code') as String?;
  @override
  set variantCode(String? value) =>
      RealmObjectBase.set(this, 'variant_code', value);

  @override
  String? get locationCode =>
      RealmObjectBase.get<String>(this, 'location_code') as String?;
  @override
  set locationCode(String? value) =>
      RealmObjectBase.set(this, 'location_code', value);

  @override
  String? get lotNo => RealmObjectBase.get<String>(this, 'lot_no') as String?;
  @override
  set lotNo(String? value) => RealmObjectBase.set(this, 'lot_no', value);

  @override
  String? get serialNo =>
      RealmObjectBase.get<String>(this, 'serial_no') as String?;
  @override
  set serialNo(String? value) => RealmObjectBase.set(this, 'serial_no', value);

  @override
  String? get shipmentDate =>
      RealmObjectBase.get<String>(this, 'shipment_date') as String?;
  @override
  set shipmentDate(String? value) =>
      RealmObjectBase.set(this, 'shipment_date', value);

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
  String? get unitOfMeasure =>
      RealmObjectBase.get<String>(this, 'unit_of_measure') as String?;
  @override
  set unitOfMeasure(String? value) =>
      RealmObjectBase.set(this, 'unit_of_measure', value);

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
  double? get quantityBase =>
      RealmObjectBase.get<double>(this, 'quantity_base') as double?;
  @override
  set quantityBase(double? value) =>
      RealmObjectBase.set(this, 'quantity_base', value);

  @override
  int? get applyToItemEntryNo =>
      RealmObjectBase.get<int>(this, 'apply_to_item_entry_no') as int?;
  @override
  set applyToItemEntryNo(int? value) =>
      RealmObjectBase.set(this, 'apply_to_item_entry_no', value);

  @override
  String? get assignToUserid =>
      RealmObjectBase.get<String>(this, 'assign_to_userid') as String?;
  @override
  set assignToUserid(String? value) =>
      RealmObjectBase.set(this, 'assign_to_userid', value);

  @override
  String? get assignToUsername =>
      RealmObjectBase.get<String>(this, 'assign_to_username') as String?;
  @override
  set assignToUsername(String? value) =>
      RealmObjectBase.set(this, 'assign_to_username', value);

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
  String? get itemDiscGroupCode =>
      RealmObjectBase.get<String>(this, 'item_disc_group_code') as String?;
  @override
  set itemDiscGroupCode(String? value) =>
      RealmObjectBase.set(this, 'item_disc_group_code', value);

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
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  String? get appCreatedAt =>
      RealmObjectBase.get<String>(this, 'app_created_at') as String?;
  @override
  set appCreatedAt(String? value) =>
      RealmObjectBase.set(this, 'app_created_at', value);

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
  Stream<RealmObjectChanges<TmpSalesShipmentPlaning>> get changes =>
      RealmObjectBase.getChanges<TmpSalesShipmentPlaning>(this);

  @override
  Stream<RealmObjectChanges<TmpSalesShipmentPlaning>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<TmpSalesShipmentPlaning>(this, keyPaths);

  @override
  TmpSalesShipmentPlaning freeze() =>
      RealmObjectBase.freezeObject<TmpSalesShipmentPlaning>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'app_id': appId.toEJson(),
      'document_type': documentType.toEJson(),
      'document_no': documentNo.toEJson(),
      'line_no': lineNo.toEJson(),
      'cart_line_id': cartLineId.toEJson(),
      'type': type.toEJson(),
      'no': no.toEJson(),
      'special_type': specialType.toEJson(),
      'special_type_no': specialTypeNo.toEJson(),
      'variant_code': variantCode.toEJson(),
      'location_code': locationCode.toEJson(),
      'lot_no': lotNo.toEJson(),
      'serial_no': serialNo.toEJson(),
      'shipment_date': shipmentDate.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'unit_of_measure': unitOfMeasure.toEJson(),
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure.toEJson(),
      'quantity': quantity.toEJson(),
      'quantity_base': quantityBase.toEJson(),
      'apply_to_item_entry_no': applyToItemEntryNo.toEJson(),
      'assign_to_userid': assignToUserid.toEJson(),
      'assign_to_username': assignToUsername.toEJson(),
      'item_category_code': itemCategoryCode.toEJson(),
      'item_group_code': itemGroupCode.toEJson(),
      'item_disc_group_code': itemDiscGroupCode.toEJson(),
      'item_brand_code': itemBrandCode.toEJson(),
      'store_code': storeCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'customer_group_code': customerGroupCode.toEJson(),
      'is_sync': isSync.toEJson(),
      'app_created_at': appCreatedAt.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(TmpSalesShipmentPlaning value) => value.toEJson();
  static TmpSalesShipmentPlaning _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => TmpSalesShipmentPlaning(
        fromEJson(id),
        appId: fromEJson(ejson['app_id']),
        documentType: fromEJson(ejson['document_type']),
        documentNo: fromEJson(ejson['document_no']),
        lineNo: fromEJson(ejson['line_no']),
        cartLineId: fromEJson(ejson['cart_line_id']),
        type: fromEJson(ejson['type']),
        no: fromEJson(ejson['no']),
        specialType: fromEJson(ejson['special_type']),
        specialTypeNo: fromEJson(ejson['special_type_no']),
        variantCode: fromEJson(ejson['variant_code']),
        locationCode: fromEJson(ejson['location_code']),
        lotNo: fromEJson(ejson['lot_no']),
        serialNo: fromEJson(ejson['serial_no']),
        shipmentDate: fromEJson(ejson['shipment_date']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        unitOfMeasure: fromEJson(ejson['unit_of_measure']),
        qtyPerUnitOfMeasure: fromEJson(ejson['qty_per_unit_of_measure']),
        quantity: fromEJson(ejson['quantity'], defaultValue: 0),
        quantityBase: fromEJson(ejson['quantity_base'], defaultValue: 0),
        applyToItemEntryNo: fromEJson(ejson['apply_to_item_entry_no']),
        assignToUserid: fromEJson(ejson['assign_to_userid']),
        assignToUsername: fromEJson(ejson['assign_to_username']),
        itemCategoryCode: fromEJson(ejson['item_category_code']),
        itemGroupCode: fromEJson(ejson['item_group_code']),
        itemDiscGroupCode: fromEJson(ejson['item_disc_group_code']),
        itemBrandCode: fromEJson(ejson['item_brand_code']),
        storeCode: fromEJson(ejson['store_code']),
        divisionCode: fromEJson(ejson['division_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        departmentCode: fromEJson(ejson['department_code']),
        projectCode: fromEJson(ejson['project_code']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        distributorCode: fromEJson(ejson['distributor_code']),
        customerGroupCode: fromEJson(ejson['customer_group_code']),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
        appCreatedAt: fromEJson(ejson['app_created_at']),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(TmpSalesShipmentPlaning._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      TmpSalesShipmentPlaning,
      'TMP_SALES_SHIPMENT_PLANING',
      [
        SchemaProperty('id', RealmPropertyType.int, primaryKey: true),
        SchemaProperty(
          'appId',
          RealmPropertyType.int,
          mapTo: 'app_id',
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
          'lineNo',
          RealmPropertyType.int,
          mapTo: 'line_no',
          optional: true,
        ),
        SchemaProperty(
          'cartLineId',
          RealmPropertyType.int,
          mapTo: 'cart_line_id',
          optional: true,
        ),
        SchemaProperty('type', RealmPropertyType.string, optional: true),
        SchemaProperty('no', RealmPropertyType.string, optional: true),
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
          'variantCode',
          RealmPropertyType.string,
          mapTo: 'variant_code',
          optional: true,
        ),
        SchemaProperty(
          'locationCode',
          RealmPropertyType.string,
          mapTo: 'location_code',
          optional: true,
        ),
        SchemaProperty(
          'lotNo',
          RealmPropertyType.string,
          mapTo: 'lot_no',
          optional: true,
        ),
        SchemaProperty(
          'serialNo',
          RealmPropertyType.string,
          mapTo: 'serial_no',
          optional: true,
        ),
        SchemaProperty(
          'shipmentDate',
          RealmPropertyType.string,
          mapTo: 'shipment_date',
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
          'unitOfMeasure',
          RealmPropertyType.string,
          mapTo: 'unit_of_measure',
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
          'quantityBase',
          RealmPropertyType.double,
          mapTo: 'quantity_base',
          optional: true,
        ),
        SchemaProperty(
          'applyToItemEntryNo',
          RealmPropertyType.int,
          mapTo: 'apply_to_item_entry_no',
          optional: true,
        ),
        SchemaProperty(
          'assignToUserid',
          RealmPropertyType.string,
          mapTo: 'assign_to_userid',
          optional: true,
        ),
        SchemaProperty(
          'assignToUsername',
          RealmPropertyType.string,
          mapTo: 'assign_to_username',
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
          'itemDiscGroupCode',
          RealmPropertyType.string,
          mapTo: 'item_disc_group_code',
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
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
          optional: true,
        ),
        SchemaProperty(
          'appCreatedAt',
          RealmPropertyType.string,
          mapTo: 'app_created_at',
          optional: true,
        ),
        SchemaProperty(
          'createdAt',
          RealmPropertyType.string,
          mapTo: 'created_at',
          optional: true,
        ),
        SchemaProperty(
          'updatedAt',
          RealmPropertyType.string,
          mapTo: 'updated_at',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemStockRequestWorkSheet extends _ItemStockRequestWorkSheet
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ItemStockRequestWorkSheet(
    String id,
    String itemNo, {
    String? appId,
    String? fromLocationCode,
    String? locationCode,
    String? purchaserCode,
    String? variantCode,
    String? description,
    String? description2,
    String? unitOfMeasureCode,
    double qtyPerUnitOfMeasure = 1.0,
    double orgQuantity = 0,
    double quantity = 0,
    double quantityBase = 0,
    double quantityToShip = 0,
    double quantityToReceive = 0,
    double quantityShipped = 0,
    double quantityReceived = 0,
    String? postingDate,
    String? documentType,
    String? documentNo,
    String? documentLineNo,
    String status = "New",
    String? backendStatus,
    String? transferDocumentNo,
    String isSync = "Yes",
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ItemStockRequestWorkSheet>({
        'qty_per_unit_of_measure': 1.0,
        'org_quantity': 0,
        'quantity': 0,
        'quantity_base': 0,
        'quantity_to_ship': 0,
        'quantity_to_receive': 0,
        'quantity_shipped': 0,
        'quantity_received': 0,
        'status': "New",
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'app_id', appId);
    RealmObjectBase.set(this, 'from_location_code', fromLocationCode);
    RealmObjectBase.set(this, 'location_code', locationCode);
    RealmObjectBase.set(this, 'purchaser_code', purchaserCode);
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'variant_code', variantCode);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'unit_of_measure_code', unitOfMeasureCode);
    RealmObjectBase.set(this, 'qty_per_unit_of_measure', qtyPerUnitOfMeasure);
    RealmObjectBase.set(this, 'org_quantity', orgQuantity);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'quantity_base', quantityBase);
    RealmObjectBase.set(this, 'quantity_to_ship', quantityToShip);
    RealmObjectBase.set(this, 'quantity_to_receive', quantityToReceive);
    RealmObjectBase.set(this, 'quantity_shipped', quantityShipped);
    RealmObjectBase.set(this, 'quantity_received', quantityReceived);
    RealmObjectBase.set(this, 'posting_date', postingDate);
    RealmObjectBase.set(this, 'document_type', documentType);
    RealmObjectBase.set(this, 'document_no', documentNo);
    RealmObjectBase.set(this, 'document_line_no', documentLineNo);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'backend_status', backendStatus);
    RealmObjectBase.set(this, 'transfer_document_no', transferDocumentNo);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  ItemStockRequestWorkSheet._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get appId => RealmObjectBase.get<String>(this, 'app_id') as String?;
  @override
  set appId(String? value) => RealmObjectBase.set(this, 'app_id', value);

  @override
  String? get fromLocationCode =>
      RealmObjectBase.get<String>(this, 'from_location_code') as String?;
  @override
  set fromLocationCode(String? value) =>
      RealmObjectBase.set(this, 'from_location_code', value);

  @override
  String? get locationCode =>
      RealmObjectBase.get<String>(this, 'location_code') as String?;
  @override
  set locationCode(String? value) =>
      RealmObjectBase.set(this, 'location_code', value);

  @override
  String? get purchaserCode =>
      RealmObjectBase.get<String>(this, 'purchaser_code') as String?;
  @override
  set purchaserCode(String? value) =>
      RealmObjectBase.set(this, 'purchaser_code', value);

  @override
  String get itemNo => RealmObjectBase.get<String>(this, 'item_no') as String;
  @override
  set itemNo(String value) => RealmObjectBase.set(this, 'item_no', value);

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
  String? get unitOfMeasureCode =>
      RealmObjectBase.get<String>(this, 'unit_of_measure_code') as String?;
  @override
  set unitOfMeasureCode(String? value) =>
      RealmObjectBase.set(this, 'unit_of_measure_code', value);

  @override
  double get qtyPerUnitOfMeasure =>
      RealmObjectBase.get<double>(this, 'qty_per_unit_of_measure') as double;
  @override
  set qtyPerUnitOfMeasure(double value) =>
      RealmObjectBase.set(this, 'qty_per_unit_of_measure', value);

  @override
  double get orgQuantity =>
      RealmObjectBase.get<double>(this, 'org_quantity') as double;
  @override
  set orgQuantity(double value) =>
      RealmObjectBase.set(this, 'org_quantity', value);

  @override
  double get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double;
  @override
  set quantity(double value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  double get quantityBase =>
      RealmObjectBase.get<double>(this, 'quantity_base') as double;
  @override
  set quantityBase(double value) =>
      RealmObjectBase.set(this, 'quantity_base', value);

  @override
  double get quantityToShip =>
      RealmObjectBase.get<double>(this, 'quantity_to_ship') as double;
  @override
  set quantityToShip(double value) =>
      RealmObjectBase.set(this, 'quantity_to_ship', value);

  @override
  double get quantityToReceive =>
      RealmObjectBase.get<double>(this, 'quantity_to_receive') as double;
  @override
  set quantityToReceive(double value) =>
      RealmObjectBase.set(this, 'quantity_to_receive', value);

  @override
  double get quantityShipped =>
      RealmObjectBase.get<double>(this, 'quantity_shipped') as double;
  @override
  set quantityShipped(double value) =>
      RealmObjectBase.set(this, 'quantity_shipped', value);

  @override
  double get quantityReceived =>
      RealmObjectBase.get<double>(this, 'quantity_received') as double;
  @override
  set quantityReceived(double value) =>
      RealmObjectBase.set(this, 'quantity_received', value);

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
  String? get documentLineNo =>
      RealmObjectBase.get<String>(this, 'document_line_no') as String?;
  @override
  set documentLineNo(String? value) =>
      RealmObjectBase.set(this, 'document_line_no', value);

  @override
  String get status => RealmObjectBase.get<String>(this, 'status') as String;
  @override
  set status(String value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get backendStatus =>
      RealmObjectBase.get<String>(this, 'backend_status') as String?;
  @override
  set backendStatus(String? value) =>
      RealmObjectBase.set(this, 'backend_status', value);

  @override
  String? get transferDocumentNo =>
      RealmObjectBase.get<String>(this, 'transfer_document_no') as String?;
  @override
  set transferDocumentNo(String? value) =>
      RealmObjectBase.set(this, 'transfer_document_no', value);

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
  Stream<RealmObjectChanges<ItemStockRequestWorkSheet>> get changes =>
      RealmObjectBase.getChanges<ItemStockRequestWorkSheet>(this);

  @override
  Stream<RealmObjectChanges<ItemStockRequestWorkSheet>> changesFor([
    List<String>? keyPaths,
  ]) =>
      RealmObjectBase.getChangesFor<ItemStockRequestWorkSheet>(this, keyPaths);

  @override
  ItemStockRequestWorkSheet freeze() =>
      RealmObjectBase.freezeObject<ItemStockRequestWorkSheet>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'app_id': appId.toEJson(),
      'from_location_code': fromLocationCode.toEJson(),
      'location_code': locationCode.toEJson(),
      'purchaser_code': purchaserCode.toEJson(),
      'item_no': itemNo.toEJson(),
      'variant_code': variantCode.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'unit_of_measure_code': unitOfMeasureCode.toEJson(),
      'qty_per_unit_of_measure': qtyPerUnitOfMeasure.toEJson(),
      'org_quantity': orgQuantity.toEJson(),
      'quantity': quantity.toEJson(),
      'quantity_base': quantityBase.toEJson(),
      'quantity_to_ship': quantityToShip.toEJson(),
      'quantity_to_receive': quantityToReceive.toEJson(),
      'quantity_shipped': quantityShipped.toEJson(),
      'quantity_received': quantityReceived.toEJson(),
      'posting_date': postingDate.toEJson(),
      'document_type': documentType.toEJson(),
      'document_no': documentNo.toEJson(),
      'document_line_no': documentLineNo.toEJson(),
      'status': status.toEJson(),
      'backend_status': backendStatus.toEJson(),
      'transfer_document_no': transferDocumentNo.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemStockRequestWorkSheet value) =>
      value.toEJson();
  static ItemStockRequestWorkSheet _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id, 'item_no': EJsonValue itemNo} =>
        ItemStockRequestWorkSheet(
          fromEJson(id),
          fromEJson(itemNo),
          appId: fromEJson(ejson['app_id']),
          fromLocationCode: fromEJson(ejson['from_location_code']),
          locationCode: fromEJson(ejson['location_code']),
          purchaserCode: fromEJson(ejson['purchaser_code']),
          variantCode: fromEJson(ejson['variant_code']),
          description: fromEJson(ejson['description']),
          description2: fromEJson(ejson['description_2']),
          unitOfMeasureCode: fromEJson(ejson['unit_of_measure_code']),
          qtyPerUnitOfMeasure: fromEJson(
            ejson['qty_per_unit_of_measure'],
            defaultValue: 1.0,
          ),
          orgQuantity: fromEJson(ejson['org_quantity'], defaultValue: 0),
          quantity: fromEJson(ejson['quantity'], defaultValue: 0),
          quantityBase: fromEJson(ejson['quantity_base'], defaultValue: 0),
          quantityToShip: fromEJson(ejson['quantity_to_ship'], defaultValue: 0),
          quantityToReceive: fromEJson(
            ejson['quantity_to_receive'],
            defaultValue: 0,
          ),
          quantityShipped: fromEJson(
            ejson['quantity_shipped'],
            defaultValue: 0,
          ),
          quantityReceived: fromEJson(
            ejson['quantity_received'],
            defaultValue: 0,
          ),
          postingDate: fromEJson(ejson['posting_date']),
          documentType: fromEJson(ejson['document_type']),
          documentNo: fromEJson(ejson['document_no']),
          documentLineNo: fromEJson(ejson['document_line_no']),
          status: fromEJson(ejson['status'], defaultValue: "New"),
          backendStatus: fromEJson(ejson['backend_status']),
          transferDocumentNo: fromEJson(ejson['transfer_document_no']),
          isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
          createdAt: fromEJson(ejson['created_at']),
          updatedAt: fromEJson(ejson['updated_at']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemStockRequestWorkSheet._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      ItemStockRequestWorkSheet,
      'ITEM_STOCK_REQUEST_WORKSHEET',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty(
          'appId',
          RealmPropertyType.string,
          mapTo: 'app_id',
          optional: true,
        ),
        SchemaProperty(
          'fromLocationCode',
          RealmPropertyType.string,
          mapTo: 'from_location_code',
          optional: true,
        ),
        SchemaProperty(
          'locationCode',
          RealmPropertyType.string,
          mapTo: 'location_code',
          optional: true,
        ),
        SchemaProperty(
          'purchaserCode',
          RealmPropertyType.string,
          mapTo: 'purchaser_code',
          optional: true,
        ),
        SchemaProperty('itemNo', RealmPropertyType.string, mapTo: 'item_no'),
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
          'unitOfMeasureCode',
          RealmPropertyType.string,
          mapTo: 'unit_of_measure_code',
          optional: true,
        ),
        SchemaProperty(
          'qtyPerUnitOfMeasure',
          RealmPropertyType.double,
          mapTo: 'qty_per_unit_of_measure',
        ),
        SchemaProperty(
          'orgQuantity',
          RealmPropertyType.double,
          mapTo: 'org_quantity',
        ),
        SchemaProperty('quantity', RealmPropertyType.double),
        SchemaProperty(
          'quantityBase',
          RealmPropertyType.double,
          mapTo: 'quantity_base',
        ),
        SchemaProperty(
          'quantityToShip',
          RealmPropertyType.double,
          mapTo: 'quantity_to_ship',
        ),
        SchemaProperty(
          'quantityToReceive',
          RealmPropertyType.double,
          mapTo: 'quantity_to_receive',
        ),
        SchemaProperty(
          'quantityShipped',
          RealmPropertyType.double,
          mapTo: 'quantity_shipped',
        ),
        SchemaProperty(
          'quantityReceived',
          RealmPropertyType.double,
          mapTo: 'quantity_received',
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
          'documentLineNo',
          RealmPropertyType.string,
          mapTo: 'document_line_no',
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string),
        SchemaProperty(
          'backendStatus',
          RealmPropertyType.string,
          mapTo: 'backend_status',
          optional: true,
        ),
        SchemaProperty(
          'transferDocumentNo',
          RealmPropertyType.string,
          mapTo: 'transfer_document_no',
          optional: true,
        ),
        SchemaProperty('isSync', RealmPropertyType.string, mapTo: 'is_sync'),
        SchemaProperty(
          'createdAt',
          RealmPropertyType.string,
          mapTo: 'created_at',
          optional: true,
        ),
        SchemaProperty(
          'updatedAt',
          RealmPropertyType.string,
          mapTo: 'updated_at',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
