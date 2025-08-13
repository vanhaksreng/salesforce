// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'general_schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class UserSetup extends _UserSetup
    with RealmEntity, RealmObjectBase, RealmObject {
  UserSetup(
    String email, {
    String? roleCode,
    String? permissionCode,
    String? locationCode,
    String? intransitLocationCode,
    String? businessUnitCode,
    String? divisionCode,
    String? storeCode,
    String? projectCode,
    String? salespersonCode,
    String? distributorCode,
    String? departmentCode,
    String? cashJournalBatchName,
    String? cashBankAccountCode,
    String? payJournalBatchName,
    String? genJournalBatchName,
    String? itemJournalBatchName,
    String? type,
    String? fromLocationCode,
    String? customerNo,
    String? vendorNo,
    int? userId,
  }) {
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'role_code', roleCode);
    RealmObjectBase.set(this, 'permission_code', permissionCode);
    RealmObjectBase.set(this, 'location_code', locationCode);
    RealmObjectBase.set(this, 'intransit_location_code', intransitLocationCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'cash_journal_batch_name', cashJournalBatchName);
    RealmObjectBase.set(this, 'cash_bank_account_code', cashBankAccountCode);
    RealmObjectBase.set(this, 'pay_journal_batch_name', payJournalBatchName);
    RealmObjectBase.set(this, 'gen_journal_batch_name', genJournalBatchName);
    RealmObjectBase.set(this, 'item_journal_batch_name', itemJournalBatchName);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'from_location_code', fromLocationCode);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'vendor_no', vendorNo);
    RealmObjectBase.set(this, 'user_id', userId);
  }

  UserSetup._();

  @override
  String get email => RealmObjectBase.get<String>(this, 'email') as String;
  @override
  set email(String value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get roleCode =>
      RealmObjectBase.get<String>(this, 'role_code') as String?;
  @override
  set roleCode(String? value) => RealmObjectBase.set(this, 'role_code', value);

  @override
  String? get permissionCode =>
      RealmObjectBase.get<String>(this, 'permission_code') as String?;
  @override
  set permissionCode(String? value) =>
      RealmObjectBase.set(this, 'permission_code', value);

  @override
  String? get locationCode =>
      RealmObjectBase.get<String>(this, 'location_code') as String?;
  @override
  set locationCode(String? value) =>
      RealmObjectBase.set(this, 'location_code', value);

  @override
  String? get intransitLocationCode =>
      RealmObjectBase.get<String>(this, 'intransit_location_code') as String?;
  @override
  set intransitLocationCode(String? value) =>
      RealmObjectBase.set(this, 'intransit_location_code', value);

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
  String? get storeCode =>
      RealmObjectBase.get<String>(this, 'store_code') as String?;
  @override
  set storeCode(String? value) =>
      RealmObjectBase.set(this, 'store_code', value);

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
  String? get departmentCode =>
      RealmObjectBase.get<String>(this, 'department_code') as String?;
  @override
  set departmentCode(String? value) =>
      RealmObjectBase.set(this, 'department_code', value);

  @override
  String? get cashJournalBatchName =>
      RealmObjectBase.get<String>(this, 'cash_journal_batch_name') as String?;
  @override
  set cashJournalBatchName(String? value) =>
      RealmObjectBase.set(this, 'cash_journal_batch_name', value);

  @override
  String? get cashBankAccountCode =>
      RealmObjectBase.get<String>(this, 'cash_bank_account_code') as String?;
  @override
  set cashBankAccountCode(String? value) =>
      RealmObjectBase.set(this, 'cash_bank_account_code', value);

  @override
  String? get payJournalBatchName =>
      RealmObjectBase.get<String>(this, 'pay_journal_batch_name') as String?;
  @override
  set payJournalBatchName(String? value) =>
      RealmObjectBase.set(this, 'pay_journal_batch_name', value);

  @override
  String? get genJournalBatchName =>
      RealmObjectBase.get<String>(this, 'gen_journal_batch_name') as String?;
  @override
  set genJournalBatchName(String? value) =>
      RealmObjectBase.set(this, 'gen_journal_batch_name', value);

  @override
  String? get itemJournalBatchName =>
      RealmObjectBase.get<String>(this, 'item_journal_batch_name') as String?;
  @override
  set itemJournalBatchName(String? value) =>
      RealmObjectBase.set(this, 'item_journal_batch_name', value);

  @override
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get fromLocationCode =>
      RealmObjectBase.get<String>(this, 'from_location_code') as String?;
  @override
  set fromLocationCode(String? value) =>
      RealmObjectBase.set(this, 'from_location_code', value);

  @override
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

  @override
  String? get vendorNo =>
      RealmObjectBase.get<String>(this, 'vendor_no') as String?;
  @override
  set vendorNo(String? value) => RealmObjectBase.set(this, 'vendor_no', value);

  @override
  int? get userId => RealmObjectBase.get<int>(this, 'user_id') as int?;
  @override
  set userId(int? value) => RealmObjectBase.set(this, 'user_id', value);

  @override
  Stream<RealmObjectChanges<UserSetup>> get changes =>
      RealmObjectBase.getChanges<UserSetup>(this);

  @override
  Stream<RealmObjectChanges<UserSetup>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<UserSetup>(this, keyPaths);

  @override
  UserSetup freeze() => RealmObjectBase.freezeObject<UserSetup>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'email': email.toEJson(),
      'role_code': roleCode.toEJson(),
      'permission_code': permissionCode.toEJson(),
      'location_code': locationCode.toEJson(),
      'intransit_location_code': intransitLocationCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'store_code': storeCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'cash_journal_batch_name': cashJournalBatchName.toEJson(),
      'cash_bank_account_code': cashBankAccountCode.toEJson(),
      'pay_journal_batch_name': payJournalBatchName.toEJson(),
      'gen_journal_batch_name': genJournalBatchName.toEJson(),
      'item_journal_batch_name': itemJournalBatchName.toEJson(),
      'type': type.toEJson(),
      'from_location_code': fromLocationCode.toEJson(),
      'customer_no': customerNo.toEJson(),
      'vendor_no': vendorNo.toEJson(),
      'user_id': userId.toEJson(),
    };
  }

  static EJsonValue _toEJson(UserSetup value) => value.toEJson();
  static UserSetup _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'email': EJsonValue email,
      } =>
        UserSetup(
          fromEJson(email),
          roleCode: fromEJson(ejson['role_code']),
          permissionCode: fromEJson(ejson['permission_code']),
          locationCode: fromEJson(ejson['location_code']),
          intransitLocationCode: fromEJson(ejson['intransit_location_code']),
          businessUnitCode: fromEJson(ejson['business_unit_code']),
          divisionCode: fromEJson(ejson['division_code']),
          storeCode: fromEJson(ejson['store_code']),
          projectCode: fromEJson(ejson['project_code']),
          salespersonCode: fromEJson(ejson['salesperson_code']),
          distributorCode: fromEJson(ejson['distributor_code']),
          departmentCode: fromEJson(ejson['department_code']),
          cashJournalBatchName: fromEJson(ejson['cash_journal_batch_name']),
          cashBankAccountCode: fromEJson(ejson['cash_bank_account_code']),
          payJournalBatchName: fromEJson(ejson['pay_journal_batch_name']),
          genJournalBatchName: fromEJson(ejson['gen_journal_batch_name']),
          itemJournalBatchName: fromEJson(ejson['item_journal_batch_name']),
          type: fromEJson(ejson['type']),
          fromLocationCode: fromEJson(ejson['from_location_code']),
          customerNo: fromEJson(ejson['customer_no']),
          vendorNo: fromEJson(ejson['vendor_no']),
          userId: fromEJson(ejson['user_id']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(UserSetup._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, UserSetup, 'USER_SETUP', [
      SchemaProperty('email', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('roleCode', RealmPropertyType.string,
          mapTo: 'role_code', optional: true),
      SchemaProperty('permissionCode', RealmPropertyType.string,
          mapTo: 'permission_code', optional: true),
      SchemaProperty('locationCode', RealmPropertyType.string,
          mapTo: 'location_code', optional: true),
      SchemaProperty('intransitLocationCode', RealmPropertyType.string,
          mapTo: 'intransit_location_code', optional: true),
      SchemaProperty('businessUnitCode', RealmPropertyType.string,
          mapTo: 'business_unit_code', optional: true),
      SchemaProperty('divisionCode', RealmPropertyType.string,
          mapTo: 'division_code', optional: true),
      SchemaProperty('storeCode', RealmPropertyType.string,
          mapTo: 'store_code', optional: true),
      SchemaProperty('projectCode', RealmPropertyType.string,
          mapTo: 'project_code', optional: true),
      SchemaProperty('salespersonCode', RealmPropertyType.string,
          mapTo: 'salesperson_code', optional: true),
      SchemaProperty('distributorCode', RealmPropertyType.string,
          mapTo: 'distributor_code', optional: true),
      SchemaProperty('departmentCode', RealmPropertyType.string,
          mapTo: 'department_code', optional: true),
      SchemaProperty('cashJournalBatchName', RealmPropertyType.string,
          mapTo: 'cash_journal_batch_name', optional: true),
      SchemaProperty('cashBankAccountCode', RealmPropertyType.string,
          mapTo: 'cash_bank_account_code', optional: true),
      SchemaProperty('payJournalBatchName', RealmPropertyType.string,
          mapTo: 'pay_journal_batch_name', optional: true),
      SchemaProperty('genJournalBatchName', RealmPropertyType.string,
          mapTo: 'gen_journal_batch_name', optional: true),
      SchemaProperty('itemJournalBatchName', RealmPropertyType.string,
          mapTo: 'item_journal_batch_name', optional: true),
      SchemaProperty('type', RealmPropertyType.string, optional: true),
      SchemaProperty('fromLocationCode', RealmPropertyType.string,
          mapTo: 'from_location_code', optional: true),
      SchemaProperty('customerNo', RealmPropertyType.string,
          mapTo: 'customer_no', optional: true),
      SchemaProperty('vendorNo', RealmPropertyType.string,
          mapTo: 'vendor_no', optional: true),
      SchemaProperty('userId', RealmPropertyType.int,
          mapTo: 'user_id', optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Profile extends _Profile with RealmEntity, RealmObjectBase, RealmObject {
  Profile(
    String email, {
    String? firstName,
    String? lastName,
    String? gender,
    String? dateOfBirth,
    String? idCardNo,
    String? phoneNo,
    String? userEmail,
    String? organizationName,
    String? businessIndustry,
    String? subBusinessIndustry,
    String? userType,
    String? address,
    String? address2,
    String? countryCode,
    String? city,
    String? avatar,
    String? avatar32,
    String? avatar128,
    String? locale,
    String? timeZone,
    int? tablePagination,
  }) {
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'first_name', firstName);
    RealmObjectBase.set(this, 'last_name', lastName);
    RealmObjectBase.set(this, 'gender', gender);
    RealmObjectBase.set(this, 'date_of_birth', dateOfBirth);
    RealmObjectBase.set(this, 'id_card_no', idCardNo);
    RealmObjectBase.set(this, 'phone_no', phoneNo);
    RealmObjectBase.set(this, 'user_email', userEmail);
    RealmObjectBase.set(this, 'organization_name', organizationName);
    RealmObjectBase.set(this, 'business_industry', businessIndustry);
    RealmObjectBase.set(this, 'sub_business_industry', subBusinessIndustry);
    RealmObjectBase.set(this, 'user_type', userType);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'country_code', countryCode);
    RealmObjectBase.set(this, 'city', city);
    RealmObjectBase.set(this, 'avatar', avatar);
    RealmObjectBase.set(this, 'avatar_32', avatar32);
    RealmObjectBase.set(this, 'avatar_128', avatar128);
    RealmObjectBase.set(this, 'locale', locale);
    RealmObjectBase.set(this, 'time_zone', timeZone);
    RealmObjectBase.set(this, 'table_pagination', tablePagination);
  }

  Profile._();

  @override
  String get email => RealmObjectBase.get<String>(this, 'email') as String;
  @override
  set email(String value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get firstName =>
      RealmObjectBase.get<String>(this, 'first_name') as String?;
  @override
  set firstName(String? value) =>
      RealmObjectBase.set(this, 'first_name', value);

  @override
  String? get lastName =>
      RealmObjectBase.get<String>(this, 'last_name') as String?;
  @override
  set lastName(String? value) => RealmObjectBase.set(this, 'last_name', value);

  @override
  String? get gender => RealmObjectBase.get<String>(this, 'gender') as String?;
  @override
  set gender(String? value) => RealmObjectBase.set(this, 'gender', value);

  @override
  String? get dateOfBirth =>
      RealmObjectBase.get<String>(this, 'date_of_birth') as String?;
  @override
  set dateOfBirth(String? value) =>
      RealmObjectBase.set(this, 'date_of_birth', value);

  @override
  String? get idCardNo =>
      RealmObjectBase.get<String>(this, 'id_card_no') as String?;
  @override
  set idCardNo(String? value) => RealmObjectBase.set(this, 'id_card_no', value);

  @override
  String? get phoneNo =>
      RealmObjectBase.get<String>(this, 'phone_no') as String?;
  @override
  set phoneNo(String? value) => RealmObjectBase.set(this, 'phone_no', value);

  @override
  String? get userEmail =>
      RealmObjectBase.get<String>(this, 'user_email') as String?;
  @override
  set userEmail(String? value) =>
      RealmObjectBase.set(this, 'user_email', value);

  @override
  String? get organizationName =>
      RealmObjectBase.get<String>(this, 'organization_name') as String?;
  @override
  set organizationName(String? value) =>
      RealmObjectBase.set(this, 'organization_name', value);

  @override
  String? get businessIndustry =>
      RealmObjectBase.get<String>(this, 'business_industry') as String?;
  @override
  set businessIndustry(String? value) =>
      RealmObjectBase.set(this, 'business_industry', value);

  @override
  String? get subBusinessIndustry =>
      RealmObjectBase.get<String>(this, 'sub_business_industry') as String?;
  @override
  set subBusinessIndustry(String? value) =>
      RealmObjectBase.set(this, 'sub_business_industry', value);

  @override
  String? get userType =>
      RealmObjectBase.get<String>(this, 'user_type') as String?;
  @override
  set userType(String? value) => RealmObjectBase.set(this, 'user_type', value);

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
  String? get countryCode =>
      RealmObjectBase.get<String>(this, 'country_code') as String?;
  @override
  set countryCode(String? value) =>
      RealmObjectBase.set(this, 'country_code', value);

  @override
  String? get city => RealmObjectBase.get<String>(this, 'city') as String?;
  @override
  set city(String? value) => RealmObjectBase.set(this, 'city', value);

  @override
  String? get avatar => RealmObjectBase.get<String>(this, 'avatar') as String?;
  @override
  set avatar(String? value) => RealmObjectBase.set(this, 'avatar', value);

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
  String? get locale => RealmObjectBase.get<String>(this, 'locale') as String?;
  @override
  set locale(String? value) => RealmObjectBase.set(this, 'locale', value);

  @override
  String? get timeZone =>
      RealmObjectBase.get<String>(this, 'time_zone') as String?;
  @override
  set timeZone(String? value) => RealmObjectBase.set(this, 'time_zone', value);

  @override
  int? get tablePagination =>
      RealmObjectBase.get<int>(this, 'table_pagination') as int?;
  @override
  set tablePagination(int? value) =>
      RealmObjectBase.set(this, 'table_pagination', value);

  @override
  Stream<RealmObjectChanges<Profile>> get changes =>
      RealmObjectBase.getChanges<Profile>(this);

  @override
  Stream<RealmObjectChanges<Profile>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Profile>(this, keyPaths);

  @override
  Profile freeze() => RealmObjectBase.freezeObject<Profile>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'email': email.toEJson(),
      'first_name': firstName.toEJson(),
      'last_name': lastName.toEJson(),
      'gender': gender.toEJson(),
      'date_of_birth': dateOfBirth.toEJson(),
      'id_card_no': idCardNo.toEJson(),
      'phone_no': phoneNo.toEJson(),
      'user_email': userEmail.toEJson(),
      'organization_name': organizationName.toEJson(),
      'business_industry': businessIndustry.toEJson(),
      'sub_business_industry': subBusinessIndustry.toEJson(),
      'user_type': userType.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'country_code': countryCode.toEJson(),
      'city': city.toEJson(),
      'avatar': avatar.toEJson(),
      'avatar_32': avatar32.toEJson(),
      'avatar_128': avatar128.toEJson(),
      'locale': locale.toEJson(),
      'time_zone': timeZone.toEJson(),
      'table_pagination': tablePagination.toEJson(),
    };
  }

  static EJsonValue _toEJson(Profile value) => value.toEJson();
  static Profile _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'email': EJsonValue email,
      } =>
        Profile(
          fromEJson(email),
          firstName: fromEJson(ejson['first_name']),
          lastName: fromEJson(ejson['last_name']),
          gender: fromEJson(ejson['gender']),
          dateOfBirth: fromEJson(ejson['date_of_birth']),
          idCardNo: fromEJson(ejson['id_card_no']),
          phoneNo: fromEJson(ejson['phone_no']),
          userEmail: fromEJson(ejson['user_email']),
          organizationName: fromEJson(ejson['organization_name']),
          businessIndustry: fromEJson(ejson['business_industry']),
          subBusinessIndustry: fromEJson(ejson['sub_business_industry']),
          userType: fromEJson(ejson['user_type']),
          address: fromEJson(ejson['address']),
          address2: fromEJson(ejson['address_2']),
          countryCode: fromEJson(ejson['country_code']),
          city: fromEJson(ejson['city']),
          avatar: fromEJson(ejson['avatar']),
          avatar32: fromEJson(ejson['avatar_32']),
          avatar128: fromEJson(ejson['avatar_128']),
          locale: fromEJson(ejson['locale']),
          timeZone: fromEJson(ejson['time_zone']),
          tablePagination: fromEJson(ejson['table_pagination']),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Profile._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Profile, 'PROFILE', [
      SchemaProperty('email', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('firstName', RealmPropertyType.string,
          mapTo: 'first_name', optional: true),
      SchemaProperty('lastName', RealmPropertyType.string,
          mapTo: 'last_name', optional: true),
      SchemaProperty('gender', RealmPropertyType.string, optional: true),
      SchemaProperty('dateOfBirth', RealmPropertyType.string,
          mapTo: 'date_of_birth', optional: true),
      SchemaProperty('idCardNo', RealmPropertyType.string,
          mapTo: 'id_card_no', optional: true),
      SchemaProperty('phoneNo', RealmPropertyType.string,
          mapTo: 'phone_no', optional: true),
      SchemaProperty('userEmail', RealmPropertyType.string,
          mapTo: 'user_email', optional: true),
      SchemaProperty('organizationName', RealmPropertyType.string,
          mapTo: 'organization_name', optional: true),
      SchemaProperty('businessIndustry', RealmPropertyType.string,
          mapTo: 'business_industry', optional: true),
      SchemaProperty('subBusinessIndustry', RealmPropertyType.string,
          mapTo: 'sub_business_industry', optional: true),
      SchemaProperty('userType', RealmPropertyType.string,
          mapTo: 'user_type', optional: true),
      SchemaProperty('address', RealmPropertyType.string, optional: true),
      SchemaProperty('address2', RealmPropertyType.string,
          mapTo: 'address_2', optional: true),
      SchemaProperty('countryCode', RealmPropertyType.string,
          mapTo: 'country_code', optional: true),
      SchemaProperty('city', RealmPropertyType.string, optional: true),
      SchemaProperty('avatar', RealmPropertyType.string, optional: true),
      SchemaProperty('avatar32', RealmPropertyType.string,
          mapTo: 'avatar_32', optional: true),
      SchemaProperty('avatar128', RealmPropertyType.string,
          mapTo: 'avatar_128', optional: true),
      SchemaProperty('locale', RealmPropertyType.string, optional: true),
      SchemaProperty('timeZone', RealmPropertyType.string,
          mapTo: 'time_zone', optional: true),
      SchemaProperty('tablePagination', RealmPropertyType.int,
          mapTo: 'table_pagination', optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ApplicationSetup extends _ApplicationSetup
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  ApplicationSetup(
    String id, {
    String? decimalPoint,
    String? separatorSymbol,
    int? quantityDecimal,
    int? priceDecimal,
    int? costDecimal,
    int? measurementDecimal,
    int? generalDecimal,
    int? amountDecimal,
    int? percentageDecimal,
    int? itemQtyFormat = 0,
    String? allowPostingFrom,
    String? allowPostingTo,
    String? localCurrencyCode = "USD",
    String? decimalZero,
    String? incomeClosingPeriod,
    String? scrollPagination,
    String? defaultSalesVatAccNo,
    String? defaultPurchaseVatAccNo,
    String? defaultApAccNo,
    String? defaultArAccNo,
    String? defaultBankAccNo,
    String? defaultCashAccNo,
    String? defaultCostAccNo,
    String? defaultSalesAccNo,
    String? defaultPurchaseAccNo,
    String? defaultInventoryAccNo,
    String? defaultPositiveAdjAccountNo,
    String? defaultNegativeAdjAccountNo,
    String? defaultInvPostingGroup,
    String? defaultApPostingGroup,
    String? defaultArPostingGroup,
    String? defaultGenBusPostingGroup,
    String? defaultGenProdPostingGroup,
    String? defaultVatBusPostingGroup,
    String? defaultVatProdPostingGroup,
    String? defaultPaymentTerm,
    String? defaultStockUnitMeasure,
    String? defaultItemPriceIncludeVat,
    String? acceptEorderOrderStatus,
    String? autoAcceptIncomingEorder,
    String? ctrlItemTracking = kStatusNo,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<ApplicationSetup>({
        'item_qty_format': 0,
        'local_currency_code': "USD",
        'ctrl_item_tracking': kStatusNo,
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'decimal_point', decimalPoint);
    RealmObjectBase.set(this, 'separator_symbol', separatorSymbol);
    RealmObjectBase.set(this, 'quantity_decimal', quantityDecimal);
    RealmObjectBase.set(this, 'price_decimal', priceDecimal);
    RealmObjectBase.set(this, 'cost_decimal', costDecimal);
    RealmObjectBase.set(this, 'measurement_decimal', measurementDecimal);
    RealmObjectBase.set(this, 'general_decimal', generalDecimal);
    RealmObjectBase.set(this, 'amount_decimal', amountDecimal);
    RealmObjectBase.set(this, 'percentage_decimal', percentageDecimal);
    RealmObjectBase.set(this, 'item_qty_format', itemQtyFormat);
    RealmObjectBase.set(this, 'allow_posting_from', allowPostingFrom);
    RealmObjectBase.set(this, 'allow_posting_to', allowPostingTo);
    RealmObjectBase.set(this, 'local_currency_code', localCurrencyCode);
    RealmObjectBase.set(this, 'decimal_zero', decimalZero);
    RealmObjectBase.set(this, 'income_closing_period', incomeClosingPeriod);
    RealmObjectBase.set(this, 'scroll_pagination', scrollPagination);
    RealmObjectBase.set(this, 'default_sales_vat_acc_no', defaultSalesVatAccNo);
    RealmObjectBase.set(
        this, 'default_purchase_vat_acc_no', defaultPurchaseVatAccNo);
    RealmObjectBase.set(this, 'default_ap_acc_no', defaultApAccNo);
    RealmObjectBase.set(this, 'default_ar_acc_no', defaultArAccNo);
    RealmObjectBase.set(this, 'default_bank_acc_no', defaultBankAccNo);
    RealmObjectBase.set(this, 'default_cash_acc_no', defaultCashAccNo);
    RealmObjectBase.set(this, 'default_cost_acc_no', defaultCostAccNo);
    RealmObjectBase.set(this, 'default_sales_acc_no', defaultSalesAccNo);
    RealmObjectBase.set(this, 'default_purchase_acc_no', defaultPurchaseAccNo);
    RealmObjectBase.set(
        this, 'default_inventory_acc_no', defaultInventoryAccNo);
    RealmObjectBase.set(
        this, 'default_positive_adj_account_no', defaultPositiveAdjAccountNo);
    RealmObjectBase.set(
        this, 'default_negative_adj_account_no', defaultNegativeAdjAccountNo);
    RealmObjectBase.set(
        this, 'default_inv_posting_group', defaultInvPostingGroup);
    RealmObjectBase.set(
        this, 'default_ap_posting_group', defaultApPostingGroup);
    RealmObjectBase.set(
        this, 'default_ar_posting_group', defaultArPostingGroup);
    RealmObjectBase.set(
        this, 'default_gen_bus_posting_group', defaultGenBusPostingGroup);
    RealmObjectBase.set(
        this, 'default_gen_prod_posting_group', defaultGenProdPostingGroup);
    RealmObjectBase.set(
        this, 'default_vat_bus_posting_group', defaultVatBusPostingGroup);
    RealmObjectBase.set(
        this, 'default_vat_prod_posting_group', defaultVatProdPostingGroup);
    RealmObjectBase.set(this, 'default_payment_term', defaultPaymentTerm);
    RealmObjectBase.set(
        this, 'default_stock_unit_measure', defaultStockUnitMeasure);
    RealmObjectBase.set(
        this, 'default_item_price_include_vat', defaultItemPriceIncludeVat);
    RealmObjectBase.set(
        this, 'accept_eorder_order_status', acceptEorderOrderStatus);
    RealmObjectBase.set(
        this, 'auto_accept_incoming_eorder', autoAcceptIncomingEorder);
    RealmObjectBase.set(this, 'ctrl_item_tracking', ctrlItemTracking);
  }

  ApplicationSetup._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get decimalPoint =>
      RealmObjectBase.get<String>(this, 'decimal_point') as String?;
  @override
  set decimalPoint(String? value) =>
      RealmObjectBase.set(this, 'decimal_point', value);

  @override
  String? get separatorSymbol =>
      RealmObjectBase.get<String>(this, 'separator_symbol') as String?;
  @override
  set separatorSymbol(String? value) =>
      RealmObjectBase.set(this, 'separator_symbol', value);

  @override
  int? get quantityDecimal =>
      RealmObjectBase.get<int>(this, 'quantity_decimal') as int?;
  @override
  set quantityDecimal(int? value) =>
      RealmObjectBase.set(this, 'quantity_decimal', value);

  @override
  int? get priceDecimal =>
      RealmObjectBase.get<int>(this, 'price_decimal') as int?;
  @override
  set priceDecimal(int? value) =>
      RealmObjectBase.set(this, 'price_decimal', value);

  @override
  int? get costDecimal =>
      RealmObjectBase.get<int>(this, 'cost_decimal') as int?;
  @override
  set costDecimal(int? value) =>
      RealmObjectBase.set(this, 'cost_decimal', value);

  @override
  int? get measurementDecimal =>
      RealmObjectBase.get<int>(this, 'measurement_decimal') as int?;
  @override
  set measurementDecimal(int? value) =>
      RealmObjectBase.set(this, 'measurement_decimal', value);

  @override
  int? get generalDecimal =>
      RealmObjectBase.get<int>(this, 'general_decimal') as int?;
  @override
  set generalDecimal(int? value) =>
      RealmObjectBase.set(this, 'general_decimal', value);

  @override
  int? get amountDecimal =>
      RealmObjectBase.get<int>(this, 'amount_decimal') as int?;
  @override
  set amountDecimal(int? value) =>
      RealmObjectBase.set(this, 'amount_decimal', value);

  @override
  int? get percentageDecimal =>
      RealmObjectBase.get<int>(this, 'percentage_decimal') as int?;
  @override
  set percentageDecimal(int? value) =>
      RealmObjectBase.set(this, 'percentage_decimal', value);

  @override
  int? get itemQtyFormat =>
      RealmObjectBase.get<int>(this, 'item_qty_format') as int?;
  @override
  set itemQtyFormat(int? value) =>
      RealmObjectBase.set(this, 'item_qty_format', value);

  @override
  String? get allowPostingFrom =>
      RealmObjectBase.get<String>(this, 'allow_posting_from') as String?;
  @override
  set allowPostingFrom(String? value) =>
      RealmObjectBase.set(this, 'allow_posting_from', value);

  @override
  String? get allowPostingTo =>
      RealmObjectBase.get<String>(this, 'allow_posting_to') as String?;
  @override
  set allowPostingTo(String? value) =>
      RealmObjectBase.set(this, 'allow_posting_to', value);

  @override
  String? get localCurrencyCode =>
      RealmObjectBase.get<String>(this, 'local_currency_code') as String?;
  @override
  set localCurrencyCode(String? value) =>
      RealmObjectBase.set(this, 'local_currency_code', value);

  @override
  String? get decimalZero =>
      RealmObjectBase.get<String>(this, 'decimal_zero') as String?;
  @override
  set decimalZero(String? value) =>
      RealmObjectBase.set(this, 'decimal_zero', value);

  @override
  String? get incomeClosingPeriod =>
      RealmObjectBase.get<String>(this, 'income_closing_period') as String?;
  @override
  set incomeClosingPeriod(String? value) =>
      RealmObjectBase.set(this, 'income_closing_period', value);

  @override
  String? get scrollPagination =>
      RealmObjectBase.get<String>(this, 'scroll_pagination') as String?;
  @override
  set scrollPagination(String? value) =>
      RealmObjectBase.set(this, 'scroll_pagination', value);

  @override
  String? get defaultSalesVatAccNo =>
      RealmObjectBase.get<String>(this, 'default_sales_vat_acc_no') as String?;
  @override
  set defaultSalesVatAccNo(String? value) =>
      RealmObjectBase.set(this, 'default_sales_vat_acc_no', value);

  @override
  String? get defaultPurchaseVatAccNo =>
      RealmObjectBase.get<String>(this, 'default_purchase_vat_acc_no')
          as String?;
  @override
  set defaultPurchaseVatAccNo(String? value) =>
      RealmObjectBase.set(this, 'default_purchase_vat_acc_no', value);

  @override
  String? get defaultApAccNo =>
      RealmObjectBase.get<String>(this, 'default_ap_acc_no') as String?;
  @override
  set defaultApAccNo(String? value) =>
      RealmObjectBase.set(this, 'default_ap_acc_no', value);

  @override
  String? get defaultArAccNo =>
      RealmObjectBase.get<String>(this, 'default_ar_acc_no') as String?;
  @override
  set defaultArAccNo(String? value) =>
      RealmObjectBase.set(this, 'default_ar_acc_no', value);

  @override
  String? get defaultBankAccNo =>
      RealmObjectBase.get<String>(this, 'default_bank_acc_no') as String?;
  @override
  set defaultBankAccNo(String? value) =>
      RealmObjectBase.set(this, 'default_bank_acc_no', value);

  @override
  String? get defaultCashAccNo =>
      RealmObjectBase.get<String>(this, 'default_cash_acc_no') as String?;
  @override
  set defaultCashAccNo(String? value) =>
      RealmObjectBase.set(this, 'default_cash_acc_no', value);

  @override
  String? get defaultCostAccNo =>
      RealmObjectBase.get<String>(this, 'default_cost_acc_no') as String?;
  @override
  set defaultCostAccNo(String? value) =>
      RealmObjectBase.set(this, 'default_cost_acc_no', value);

  @override
  String? get defaultSalesAccNo =>
      RealmObjectBase.get<String>(this, 'default_sales_acc_no') as String?;
  @override
  set defaultSalesAccNo(String? value) =>
      RealmObjectBase.set(this, 'default_sales_acc_no', value);

  @override
  String? get defaultPurchaseAccNo =>
      RealmObjectBase.get<String>(this, 'default_purchase_acc_no') as String?;
  @override
  set defaultPurchaseAccNo(String? value) =>
      RealmObjectBase.set(this, 'default_purchase_acc_no', value);

  @override
  String? get defaultInventoryAccNo =>
      RealmObjectBase.get<String>(this, 'default_inventory_acc_no') as String?;
  @override
  set defaultInventoryAccNo(String? value) =>
      RealmObjectBase.set(this, 'default_inventory_acc_no', value);

  @override
  String? get defaultPositiveAdjAccountNo =>
      RealmObjectBase.get<String>(this, 'default_positive_adj_account_no')
          as String?;
  @override
  set defaultPositiveAdjAccountNo(String? value) =>
      RealmObjectBase.set(this, 'default_positive_adj_account_no', value);

  @override
  String? get defaultNegativeAdjAccountNo =>
      RealmObjectBase.get<String>(this, 'default_negative_adj_account_no')
          as String?;
  @override
  set defaultNegativeAdjAccountNo(String? value) =>
      RealmObjectBase.set(this, 'default_negative_adj_account_no', value);

  @override
  String? get defaultInvPostingGroup =>
      RealmObjectBase.get<String>(this, 'default_inv_posting_group') as String?;
  @override
  set defaultInvPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'default_inv_posting_group', value);

  @override
  String? get defaultApPostingGroup =>
      RealmObjectBase.get<String>(this, 'default_ap_posting_group') as String?;
  @override
  set defaultApPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'default_ap_posting_group', value);

  @override
  String? get defaultArPostingGroup =>
      RealmObjectBase.get<String>(this, 'default_ar_posting_group') as String?;
  @override
  set defaultArPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'default_ar_posting_group', value);

  @override
  String? get defaultGenBusPostingGroup =>
      RealmObjectBase.get<String>(this, 'default_gen_bus_posting_group')
          as String?;
  @override
  set defaultGenBusPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'default_gen_bus_posting_group', value);

  @override
  String? get defaultGenProdPostingGroup =>
      RealmObjectBase.get<String>(this, 'default_gen_prod_posting_group')
          as String?;
  @override
  set defaultGenProdPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'default_gen_prod_posting_group', value);

  @override
  String? get defaultVatBusPostingGroup =>
      RealmObjectBase.get<String>(this, 'default_vat_bus_posting_group')
          as String?;
  @override
  set defaultVatBusPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'default_vat_bus_posting_group', value);

  @override
  String? get defaultVatProdPostingGroup =>
      RealmObjectBase.get<String>(this, 'default_vat_prod_posting_group')
          as String?;
  @override
  set defaultVatProdPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'default_vat_prod_posting_group', value);

  @override
  String? get defaultPaymentTerm =>
      RealmObjectBase.get<String>(this, 'default_payment_term') as String?;
  @override
  set defaultPaymentTerm(String? value) =>
      RealmObjectBase.set(this, 'default_payment_term', value);

  @override
  String? get defaultStockUnitMeasure =>
      RealmObjectBase.get<String>(this, 'default_stock_unit_measure')
          as String?;
  @override
  set defaultStockUnitMeasure(String? value) =>
      RealmObjectBase.set(this, 'default_stock_unit_measure', value);

  @override
  String? get defaultItemPriceIncludeVat =>
      RealmObjectBase.get<String>(this, 'default_item_price_include_vat')
          as String?;
  @override
  set defaultItemPriceIncludeVat(String? value) =>
      RealmObjectBase.set(this, 'default_item_price_include_vat', value);

  @override
  String? get acceptEorderOrderStatus =>
      RealmObjectBase.get<String>(this, 'accept_eorder_order_status')
          as String?;
  @override
  set acceptEorderOrderStatus(String? value) =>
      RealmObjectBase.set(this, 'accept_eorder_order_status', value);

  @override
  String? get autoAcceptIncomingEorder =>
      RealmObjectBase.get<String>(this, 'auto_accept_incoming_eorder')
          as String?;
  @override
  set autoAcceptIncomingEorder(String? value) =>
      RealmObjectBase.set(this, 'auto_accept_incoming_eorder', value);

  @override
  String? get ctrlItemTracking =>
      RealmObjectBase.get<String>(this, 'ctrl_item_tracking') as String?;
  @override
  set ctrlItemTracking(String? value) =>
      RealmObjectBase.set(this, 'ctrl_item_tracking', value);

  @override
  Stream<RealmObjectChanges<ApplicationSetup>> get changes =>
      RealmObjectBase.getChanges<ApplicationSetup>(this);

  @override
  Stream<RealmObjectChanges<ApplicationSetup>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ApplicationSetup>(this, keyPaths);

  @override
  ApplicationSetup freeze() =>
      RealmObjectBase.freezeObject<ApplicationSetup>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'decimal_point': decimalPoint.toEJson(),
      'separator_symbol': separatorSymbol.toEJson(),
      'quantity_decimal': quantityDecimal.toEJson(),
      'price_decimal': priceDecimal.toEJson(),
      'cost_decimal': costDecimal.toEJson(),
      'measurement_decimal': measurementDecimal.toEJson(),
      'general_decimal': generalDecimal.toEJson(),
      'amount_decimal': amountDecimal.toEJson(),
      'percentage_decimal': percentageDecimal.toEJson(),
      'item_qty_format': itemQtyFormat.toEJson(),
      'allow_posting_from': allowPostingFrom.toEJson(),
      'allow_posting_to': allowPostingTo.toEJson(),
      'local_currency_code': localCurrencyCode.toEJson(),
      'decimal_zero': decimalZero.toEJson(),
      'income_closing_period': incomeClosingPeriod.toEJson(),
      'scroll_pagination': scrollPagination.toEJson(),
      'default_sales_vat_acc_no': defaultSalesVatAccNo.toEJson(),
      'default_purchase_vat_acc_no': defaultPurchaseVatAccNo.toEJson(),
      'default_ap_acc_no': defaultApAccNo.toEJson(),
      'default_ar_acc_no': defaultArAccNo.toEJson(),
      'default_bank_acc_no': defaultBankAccNo.toEJson(),
      'default_cash_acc_no': defaultCashAccNo.toEJson(),
      'default_cost_acc_no': defaultCostAccNo.toEJson(),
      'default_sales_acc_no': defaultSalesAccNo.toEJson(),
      'default_purchase_acc_no': defaultPurchaseAccNo.toEJson(),
      'default_inventory_acc_no': defaultInventoryAccNo.toEJson(),
      'default_positive_adj_account_no': defaultPositiveAdjAccountNo.toEJson(),
      'default_negative_adj_account_no': defaultNegativeAdjAccountNo.toEJson(),
      'default_inv_posting_group': defaultInvPostingGroup.toEJson(),
      'default_ap_posting_group': defaultApPostingGroup.toEJson(),
      'default_ar_posting_group': defaultArPostingGroup.toEJson(),
      'default_gen_bus_posting_group': defaultGenBusPostingGroup.toEJson(),
      'default_gen_prod_posting_group': defaultGenProdPostingGroup.toEJson(),
      'default_vat_bus_posting_group': defaultVatBusPostingGroup.toEJson(),
      'default_vat_prod_posting_group': defaultVatProdPostingGroup.toEJson(),
      'default_payment_term': defaultPaymentTerm.toEJson(),
      'default_stock_unit_measure': defaultStockUnitMeasure.toEJson(),
      'default_item_price_include_vat': defaultItemPriceIncludeVat.toEJson(),
      'accept_eorder_order_status': acceptEorderOrderStatus.toEJson(),
      'auto_accept_incoming_eorder': autoAcceptIncomingEorder.toEJson(),
      'ctrl_item_tracking': ctrlItemTracking.toEJson(),
    };
  }

  static EJsonValue _toEJson(ApplicationSetup value) => value.toEJson();
  static ApplicationSetup _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        ApplicationSetup(
          fromEJson(id),
          decimalPoint: fromEJson(ejson['decimal_point']),
          separatorSymbol: fromEJson(ejson['separator_symbol']),
          quantityDecimal: fromEJson(ejson['quantity_decimal']),
          priceDecimal: fromEJson(ejson['price_decimal']),
          costDecimal: fromEJson(ejson['cost_decimal']),
          measurementDecimal: fromEJson(ejson['measurement_decimal']),
          generalDecimal: fromEJson(ejson['general_decimal']),
          amountDecimal: fromEJson(ejson['amount_decimal']),
          percentageDecimal: fromEJson(ejson['percentage_decimal']),
          itemQtyFormat: fromEJson(ejson['item_qty_format'], defaultValue: 0),
          allowPostingFrom: fromEJson(ejson['allow_posting_from']),
          allowPostingTo: fromEJson(ejson['allow_posting_to']),
          localCurrencyCode:
              fromEJson(ejson['local_currency_code'], defaultValue: "USD"),
          decimalZero: fromEJson(ejson['decimal_zero']),
          incomeClosingPeriod: fromEJson(ejson['income_closing_period']),
          scrollPagination: fromEJson(ejson['scroll_pagination']),
          defaultSalesVatAccNo: fromEJson(ejson['default_sales_vat_acc_no']),
          defaultPurchaseVatAccNo:
              fromEJson(ejson['default_purchase_vat_acc_no']),
          defaultApAccNo: fromEJson(ejson['default_ap_acc_no']),
          defaultArAccNo: fromEJson(ejson['default_ar_acc_no']),
          defaultBankAccNo: fromEJson(ejson['default_bank_acc_no']),
          defaultCashAccNo: fromEJson(ejson['default_cash_acc_no']),
          defaultCostAccNo: fromEJson(ejson['default_cost_acc_no']),
          defaultSalesAccNo: fromEJson(ejson['default_sales_acc_no']),
          defaultPurchaseAccNo: fromEJson(ejson['default_purchase_acc_no']),
          defaultInventoryAccNo: fromEJson(ejson['default_inventory_acc_no']),
          defaultPositiveAdjAccountNo:
              fromEJson(ejson['default_positive_adj_account_no']),
          defaultNegativeAdjAccountNo:
              fromEJson(ejson['default_negative_adj_account_no']),
          defaultInvPostingGroup: fromEJson(ejson['default_inv_posting_group']),
          defaultApPostingGroup: fromEJson(ejson['default_ap_posting_group']),
          defaultArPostingGroup: fromEJson(ejson['default_ar_posting_group']),
          defaultGenBusPostingGroup:
              fromEJson(ejson['default_gen_bus_posting_group']),
          defaultGenProdPostingGroup:
              fromEJson(ejson['default_gen_prod_posting_group']),
          defaultVatBusPostingGroup:
              fromEJson(ejson['default_vat_bus_posting_group']),
          defaultVatProdPostingGroup:
              fromEJson(ejson['default_vat_prod_posting_group']),
          defaultPaymentTerm: fromEJson(ejson['default_payment_term']),
          defaultStockUnitMeasure:
              fromEJson(ejson['default_stock_unit_measure']),
          defaultItemPriceIncludeVat:
              fromEJson(ejson['default_item_price_include_vat']),
          acceptEorderOrderStatus:
              fromEJson(ejson['accept_eorder_order_status']),
          autoAcceptIncomingEorder:
              fromEJson(ejson['auto_accept_incoming_eorder']),
          ctrlItemTracking:
              fromEJson(ejson['ctrl_item_tracking'], defaultValue: kStatusNo),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ApplicationSetup._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ApplicationSetup, 'APPLICATION_SETUP', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('decimalPoint', RealmPropertyType.string,
          mapTo: 'decimal_point', optional: true),
      SchemaProperty('separatorSymbol', RealmPropertyType.string,
          mapTo: 'separator_symbol', optional: true),
      SchemaProperty('quantityDecimal', RealmPropertyType.int,
          mapTo: 'quantity_decimal', optional: true),
      SchemaProperty('priceDecimal', RealmPropertyType.int,
          mapTo: 'price_decimal', optional: true),
      SchemaProperty('costDecimal', RealmPropertyType.int,
          mapTo: 'cost_decimal', optional: true),
      SchemaProperty('measurementDecimal', RealmPropertyType.int,
          mapTo: 'measurement_decimal', optional: true),
      SchemaProperty('generalDecimal', RealmPropertyType.int,
          mapTo: 'general_decimal', optional: true),
      SchemaProperty('amountDecimal', RealmPropertyType.int,
          mapTo: 'amount_decimal', optional: true),
      SchemaProperty('percentageDecimal', RealmPropertyType.int,
          mapTo: 'percentage_decimal', optional: true),
      SchemaProperty('itemQtyFormat', RealmPropertyType.int,
          mapTo: 'item_qty_format', optional: true),
      SchemaProperty('allowPostingFrom', RealmPropertyType.string,
          mapTo: 'allow_posting_from', optional: true),
      SchemaProperty('allowPostingTo', RealmPropertyType.string,
          mapTo: 'allow_posting_to', optional: true),
      SchemaProperty('localCurrencyCode', RealmPropertyType.string,
          mapTo: 'local_currency_code', optional: true),
      SchemaProperty('decimalZero', RealmPropertyType.string,
          mapTo: 'decimal_zero', optional: true),
      SchemaProperty('incomeClosingPeriod', RealmPropertyType.string,
          mapTo: 'income_closing_period', optional: true),
      SchemaProperty('scrollPagination', RealmPropertyType.string,
          mapTo: 'scroll_pagination', optional: true),
      SchemaProperty('defaultSalesVatAccNo', RealmPropertyType.string,
          mapTo: 'default_sales_vat_acc_no', optional: true),
      SchemaProperty('defaultPurchaseVatAccNo', RealmPropertyType.string,
          mapTo: 'default_purchase_vat_acc_no', optional: true),
      SchemaProperty('defaultApAccNo', RealmPropertyType.string,
          mapTo: 'default_ap_acc_no', optional: true),
      SchemaProperty('defaultArAccNo', RealmPropertyType.string,
          mapTo: 'default_ar_acc_no', optional: true),
      SchemaProperty('defaultBankAccNo', RealmPropertyType.string,
          mapTo: 'default_bank_acc_no', optional: true),
      SchemaProperty('defaultCashAccNo', RealmPropertyType.string,
          mapTo: 'default_cash_acc_no', optional: true),
      SchemaProperty('defaultCostAccNo', RealmPropertyType.string,
          mapTo: 'default_cost_acc_no', optional: true),
      SchemaProperty('defaultSalesAccNo', RealmPropertyType.string,
          mapTo: 'default_sales_acc_no', optional: true),
      SchemaProperty('defaultPurchaseAccNo', RealmPropertyType.string,
          mapTo: 'default_purchase_acc_no', optional: true),
      SchemaProperty('defaultInventoryAccNo', RealmPropertyType.string,
          mapTo: 'default_inventory_acc_no', optional: true),
      SchemaProperty('defaultPositiveAdjAccountNo', RealmPropertyType.string,
          mapTo: 'default_positive_adj_account_no', optional: true),
      SchemaProperty('defaultNegativeAdjAccountNo', RealmPropertyType.string,
          mapTo: 'default_negative_adj_account_no', optional: true),
      SchemaProperty('defaultInvPostingGroup', RealmPropertyType.string,
          mapTo: 'default_inv_posting_group', optional: true),
      SchemaProperty('defaultApPostingGroup', RealmPropertyType.string,
          mapTo: 'default_ap_posting_group', optional: true),
      SchemaProperty('defaultArPostingGroup', RealmPropertyType.string,
          mapTo: 'default_ar_posting_group', optional: true),
      SchemaProperty('defaultGenBusPostingGroup', RealmPropertyType.string,
          mapTo: 'default_gen_bus_posting_group', optional: true),
      SchemaProperty('defaultGenProdPostingGroup', RealmPropertyType.string,
          mapTo: 'default_gen_prod_posting_group', optional: true),
      SchemaProperty('defaultVatBusPostingGroup', RealmPropertyType.string,
          mapTo: 'default_vat_bus_posting_group', optional: true),
      SchemaProperty('defaultVatProdPostingGroup', RealmPropertyType.string,
          mapTo: 'default_vat_prod_posting_group', optional: true),
      SchemaProperty('defaultPaymentTerm', RealmPropertyType.string,
          mapTo: 'default_payment_term', optional: true),
      SchemaProperty('defaultStockUnitMeasure', RealmPropertyType.string,
          mapTo: 'default_stock_unit_measure', optional: true),
      SchemaProperty('defaultItemPriceIncludeVat', RealmPropertyType.string,
          mapTo: 'default_item_price_include_vat', optional: true),
      SchemaProperty('acceptEorderOrderStatus', RealmPropertyType.string,
          mapTo: 'accept_eorder_order_status', optional: true),
      SchemaProperty('autoAcceptIncomingEorder', RealmPropertyType.string,
          mapTo: 'auto_accept_incoming_eorder', optional: true),
      SchemaProperty('ctrlItemTracking', RealmPropertyType.string,
          mapTo: 'ctrl_item_tracking', optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class LoginSession extends _LoginSession
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  LoginSession(
    String id, {
    String? username,
    String? phoneNo,
    String? email,
    String? accessToken,
    String? lastLoginDateTime,
    String? avatar128,
    String? locale,
    String? timeZone,
    int? accountId,
    String? isLogin = "No",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<LoginSession>({
        'is_login': "No",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'username', username);
    RealmObjectBase.set(this, 'phone_no', phoneNo);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'access_token', accessToken);
    RealmObjectBase.set(this, 'last_login_datetime', lastLoginDateTime);
    RealmObjectBase.set(this, 'avatar_128', avatar128);
    RealmObjectBase.set(this, 'locale', locale);
    RealmObjectBase.set(this, 'time_zone', timeZone);
    RealmObjectBase.set(this, 'account_id', accountId);
    RealmObjectBase.set(this, 'is_login', isLogin);
  }

  LoginSession._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get username =>
      RealmObjectBase.get<String>(this, 'username') as String?;
  @override
  set username(String? value) => RealmObjectBase.set(this, 'username', value);

  @override
  String? get phoneNo =>
      RealmObjectBase.get<String>(this, 'phone_no') as String?;
  @override
  set phoneNo(String? value) => RealmObjectBase.set(this, 'phone_no', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get accessToken =>
      RealmObjectBase.get<String>(this, 'access_token') as String?;
  @override
  set accessToken(String? value) =>
      RealmObjectBase.set(this, 'access_token', value);

  @override
  String? get lastLoginDateTime =>
      RealmObjectBase.get<String>(this, 'last_login_datetime') as String?;
  @override
  set lastLoginDateTime(String? value) =>
      RealmObjectBase.set(this, 'last_login_datetime', value);

  @override
  String? get avatar128 =>
      RealmObjectBase.get<String>(this, 'avatar_128') as String?;
  @override
  set avatar128(String? value) =>
      RealmObjectBase.set(this, 'avatar_128', value);

  @override
  String? get locale => RealmObjectBase.get<String>(this, 'locale') as String?;
  @override
  set locale(String? value) => RealmObjectBase.set(this, 'locale', value);

  @override
  String? get timeZone =>
      RealmObjectBase.get<String>(this, 'time_zone') as String?;
  @override
  set timeZone(String? value) => RealmObjectBase.set(this, 'time_zone', value);

  @override
  int? get accountId => RealmObjectBase.get<int>(this, 'account_id') as int?;
  @override
  set accountId(int? value) => RealmObjectBase.set(this, 'account_id', value);

  @override
  String? get isLogin =>
      RealmObjectBase.get<String>(this, 'is_login') as String?;
  @override
  set isLogin(String? value) => RealmObjectBase.set(this, 'is_login', value);

  @override
  Stream<RealmObjectChanges<LoginSession>> get changes =>
      RealmObjectBase.getChanges<LoginSession>(this);

  @override
  Stream<RealmObjectChanges<LoginSession>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<LoginSession>(this, keyPaths);

  @override
  LoginSession freeze() => RealmObjectBase.freezeObject<LoginSession>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'username': username.toEJson(),
      'phone_no': phoneNo.toEJson(),
      'email': email.toEJson(),
      'access_token': accessToken.toEJson(),
      'last_login_datetime': lastLoginDateTime.toEJson(),
      'avatar_128': avatar128.toEJson(),
      'locale': locale.toEJson(),
      'time_zone': timeZone.toEJson(),
      'account_id': accountId.toEJson(),
      'is_login': isLogin.toEJson(),
    };
  }

  static EJsonValue _toEJson(LoginSession value) => value.toEJson();
  static LoginSession _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
      } =>
        LoginSession(
          fromEJson(id),
          username: fromEJson(ejson['username']),
          phoneNo: fromEJson(ejson['phone_no']),
          email: fromEJson(ejson['email']),
          accessToken: fromEJson(ejson['access_token']),
          lastLoginDateTime: fromEJson(ejson['last_login_datetime']),
          avatar128: fromEJson(ejson['avatar_128']),
          locale: fromEJson(ejson['locale']),
          timeZone: fromEJson(ejson['time_zone']),
          accountId: fromEJson(ejson['account_id']),
          isLogin: fromEJson(ejson['is_login'], defaultValue: "No"),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(LoginSession._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, LoginSession, 'LOGIN_SESSION', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('username', RealmPropertyType.string, optional: true),
      SchemaProperty('phoneNo', RealmPropertyType.string,
          mapTo: 'phone_no', optional: true),
      SchemaProperty('email', RealmPropertyType.string, optional: true),
      SchemaProperty('accessToken', RealmPropertyType.string,
          mapTo: 'access_token', optional: true),
      SchemaProperty('lastLoginDateTime', RealmPropertyType.string,
          mapTo: 'last_login_datetime', optional: true),
      SchemaProperty('avatar128', RealmPropertyType.string,
          mapTo: 'avatar_128', optional: true),
      SchemaProperty('locale', RealmPropertyType.string, optional: true),
      SchemaProperty('timeZone', RealmPropertyType.string,
          mapTo: 'time_zone', optional: true),
      SchemaProperty('accountId', RealmPropertyType.int,
          mapTo: 'account_id', optional: true),
      SchemaProperty('isLogin', RealmPropertyType.string,
          mapTo: 'is_login', optional: true),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class AppSetting extends _AppSetting
    with RealmEntity, RealmObjectBase, RealmObject {
  AppSetting(
    String key,
    String value,
  ) {
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set(this, 'value', value);
  }

  AppSetting._();

  @override
  String get key => RealmObjectBase.get<String>(this, 'key') as String;
  @override
  set key(String value) => RealmObjectBase.set(this, 'key', value);

  @override
  String get value => RealmObjectBase.get<String>(this, 'value') as String;
  @override
  set value(String value) => RealmObjectBase.set(this, 'value', value);

  @override
  Stream<RealmObjectChanges<AppSetting>> get changes =>
      RealmObjectBase.getChanges<AppSetting>(this);

  @override
  Stream<RealmObjectChanges<AppSetting>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AppSetting>(this, keyPaths);

  @override
  AppSetting freeze() => RealmObjectBase.freezeObject<AppSetting>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'key': key.toEJson(),
      'value': value.toEJson(),
    };
  }

  static EJsonValue _toEJson(AppSetting value) => value.toEJson();
  static AppSetting _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'key': EJsonValue key,
        'value': EJsonValue value,
      } =>
        AppSetting(
          fromEJson(key),
          fromEJson(value),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AppSetting._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, AppSetting, 'APP_SETTING', [
      SchemaProperty('key', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('value', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class GpsRouteTracking extends _GpsRouteTracking
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  GpsRouteTracking(
    String salepersonCode,
    double latitude,
    double longitude,
    String createdDate,
    String createdTime, {
    String isSync = "No",
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<GpsRouteTracking>({
        'is_sync': "No",
      });
    }
    RealmObjectBase.set(this, 'saleperson_code', salepersonCode);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'created_date', createdDate);
    RealmObjectBase.set(this, 'created_time', createdTime);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  GpsRouteTracking._();

  @override
  String get salepersonCode =>
      RealmObjectBase.get<String>(this, 'saleperson_code') as String;
  @override
  set salepersonCode(String value) =>
      RealmObjectBase.set(this, 'saleperson_code', value);

  @override
  double get latitude =>
      RealmObjectBase.get<double>(this, 'latitude') as double;
  @override
  set latitude(double value) => RealmObjectBase.set(this, 'latitude', value);

  @override
  double get longitude =>
      RealmObjectBase.get<double>(this, 'longitude') as double;
  @override
  set longitude(double value) => RealmObjectBase.set(this, 'longitude', value);

  @override
  String get createdDate =>
      RealmObjectBase.get<String>(this, 'created_date') as String;
  @override
  set createdDate(String value) =>
      RealmObjectBase.set(this, 'created_date', value);

  @override
  String get createdTime =>
      RealmObjectBase.get<String>(this, 'created_time') as String;
  @override
  set createdTime(String value) =>
      RealmObjectBase.set(this, 'created_time', value);

  @override
  String get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String;
  @override
  set isSync(String value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<GpsRouteTracking>> get changes =>
      RealmObjectBase.getChanges<GpsRouteTracking>(this);

  @override
  Stream<RealmObjectChanges<GpsRouteTracking>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<GpsRouteTracking>(this, keyPaths);

  @override
  GpsRouteTracking freeze() =>
      RealmObjectBase.freezeObject<GpsRouteTracking>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'saleperson_code': salepersonCode.toEJson(),
      'latitude': latitude.toEJson(),
      'longitude': longitude.toEJson(),
      'created_date': createdDate.toEJson(),
      'created_time': createdTime.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(GpsRouteTracking value) => value.toEJson();
  static GpsRouteTracking _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'saleperson_code': EJsonValue salepersonCode,
        'latitude': EJsonValue latitude,
        'longitude': EJsonValue longitude,
        'created_date': EJsonValue createdDate,
        'created_time': EJsonValue createdTime,
      } =>
        GpsRouteTracking(
          fromEJson(salepersonCode),
          fromEJson(latitude),
          fromEJson(longitude),
          fromEJson(createdDate),
          fromEJson(createdTime),
          isSync: fromEJson(ejson['is_sync'], defaultValue: "No"),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(GpsRouteTracking._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, GpsRouteTracking, 'GPS_ROUTE_TRACKING', [
      SchemaProperty('salepersonCode', RealmPropertyType.string,
          mapTo: 'saleperson_code'),
      SchemaProperty('latitude', RealmPropertyType.double),
      SchemaProperty('longitude', RealmPropertyType.double),
      SchemaProperty('createdDate', RealmPropertyType.string,
          mapTo: 'created_date'),
      SchemaProperty('createdTime', RealmPropertyType.string,
          mapTo: 'created_time'),
      SchemaProperty('isSync', RealmPropertyType.string, mapTo: 'is_sync'),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class ItemLedgerEntry extends _ItemLedgerEntry
    with RealmEntity, RealmObjectBase, RealmObject {
  ItemLedgerEntry(
    String itemNo,
    String lotNo,
    String serailNo,
    double quantity,
    String date,
  ) {
    RealmObjectBase.set(this, 'item_no', itemNo);
    RealmObjectBase.set(this, 'lot_no', lotNo);
    RealmObjectBase.set(this, 'serail_no', serailNo);
    RealmObjectBase.set(this, 'quantity', quantity);
    RealmObjectBase.set(this, 'date', date);
  }

  ItemLedgerEntry._();

  @override
  String get itemNo => RealmObjectBase.get<String>(this, 'item_no') as String;
  @override
  set itemNo(String value) => RealmObjectBase.set(this, 'item_no', value);

  @override
  String get lotNo => RealmObjectBase.get<String>(this, 'lot_no') as String;
  @override
  set lotNo(String value) => RealmObjectBase.set(this, 'lot_no', value);

  @override
  String get serailNo =>
      RealmObjectBase.get<String>(this, 'serail_no') as String;
  @override
  set serailNo(String value) => RealmObjectBase.set(this, 'serail_no', value);

  @override
  double get quantity =>
      RealmObjectBase.get<double>(this, 'quantity') as double;
  @override
  set quantity(double value) => RealmObjectBase.set(this, 'quantity', value);

  @override
  String get date => RealmObjectBase.get<String>(this, 'date') as String;
  @override
  set date(String value) => RealmObjectBase.set(this, 'date', value);

  @override
  Stream<RealmObjectChanges<ItemLedgerEntry>> get changes =>
      RealmObjectBase.getChanges<ItemLedgerEntry>(this);

  @override
  Stream<RealmObjectChanges<ItemLedgerEntry>> changesFor(
          [List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<ItemLedgerEntry>(this, keyPaths);

  @override
  ItemLedgerEntry freeze() =>
      RealmObjectBase.freezeObject<ItemLedgerEntry>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'item_no': itemNo.toEJson(),
      'lot_no': lotNo.toEJson(),
      'serail_no': serailNo.toEJson(),
      'quantity': quantity.toEJson(),
      'date': date.toEJson(),
    };
  }

  static EJsonValue _toEJson(ItemLedgerEntry value) => value.toEJson();
  static ItemLedgerEntry _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'item_no': EJsonValue itemNo,
        'lot_no': EJsonValue lotNo,
        'serail_no': EJsonValue serailNo,
        'quantity': EJsonValue quantity,
        'date': EJsonValue date,
      } =>
        ItemLedgerEntry(
          fromEJson(itemNo),
          fromEJson(lotNo),
          fromEJson(serailNo),
          fromEJson(quantity),
          fromEJson(date),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(ItemLedgerEntry._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
        ObjectType.realmObject, ItemLedgerEntry, 'ITEM_LEDGER_ENTRY', [
      SchemaProperty('itemNo', RealmPropertyType.string, mapTo: 'item_no'),
      SchemaProperty('lotNo', RealmPropertyType.string, mapTo: 'lot_no'),
      SchemaProperty('serailNo', RealmPropertyType.string, mapTo: 'serail_no'),
      SchemaProperty('quantity', RealmPropertyType.double),
      SchemaProperty('date', RealmPropertyType.string),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}
