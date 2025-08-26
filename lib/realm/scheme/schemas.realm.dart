// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class AppServer extends _AppServer
    with RealmEntity, RealmObjectBase, RealmObject {
  AppServer(
    String id,
    String name,
    String icon,
    int hide,
    String url,
    String backendUrl,
  ) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'icon', icon);
    RealmObjectBase.set(this, 'hide', hide);
    RealmObjectBase.set(this, 'url', url);
    RealmObjectBase.set(this, 'backend_url', backendUrl);
  }

  AppServer._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String get name => RealmObjectBase.get<String>(this, 'name') as String;
  @override
  set name(String value) => RealmObjectBase.set(this, 'name', value);

  @override
  String get icon => RealmObjectBase.get<String>(this, 'icon') as String;
  @override
  set icon(String value) => RealmObjectBase.set(this, 'icon', value);

  @override
  int get hide => RealmObjectBase.get<int>(this, 'hide') as int;
  @override
  set hide(int value) => RealmObjectBase.set(this, 'hide', value);

  @override
  String get url => RealmObjectBase.get<String>(this, 'url') as String;
  @override
  set url(String value) => RealmObjectBase.set(this, 'url', value);

  @override
  String get backendUrl =>
      RealmObjectBase.get<String>(this, 'backend_url') as String;
  @override
  set backendUrl(String value) =>
      RealmObjectBase.set(this, 'backend_url', value);

  @override
  Stream<RealmObjectChanges<AppServer>> get changes =>
      RealmObjectBase.getChanges<AppServer>(this);

  @override
  Stream<RealmObjectChanges<AppServer>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AppServer>(this, keyPaths);

  @override
  AppServer freeze() => RealmObjectBase.freezeObject<AppServer>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'icon': icon.toEJson(),
      'hide': hide.toEJson(),
      'url': url.toEJson(),
      'backend_url': backendUrl.toEJson(),
    };
  }

  static EJsonValue _toEJson(AppServer value) => value.toEJson();
  static AppServer _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {
        'id': EJsonValue id,
        'name': EJsonValue name,
        'icon': EJsonValue icon,
        'hide': EJsonValue hide,
        'url': EJsonValue url,
        'backend_url': EJsonValue backendUrl,
      } =>
        AppServer(
          fromEJson(id),
          fromEJson(name),
          fromEJson(icon),
          fromEJson(hide),
          fromEJson(url),
          fromEJson(backendUrl),
        ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AppServer._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, AppServer, 'APP_SERVER', [
      SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string),
      SchemaProperty('icon', RealmPropertyType.string),
      SchemaProperty('hide', RealmPropertyType.int),
      SchemaProperty('url', RealmPropertyType.string),
      SchemaProperty(
        'backendUrl',
        RealmPropertyType.string,
        mapTo: 'backend_url',
      ),
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CompanyInformation extends _CompanyInformation
    with RealmEntity, RealmObjectBase, RealmObject {
  CompanyInformation(
    String id, {
    String? name,
    String? name2,
    String? address,
    String? address2,
    String? logo128,
    String? email,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'name_2', name2);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'logo_128', logo128);
    RealmObjectBase.set(this, 'email', email);
  }

  CompanyInformation._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get name2 => RealmObjectBase.get<String>(this, 'name_2') as String?;
  @override
  set name2(String? value) => RealmObjectBase.set(this, 'name_2', value);

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
  String? get logo128 =>
      RealmObjectBase.get<String>(this, 'logo_128') as String?;
  @override
  set logo128(String? value) => RealmObjectBase.set(this, 'logo_128', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  Stream<RealmObjectChanges<CompanyInformation>> get changes =>
      RealmObjectBase.getChanges<CompanyInformation>(this);

  @override
  Stream<RealmObjectChanges<CompanyInformation>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CompanyInformation>(this, keyPaths);

  @override
  CompanyInformation freeze() =>
      RealmObjectBase.freezeObject<CompanyInformation>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'name': name.toEJson(),
      'name_2': name2.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'logo_128': logo128.toEJson(),
      'email': email.toEJson(),
    };
  }

  static EJsonValue _toEJson(CompanyInformation value) => value.toEJson();
  static CompanyInformation _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => CompanyInformation(
        fromEJson(id),
        name: fromEJson(ejson['name']),
        name2: fromEJson(ejson['name_2']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        logo128: fromEJson(ejson['logo_128']),
        email: fromEJson(ejson['email']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CompanyInformation._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CompanyInformation,
      'COMPANY_INFORMATION',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'name2',
          RealmPropertyType.string,
          mapTo: 'name_2',
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
          'logo128',
          RealmPropertyType.string,
          mapTo: 'logo_128',
          optional: true,
        ),
        SchemaProperty('email', RealmPropertyType.string, optional: true),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class DistributionSetUp extends _DistributionSetUp
    with RealmEntity, RealmObjectBase, RealmObject {
  DistributionSetUp(String key, String value) {
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set(this, 'value', value);
  }

  DistributionSetUp._();

  @override
  String get key => RealmObjectBase.get<String>(this, 'key') as String;
  @override
  set key(String value) => RealmObjectBase.set(this, 'key', value);

  @override
  String get value => RealmObjectBase.get<String>(this, 'value') as String;
  @override
  set value(String value) => RealmObjectBase.set(this, 'value', value);

  @override
  Stream<RealmObjectChanges<DistributionSetUp>> get changes =>
      RealmObjectBase.getChanges<DistributionSetUp>(this);

  @override
  Stream<RealmObjectChanges<DistributionSetUp>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<DistributionSetUp>(this, keyPaths);

  @override
  DistributionSetUp freeze() =>
      RealmObjectBase.freezeObject<DistributionSetUp>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{'key': key.toEJson(), 'value': value.toEJson()};
  }

  static EJsonValue _toEJson(DistributionSetUp value) => value.toEJson();
  static DistributionSetUp _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'key': EJsonValue key, 'value': EJsonValue value} => DistributionSetUp(
        fromEJson(key),
        fromEJson(value),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(DistributionSetUp._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      DistributionSetUp,
      'DISTRIBUTION_SETUP',
      [
        SchemaProperty('key', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('value', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Organization extends _Organization
    with RealmEntity, RealmObjectBase, RealmObject {
  Organization(
    String userId, {
    String? organizationName,
    String? databaseName,
    String? logo,
    String? typeOfIndustry,
    String? businessIndustry,
    String? contactName,
    String? phoneNo,
    String? email,
    String? website,
    String? address,
    String? address2,
    String? status,
    String? registerDate,
    String? inMaintenanceMode,
  }) {
    RealmObjectBase.set(this, 'user_id', userId);
    RealmObjectBase.set(this, 'orgnaization_name', organizationName);
    RealmObjectBase.set(this, 'database_name', databaseName);
    RealmObjectBase.set(this, 'logo', logo);
    RealmObjectBase.set(this, 'type_of_industry', typeOfIndustry);
    RealmObjectBase.set(this, 'business_industry', businessIndustry);
    RealmObjectBase.set(this, 'contact_name', contactName);
    RealmObjectBase.set(this, 'phone_no', phoneNo);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'website', website);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'register_date', registerDate);
    RealmObjectBase.set(this, 'in_maintenance_mode', inMaintenanceMode);
  }

  Organization._();

  @override
  String get userId => RealmObjectBase.get<String>(this, 'user_id') as String;
  @override
  set userId(String value) => RealmObjectBase.set(this, 'user_id', value);

  @override
  String? get organizationName =>
      RealmObjectBase.get<String>(this, 'orgnaization_name') as String?;
  @override
  set organizationName(String? value) =>
      RealmObjectBase.set(this, 'orgnaization_name', value);

  @override
  String? get databaseName =>
      RealmObjectBase.get<String>(this, 'database_name') as String?;
  @override
  set databaseName(String? value) =>
      RealmObjectBase.set(this, 'database_name', value);

  @override
  String? get logo => RealmObjectBase.get<String>(this, 'logo') as String?;
  @override
  set logo(String? value) => RealmObjectBase.set(this, 'logo', value);

  @override
  String? get typeOfIndustry =>
      RealmObjectBase.get<String>(this, 'type_of_industry') as String?;
  @override
  set typeOfIndustry(String? value) =>
      RealmObjectBase.set(this, 'type_of_industry', value);

  @override
  String? get businessIndustry =>
      RealmObjectBase.get<String>(this, 'business_industry') as String?;
  @override
  set businessIndustry(String? value) =>
      RealmObjectBase.set(this, 'business_industry', value);

  @override
  String? get contactName =>
      RealmObjectBase.get<String>(this, 'contact_name') as String?;
  @override
  set contactName(String? value) =>
      RealmObjectBase.set(this, 'contact_name', value);

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
  String? get website =>
      RealmObjectBase.get<String>(this, 'website') as String?;
  @override
  set website(String? value) => RealmObjectBase.set(this, 'website', value);

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
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get registerDate =>
      RealmObjectBase.get<String>(this, 'register_date') as String?;
  @override
  set registerDate(String? value) =>
      RealmObjectBase.set(this, 'register_date', value);

  @override
  String? get inMaintenanceMode =>
      RealmObjectBase.get<String>(this, 'in_maintenance_mode') as String?;
  @override
  set inMaintenanceMode(String? value) =>
      RealmObjectBase.set(this, 'in_maintenance_mode', value);

  @override
  Stream<RealmObjectChanges<Organization>> get changes =>
      RealmObjectBase.getChanges<Organization>(this);

  @override
  Stream<RealmObjectChanges<Organization>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<Organization>(this, keyPaths);

  @override
  Organization freeze() => RealmObjectBase.freezeObject<Organization>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'user_id': userId.toEJson(),
      'orgnaization_name': organizationName.toEJson(),
      'database_name': databaseName.toEJson(),
      'logo': logo.toEJson(),
      'type_of_industry': typeOfIndustry.toEJson(),
      'business_industry': businessIndustry.toEJson(),
      'contact_name': contactName.toEJson(),
      'phone_no': phoneNo.toEJson(),
      'email': email.toEJson(),
      'website': website.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'status': status.toEJson(),
      'register_date': registerDate.toEJson(),
      'in_maintenance_mode': inMaintenanceMode.toEJson(),
    };
  }

  static EJsonValue _toEJson(Organization value) => value.toEJson();
  static Organization _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'user_id': EJsonValue userId} => Organization(
        fromEJson(userId),
        organizationName: fromEJson(ejson['orgnaization_name']),
        databaseName: fromEJson(ejson['database_name']),
        logo: fromEJson(ejson['logo']),
        typeOfIndustry: fromEJson(ejson['type_of_industry']),
        businessIndustry: fromEJson(ejson['business_industry']),
        contactName: fromEJson(ejson['contact_name']),
        phoneNo: fromEJson(ejson['phone_no']),
        email: fromEJson(ejson['email']),
        website: fromEJson(ejson['website']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        status: fromEJson(ejson['status']),
        registerDate: fromEJson(ejson['register_date']),
        inMaintenanceMode: fromEJson(ejson['in_maintenance_mode']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Organization._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      Organization,
      'ORGANIZATION',
      [
        SchemaProperty(
          'userId',
          RealmPropertyType.string,
          mapTo: 'user_id',
          primaryKey: true,
        ),
        SchemaProperty(
          'organizationName',
          RealmPropertyType.string,
          mapTo: 'orgnaization_name',
          optional: true,
        ),
        SchemaProperty(
          'databaseName',
          RealmPropertyType.string,
          mapTo: 'database_name',
          optional: true,
        ),
        SchemaProperty('logo', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'typeOfIndustry',
          RealmPropertyType.string,
          mapTo: 'type_of_industry',
          optional: true,
        ),
        SchemaProperty(
          'businessIndustry',
          RealmPropertyType.string,
          mapTo: 'business_industry',
          optional: true,
        ),
        SchemaProperty(
          'contactName',
          RealmPropertyType.string,
          mapTo: 'contact_name',
          optional: true,
        ),
        SchemaProperty(
          'phoneNo',
          RealmPropertyType.string,
          mapTo: 'phone_no',
          optional: true,
        ),
        SchemaProperty('email', RealmPropertyType.string, optional: true),
        SchemaProperty('website', RealmPropertyType.string, optional: true),
        SchemaProperty('address', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'address2',
          RealmPropertyType.string,
          mapTo: 'address_2',
          optional: true,
        ),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'registerDate',
          RealmPropertyType.string,
          mapTo: 'register_date',
          optional: true,
        ),
        SchemaProperty(
          'inMaintenanceMode',
          RealmPropertyType.string,
          mapTo: 'in_maintenance_mode',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class Permission extends _Permission
    with RealmEntity, RealmObjectBase, RealmObject {
  Permission(String key, String value) {
    RealmObjectBase.set(this, 'key', key);
    RealmObjectBase.set(this, 'value', value);
  }

  Permission._();

  @override
  String get key => RealmObjectBase.get<String>(this, 'key') as String;
  @override
  set key(String value) => RealmObjectBase.set(this, 'key', value);

  @override
  String get value => RealmObjectBase.get<String>(this, 'value') as String;
  @override
  set value(String value) => RealmObjectBase.set(this, 'value', value);

  @override
  Stream<RealmObjectChanges<Permission>> get changes =>
      RealmObjectBase.getChanges<Permission>(this);

  @override
  Stream<RealmObjectChanges<Permission>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Permission>(this, keyPaths);

  @override
  Permission freeze() => RealmObjectBase.freezeObject<Permission>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{'key': key.toEJson(), 'value': value.toEJson()};
  }

  static EJsonValue _toEJson(Permission value) => value.toEJson();
  static Permission _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'key': EJsonValue key, 'value': EJsonValue value} => Permission(
        fromEJson(key),
        fromEJson(value),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Permission._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      Permission,
      'PERMISSION',
      [
        SchemaProperty('key', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('value', RealmPropertyType.string),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class AppSyncLog extends _AppSyncLog
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  AppSyncLog(
    String tableName, {
    String? displayName,
    String? userAgent,
    String? type,
    String? lastSynchedDatetime,
    String? lastLocalQueryDatetime,
    String? total,
    String? setRecordAfterDownload = 'No',
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<AppSyncLog>({
        'set_record_after_download': 'No',
      });
    }
    RealmObjectBase.set(this, 'table_name', tableName);
    RealmObjectBase.set(this, 'display_name', displayName);
    RealmObjectBase.set(this, 'user_agent', userAgent);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'last_synched_datetime', lastSynchedDatetime);
    RealmObjectBase.set(
      this,
      'last_local_query_datetime',
      lastLocalQueryDatetime,
    );
    RealmObjectBase.set(this, 'total', total);
    RealmObjectBase.set(
      this,
      'set_record_after_download',
      setRecordAfterDownload,
    );
  }

  AppSyncLog._();

  @override
  String get tableName =>
      RealmObjectBase.get<String>(this, 'table_name') as String;
  @override
  set tableName(String value) => RealmObjectBase.set(this, 'table_name', value);

  @override
  String? get displayName =>
      RealmObjectBase.get<String>(this, 'display_name') as String?;
  @override
  set displayName(String? value) =>
      RealmObjectBase.set(this, 'display_name', value);

  @override
  String? get userAgent =>
      RealmObjectBase.get<String>(this, 'user_agent') as String?;
  @override
  set userAgent(String? value) =>
      RealmObjectBase.set(this, 'user_agent', value);

  @override
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get lastSynchedDatetime =>
      RealmObjectBase.get<String>(this, 'last_synched_datetime') as String?;
  @override
  set lastSynchedDatetime(String? value) =>
      RealmObjectBase.set(this, 'last_synched_datetime', value);

  @override
  String? get lastLocalQueryDatetime =>
      RealmObjectBase.get<String>(this, 'last_local_query_datetime') as String?;
  @override
  set lastLocalQueryDatetime(String? value) =>
      RealmObjectBase.set(this, 'last_local_query_datetime', value);

  @override
  String? get total => RealmObjectBase.get<String>(this, 'total') as String?;
  @override
  set total(String? value) => RealmObjectBase.set(this, 'total', value);

  @override
  String? get setRecordAfterDownload =>
      RealmObjectBase.get<String>(this, 'set_record_after_download') as String?;
  @override
  set setRecordAfterDownload(String? value) =>
      RealmObjectBase.set(this, 'set_record_after_download', value);

  @override
  Stream<RealmObjectChanges<AppSyncLog>> get changes =>
      RealmObjectBase.getChanges<AppSyncLog>(this);

  @override
  Stream<RealmObjectChanges<AppSyncLog>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<AppSyncLog>(this, keyPaths);

  @override
  AppSyncLog freeze() => RealmObjectBase.freezeObject<AppSyncLog>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'table_name': tableName.toEJson(),
      'display_name': displayName.toEJson(),
      'user_agent': userAgent.toEJson(),
      'type': type.toEJson(),
      'last_synched_datetime': lastSynchedDatetime.toEJson(),
      'last_local_query_datetime': lastLocalQueryDatetime.toEJson(),
      'total': total.toEJson(),
      'set_record_after_download': setRecordAfterDownload.toEJson(),
    };
  }

  static EJsonValue _toEJson(AppSyncLog value) => value.toEJson();
  static AppSyncLog _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'table_name': EJsonValue tableName} => AppSyncLog(
        fromEJson(tableName),
        displayName: fromEJson(ejson['display_name']),
        userAgent: fromEJson(ejson['user_agent']),
        type: fromEJson(ejson['type']),
        lastSynchedDatetime: fromEJson(ejson['last_synched_datetime']),
        lastLocalQueryDatetime: fromEJson(ejson['last_local_query_datetime']),
        total: fromEJson(ejson['total']),
        setRecordAfterDownload: fromEJson(
          ejson['set_record_after_download'],
          defaultValue: 'No',
        ),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(AppSyncLog._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      AppSyncLog,
      'APP_SYNC_LOG',
      [
        SchemaProperty(
          'tableName',
          RealmPropertyType.string,
          mapTo: 'table_name',
          primaryKey: true,
        ),
        SchemaProperty(
          'displayName',
          RealmPropertyType.string,
          mapTo: 'display_name',
          optional: true,
        ),
        SchemaProperty(
          'userAgent',
          RealmPropertyType.string,
          mapTo: 'user_agent',
          optional: true,
        ),
        SchemaProperty('type', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'lastSynchedDatetime',
          RealmPropertyType.string,
          mapTo: 'last_synched_datetime',
          optional: true,
        ),
        SchemaProperty(
          'lastLocalQueryDatetime',
          RealmPropertyType.string,
          mapTo: 'last_local_query_datetime',
          optional: true,
        ),
        SchemaProperty('total', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'setRecordAfterDownload',
          RealmPropertyType.string,
          mapTo: 'set_record_after_download',
          optional: true,
        ),
      ],
    );
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class BankAccount extends _BankAccount
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  BankAccount(
    String no, {
    String? name,
    String? name2,
    String? address,
    String? address2,
    String? postCode,
    String? village,
    String? commune,
    String? district,
    String? province,
    String? countryCode,
    String? phoneNo,
    String? phoneNo2,
    String? email,
    String? contactName,
    String? transitNo,
    String? bankAccountNo,
    String? currencyCode,
    String? swiftCode,
    String? lastCheckNo,
    String? lastStatementNo,
    String? lastPaymentStatementNo,
    String? bankAccPostingGroup,
    String? divisionCode,
    String? branchCode,
    String? mobilePayment,
    String inctived = 'No',
    String isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<BankAccount>({
        'inctived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'name_2', name2);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'post_code', postCode);
    RealmObjectBase.set(this, 'village', village);
    RealmObjectBase.set(this, 'commune', commune);
    RealmObjectBase.set(this, 'district', district);
    RealmObjectBase.set(this, 'province', province);
    RealmObjectBase.set(this, 'country_code', countryCode);
    RealmObjectBase.set(this, 'phone_no', phoneNo);
    RealmObjectBase.set(this, 'phone_no_2', phoneNo2);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'contactName', contactName);
    RealmObjectBase.set(this, 'transit_no', transitNo);
    RealmObjectBase.set(this, 'bank_account_no', bankAccountNo);
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'swift_code', swiftCode);
    RealmObjectBase.set(this, 'last_check_no', lastCheckNo);
    RealmObjectBase.set(this, 'last_statement_no', lastStatementNo);
    RealmObjectBase.set(
      this,
      'last_payment_statement_no',
      lastPaymentStatementNo,
    );
    RealmObjectBase.set(this, 'bank_acc_posting_group', bankAccPostingGroup);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'branch_code', branchCode);
    RealmObjectBase.set(this, 'mobile_payment', mobilePayment);
    RealmObjectBase.set(this, 'inctived', inctived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  BankAccount._();

  @override
  String get no => RealmObjectBase.get<String>(this, 'no') as String;
  @override
  set no(String value) => RealmObjectBase.set(this, 'no', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get name2 => RealmObjectBase.get<String>(this, 'name_2') as String?;
  @override
  set name2(String? value) => RealmObjectBase.set(this, 'name_2', value);

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
  String? get postCode =>
      RealmObjectBase.get<String>(this, 'post_code') as String?;
  @override
  set postCode(String? value) => RealmObjectBase.set(this, 'post_code', value);

  @override
  String? get village =>
      RealmObjectBase.get<String>(this, 'village') as String?;
  @override
  set village(String? value) => RealmObjectBase.set(this, 'village', value);

  @override
  String? get commune =>
      RealmObjectBase.get<String>(this, 'commune') as String?;
  @override
  set commune(String? value) => RealmObjectBase.set(this, 'commune', value);

  @override
  String? get district =>
      RealmObjectBase.get<String>(this, 'district') as String?;
  @override
  set district(String? value) => RealmObjectBase.set(this, 'district', value);

  @override
  String? get province =>
      RealmObjectBase.get<String>(this, 'province') as String?;
  @override
  set province(String? value) => RealmObjectBase.set(this, 'province', value);

  @override
  String? get countryCode =>
      RealmObjectBase.get<String>(this, 'country_code') as String?;
  @override
  set countryCode(String? value) =>
      RealmObjectBase.set(this, 'country_code', value);

  @override
  String? get phoneNo =>
      RealmObjectBase.get<String>(this, 'phone_no') as String?;
  @override
  set phoneNo(String? value) => RealmObjectBase.set(this, 'phone_no', value);

  @override
  String? get phoneNo2 =>
      RealmObjectBase.get<String>(this, 'phone_no_2') as String?;
  @override
  set phoneNo2(String? value) => RealmObjectBase.set(this, 'phone_no_2', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get contactName =>
      RealmObjectBase.get<String>(this, 'contactName') as String?;
  @override
  set contactName(String? value) =>
      RealmObjectBase.set(this, 'contactName', value);

  @override
  String? get transitNo =>
      RealmObjectBase.get<String>(this, 'transit_no') as String?;
  @override
  set transitNo(String? value) =>
      RealmObjectBase.set(this, 'transit_no', value);

  @override
  String? get bankAccountNo =>
      RealmObjectBase.get<String>(this, 'bank_account_no') as String?;
  @override
  set bankAccountNo(String? value) =>
      RealmObjectBase.set(this, 'bank_account_no', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currency_code') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currency_code', value);

  @override
  String? get swiftCode =>
      RealmObjectBase.get<String>(this, 'swift_code') as String?;
  @override
  set swiftCode(String? value) =>
      RealmObjectBase.set(this, 'swift_code', value);

  @override
  String? get lastCheckNo =>
      RealmObjectBase.get<String>(this, 'last_check_no') as String?;
  @override
  set lastCheckNo(String? value) =>
      RealmObjectBase.set(this, 'last_check_no', value);

  @override
  String? get lastStatementNo =>
      RealmObjectBase.get<String>(this, 'last_statement_no') as String?;
  @override
  set lastStatementNo(String? value) =>
      RealmObjectBase.set(this, 'last_statement_no', value);

  @override
  String? get lastPaymentStatementNo =>
      RealmObjectBase.get<String>(this, 'last_payment_statement_no') as String?;
  @override
  set lastPaymentStatementNo(String? value) =>
      RealmObjectBase.set(this, 'last_payment_statement_no', value);

  @override
  String? get bankAccPostingGroup =>
      RealmObjectBase.get<String>(this, 'bank_acc_posting_group') as String?;
  @override
  set bankAccPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'bank_acc_posting_group', value);

  @override
  String? get divisionCode =>
      RealmObjectBase.get<String>(this, 'division_code') as String?;
  @override
  set divisionCode(String? value) =>
      RealmObjectBase.set(this, 'division_code', value);

  @override
  String? get branchCode =>
      RealmObjectBase.get<String>(this, 'branch_code') as String?;
  @override
  set branchCode(String? value) =>
      RealmObjectBase.set(this, 'branch_code', value);

  @override
  String? get mobilePayment =>
      RealmObjectBase.get<String>(this, 'mobile_payment') as String?;
  @override
  set mobilePayment(String? value) =>
      RealmObjectBase.set(this, 'mobile_payment', value);

  @override
  String get inctived =>
      RealmObjectBase.get<String>(this, 'inctived') as String;
  @override
  set inctived(String value) => RealmObjectBase.set(this, 'inctived', value);

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
  Stream<RealmObjectChanges<BankAccount>> get changes =>
      RealmObjectBase.getChanges<BankAccount>(this);

  @override
  Stream<RealmObjectChanges<BankAccount>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<BankAccount>(this, keyPaths);

  @override
  BankAccount freeze() => RealmObjectBase.freezeObject<BankAccount>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'no': no.toEJson(),
      'name': name.toEJson(),
      'name_2': name2.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'post_code': postCode.toEJson(),
      'village': village.toEJson(),
      'commune': commune.toEJson(),
      'district': district.toEJson(),
      'province': province.toEJson(),
      'country_code': countryCode.toEJson(),
      'phone_no': phoneNo.toEJson(),
      'phone_no_2': phoneNo2.toEJson(),
      'email': email.toEJson(),
      'contactName': contactName.toEJson(),
      'transit_no': transitNo.toEJson(),
      'bank_account_no': bankAccountNo.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'swift_code': swiftCode.toEJson(),
      'last_check_no': lastCheckNo.toEJson(),
      'last_statement_no': lastStatementNo.toEJson(),
      'last_payment_statement_no': lastPaymentStatementNo.toEJson(),
      'bank_acc_posting_group': bankAccPostingGroup.toEJson(),
      'division_code': divisionCode.toEJson(),
      'branch_code': branchCode.toEJson(),
      'mobile_payment': mobilePayment.toEJson(),
      'inctived': inctived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(BankAccount value) => value.toEJson();
  static BankAccount _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'no': EJsonValue no} => BankAccount(
        fromEJson(no),
        name: fromEJson(ejson['name']),
        name2: fromEJson(ejson['name_2']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        postCode: fromEJson(ejson['post_code']),
        village: fromEJson(ejson['village']),
        commune: fromEJson(ejson['commune']),
        district: fromEJson(ejson['district']),
        province: fromEJson(ejson['province']),
        countryCode: fromEJson(ejson['country_code']),
        phoneNo: fromEJson(ejson['phone_no']),
        phoneNo2: fromEJson(ejson['phone_no_2']),
        email: fromEJson(ejson['email']),
        contactName: fromEJson(ejson['contactName']),
        transitNo: fromEJson(ejson['transit_no']),
        bankAccountNo: fromEJson(ejson['bank_account_no']),
        currencyCode: fromEJson(ejson['currency_code']),
        swiftCode: fromEJson(ejson['swift_code']),
        lastCheckNo: fromEJson(ejson['last_check_no']),
        lastStatementNo: fromEJson(ejson['last_statement_no']),
        lastPaymentStatementNo: fromEJson(ejson['last_payment_statement_no']),
        bankAccPostingGroup: fromEJson(ejson['bank_acc_posting_group']),
        divisionCode: fromEJson(ejson['division_code']),
        branchCode: fromEJson(ejson['branch_code']),
        mobilePayment: fromEJson(ejson['mobile_payment']),
        inctived: fromEJson(ejson['inctived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(BankAccount._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      BankAccount,
      'BANK_ACCOUNT',
      [
        SchemaProperty('no', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'name2',
          RealmPropertyType.string,
          mapTo: 'name_2',
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
          'postCode',
          RealmPropertyType.string,
          mapTo: 'post_code',
          optional: true,
        ),
        SchemaProperty('village', RealmPropertyType.string, optional: true),
        SchemaProperty('commune', RealmPropertyType.string, optional: true),
        SchemaProperty('district', RealmPropertyType.string, optional: true),
        SchemaProperty('province', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'countryCode',
          RealmPropertyType.string,
          mapTo: 'country_code',
          optional: true,
        ),
        SchemaProperty(
          'phoneNo',
          RealmPropertyType.string,
          mapTo: 'phone_no',
          optional: true,
        ),
        SchemaProperty(
          'phoneNo2',
          RealmPropertyType.string,
          mapTo: 'phone_no_2',
          optional: true,
        ),
        SchemaProperty('email', RealmPropertyType.string, optional: true),
        SchemaProperty('contactName', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'transitNo',
          RealmPropertyType.string,
          mapTo: 'transit_no',
          optional: true,
        ),
        SchemaProperty(
          'bankAccountNo',
          RealmPropertyType.string,
          mapTo: 'bank_account_no',
          optional: true,
        ),
        SchemaProperty(
          'currencyCode',
          RealmPropertyType.string,
          mapTo: 'currency_code',
          optional: true,
        ),
        SchemaProperty(
          'swiftCode',
          RealmPropertyType.string,
          mapTo: 'swift_code',
          optional: true,
        ),
        SchemaProperty(
          'lastCheckNo',
          RealmPropertyType.string,
          mapTo: 'last_check_no',
          optional: true,
        ),
        SchemaProperty(
          'lastStatementNo',
          RealmPropertyType.string,
          mapTo: 'last_statement_no',
          optional: true,
        ),
        SchemaProperty(
          'lastPaymentStatementNo',
          RealmPropertyType.string,
          mapTo: 'last_payment_statement_no',
          optional: true,
        ),
        SchemaProperty(
          'bankAccPostingGroup',
          RealmPropertyType.string,
          mapTo: 'bank_acc_posting_group',
          optional: true,
        ),
        SchemaProperty(
          'divisionCode',
          RealmPropertyType.string,
          mapTo: 'division_code',
          optional: true,
        ),
        SchemaProperty(
          'branchCode',
          RealmPropertyType.string,
          mapTo: 'branch_code',
          optional: true,
        ),
        SchemaProperty(
          'mobilePayment',
          RealmPropertyType.string,
          mapTo: 'mobile_payment',
          optional: true,
        ),
        SchemaProperty('inctived', RealmPropertyType.string),
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

class Customer extends _Customer
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Customer(
    String no, {
    String? name,
    String? name2,
    String? address,
    String? address2,
    String? postCode,
    String? village,
    String? commune,
    String? district,
    String? province,
    String? countryCode,
    String? phoneNo,
    String? phoneNo2,
    String? faxNo,
    String? email,
    String? website,
    String? primaryContactNo,
    String? contactName,
    String? territoryCode,
    String? customerGroupCode,
    String? paymentTermCode,
    String? shipmentMethodCode,
    String? shipmentAgentCode,
    String? shipToCode,
    String? storeCode,
    String? divisionCode,
    String? businessUnitCode,
    String? departmentCode,
    String? projectCode,
    String? salespersonCode,
    String? distributorCode,
    String? locationCode,
    String? customerDiscountCode,
    String? customerPriceGroupCode,
    String? currencyCode,
    String? recPostingGroupCode,
    String? vatPostingGroupCode,
    String? genBusPostingGroupCode,
    String? salesKpiAnalysisCode,
    String? priceIncludeVat = 'No',
    String? taxRegistrationNo,
    String? creditLimitedType,
    double? creditLimitedAmount,
    String? tag,
    String? passcode,
    String? logo,
    String? avatar32,
    String? avatar128,
    String? inactived = 'No',
    String? frequencyVisitPeroid = '1W',
    String? monday = 'No',
    String? tuesday = 'No',
    String? wednesday = 'No',
    String? thursday = 'No',
    String? friday = 'No',
    String? saturday = 'No',
    String? sunday = 'No',
    double? latitude,
    double? longitude,
    String? registeredDate,
    String? approvedDate,
    String? status = 'Open',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Customer>({
        'price_include_vat': 'No',
        'inactived': 'No',
        'frequency_visit_peroid': '1W',
        'monday': 'No',
        'tuesday': 'No',
        'wednesday': 'No',
        'thursday': 'No',
        'friday': 'No',
        'saturday': 'No',
        'sunday': 'No',
        'status': 'Open',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'name_2', name2);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'post_code', postCode);
    RealmObjectBase.set(this, 'village', village);
    RealmObjectBase.set(this, 'commune', commune);
    RealmObjectBase.set(this, 'district', district);
    RealmObjectBase.set(this, 'province', province);
    RealmObjectBase.set(this, 'country_code', countryCode);
    RealmObjectBase.set(this, 'phone_no', phoneNo);
    RealmObjectBase.set(this, 'phone_no_2', phoneNo2);
    RealmObjectBase.set(this, 'fax_no', faxNo);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'website', website);
    RealmObjectBase.set(this, 'primary_contact_no', primaryContactNo);
    RealmObjectBase.set(this, 'contactName', contactName);
    RealmObjectBase.set(this, 'territory_code', territoryCode);
    RealmObjectBase.set(this, 'customer_group_code', customerGroupCode);
    RealmObjectBase.set(this, 'payment_term_code', paymentTermCode);
    RealmObjectBase.set(this, 'shipment_method_code', shipmentMethodCode);
    RealmObjectBase.set(this, 'shipment_agent_code', shipmentAgentCode);
    RealmObjectBase.set(this, 'ship_to_code', shipToCode);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'location_code', locationCode);
    RealmObjectBase.set(this, 'customer_discount_code', customerDiscountCode);
    RealmObjectBase.set(
      this,
      'customer_price_group_code',
      customerPriceGroupCode,
    );
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'rec_posting_group_code', recPostingGroupCode);
    RealmObjectBase.set(this, 'vat_posting_group_code', vatPostingGroupCode);
    RealmObjectBase.set(
      this,
      'gen_bus_posting_group_code',
      genBusPostingGroupCode,
    );
    RealmObjectBase.set(this, 'sales_kpi_analysis_code', salesKpiAnalysisCode);
    RealmObjectBase.set(this, 'price_include_vat', priceIncludeVat);
    RealmObjectBase.set(this, 'tax_registration_no', taxRegistrationNo);
    RealmObjectBase.set(this, 'credit_limited_type', creditLimitedType);
    RealmObjectBase.set(this, 'credit_limited_amount', creditLimitedAmount);
    RealmObjectBase.set(this, 'tag', tag);
    RealmObjectBase.set(this, 'passcode', passcode);
    RealmObjectBase.set(this, 'logo', logo);
    RealmObjectBase.set(this, 'avatar_32', avatar32);
    RealmObjectBase.set(this, 'avatar_128', avatar128);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'frequency_visit_peroid', frequencyVisitPeroid);
    RealmObjectBase.set(this, 'monday', monday);
    RealmObjectBase.set(this, 'tuesday', tuesday);
    RealmObjectBase.set(this, 'wednesday', wednesday);
    RealmObjectBase.set(this, 'thursday', thursday);
    RealmObjectBase.set(this, 'friday', friday);
    RealmObjectBase.set(this, 'saturday', saturday);
    RealmObjectBase.set(this, 'sunday', sunday);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'registered_date', registeredDate);
    RealmObjectBase.set(this, 'approved_date', approvedDate);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  Customer._();

  @override
  String get no => RealmObjectBase.get<String>(this, 'no') as String;
  @override
  set no(String value) => RealmObjectBase.set(this, 'no', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get name2 => RealmObjectBase.get<String>(this, 'name_2') as String?;
  @override
  set name2(String? value) => RealmObjectBase.set(this, 'name_2', value);

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
  String? get postCode =>
      RealmObjectBase.get<String>(this, 'post_code') as String?;
  @override
  set postCode(String? value) => RealmObjectBase.set(this, 'post_code', value);

  @override
  String? get village =>
      RealmObjectBase.get<String>(this, 'village') as String?;
  @override
  set village(String? value) => RealmObjectBase.set(this, 'village', value);

  @override
  String? get commune =>
      RealmObjectBase.get<String>(this, 'commune') as String?;
  @override
  set commune(String? value) => RealmObjectBase.set(this, 'commune', value);

  @override
  String? get district =>
      RealmObjectBase.get<String>(this, 'district') as String?;
  @override
  set district(String? value) => RealmObjectBase.set(this, 'district', value);

  @override
  String? get province =>
      RealmObjectBase.get<String>(this, 'province') as String?;
  @override
  set province(String? value) => RealmObjectBase.set(this, 'province', value);

  @override
  String? get countryCode =>
      RealmObjectBase.get<String>(this, 'country_code') as String?;
  @override
  set countryCode(String? value) =>
      RealmObjectBase.set(this, 'country_code', value);

  @override
  String? get phoneNo =>
      RealmObjectBase.get<String>(this, 'phone_no') as String?;
  @override
  set phoneNo(String? value) => RealmObjectBase.set(this, 'phone_no', value);

  @override
  String? get phoneNo2 =>
      RealmObjectBase.get<String>(this, 'phone_no_2') as String?;
  @override
  set phoneNo2(String? value) => RealmObjectBase.set(this, 'phone_no_2', value);

  @override
  String? get faxNo => RealmObjectBase.get<String>(this, 'fax_no') as String?;
  @override
  set faxNo(String? value) => RealmObjectBase.set(this, 'fax_no', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get website =>
      RealmObjectBase.get<String>(this, 'website') as String?;
  @override
  set website(String? value) => RealmObjectBase.set(this, 'website', value);

  @override
  String? get primaryContactNo =>
      RealmObjectBase.get<String>(this, 'primary_contact_no') as String?;
  @override
  set primaryContactNo(String? value) =>
      RealmObjectBase.set(this, 'primary_contact_no', value);

  @override
  String? get contactName =>
      RealmObjectBase.get<String>(this, 'contactName') as String?;
  @override
  set contactName(String? value) =>
      RealmObjectBase.set(this, 'contactName', value);

  @override
  String? get territoryCode =>
      RealmObjectBase.get<String>(this, 'territory_code') as String?;
  @override
  set territoryCode(String? value) =>
      RealmObjectBase.set(this, 'territory_code', value);

  @override
  String? get customerGroupCode =>
      RealmObjectBase.get<String>(this, 'customer_group_code') as String?;
  @override
  set customerGroupCode(String? value) =>
      RealmObjectBase.set(this, 'customer_group_code', value);

  @override
  String? get paymentTermCode =>
      RealmObjectBase.get<String>(this, 'payment_term_code') as String?;
  @override
  set paymentTermCode(String? value) =>
      RealmObjectBase.set(this, 'payment_term_code', value);

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
  String? get shipToCode =>
      RealmObjectBase.get<String>(this, 'ship_to_code') as String?;
  @override
  set shipToCode(String? value) =>
      RealmObjectBase.set(this, 'ship_to_code', value);

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
  String? get locationCode =>
      RealmObjectBase.get<String>(this, 'location_code') as String?;
  @override
  set locationCode(String? value) =>
      RealmObjectBase.set(this, 'location_code', value);

  @override
  String? get customerDiscountCode =>
      RealmObjectBase.get<String>(this, 'customer_discount_code') as String?;
  @override
  set customerDiscountCode(String? value) =>
      RealmObjectBase.set(this, 'customer_discount_code', value);

  @override
  String? get customerPriceGroupCode =>
      RealmObjectBase.get<String>(this, 'customer_price_group_code') as String?;
  @override
  set customerPriceGroupCode(String? value) =>
      RealmObjectBase.set(this, 'customer_price_group_code', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currency_code') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currency_code', value);

  @override
  String? get recPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'rec_posting_group_code') as String?;
  @override
  set recPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'rec_posting_group_code', value);

  @override
  String? get vatPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'vat_posting_group_code') as String?;
  @override
  set vatPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'vat_posting_group_code', value);

  @override
  String? get genBusPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'gen_bus_posting_group_code')
          as String?;
  @override
  set genBusPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'gen_bus_posting_group_code', value);

  @override
  String? get salesKpiAnalysisCode =>
      RealmObjectBase.get<String>(this, 'sales_kpi_analysis_code') as String?;
  @override
  set salesKpiAnalysisCode(String? value) =>
      RealmObjectBase.set(this, 'sales_kpi_analysis_code', value);

  @override
  String? get priceIncludeVat =>
      RealmObjectBase.get<String>(this, 'price_include_vat') as String?;
  @override
  set priceIncludeVat(String? value) =>
      RealmObjectBase.set(this, 'price_include_vat', value);

  @override
  String? get taxRegistrationNo =>
      RealmObjectBase.get<String>(this, 'tax_registration_no') as String?;
  @override
  set taxRegistrationNo(String? value) =>
      RealmObjectBase.set(this, 'tax_registration_no', value);

  @override
  String? get creditLimitedType =>
      RealmObjectBase.get<String>(this, 'credit_limited_type') as String?;
  @override
  set creditLimitedType(String? value) =>
      RealmObjectBase.set(this, 'credit_limited_type', value);

  @override
  double? get creditLimitedAmount =>
      RealmObjectBase.get<double>(this, 'credit_limited_amount') as double?;
  @override
  set creditLimitedAmount(double? value) =>
      RealmObjectBase.set(this, 'credit_limited_amount', value);

  @override
  String? get tag => RealmObjectBase.get<String>(this, 'tag') as String?;
  @override
  set tag(String? value) => RealmObjectBase.set(this, 'tag', value);

  @override
  String? get passcode =>
      RealmObjectBase.get<String>(this, 'passcode') as String?;
  @override
  set passcode(String? value) => RealmObjectBase.set(this, 'passcode', value);

  @override
  String? get logo => RealmObjectBase.get<String>(this, 'logo') as String?;
  @override
  set logo(String? value) => RealmObjectBase.set(this, 'logo', value);

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
  String? get frequencyVisitPeroid =>
      RealmObjectBase.get<String>(this, 'frequency_visit_peroid') as String?;
  @override
  set frequencyVisitPeroid(String? value) =>
      RealmObjectBase.set(this, 'frequency_visit_peroid', value);

  @override
  String? get monday => RealmObjectBase.get<String>(this, 'monday') as String?;
  @override
  set monday(String? value) => RealmObjectBase.set(this, 'monday', value);

  @override
  String? get tuesday =>
      RealmObjectBase.get<String>(this, 'tuesday') as String?;
  @override
  set tuesday(String? value) => RealmObjectBase.set(this, 'tuesday', value);

  @override
  String? get wednesday =>
      RealmObjectBase.get<String>(this, 'wednesday') as String?;
  @override
  set wednesday(String? value) => RealmObjectBase.set(this, 'wednesday', value);

  @override
  String? get thursday =>
      RealmObjectBase.get<String>(this, 'thursday') as String?;
  @override
  set thursday(String? value) => RealmObjectBase.set(this, 'thursday', value);

  @override
  String? get friday => RealmObjectBase.get<String>(this, 'friday') as String?;
  @override
  set friday(String? value) => RealmObjectBase.set(this, 'friday', value);

  @override
  String? get saturday =>
      RealmObjectBase.get<String>(this, 'saturday') as String?;
  @override
  set saturday(String? value) => RealmObjectBase.set(this, 'saturday', value);

  @override
  String? get sunday => RealmObjectBase.get<String>(this, 'sunday') as String?;
  @override
  set sunday(String? value) => RealmObjectBase.set(this, 'sunday', value);

  @override
  double? get latitude =>
      RealmObjectBase.get<double>(this, 'latitude') as double?;
  @override
  set latitude(double? value) => RealmObjectBase.set(this, 'latitude', value);

  @override
  double? get longitude =>
      RealmObjectBase.get<double>(this, 'longitude') as double?;
  @override
  set longitude(double? value) => RealmObjectBase.set(this, 'longitude', value);

  @override
  String? get registeredDate =>
      RealmObjectBase.get<String>(this, 'registered_date') as String?;
  @override
  set registeredDate(String? value) =>
      RealmObjectBase.set(this, 'registered_date', value);

  @override
  String? get approvedDate =>
      RealmObjectBase.get<String>(this, 'approved_date') as String?;
  @override
  set approvedDate(String? value) =>
      RealmObjectBase.set(this, 'approved_date', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<Customer>> get changes =>
      RealmObjectBase.getChanges<Customer>(this);

  @override
  Stream<RealmObjectChanges<Customer>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Customer>(this, keyPaths);

  @override
  Customer freeze() => RealmObjectBase.freezeObject<Customer>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'no': no.toEJson(),
      'name': name.toEJson(),
      'name_2': name2.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'post_code': postCode.toEJson(),
      'village': village.toEJson(),
      'commune': commune.toEJson(),
      'district': district.toEJson(),
      'province': province.toEJson(),
      'country_code': countryCode.toEJson(),
      'phone_no': phoneNo.toEJson(),
      'phone_no_2': phoneNo2.toEJson(),
      'fax_no': faxNo.toEJson(),
      'email': email.toEJson(),
      'website': website.toEJson(),
      'primary_contact_no': primaryContactNo.toEJson(),
      'contactName': contactName.toEJson(),
      'territory_code': territoryCode.toEJson(),
      'customer_group_code': customerGroupCode.toEJson(),
      'payment_term_code': paymentTermCode.toEJson(),
      'shipment_method_code': shipmentMethodCode.toEJson(),
      'shipment_agent_code': shipmentAgentCode.toEJson(),
      'ship_to_code': shipToCode.toEJson(),
      'store_code': storeCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'location_code': locationCode.toEJson(),
      'customer_discount_code': customerDiscountCode.toEJson(),
      'customer_price_group_code': customerPriceGroupCode.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'rec_posting_group_code': recPostingGroupCode.toEJson(),
      'vat_posting_group_code': vatPostingGroupCode.toEJson(),
      'gen_bus_posting_group_code': genBusPostingGroupCode.toEJson(),
      'sales_kpi_analysis_code': salesKpiAnalysisCode.toEJson(),
      'price_include_vat': priceIncludeVat.toEJson(),
      'tax_registration_no': taxRegistrationNo.toEJson(),
      'credit_limited_type': creditLimitedType.toEJson(),
      'credit_limited_amount': creditLimitedAmount.toEJson(),
      'tag': tag.toEJson(),
      'passcode': passcode.toEJson(),
      'logo': logo.toEJson(),
      'avatar_32': avatar32.toEJson(),
      'avatar_128': avatar128.toEJson(),
      'inactived': inactived.toEJson(),
      'frequency_visit_peroid': frequencyVisitPeroid.toEJson(),
      'monday': monday.toEJson(),
      'tuesday': tuesday.toEJson(),
      'wednesday': wednesday.toEJson(),
      'thursday': thursday.toEJson(),
      'friday': friday.toEJson(),
      'saturday': saturday.toEJson(),
      'sunday': sunday.toEJson(),
      'latitude': latitude.toEJson(),
      'longitude': longitude.toEJson(),
      'registered_date': registeredDate.toEJson(),
      'approved_date': approvedDate.toEJson(),
      'status': status.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Customer value) => value.toEJson();
  static Customer _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'no': EJsonValue no} => Customer(
        fromEJson(no),
        name: fromEJson(ejson['name']),
        name2: fromEJson(ejson['name_2']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        postCode: fromEJson(ejson['post_code']),
        village: fromEJson(ejson['village']),
        commune: fromEJson(ejson['commune']),
        district: fromEJson(ejson['district']),
        province: fromEJson(ejson['province']),
        countryCode: fromEJson(ejson['country_code']),
        phoneNo: fromEJson(ejson['phone_no']),
        phoneNo2: fromEJson(ejson['phone_no_2']),
        faxNo: fromEJson(ejson['fax_no']),
        email: fromEJson(ejson['email']),
        website: fromEJson(ejson['website']),
        primaryContactNo: fromEJson(ejson['primary_contact_no']),
        contactName: fromEJson(ejson['contactName']),
        territoryCode: fromEJson(ejson['territory_code']),
        customerGroupCode: fromEJson(ejson['customer_group_code']),
        paymentTermCode: fromEJson(ejson['payment_term_code']),
        shipmentMethodCode: fromEJson(ejson['shipment_method_code']),
        shipmentAgentCode: fromEJson(ejson['shipment_agent_code']),
        shipToCode: fromEJson(ejson['ship_to_code']),
        storeCode: fromEJson(ejson['store_code']),
        divisionCode: fromEJson(ejson['division_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        departmentCode: fromEJson(ejson['department_code']),
        projectCode: fromEJson(ejson['project_code']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        distributorCode: fromEJson(ejson['distributor_code']),
        locationCode: fromEJson(ejson['location_code']),
        customerDiscountCode: fromEJson(ejson['customer_discount_code']),
        customerPriceGroupCode: fromEJson(ejson['customer_price_group_code']),
        currencyCode: fromEJson(ejson['currency_code']),
        recPostingGroupCode: fromEJson(ejson['rec_posting_group_code']),
        vatPostingGroupCode: fromEJson(ejson['vat_posting_group_code']),
        genBusPostingGroupCode: fromEJson(ejson['gen_bus_posting_group_code']),
        salesKpiAnalysisCode: fromEJson(ejson['sales_kpi_analysis_code']),
        priceIncludeVat: fromEJson(
          ejson['price_include_vat'],
          defaultValue: 'No',
        ),
        taxRegistrationNo: fromEJson(ejson['tax_registration_no']),
        creditLimitedType: fromEJson(ejson['credit_limited_type']),
        creditLimitedAmount: fromEJson(ejson['credit_limited_amount']),
        tag: fromEJson(ejson['tag']),
        passcode: fromEJson(ejson['passcode']),
        logo: fromEJson(ejson['logo']),
        avatar32: fromEJson(ejson['avatar_32']),
        avatar128: fromEJson(ejson['avatar_128']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        frequencyVisitPeroid: fromEJson(
          ejson['frequency_visit_peroid'],
          defaultValue: '1W',
        ),
        monday: fromEJson(ejson['monday'], defaultValue: 'No'),
        tuesday: fromEJson(ejson['tuesday'], defaultValue: 'No'),
        wednesday: fromEJson(ejson['wednesday'], defaultValue: 'No'),
        thursday: fromEJson(ejson['thursday'], defaultValue: 'No'),
        friday: fromEJson(ejson['friday'], defaultValue: 'No'),
        saturday: fromEJson(ejson['saturday'], defaultValue: 'No'),
        sunday: fromEJson(ejson['sunday'], defaultValue: 'No'),
        latitude: fromEJson(ejson['latitude']),
        longitude: fromEJson(ejson['longitude']),
        registeredDate: fromEJson(ejson['registered_date']),
        approvedDate: fromEJson(ejson['approved_date']),
        status: fromEJson(ejson['status'], defaultValue: 'Open'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Customer._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Customer, 'CUSTOMER', [
      SchemaProperty('no', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('name', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'name2',
        RealmPropertyType.string,
        mapTo: 'name_2',
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
        'postCode',
        RealmPropertyType.string,
        mapTo: 'post_code',
        optional: true,
      ),
      SchemaProperty('village', RealmPropertyType.string, optional: true),
      SchemaProperty('commune', RealmPropertyType.string, optional: true),
      SchemaProperty('district', RealmPropertyType.string, optional: true),
      SchemaProperty('province', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'countryCode',
        RealmPropertyType.string,
        mapTo: 'country_code',
        optional: true,
      ),
      SchemaProperty(
        'phoneNo',
        RealmPropertyType.string,
        mapTo: 'phone_no',
        optional: true,
      ),
      SchemaProperty(
        'phoneNo2',
        RealmPropertyType.string,
        mapTo: 'phone_no_2',
        optional: true,
      ),
      SchemaProperty(
        'faxNo',
        RealmPropertyType.string,
        mapTo: 'fax_no',
        optional: true,
      ),
      SchemaProperty('email', RealmPropertyType.string, optional: true),
      SchemaProperty('website', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'primaryContactNo',
        RealmPropertyType.string,
        mapTo: 'primary_contact_no',
        optional: true,
      ),
      SchemaProperty('contactName', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'territoryCode',
        RealmPropertyType.string,
        mapTo: 'territory_code',
        optional: true,
      ),
      SchemaProperty(
        'customerGroupCode',
        RealmPropertyType.string,
        mapTo: 'customer_group_code',
        optional: true,
      ),
      SchemaProperty(
        'paymentTermCode',
        RealmPropertyType.string,
        mapTo: 'payment_term_code',
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
        'shipToCode',
        RealmPropertyType.string,
        mapTo: 'ship_to_code',
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
        'locationCode',
        RealmPropertyType.string,
        mapTo: 'location_code',
        optional: true,
      ),
      SchemaProperty(
        'customerDiscountCode',
        RealmPropertyType.string,
        mapTo: 'customer_discount_code',
        optional: true,
      ),
      SchemaProperty(
        'customerPriceGroupCode',
        RealmPropertyType.string,
        mapTo: 'customer_price_group_code',
        optional: true,
      ),
      SchemaProperty(
        'currencyCode',
        RealmPropertyType.string,
        mapTo: 'currency_code',
        optional: true,
      ),
      SchemaProperty(
        'recPostingGroupCode',
        RealmPropertyType.string,
        mapTo: 'rec_posting_group_code',
        optional: true,
      ),
      SchemaProperty(
        'vatPostingGroupCode',
        RealmPropertyType.string,
        mapTo: 'vat_posting_group_code',
        optional: true,
      ),
      SchemaProperty(
        'genBusPostingGroupCode',
        RealmPropertyType.string,
        mapTo: 'gen_bus_posting_group_code',
        optional: true,
      ),
      SchemaProperty(
        'salesKpiAnalysisCode',
        RealmPropertyType.string,
        mapTo: 'sales_kpi_analysis_code',
        optional: true,
      ),
      SchemaProperty(
        'priceIncludeVat',
        RealmPropertyType.string,
        mapTo: 'price_include_vat',
        optional: true,
      ),
      SchemaProperty(
        'taxRegistrationNo',
        RealmPropertyType.string,
        mapTo: 'tax_registration_no',
        optional: true,
      ),
      SchemaProperty(
        'creditLimitedType',
        RealmPropertyType.string,
        mapTo: 'credit_limited_type',
        optional: true,
      ),
      SchemaProperty(
        'creditLimitedAmount',
        RealmPropertyType.double,
        mapTo: 'credit_limited_amount',
        optional: true,
      ),
      SchemaProperty('tag', RealmPropertyType.string, optional: true),
      SchemaProperty('passcode', RealmPropertyType.string, optional: true),
      SchemaProperty('logo', RealmPropertyType.string, optional: true),
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
      SchemaProperty('inactived', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'frequencyVisitPeroid',
        RealmPropertyType.string,
        mapTo: 'frequency_visit_peroid',
        optional: true,
      ),
      SchemaProperty('monday', RealmPropertyType.string, optional: true),
      SchemaProperty('tuesday', RealmPropertyType.string, optional: true),
      SchemaProperty('wednesday', RealmPropertyType.string, optional: true),
      SchemaProperty('thursday', RealmPropertyType.string, optional: true),
      SchemaProperty('friday', RealmPropertyType.string, optional: true),
      SchemaProperty('saturday', RealmPropertyType.string, optional: true),
      SchemaProperty('sunday', RealmPropertyType.string, optional: true),
      SchemaProperty('latitude', RealmPropertyType.double, optional: true),
      SchemaProperty('longitude', RealmPropertyType.double, optional: true),
      SchemaProperty(
        'registeredDate',
        RealmPropertyType.string,
        mapTo: 'registered_date',
        optional: true,
      ),
      SchemaProperty(
        'approvedDate',
        RealmPropertyType.string,
        mapTo: 'approved_date',
        optional: true,
      ),
      SchemaProperty('status', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'isSync',
        RealmPropertyType.string,
        mapTo: 'is_sync',
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
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CustomerAddress extends _CustomerAddress
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  CustomerAddress(
    String id, {
    String? customerNo,
    String? code,
    String? name,
    String? name2,
    String? address,
    String? address2,
    String? postCode,
    String? village,
    String? commune,
    String? district,
    String? province,
    String? countryCode,
    String? phoneNo,
    String? phoneNo2,
    String? email,
    String? contactName,
    double? latitude,
    double? longitude,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? isDefault = 'No',
    String? isDeleted = 'No',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CustomerAddress>({
        'inactived': 'No',
        'is_sync': 'Yes',
        'is_default': 'No',
        'is_deleted': 'No',
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'name_2', name2);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'post_code', postCode);
    RealmObjectBase.set(this, 'village', village);
    RealmObjectBase.set(this, 'commune', commune);
    RealmObjectBase.set(this, 'district', district);
    RealmObjectBase.set(this, 'province', province);
    RealmObjectBase.set(this, 'country_code', countryCode);
    RealmObjectBase.set(this, 'phone_no', phoneNo);
    RealmObjectBase.set(this, 'phone_no_2', phoneNo2);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'contact_name', contactName);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'is_default', isDefault);
    RealmObjectBase.set(this, 'is_deleted', isDeleted);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  CustomerAddress._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get customerNo =>
      RealmObjectBase.get<String>(this, 'customer_no') as String?;
  @override
  set customerNo(String? value) =>
      RealmObjectBase.set(this, 'customer_no', value);

  @override
  String? get code => RealmObjectBase.get<String>(this, 'code') as String?;
  @override
  set code(String? value) => RealmObjectBase.set(this, 'code', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get name2 => RealmObjectBase.get<String>(this, 'name_2') as String?;
  @override
  set name2(String? value) => RealmObjectBase.set(this, 'name_2', value);

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
  String? get postCode =>
      RealmObjectBase.get<String>(this, 'post_code') as String?;
  @override
  set postCode(String? value) => RealmObjectBase.set(this, 'post_code', value);

  @override
  String? get village =>
      RealmObjectBase.get<String>(this, 'village') as String?;
  @override
  set village(String? value) => RealmObjectBase.set(this, 'village', value);

  @override
  String? get commune =>
      RealmObjectBase.get<String>(this, 'commune') as String?;
  @override
  set commune(String? value) => RealmObjectBase.set(this, 'commune', value);

  @override
  String? get district =>
      RealmObjectBase.get<String>(this, 'district') as String?;
  @override
  set district(String? value) => RealmObjectBase.set(this, 'district', value);

  @override
  String? get province =>
      RealmObjectBase.get<String>(this, 'province') as String?;
  @override
  set province(String? value) => RealmObjectBase.set(this, 'province', value);

  @override
  String? get countryCode =>
      RealmObjectBase.get<String>(this, 'country_code') as String?;
  @override
  set countryCode(String? value) =>
      RealmObjectBase.set(this, 'country_code', value);

  @override
  String? get phoneNo =>
      RealmObjectBase.get<String>(this, 'phone_no') as String?;
  @override
  set phoneNo(String? value) => RealmObjectBase.set(this, 'phone_no', value);

  @override
  String? get phoneNo2 =>
      RealmObjectBase.get<String>(this, 'phone_no_2') as String?;
  @override
  set phoneNo2(String? value) => RealmObjectBase.set(this, 'phone_no_2', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get contactName =>
      RealmObjectBase.get<String>(this, 'contact_name') as String?;
  @override
  set contactName(String? value) =>
      RealmObjectBase.set(this, 'contact_name', value);

  @override
  double? get latitude =>
      RealmObjectBase.get<double>(this, 'latitude') as double?;
  @override
  set latitude(double? value) => RealmObjectBase.set(this, 'latitude', value);

  @override
  double? get longitude =>
      RealmObjectBase.get<double>(this, 'longitude') as double?;
  @override
  set longitude(double? value) => RealmObjectBase.set(this, 'longitude', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  String? get isDefault =>
      RealmObjectBase.get<String>(this, 'is_default') as String?;
  @override
  set isDefault(String? value) =>
      RealmObjectBase.set(this, 'is_default', value);

  @override
  String? get isDeleted =>
      RealmObjectBase.get<String>(this, 'is_deleted') as String?;
  @override
  set isDeleted(String? value) =>
      RealmObjectBase.set(this, 'is_deleted', value);

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
  Stream<RealmObjectChanges<CustomerAddress>> get changes =>
      RealmObjectBase.getChanges<CustomerAddress>(this);

  @override
  Stream<RealmObjectChanges<CustomerAddress>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CustomerAddress>(this, keyPaths);

  @override
  CustomerAddress freeze() =>
      RealmObjectBase.freezeObject<CustomerAddress>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'customer_no': customerNo.toEJson(),
      'code': code.toEJson(),
      'name': name.toEJson(),
      'name_2': name2.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'post_code': postCode.toEJson(),
      'village': village.toEJson(),
      'commune': commune.toEJson(),
      'district': district.toEJson(),
      'province': province.toEJson(),
      'country_code': countryCode.toEJson(),
      'phone_no': phoneNo.toEJson(),
      'phone_no_2': phoneNo2.toEJson(),
      'email': email.toEJson(),
      'contact_name': contactName.toEJson(),
      'latitude': latitude.toEJson(),
      'longitude': longitude.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'is_default': isDefault.toEJson(),
      'is_deleted': isDeleted.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(CustomerAddress value) => value.toEJson();
  static CustomerAddress _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => CustomerAddress(
        fromEJson(id),
        customerNo: fromEJson(ejson['customer_no']),
        code: fromEJson(ejson['code']),
        name: fromEJson(ejson['name']),
        name2: fromEJson(ejson['name_2']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        postCode: fromEJson(ejson['post_code']),
        village: fromEJson(ejson['village']),
        commune: fromEJson(ejson['commune']),
        district: fromEJson(ejson['district']),
        province: fromEJson(ejson['province']),
        countryCode: fromEJson(ejson['country_code']),
        phoneNo: fromEJson(ejson['phone_no']),
        phoneNo2: fromEJson(ejson['phone_no_2']),
        email: fromEJson(ejson['email']),
        contactName: fromEJson(ejson['contact_name']),
        latitude: fromEJson(ejson['latitude']),
        longitude: fromEJson(ejson['longitude']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        isDefault: fromEJson(ejson['is_default'], defaultValue: 'No'),
        isDeleted: fromEJson(ejson['is_deleted'], defaultValue: 'No'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CustomerAddress._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CustomerAddress,
      'CUSTOMER_ADDRESS',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty(
          'customerNo',
          RealmPropertyType.string,
          mapTo: 'customer_no',
          optional: true,
        ),
        SchemaProperty('code', RealmPropertyType.string, optional: true),
        SchemaProperty('name', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'name2',
          RealmPropertyType.string,
          mapTo: 'name_2',
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
          'postCode',
          RealmPropertyType.string,
          mapTo: 'post_code',
          optional: true,
        ),
        SchemaProperty('village', RealmPropertyType.string, optional: true),
        SchemaProperty('commune', RealmPropertyType.string, optional: true),
        SchemaProperty('district', RealmPropertyType.string, optional: true),
        SchemaProperty('province', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'countryCode',
          RealmPropertyType.string,
          mapTo: 'country_code',
          optional: true,
        ),
        SchemaProperty(
          'phoneNo',
          RealmPropertyType.string,
          mapTo: 'phone_no',
          optional: true,
        ),
        SchemaProperty(
          'phoneNo2',
          RealmPropertyType.string,
          mapTo: 'phone_no_2',
          optional: true,
        ),
        SchemaProperty('email', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'contactName',
          RealmPropertyType.string,
          mapTo: 'contact_name',
          optional: true,
        ),
        SchemaProperty('latitude', RealmPropertyType.double, optional: true),
        SchemaProperty('longitude', RealmPropertyType.double, optional: true),
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
          optional: true,
        ),
        SchemaProperty(
          'isDefault',
          RealmPropertyType.string,
          mapTo: 'is_default',
          optional: true,
        ),
        SchemaProperty(
          'isDeleted',
          RealmPropertyType.string,
          mapTo: 'is_deleted',
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

class Competitor extends _Competitor
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Competitor(
    String no, {
    String? name,
    String? name2,
    String? address,
    String? address2,
    String? postCode,
    String? village,
    String? commune,
    String? district,
    String? province,
    String? countryCode,
    String? phoneNo,
    String? phoneNo2,
    String? faxNo,
    String? email,
    String? website,
    String? primaryContactNo,
    String? contactName,
    String? territoryCode,
    String? paymentTermCode,
    String? paymentMethodCode,
    String? shipmentMethodCode,
    String? shipmentAgentCode,
    String? storeCode,
    String? divisionCode,
    String? businessUnitCode,
    String? departmentCode,
    String? projectCode,
    String? purchaserCode,
    String? distributorCode,
    String? locationCode,
    String? currencyCode,
    String? apPostingGroupCode,
    String? genBusPostingGroupCode,
    String? vatBusPostingGroupCode,
    String? priceIncludeVat = 'No',
    String? taxRegistrationNo,
    String? logo,
    String? avatar32,
    String? avatar128,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Competitor>({
        'price_include_vat': 'No',
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'no', no);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'name_2', name2);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'post_code', postCode);
    RealmObjectBase.set(this, 'village', village);
    RealmObjectBase.set(this, 'commune', commune);
    RealmObjectBase.set(this, 'district', district);
    RealmObjectBase.set(this, 'province', province);
    RealmObjectBase.set(this, 'country_code', countryCode);
    RealmObjectBase.set(this, 'phone_no', phoneNo);
    RealmObjectBase.set(this, 'phone_no_2', phoneNo2);
    RealmObjectBase.set(this, 'fax_no', faxNo);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'website', website);
    RealmObjectBase.set(this, 'primary_contact_no', primaryContactNo);
    RealmObjectBase.set(this, 'contactName', contactName);
    RealmObjectBase.set(this, 'territory_code', territoryCode);
    RealmObjectBase.set(this, 'payment_term_code', paymentTermCode);
    RealmObjectBase.set(this, 'payment_method_code', paymentMethodCode);
    RealmObjectBase.set(this, 'shipment_method_code', shipmentMethodCode);
    RealmObjectBase.set(this, 'shipment_agent_code', shipmentAgentCode);
    RealmObjectBase.set(this, 'store_code', storeCode);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'department_code', departmentCode);
    RealmObjectBase.set(this, 'project_code', projectCode);
    RealmObjectBase.set(this, 'purchaser_code', purchaserCode);
    RealmObjectBase.set(this, 'distributor_code', distributorCode);
    RealmObjectBase.set(this, 'location_code', locationCode);
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'ap_posting_group_code', apPostingGroupCode);
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
    RealmObjectBase.set(this, 'price_include_vat', priceIncludeVat);
    RealmObjectBase.set(this, 'tax_registration_no', taxRegistrationNo);
    RealmObjectBase.set(this, 'logo', logo);
    RealmObjectBase.set(this, 'avatar_32', avatar32);
    RealmObjectBase.set(this, 'avatar_128', avatar128);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  Competitor._();

  @override
  String get no => RealmObjectBase.get<String>(this, 'no') as String;
  @override
  set no(String value) => RealmObjectBase.set(this, 'no', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get name2 => RealmObjectBase.get<String>(this, 'name_2') as String?;
  @override
  set name2(String? value) => RealmObjectBase.set(this, 'name_2', value);

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
  String? get postCode =>
      RealmObjectBase.get<String>(this, 'post_code') as String?;
  @override
  set postCode(String? value) => RealmObjectBase.set(this, 'post_code', value);

  @override
  String? get village =>
      RealmObjectBase.get<String>(this, 'village') as String?;
  @override
  set village(String? value) => RealmObjectBase.set(this, 'village', value);

  @override
  String? get commune =>
      RealmObjectBase.get<String>(this, 'commune') as String?;
  @override
  set commune(String? value) => RealmObjectBase.set(this, 'commune', value);

  @override
  String? get district =>
      RealmObjectBase.get<String>(this, 'district') as String?;
  @override
  set district(String? value) => RealmObjectBase.set(this, 'district', value);

  @override
  String? get province =>
      RealmObjectBase.get<String>(this, 'province') as String?;
  @override
  set province(String? value) => RealmObjectBase.set(this, 'province', value);

  @override
  String? get countryCode =>
      RealmObjectBase.get<String>(this, 'country_code') as String?;
  @override
  set countryCode(String? value) =>
      RealmObjectBase.set(this, 'country_code', value);

  @override
  String? get phoneNo =>
      RealmObjectBase.get<String>(this, 'phone_no') as String?;
  @override
  set phoneNo(String? value) => RealmObjectBase.set(this, 'phone_no', value);

  @override
  String? get phoneNo2 =>
      RealmObjectBase.get<String>(this, 'phone_no_2') as String?;
  @override
  set phoneNo2(String? value) => RealmObjectBase.set(this, 'phone_no_2', value);

  @override
  String? get faxNo => RealmObjectBase.get<String>(this, 'fax_no') as String?;
  @override
  set faxNo(String? value) => RealmObjectBase.set(this, 'fax_no', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get website =>
      RealmObjectBase.get<String>(this, 'website') as String?;
  @override
  set website(String? value) => RealmObjectBase.set(this, 'website', value);

  @override
  String? get primaryContactNo =>
      RealmObjectBase.get<String>(this, 'primary_contact_no') as String?;
  @override
  set primaryContactNo(String? value) =>
      RealmObjectBase.set(this, 'primary_contact_no', value);

  @override
  String? get contactName =>
      RealmObjectBase.get<String>(this, 'contactName') as String?;
  @override
  set contactName(String? value) =>
      RealmObjectBase.set(this, 'contactName', value);

  @override
  String? get territoryCode =>
      RealmObjectBase.get<String>(this, 'territory_code') as String?;
  @override
  set territoryCode(String? value) =>
      RealmObjectBase.set(this, 'territory_code', value);

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
  String? get purchaserCode =>
      RealmObjectBase.get<String>(this, 'purchaser_code') as String?;
  @override
  set purchaserCode(String? value) =>
      RealmObjectBase.set(this, 'purchaser_code', value);

  @override
  String? get distributorCode =>
      RealmObjectBase.get<String>(this, 'distributor_code') as String?;
  @override
  set distributorCode(String? value) =>
      RealmObjectBase.set(this, 'distributor_code', value);

  @override
  String? get locationCode =>
      RealmObjectBase.get<String>(this, 'location_code') as String?;
  @override
  set locationCode(String? value) =>
      RealmObjectBase.set(this, 'location_code', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currency_code') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currency_code', value);

  @override
  String? get apPostingGroupCode =>
      RealmObjectBase.get<String>(this, 'ap_posting_group_code') as String?;
  @override
  set apPostingGroupCode(String? value) =>
      RealmObjectBase.set(this, 'ap_posting_group_code', value);

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
  String? get priceIncludeVat =>
      RealmObjectBase.get<String>(this, 'price_include_vat') as String?;
  @override
  set priceIncludeVat(String? value) =>
      RealmObjectBase.set(this, 'price_include_vat', value);

  @override
  String? get taxRegistrationNo =>
      RealmObjectBase.get<String>(this, 'tax_registration_no') as String?;
  @override
  set taxRegistrationNo(String? value) =>
      RealmObjectBase.set(this, 'tax_registration_no', value);

  @override
  String? get logo => RealmObjectBase.get<String>(this, 'logo') as String?;
  @override
  set logo(String? value) => RealmObjectBase.set(this, 'logo', value);

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
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<Competitor>> get changes =>
      RealmObjectBase.getChanges<Competitor>(this);

  @override
  Stream<RealmObjectChanges<Competitor>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Competitor>(this, keyPaths);

  @override
  Competitor freeze() => RealmObjectBase.freezeObject<Competitor>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'no': no.toEJson(),
      'name': name.toEJson(),
      'name_2': name2.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'post_code': postCode.toEJson(),
      'village': village.toEJson(),
      'commune': commune.toEJson(),
      'district': district.toEJson(),
      'province': province.toEJson(),
      'country_code': countryCode.toEJson(),
      'phone_no': phoneNo.toEJson(),
      'phone_no_2': phoneNo2.toEJson(),
      'fax_no': faxNo.toEJson(),
      'email': email.toEJson(),
      'website': website.toEJson(),
      'primary_contact_no': primaryContactNo.toEJson(),
      'contactName': contactName.toEJson(),
      'territory_code': territoryCode.toEJson(),
      'payment_term_code': paymentTermCode.toEJson(),
      'payment_method_code': paymentMethodCode.toEJson(),
      'shipment_method_code': shipmentMethodCode.toEJson(),
      'shipment_agent_code': shipmentAgentCode.toEJson(),
      'store_code': storeCode.toEJson(),
      'division_code': divisionCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'department_code': departmentCode.toEJson(),
      'project_code': projectCode.toEJson(),
      'purchaser_code': purchaserCode.toEJson(),
      'distributor_code': distributorCode.toEJson(),
      'location_code': locationCode.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'ap_posting_group_code': apPostingGroupCode.toEJson(),
      'gen_bus_posting_group_code': genBusPostingGroupCode.toEJson(),
      'vat_bus_posting_group_code': vatBusPostingGroupCode.toEJson(),
      'price_include_vat': priceIncludeVat.toEJson(),
      'tax_registration_no': taxRegistrationNo.toEJson(),
      'logo': logo.toEJson(),
      'avatar_32': avatar32.toEJson(),
      'avatar_128': avatar128.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Competitor value) => value.toEJson();
  static Competitor _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'no': EJsonValue no} => Competitor(
        fromEJson(no),
        name: fromEJson(ejson['name']),
        name2: fromEJson(ejson['name_2']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        postCode: fromEJson(ejson['post_code']),
        village: fromEJson(ejson['village']),
        commune: fromEJson(ejson['commune']),
        district: fromEJson(ejson['district']),
        province: fromEJson(ejson['province']),
        countryCode: fromEJson(ejson['country_code']),
        phoneNo: fromEJson(ejson['phone_no']),
        phoneNo2: fromEJson(ejson['phone_no_2']),
        faxNo: fromEJson(ejson['fax_no']),
        email: fromEJson(ejson['email']),
        website: fromEJson(ejson['website']),
        primaryContactNo: fromEJson(ejson['primary_contact_no']),
        contactName: fromEJson(ejson['contactName']),
        territoryCode: fromEJson(ejson['territory_code']),
        paymentTermCode: fromEJson(ejson['payment_term_code']),
        paymentMethodCode: fromEJson(ejson['payment_method_code']),
        shipmentMethodCode: fromEJson(ejson['shipment_method_code']),
        shipmentAgentCode: fromEJson(ejson['shipment_agent_code']),
        storeCode: fromEJson(ejson['store_code']),
        divisionCode: fromEJson(ejson['division_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        departmentCode: fromEJson(ejson['department_code']),
        projectCode: fromEJson(ejson['project_code']),
        purchaserCode: fromEJson(ejson['purchaser_code']),
        distributorCode: fromEJson(ejson['distributor_code']),
        locationCode: fromEJson(ejson['location_code']),
        currencyCode: fromEJson(ejson['currency_code']),
        apPostingGroupCode: fromEJson(ejson['ap_posting_group_code']),
        genBusPostingGroupCode: fromEJson(ejson['gen_bus_posting_group_code']),
        vatBusPostingGroupCode: fromEJson(ejson['vat_bus_posting_group_code']),
        priceIncludeVat: fromEJson(
          ejson['price_include_vat'],
          defaultValue: 'No',
        ),
        taxRegistrationNo: fromEJson(ejson['tax_registration_no']),
        logo: fromEJson(ejson['logo']),
        avatar32: fromEJson(ejson['avatar_32']),
        avatar128: fromEJson(ejson['avatar_128']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Competitor._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      Competitor,
      'COMPETITOR',
      [
        SchemaProperty('no', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'name2',
          RealmPropertyType.string,
          mapTo: 'name_2',
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
          'postCode',
          RealmPropertyType.string,
          mapTo: 'post_code',
          optional: true,
        ),
        SchemaProperty('village', RealmPropertyType.string, optional: true),
        SchemaProperty('commune', RealmPropertyType.string, optional: true),
        SchemaProperty('district', RealmPropertyType.string, optional: true),
        SchemaProperty('province', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'countryCode',
          RealmPropertyType.string,
          mapTo: 'country_code',
          optional: true,
        ),
        SchemaProperty(
          'phoneNo',
          RealmPropertyType.string,
          mapTo: 'phone_no',
          optional: true,
        ),
        SchemaProperty(
          'phoneNo2',
          RealmPropertyType.string,
          mapTo: 'phone_no_2',
          optional: true,
        ),
        SchemaProperty(
          'faxNo',
          RealmPropertyType.string,
          mapTo: 'fax_no',
          optional: true,
        ),
        SchemaProperty('email', RealmPropertyType.string, optional: true),
        SchemaProperty('website', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'primaryContactNo',
          RealmPropertyType.string,
          mapTo: 'primary_contact_no',
          optional: true,
        ),
        SchemaProperty('contactName', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'territoryCode',
          RealmPropertyType.string,
          mapTo: 'territory_code',
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
          'purchaserCode',
          RealmPropertyType.string,
          mapTo: 'purchaser_code',
          optional: true,
        ),
        SchemaProperty(
          'distributorCode',
          RealmPropertyType.string,
          mapTo: 'distributor_code',
          optional: true,
        ),
        SchemaProperty(
          'locationCode',
          RealmPropertyType.string,
          mapTo: 'location_code',
          optional: true,
        ),
        SchemaProperty(
          'currencyCode',
          RealmPropertyType.string,
          mapTo: 'currency_code',
          optional: true,
        ),
        SchemaProperty(
          'apPostingGroupCode',
          RealmPropertyType.string,
          mapTo: 'ap_posting_group_code',
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
          'priceIncludeVat',
          RealmPropertyType.string,
          mapTo: 'price_include_vat',
          optional: true,
        ),
        SchemaProperty(
          'taxRegistrationNo',
          RealmPropertyType.string,
          mapTo: 'tax_registration_no',
          optional: true,
        ),
        SchemaProperty('logo', RealmPropertyType.string, optional: true),
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
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
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

class Currency extends _Currency
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Currency(
    String code, {
    String? description,
    String? description2,
    String? realizedGainsAccountNo,
    String? realisedLossesAccountNo,
    String? unrealizedGainsAccountNo,
    String? unrealisedLossesAccountNo,
    double? unitAmountDecimal,
    double? amountDecimal,
    String? symbol,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Currency>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(
      this,
      'realized_gains_account_no',
      realizedGainsAccountNo,
    );
    RealmObjectBase.set(
      this,
      'realised_losses_account_no',
      realisedLossesAccountNo,
    );
    RealmObjectBase.set(
      this,
      'unrealized_gains_account_no',
      unrealizedGainsAccountNo,
    );
    RealmObjectBase.set(
      this,
      'unrealised_losses_account_no',
      unrealisedLossesAccountNo,
    );
    RealmObjectBase.set(this, 'unit_amount_decimal', unitAmountDecimal);
    RealmObjectBase.set(this, 'amount_decimal', amountDecimal);
    RealmObjectBase.set(this, 'symbol', symbol);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  Currency._();

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
  String? get realizedGainsAccountNo =>
      RealmObjectBase.get<String>(this, 'realized_gains_account_no') as String?;
  @override
  set realizedGainsAccountNo(String? value) =>
      RealmObjectBase.set(this, 'realized_gains_account_no', value);

  @override
  String? get realisedLossesAccountNo =>
      RealmObjectBase.get<String>(this, 'realised_losses_account_no')
          as String?;
  @override
  set realisedLossesAccountNo(String? value) =>
      RealmObjectBase.set(this, 'realised_losses_account_no', value);

  @override
  String? get unrealizedGainsAccountNo =>
      RealmObjectBase.get<String>(this, 'unrealized_gains_account_no')
          as String?;
  @override
  set unrealizedGainsAccountNo(String? value) =>
      RealmObjectBase.set(this, 'unrealized_gains_account_no', value);

  @override
  String? get unrealisedLossesAccountNo =>
      RealmObjectBase.get<String>(this, 'unrealised_losses_account_no')
          as String?;
  @override
  set unrealisedLossesAccountNo(String? value) =>
      RealmObjectBase.set(this, 'unrealised_losses_account_no', value);

  @override
  double? get unitAmountDecimal =>
      RealmObjectBase.get<double>(this, 'unit_amount_decimal') as double?;
  @override
  set unitAmountDecimal(double? value) =>
      RealmObjectBase.set(this, 'unit_amount_decimal', value);

  @override
  double? get amountDecimal =>
      RealmObjectBase.get<double>(this, 'amount_decimal') as double?;
  @override
  set amountDecimal(double? value) =>
      RealmObjectBase.set(this, 'amount_decimal', value);

  @override
  String? get symbol => RealmObjectBase.get<String>(this, 'symbol') as String?;
  @override
  set symbol(String? value) => RealmObjectBase.set(this, 'symbol', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<Currency>> get changes =>
      RealmObjectBase.getChanges<Currency>(this);

  @override
  Stream<RealmObjectChanges<Currency>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Currency>(this, keyPaths);

  @override
  Currency freeze() => RealmObjectBase.freezeObject<Currency>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'realized_gains_account_no': realizedGainsAccountNo.toEJson(),
      'realised_losses_account_no': realisedLossesAccountNo.toEJson(),
      'unrealized_gains_account_no': unrealizedGainsAccountNo.toEJson(),
      'unrealised_losses_account_no': unrealisedLossesAccountNo.toEJson(),
      'unit_amount_decimal': unitAmountDecimal.toEJson(),
      'amount_decimal': amountDecimal.toEJson(),
      'symbol': symbol.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Currency value) => value.toEJson();
  static Currency _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'code': EJsonValue code} => Currency(
        fromEJson(code),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        realizedGainsAccountNo: fromEJson(ejson['realized_gains_account_no']),
        realisedLossesAccountNo: fromEJson(ejson['realised_losses_account_no']),
        unrealizedGainsAccountNo: fromEJson(
          ejson['unrealized_gains_account_no'],
        ),
        unrealisedLossesAccountNo: fromEJson(
          ejson['unrealised_losses_account_no'],
        ),
        unitAmountDecimal: fromEJson(ejson['unit_amount_decimal']),
        amountDecimal: fromEJson(ejson['amount_decimal']),
        symbol: fromEJson(ejson['symbol']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Currency._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Currency, 'CURRENCY', [
      SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'description2',
        RealmPropertyType.string,
        mapTo: 'description_2',
        optional: true,
      ),
      SchemaProperty(
        'realizedGainsAccountNo',
        RealmPropertyType.string,
        mapTo: 'realized_gains_account_no',
        optional: true,
      ),
      SchemaProperty(
        'realisedLossesAccountNo',
        RealmPropertyType.string,
        mapTo: 'realised_losses_account_no',
        optional: true,
      ),
      SchemaProperty(
        'unrealizedGainsAccountNo',
        RealmPropertyType.string,
        mapTo: 'unrealized_gains_account_no',
        optional: true,
      ),
      SchemaProperty(
        'unrealisedLossesAccountNo',
        RealmPropertyType.string,
        mapTo: 'unrealised_losses_account_no',
        optional: true,
      ),
      SchemaProperty(
        'unitAmountDecimal',
        RealmPropertyType.double,
        mapTo: 'unit_amount_decimal',
        optional: true,
      ),
      SchemaProperty(
        'amountDecimal',
        RealmPropertyType.double,
        mapTo: 'amount_decimal',
        optional: true,
      ),
      SchemaProperty('symbol', RealmPropertyType.string, optional: true),
      SchemaProperty('inactived', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'isSync',
        RealmPropertyType.string,
        mapTo: 'is_sync',
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
    ]);
  }();

  @override
  SchemaObject get objectSchema => RealmObjectBase.getSchema(this) ?? schema;
}

class CurrencyExchangeRate extends _CurrencyExchangeRate
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  CurrencyExchangeRate(
    String id, {
    String? startingDate,
    String? currencyCode,
    double? exchangeAmount,
    double? exchangeRate,
    double? currencyFactor,
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<CurrencyExchangeRate>({
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'starting_date', startingDate);
    RealmObjectBase.set(this, 'currency_code', currencyCode);
    RealmObjectBase.set(this, 'exchange_amount', exchangeAmount);
    RealmObjectBase.set(this, 'exchange_rate', exchangeRate);
    RealmObjectBase.set(this, 'currency_factor', currencyFactor);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  CurrencyExchangeRate._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get startingDate =>
      RealmObjectBase.get<String>(this, 'starting_date') as String?;
  @override
  set startingDate(String? value) =>
      RealmObjectBase.set(this, 'starting_date', value);

  @override
  String? get currencyCode =>
      RealmObjectBase.get<String>(this, 'currency_code') as String?;
  @override
  set currencyCode(String? value) =>
      RealmObjectBase.set(this, 'currency_code', value);

  @override
  double? get exchangeAmount =>
      RealmObjectBase.get<double>(this, 'exchange_amount') as double?;
  @override
  set exchangeAmount(double? value) =>
      RealmObjectBase.set(this, 'exchange_amount', value);

  @override
  double? get exchangeRate =>
      RealmObjectBase.get<double>(this, 'exchange_rate') as double?;
  @override
  set exchangeRate(double? value) =>
      RealmObjectBase.set(this, 'exchange_rate', value);

  @override
  double? get currencyFactor =>
      RealmObjectBase.get<double>(this, 'currency_factor') as double?;
  @override
  set currencyFactor(double? value) =>
      RealmObjectBase.set(this, 'currency_factor', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<CurrencyExchangeRate>> get changes =>
      RealmObjectBase.getChanges<CurrencyExchangeRate>(this);

  @override
  Stream<RealmObjectChanges<CurrencyExchangeRate>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<CurrencyExchangeRate>(this, keyPaths);

  @override
  CurrencyExchangeRate freeze() =>
      RealmObjectBase.freezeObject<CurrencyExchangeRate>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'starting_date': startingDate.toEJson(),
      'currency_code': currencyCode.toEJson(),
      'exchange_amount': exchangeAmount.toEJson(),
      'exchange_rate': exchangeRate.toEJson(),
      'currency_factor': currencyFactor.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(CurrencyExchangeRate value) => value.toEJson();
  static CurrencyExchangeRate _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => CurrencyExchangeRate(
        fromEJson(id),
        startingDate: fromEJson(ejson['starting_date']),
        currencyCode: fromEJson(ejson['currency_code']),
        exchangeAmount: fromEJson(ejson['exchange_amount']),
        exchangeRate: fromEJson(ejson['exchange_rate']),
        currencyFactor: fromEJson(ejson['currency_factor']),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(CurrencyExchangeRate._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      CurrencyExchangeRate,
      'CURRENCY_EXCHANGE_RATE',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty(
          'startingDate',
          RealmPropertyType.string,
          mapTo: 'starting_date',
          optional: true,
        ),
        SchemaProperty(
          'currencyCode',
          RealmPropertyType.string,
          mapTo: 'currency_code',
          optional: true,
        ),
        SchemaProperty(
          'exchangeAmount',
          RealmPropertyType.double,
          mapTo: 'exchange_amount',
          optional: true,
        ),
        SchemaProperty(
          'exchangeRate',
          RealmPropertyType.double,
          mapTo: 'exchange_rate',
          optional: true,
        ),
        SchemaProperty(
          'currencyFactor',
          RealmPropertyType.double,
          mapTo: 'currency_factor',
          optional: true,
        ),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
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

class Distributor extends _Distributor
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Distributor(
    String code, {
    String? name,
    String? name2,
    String? address,
    String? address2,
    String? postCode,
    String? village,
    String? commune,
    String? district,
    String? province,
    String? countryCode,
    String? locationCode,
    String? phoneNo,
    String? phoneNo2,
    String? email,
    String? contactName,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Distributor>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'name_2', name2);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'post_code', postCode);
    RealmObjectBase.set(this, 'village', village);
    RealmObjectBase.set(this, 'commune', commune);
    RealmObjectBase.set(this, 'district', district);
    RealmObjectBase.set(this, 'province', province);
    RealmObjectBase.set(this, 'country_code', countryCode);
    RealmObjectBase.set(this, 'location_code', locationCode);
    RealmObjectBase.set(this, 'phone_no', phoneNo);
    RealmObjectBase.set(this, 'phone_no_2', phoneNo2);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'contactName', contactName);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  Distributor._();

  @override
  String get code => RealmObjectBase.get<String>(this, 'code') as String;
  @override
  set code(String value) => RealmObjectBase.set(this, 'code', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get name2 => RealmObjectBase.get<String>(this, 'name_2') as String?;
  @override
  set name2(String? value) => RealmObjectBase.set(this, 'name_2', value);

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
  String? get postCode =>
      RealmObjectBase.get<String>(this, 'post_code') as String?;
  @override
  set postCode(String? value) => RealmObjectBase.set(this, 'post_code', value);

  @override
  String? get village =>
      RealmObjectBase.get<String>(this, 'village') as String?;
  @override
  set village(String? value) => RealmObjectBase.set(this, 'village', value);

  @override
  String? get commune =>
      RealmObjectBase.get<String>(this, 'commune') as String?;
  @override
  set commune(String? value) => RealmObjectBase.set(this, 'commune', value);

  @override
  String? get district =>
      RealmObjectBase.get<String>(this, 'district') as String?;
  @override
  set district(String? value) => RealmObjectBase.set(this, 'district', value);

  @override
  String? get province =>
      RealmObjectBase.get<String>(this, 'province') as String?;
  @override
  set province(String? value) => RealmObjectBase.set(this, 'province', value);

  @override
  String? get countryCode =>
      RealmObjectBase.get<String>(this, 'country_code') as String?;
  @override
  set countryCode(String? value) =>
      RealmObjectBase.set(this, 'country_code', value);

  @override
  String? get locationCode =>
      RealmObjectBase.get<String>(this, 'location_code') as String?;
  @override
  set locationCode(String? value) =>
      RealmObjectBase.set(this, 'location_code', value);

  @override
  String? get phoneNo =>
      RealmObjectBase.get<String>(this, 'phone_no') as String?;
  @override
  set phoneNo(String? value) => RealmObjectBase.set(this, 'phone_no', value);

  @override
  String? get phoneNo2 =>
      RealmObjectBase.get<String>(this, 'phone_no_2') as String?;
  @override
  set phoneNo2(String? value) => RealmObjectBase.set(this, 'phone_no_2', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get contactName =>
      RealmObjectBase.get<String>(this, 'contactName') as String?;
  @override
  set contactName(String? value) =>
      RealmObjectBase.set(this, 'contactName', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<Distributor>> get changes =>
      RealmObjectBase.getChanges<Distributor>(this);

  @override
  Stream<RealmObjectChanges<Distributor>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<Distributor>(this, keyPaths);

  @override
  Distributor freeze() => RealmObjectBase.freezeObject<Distributor>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'name': name.toEJson(),
      'name_2': name2.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'post_code': postCode.toEJson(),
      'village': village.toEJson(),
      'commune': commune.toEJson(),
      'district': district.toEJson(),
      'province': province.toEJson(),
      'country_code': countryCode.toEJson(),
      'location_code': locationCode.toEJson(),
      'phone_no': phoneNo.toEJson(),
      'phone_no_2': phoneNo2.toEJson(),
      'email': email.toEJson(),
      'contactName': contactName.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Distributor value) => value.toEJson();
  static Distributor _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'code': EJsonValue code} => Distributor(
        fromEJson(code),
        name: fromEJson(ejson['name']),
        name2: fromEJson(ejson['name_2']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        postCode: fromEJson(ejson['post_code']),
        village: fromEJson(ejson['village']),
        commune: fromEJson(ejson['commune']),
        district: fromEJson(ejson['district']),
        province: fromEJson(ejson['province']),
        countryCode: fromEJson(ejson['country_code']),
        locationCode: fromEJson(ejson['location_code']),
        phoneNo: fromEJson(ejson['phone_no']),
        phoneNo2: fromEJson(ejson['phone_no_2']),
        email: fromEJson(ejson['email']),
        contactName: fromEJson(ejson['contactName']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Distributor._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      Distributor,
      'DISTRIBUTOR',
      [
        SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'name2',
          RealmPropertyType.string,
          mapTo: 'name_2',
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
          'postCode',
          RealmPropertyType.string,
          mapTo: 'post_code',
          optional: true,
        ),
        SchemaProperty('village', RealmPropertyType.string, optional: true),
        SchemaProperty('commune', RealmPropertyType.string, optional: true),
        SchemaProperty('district', RealmPropertyType.string, optional: true),
        SchemaProperty('province', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'countryCode',
          RealmPropertyType.string,
          mapTo: 'country_code',
          optional: true,
        ),
        SchemaProperty(
          'locationCode',
          RealmPropertyType.string,
          mapTo: 'location_code',
          optional: true,
        ),
        SchemaProperty(
          'phoneNo',
          RealmPropertyType.string,
          mapTo: 'phone_no',
          optional: true,
        ),
        SchemaProperty(
          'phoneNo2',
          RealmPropertyType.string,
          mapTo: 'phone_no_2',
          optional: true,
        ),
        SchemaProperty('email', RealmPropertyType.string, optional: true),
        SchemaProperty('contactName', RealmPropertyType.string, optional: true),
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
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

class Location extends _Location
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Location(
    String code, {
    String? description,
    String? description2,
    String? address,
    String? address2,
    String? isIntransit,
    String? inactived = 'No',
    String? isSync = 'Yes',
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Location>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'is_intransit', isIntransit);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  Location._();

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
  String? get isIntransit =>
      RealmObjectBase.get<String>(this, 'is_intransit') as String?;
  @override
  set isIntransit(String? value) =>
      RealmObjectBase.set(this, 'is_intransit', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<Location>> get changes =>
      RealmObjectBase.getChanges<Location>(this);

  @override
  Stream<RealmObjectChanges<Location>> changesFor([List<String>? keyPaths]) =>
      RealmObjectBase.getChangesFor<Location>(this, keyPaths);

  @override
  Location freeze() => RealmObjectBase.freezeObject<Location>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'is_intransit': isIntransit.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(Location value) => value.toEJson();
  static Location _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'code': EJsonValue code} => Location(
        fromEJson(code),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        isIntransit: fromEJson(ejson['is_intransit']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Location._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(ObjectType.realmObject, Location, 'LOCATION', [
      SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
      SchemaProperty('description', RealmPropertyType.string, optional: true),
      SchemaProperty(
        'description2',
        RealmPropertyType.string,
        mapTo: 'description_2',
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
        'isIntransit',
        RealmPropertyType.string,
        mapTo: 'is_intransit',
        optional: true,
      ),
      SchemaProperty('inactived', RealmPropertyType.string, optional: true),
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

class Merchandise extends _Merchandise
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Merchandise(
    String code, {
    String? description,
    String? description2,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Merchandise>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  Merchandise._();

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
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<Merchandise>> get changes =>
      RealmObjectBase.getChanges<Merchandise>(this);

  @override
  Stream<RealmObjectChanges<Merchandise>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<Merchandise>(this, keyPaths);

  @override
  Merchandise freeze() => RealmObjectBase.freezeObject<Merchandise>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Merchandise value) => value.toEJson();
  static Merchandise _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'code': EJsonValue code} => Merchandise(
        fromEJson(code),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Merchandise._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      Merchandise,
      'MERCHANDISE',
      [
        SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
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

class PaymentMethod extends _PaymentMethod
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  PaymentMethod(
    String code, {
    String? code2,
    String? description,
    String? description2,
    String? balanceAccountType,
    String? balanceAccountNo,
    String? appIcon,
    String? appIcon32,
    String? appIcon128,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<PaymentMethod>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'code_2', code2);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'balance_account_type', balanceAccountType);
    RealmObjectBase.set(this, 'balance_account_no', balanceAccountNo);
    RealmObjectBase.set(this, 'app_icon', appIcon);
    RealmObjectBase.set(this, 'app_icon_32', appIcon32);
    RealmObjectBase.set(this, 'app_icon_128', appIcon128);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  PaymentMethod._();

  @override
  String get code => RealmObjectBase.get<String>(this, 'code') as String;
  @override
  set code(String value) => RealmObjectBase.set(this, 'code', value);

  @override
  String? get code2 => RealmObjectBase.get<String>(this, 'code_2') as String?;
  @override
  set code2(String? value) => RealmObjectBase.set(this, 'code_2', value);

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
  String? get balanceAccountType =>
      RealmObjectBase.get<String>(this, 'balance_account_type') as String?;
  @override
  set balanceAccountType(String? value) =>
      RealmObjectBase.set(this, 'balance_account_type', value);

  @override
  String? get balanceAccountNo =>
      RealmObjectBase.get<String>(this, 'balance_account_no') as String?;
  @override
  set balanceAccountNo(String? value) =>
      RealmObjectBase.set(this, 'balance_account_no', value);

  @override
  String? get appIcon =>
      RealmObjectBase.get<String>(this, 'app_icon') as String?;
  @override
  set appIcon(String? value) => RealmObjectBase.set(this, 'app_icon', value);

  @override
  String? get appIcon32 =>
      RealmObjectBase.get<String>(this, 'app_icon_32') as String?;
  @override
  set appIcon32(String? value) =>
      RealmObjectBase.set(this, 'app_icon_32', value);

  @override
  String? get appIcon128 =>
      RealmObjectBase.get<String>(this, 'app_icon_128') as String?;
  @override
  set appIcon128(String? value) =>
      RealmObjectBase.set(this, 'app_icon_128', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<PaymentMethod>> get changes =>
      RealmObjectBase.getChanges<PaymentMethod>(this);

  @override
  Stream<RealmObjectChanges<PaymentMethod>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<PaymentMethod>(this, keyPaths);

  @override
  PaymentMethod freeze() => RealmObjectBase.freezeObject<PaymentMethod>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'code_2': code2.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'balance_account_type': balanceAccountType.toEJson(),
      'balance_account_no': balanceAccountNo.toEJson(),
      'app_icon': appIcon.toEJson(),
      'app_icon_32': appIcon32.toEJson(),
      'app_icon_128': appIcon128.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(PaymentMethod value) => value.toEJson();
  static PaymentMethod _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'code': EJsonValue code} => PaymentMethod(
        fromEJson(code),
        code2: fromEJson(ejson['code_2']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        balanceAccountType: fromEJson(ejson['balance_account_type']),
        balanceAccountNo: fromEJson(ejson['balance_account_no']),
        appIcon: fromEJson(ejson['app_icon']),
        appIcon32: fromEJson(ejson['app_icon_32']),
        appIcon128: fromEJson(ejson['app_icon_128']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PaymentMethod._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      PaymentMethod,
      'PAYMENT_METHOD',
      [
        SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
        SchemaProperty(
          'code2',
          RealmPropertyType.string,
          mapTo: 'code_2',
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
          'balanceAccountType',
          RealmPropertyType.string,
          mapTo: 'balance_account_type',
          optional: true,
        ),
        SchemaProperty(
          'balanceAccountNo',
          RealmPropertyType.string,
          mapTo: 'balance_account_no',
          optional: true,
        ),
        SchemaProperty(
          'appIcon',
          RealmPropertyType.string,
          mapTo: 'app_icon',
          optional: true,
        ),
        SchemaProperty(
          'appIcon32',
          RealmPropertyType.string,
          mapTo: 'app_icon_32',
          optional: true,
        ),
        SchemaProperty(
          'appIcon128',
          RealmPropertyType.string,
          mapTo: 'app_icon_128',
          optional: true,
        ),
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
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

class PaymentTerm extends _PaymentTerm
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  PaymentTerm(
    String code, {
    String? description,
    String? description2,
    String? dueDateCalculation,
    String? discountDateCalculation,
    double? discountPercentage,
    double? discountAmount,
    String? inactived = 'No',
    String? isSync = 'Yes',
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<PaymentTerm>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'due_date_calculation', dueDateCalculation);
    RealmObjectBase.set(
      this,
      'discount_date_calculation',
      discountDateCalculation,
    );
    RealmObjectBase.set(this, 'discount_percentage', discountPercentage);
    RealmObjectBase.set(this, 'discount_amount', discountAmount);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
  }

  PaymentTerm._();

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
  String? get dueDateCalculation =>
      RealmObjectBase.get<String>(this, 'due_date_calculation') as String?;
  @override
  set dueDateCalculation(String? value) =>
      RealmObjectBase.set(this, 'due_date_calculation', value);

  @override
  String? get discountDateCalculation =>
      RealmObjectBase.get<String>(this, 'discount_date_calculation') as String?;
  @override
  set discountDateCalculation(String? value) =>
      RealmObjectBase.set(this, 'discount_date_calculation', value);

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
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  Stream<RealmObjectChanges<PaymentTerm>> get changes =>
      RealmObjectBase.getChanges<PaymentTerm>(this);

  @override
  Stream<RealmObjectChanges<PaymentTerm>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<PaymentTerm>(this, keyPaths);

  @override
  PaymentTerm freeze() => RealmObjectBase.freezeObject<PaymentTerm>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'due_date_calculation': dueDateCalculation.toEJson(),
      'discount_date_calculation': discountDateCalculation.toEJson(),
      'discount_percentage': discountPercentage.toEJson(),
      'discount_amount': discountAmount.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
    };
  }

  static EJsonValue _toEJson(PaymentTerm value) => value.toEJson();
  static PaymentTerm _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'code': EJsonValue code} => PaymentTerm(
        fromEJson(code),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        dueDateCalculation: fromEJson(ejson['due_date_calculation']),
        discountDateCalculation: fromEJson(ejson['discount_date_calculation']),
        discountPercentage: fromEJson(ejson['discount_percentage']),
        discountAmount: fromEJson(ejson['discount_amount']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PaymentTerm._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      PaymentTerm,
      'PAYMENT_TERM',
      [
        SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty(
          'dueDateCalculation',
          RealmPropertyType.string,
          mapTo: 'due_date_calculation',
          optional: true,
        ),
        SchemaProperty(
          'discountDateCalculation',
          RealmPropertyType.string,
          mapTo: 'discount_date_calculation',
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
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
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

class GeneralJournalBatch extends _GeneralJournalBatch
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  GeneralJournalBatch(
    String id, {
    String? code,
    String? description,
    String? description2,
    String? type,
    String? noSeriesCode,
    String? balAccountType,
    String? balAccountNo,
    String? balAccountTypeValue,
    String? balAccountNoValue,
    String? reasonCode,
    String? isChequeControl,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<GeneralJournalBatch>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'no_series_code', noSeriesCode);
    RealmObjectBase.set(this, 'bal_account_type', balAccountType);
    RealmObjectBase.set(this, 'bal_account_no', balAccountNo);
    RealmObjectBase.set(this, 'bal_account_type_value', balAccountTypeValue);
    RealmObjectBase.set(this, 'bal_account_no_value', balAccountNoValue);
    RealmObjectBase.set(this, 'reason_code', reasonCode);
    RealmObjectBase.set(this, 'is_cheque_control', isChequeControl);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  GeneralJournalBatch._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get code => RealmObjectBase.get<String>(this, 'code') as String?;
  @override
  set code(String? value) => RealmObjectBase.set(this, 'code', value);

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
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

  @override
  String? get noSeriesCode =>
      RealmObjectBase.get<String>(this, 'no_series_code') as String?;
  @override
  set noSeriesCode(String? value) =>
      RealmObjectBase.set(this, 'no_series_code', value);

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
  String? get balAccountTypeValue =>
      RealmObjectBase.get<String>(this, 'bal_account_type_value') as String?;
  @override
  set balAccountTypeValue(String? value) =>
      RealmObjectBase.set(this, 'bal_account_type_value', value);

  @override
  String? get balAccountNoValue =>
      RealmObjectBase.get<String>(this, 'bal_account_no_value') as String?;
  @override
  set balAccountNoValue(String? value) =>
      RealmObjectBase.set(this, 'bal_account_no_value', value);

  @override
  String? get reasonCode =>
      RealmObjectBase.get<String>(this, 'reason_code') as String?;
  @override
  set reasonCode(String? value) =>
      RealmObjectBase.set(this, 'reason_code', value);

  @override
  String? get isChequeControl =>
      RealmObjectBase.get<String>(this, 'is_cheque_control') as String?;
  @override
  set isChequeControl(String? value) =>
      RealmObjectBase.set(this, 'is_cheque_control', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<GeneralJournalBatch>> get changes =>
      RealmObjectBase.getChanges<GeneralJournalBatch>(this);

  @override
  Stream<RealmObjectChanges<GeneralJournalBatch>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<GeneralJournalBatch>(this, keyPaths);

  @override
  GeneralJournalBatch freeze() =>
      RealmObjectBase.freezeObject<GeneralJournalBatch>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'code': code.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'type': type.toEJson(),
      'no_series_code': noSeriesCode.toEJson(),
      'bal_account_type': balAccountType.toEJson(),
      'bal_account_no': balAccountNo.toEJson(),
      'bal_account_type_value': balAccountTypeValue.toEJson(),
      'bal_account_no_value': balAccountNoValue.toEJson(),
      'reason_code': reasonCode.toEJson(),
      'is_cheque_control': isChequeControl.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(GeneralJournalBatch value) => value.toEJson();
  static GeneralJournalBatch _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => GeneralJournalBatch(
        fromEJson(id),
        code: fromEJson(ejson['code']),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        type: fromEJson(ejson['type']),
        noSeriesCode: fromEJson(ejson['no_series_code']),
        balAccountType: fromEJson(ejson['bal_account_type']),
        balAccountNo: fromEJson(ejson['bal_account_no']),
        balAccountTypeValue: fromEJson(ejson['bal_account_type_value']),
        balAccountNoValue: fromEJson(ejson['bal_account_no_value']),
        reasonCode: fromEJson(ejson['reason_code']),
        isChequeControl: fromEJson(ejson['is_cheque_control']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(GeneralJournalBatch._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      GeneralJournalBatch,
      'GENERAL_JOURNAL_BATCH',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('code', RealmPropertyType.string, optional: true),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty('type', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'noSeriesCode',
          RealmPropertyType.string,
          mapTo: 'no_series_code',
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
          'balAccountTypeValue',
          RealmPropertyType.string,
          mapTo: 'bal_account_type_value',
          optional: true,
        ),
        SchemaProperty(
          'balAccountNoValue',
          RealmPropertyType.string,
          mapTo: 'bal_account_no_value',
          optional: true,
        ),
        SchemaProperty(
          'reasonCode',
          RealmPropertyType.string,
          mapTo: 'reason_code',
          optional: true,
        ),
        SchemaProperty(
          'isChequeControl',
          RealmPropertyType.string,
          mapTo: 'is_cheque_control',
          optional: true,
        ),
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
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

class PromotionType extends _PromotionType
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  PromotionType(
    String code, {
    String? description,
    String? description2,
    String? allowManual,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<PromotionType>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'allow_manual', allowManual);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  PromotionType._();

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
  String? get allowManual =>
      RealmObjectBase.get<String>(this, 'allow_manual') as String?;
  @override
  set allowManual(String? value) =>
      RealmObjectBase.set(this, 'allow_manual', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<PromotionType>> get changes =>
      RealmObjectBase.getChanges<PromotionType>(this);

  @override
  Stream<RealmObjectChanges<PromotionType>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<PromotionType>(this, keyPaths);

  @override
  PromotionType freeze() => RealmObjectBase.freezeObject<PromotionType>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'allow_manual': allowManual.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(PromotionType value) => value.toEJson();
  static PromotionType _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'code': EJsonValue code} => PromotionType(
        fromEJson(code),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        allowManual: fromEJson(ejson['allow_manual']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PromotionType._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      PromotionType,
      'PROMOTION_TYPE',
      [
        SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty(
          'allowManual',
          RealmPropertyType.string,
          mapTo: 'allow_manual',
          optional: true,
        ),
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
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

class PointOfSalesMaterial extends _PointOfSalesMaterial
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  PointOfSalesMaterial(
    String code, {
    String? description,
    String? description2,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<PointOfSalesMaterial>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  PointOfSalesMaterial._();

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
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<PointOfSalesMaterial>> get changes =>
      RealmObjectBase.getChanges<PointOfSalesMaterial>(this);

  @override
  Stream<RealmObjectChanges<PointOfSalesMaterial>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<PointOfSalesMaterial>(this, keyPaths);

  @override
  PointOfSalesMaterial freeze() =>
      RealmObjectBase.freezeObject<PointOfSalesMaterial>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(PointOfSalesMaterial value) => value.toEJson();
  static PointOfSalesMaterial _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'code': EJsonValue code} => PointOfSalesMaterial(
        fromEJson(code),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(PointOfSalesMaterial._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      PointOfSalesMaterial,
      'POINT_OF_SALES_MATERIAL',
      [
        SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
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

class Salesperson extends _Salesperson
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  Salesperson(
    String code, {
    String? name,
    String? name2,
    String? title,
    String? divisionCode,
    String? branchCode,
    String? businessUnitCode,
    String? salespersonGroupCode,
    String? email,
    String? phoneNo,
    String? avatar,
    String? avatar32,
    String? avatar128,
    String? stockCheckOption,
    String? level,
    String? levelIndex,
    String? joinedDate,
    String? inactived = 'No',
    String? customerStockCheck,
    String? isSync = 'Yes',
    String? downLineData,
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<Salesperson>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'name_2', name2);
    RealmObjectBase.set(this, 'title', title);
    RealmObjectBase.set(this, 'division_code', divisionCode);
    RealmObjectBase.set(this, 'branch_code', branchCode);
    RealmObjectBase.set(this, 'business_unit_code', businessUnitCode);
    RealmObjectBase.set(this, 'salesperson_group_code', salespersonGroupCode);
    RealmObjectBase.set(this, 'email', email);
    RealmObjectBase.set(this, 'phone_no', phoneNo);
    RealmObjectBase.set(this, 'avatar', avatar);
    RealmObjectBase.set(this, 'avatar_32', avatar32);
    RealmObjectBase.set(this, 'avatar_128', avatar128);
    RealmObjectBase.set(this, 'stock_check_option', stockCheckOption);
    RealmObjectBase.set(this, 'level', level);
    RealmObjectBase.set(this, 'level_index', levelIndex);
    RealmObjectBase.set(this, 'joined_date', joinedDate);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'customer_stock_check', customerStockCheck);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'downline_data', downLineData);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  Salesperson._();

  @override
  String get code => RealmObjectBase.get<String>(this, 'code') as String;
  @override
  set code(String value) => RealmObjectBase.set(this, 'code', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get name2 => RealmObjectBase.get<String>(this, 'name_2') as String?;
  @override
  set name2(String? value) => RealmObjectBase.set(this, 'name_2', value);

  @override
  String? get title => RealmObjectBase.get<String>(this, 'title') as String?;
  @override
  set title(String? value) => RealmObjectBase.set(this, 'title', value);

  @override
  String? get divisionCode =>
      RealmObjectBase.get<String>(this, 'division_code') as String?;
  @override
  set divisionCode(String? value) =>
      RealmObjectBase.set(this, 'division_code', value);

  @override
  String? get branchCode =>
      RealmObjectBase.get<String>(this, 'branch_code') as String?;
  @override
  set branchCode(String? value) =>
      RealmObjectBase.set(this, 'branch_code', value);

  @override
  String? get businessUnitCode =>
      RealmObjectBase.get<String>(this, 'business_unit_code') as String?;
  @override
  set businessUnitCode(String? value) =>
      RealmObjectBase.set(this, 'business_unit_code', value);

  @override
  String? get salespersonGroupCode =>
      RealmObjectBase.get<String>(this, 'salesperson_group_code') as String?;
  @override
  set salespersonGroupCode(String? value) =>
      RealmObjectBase.set(this, 'salesperson_group_code', value);

  @override
  String? get email => RealmObjectBase.get<String>(this, 'email') as String?;
  @override
  set email(String? value) => RealmObjectBase.set(this, 'email', value);

  @override
  String? get phoneNo =>
      RealmObjectBase.get<String>(this, 'phone_no') as String?;
  @override
  set phoneNo(String? value) => RealmObjectBase.set(this, 'phone_no', value);

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
  String? get stockCheckOption =>
      RealmObjectBase.get<String>(this, 'stock_check_option') as String?;
  @override
  set stockCheckOption(String? value) =>
      RealmObjectBase.set(this, 'stock_check_option', value);

  @override
  String? get level => RealmObjectBase.get<String>(this, 'level') as String?;
  @override
  set level(String? value) => RealmObjectBase.set(this, 'level', value);

  @override
  String? get levelIndex =>
      RealmObjectBase.get<String>(this, 'level_index') as String?;
  @override
  set levelIndex(String? value) =>
      RealmObjectBase.set(this, 'level_index', value);

  @override
  String? get joinedDate =>
      RealmObjectBase.get<String>(this, 'joined_date') as String?;
  @override
  set joinedDate(String? value) =>
      RealmObjectBase.set(this, 'joined_date', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get customerStockCheck =>
      RealmObjectBase.get<String>(this, 'customer_stock_check') as String?;
  @override
  set customerStockCheck(String? value) =>
      RealmObjectBase.set(this, 'customer_stock_check', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  String? get downLineData =>
      RealmObjectBase.get<String>(this, 'downline_data') as String?;
  @override
  set downLineData(String? value) =>
      RealmObjectBase.set(this, 'downline_data', value);

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
  Stream<RealmObjectChanges<Salesperson>> get changes =>
      RealmObjectBase.getChanges<Salesperson>(this);

  @override
  Stream<RealmObjectChanges<Salesperson>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<Salesperson>(this, keyPaths);

  @override
  Salesperson freeze() => RealmObjectBase.freezeObject<Salesperson>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'name': name.toEJson(),
      'name_2': name2.toEJson(),
      'title': title.toEJson(),
      'division_code': divisionCode.toEJson(),
      'branch_code': branchCode.toEJson(),
      'business_unit_code': businessUnitCode.toEJson(),
      'salesperson_group_code': salespersonGroupCode.toEJson(),
      'email': email.toEJson(),
      'phone_no': phoneNo.toEJson(),
      'avatar': avatar.toEJson(),
      'avatar_32': avatar32.toEJson(),
      'avatar_128': avatar128.toEJson(),
      'stock_check_option': stockCheckOption.toEJson(),
      'level': level.toEJson(),
      'level_index': levelIndex.toEJson(),
      'joined_date': joinedDate.toEJson(),
      'inactived': inactived.toEJson(),
      'customer_stock_check': customerStockCheck.toEJson(),
      'is_sync': isSync.toEJson(),
      'downline_data': downLineData.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(Salesperson value) => value.toEJson();
  static Salesperson _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'code': EJsonValue code} => Salesperson(
        fromEJson(code),
        name: fromEJson(ejson['name']),
        name2: fromEJson(ejson['name_2']),
        title: fromEJson(ejson['title']),
        divisionCode: fromEJson(ejson['division_code']),
        branchCode: fromEJson(ejson['branch_code']),
        businessUnitCode: fromEJson(ejson['business_unit_code']),
        salespersonGroupCode: fromEJson(ejson['salesperson_group_code']),
        email: fromEJson(ejson['email']),
        phoneNo: fromEJson(ejson['phone_no']),
        avatar: fromEJson(ejson['avatar']),
        avatar32: fromEJson(ejson['avatar_32']),
        avatar128: fromEJson(ejson['avatar_128']),
        stockCheckOption: fromEJson(ejson['stock_check_option']),
        level: fromEJson(ejson['level']),
        levelIndex: fromEJson(ejson['level_index']),
        joinedDate: fromEJson(ejson['joined_date']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        customerStockCheck: fromEJson(ejson['customer_stock_check']),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        downLineData: fromEJson(ejson['downline_data']),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(Salesperson._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      Salesperson,
      'SALESPERSON',
      [
        SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('name', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'name2',
          RealmPropertyType.string,
          mapTo: 'name_2',
          optional: true,
        ),
        SchemaProperty('title', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'divisionCode',
          RealmPropertyType.string,
          mapTo: 'division_code',
          optional: true,
        ),
        SchemaProperty(
          'branchCode',
          RealmPropertyType.string,
          mapTo: 'branch_code',
          optional: true,
        ),
        SchemaProperty(
          'businessUnitCode',
          RealmPropertyType.string,
          mapTo: 'business_unit_code',
          optional: true,
        ),
        SchemaProperty(
          'salespersonGroupCode',
          RealmPropertyType.string,
          mapTo: 'salesperson_group_code',
          optional: true,
        ),
        SchemaProperty('email', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'phoneNo',
          RealmPropertyType.string,
          mapTo: 'phone_no',
          optional: true,
        ),
        SchemaProperty('avatar', RealmPropertyType.string, optional: true),
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
          'stockCheckOption',
          RealmPropertyType.string,
          mapTo: 'stock_check_option',
          optional: true,
        ),
        SchemaProperty('level', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'levelIndex',
          RealmPropertyType.string,
          mapTo: 'level_index',
          optional: true,
        ),
        SchemaProperty(
          'joinedDate',
          RealmPropertyType.string,
          mapTo: 'joined_date',
          optional: true,
        ),
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'customerStockCheck',
          RealmPropertyType.string,
          mapTo: 'customer_stock_check',
          optional: true,
        ),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
          optional: true,
        ),
        SchemaProperty(
          'downLineData',
          RealmPropertyType.string,
          mapTo: 'downline_data',
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

class SubContractType extends _SubContractType
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  SubContractType(
    String code, {
    String? description,
    String? description2,
    String? contractCode,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<SubContractType>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'code', code);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'description_2', description2);
    RealmObjectBase.set(this, 'contract_code', contractCode);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  SubContractType._();

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
  String? get contractCode =>
      RealmObjectBase.get<String>(this, 'contract_code') as String?;
  @override
  set contractCode(String? value) =>
      RealmObjectBase.set(this, 'contract_code', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<SubContractType>> get changes =>
      RealmObjectBase.getChanges<SubContractType>(this);

  @override
  Stream<RealmObjectChanges<SubContractType>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<SubContractType>(this, keyPaths);

  @override
  SubContractType freeze() =>
      RealmObjectBase.freezeObject<SubContractType>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'code': code.toEJson(),
      'description': description.toEJson(),
      'description_2': description2.toEJson(),
      'contract_code': contractCode.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(SubContractType value) => value.toEJson();
  static SubContractType _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'code': EJsonValue code} => SubContractType(
        fromEJson(code),
        description: fromEJson(ejson['description']),
        description2: fromEJson(ejson['description_2']),
        contractCode: fromEJson(ejson['contract_code']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SubContractType._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      SubContractType,
      'SUB_CONTRACT_TYPE',
      [
        SchemaProperty('code', RealmPropertyType.string, primaryKey: true),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'description2',
          RealmPropertyType.string,
          mapTo: 'description_2',
          optional: true,
        ),
        SchemaProperty(
          'contractCode',
          RealmPropertyType.string,
          mapTo: 'contract_code',
          optional: true,
        ),
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
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

class VatPostingSetup extends _VatPostingSetup
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  VatPostingSetup(
    String id, {
    String? vatBusPostingGroup,
    String? vatProdPostingGroup,
    String? vatCalculationType,
    String? vatAmount,
    String? inactived = 'No',
    String? isSync = 'Yes',
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<VatPostingSetup>({
        'inactived': 'No',
        'is_sync': 'Yes',
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'vat_bus_posting_group', vatBusPostingGroup);
    RealmObjectBase.set(this, 'vat_prod_posting_group', vatProdPostingGroup);
    RealmObjectBase.set(this, 'vat_calculation_type', vatCalculationType);
    RealmObjectBase.set(this, 'vat_amount', vatAmount);
    RealmObjectBase.set(this, 'inactived', inactived);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  VatPostingSetup._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get vatBusPostingGroup =>
      RealmObjectBase.get<String>(this, 'vat_bus_posting_group') as String?;
  @override
  set vatBusPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'vat_bus_posting_group', value);

  @override
  String? get vatProdPostingGroup =>
      RealmObjectBase.get<String>(this, 'vat_prod_posting_group') as String?;
  @override
  set vatProdPostingGroup(String? value) =>
      RealmObjectBase.set(this, 'vat_prod_posting_group', value);

  @override
  String? get vatCalculationType =>
      RealmObjectBase.get<String>(this, 'vat_calculation_type') as String?;
  @override
  set vatCalculationType(String? value) =>
      RealmObjectBase.set(this, 'vat_calculation_type', value);

  @override
  String? get vatAmount =>
      RealmObjectBase.get<String>(this, 'vat_amount') as String?;
  @override
  set vatAmount(String? value) =>
      RealmObjectBase.set(this, 'vat_amount', value);

  @override
  String? get inactived =>
      RealmObjectBase.get<String>(this, 'inactived') as String?;
  @override
  set inactived(String? value) => RealmObjectBase.set(this, 'inactived', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

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
  Stream<RealmObjectChanges<VatPostingSetup>> get changes =>
      RealmObjectBase.getChanges<VatPostingSetup>(this);

  @override
  Stream<RealmObjectChanges<VatPostingSetup>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<VatPostingSetup>(this, keyPaths);

  @override
  VatPostingSetup freeze() =>
      RealmObjectBase.freezeObject<VatPostingSetup>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'vat_bus_posting_group': vatBusPostingGroup.toEJson(),
      'vat_prod_posting_group': vatProdPostingGroup.toEJson(),
      'vat_calculation_type': vatCalculationType.toEJson(),
      'vat_amount': vatAmount.toEJson(),
      'inactived': inactived.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(VatPostingSetup value) => value.toEJson();
  static VatPostingSetup _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => VatPostingSetup(
        fromEJson(id),
        vatBusPostingGroup: fromEJson(ejson['vat_bus_posting_group']),
        vatProdPostingGroup: fromEJson(ejson['vat_prod_posting_group']),
        vatCalculationType: fromEJson(ejson['vat_calculation_type']),
        vatAmount: fromEJson(ejson['vat_amount']),
        inactived: fromEJson(ejson['inactived'], defaultValue: 'No'),
        isSync: fromEJson(ejson['is_sync'], defaultValue: 'Yes'),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(VatPostingSetup._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      VatPostingSetup,
      'VAT_POSTING_SETUP',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty(
          'vatBusPostingGroup',
          RealmPropertyType.string,
          mapTo: 'vat_bus_posting_group',
          optional: true,
        ),
        SchemaProperty(
          'vatProdPostingGroup',
          RealmPropertyType.string,
          mapTo: 'vat_prod_posting_group',
          optional: true,
        ),
        SchemaProperty(
          'vatCalculationType',
          RealmPropertyType.string,
          mapTo: 'vat_calculation_type',
          optional: true,
        ),
        SchemaProperty(
          'vatAmount',
          RealmPropertyType.string,
          mapTo: 'vat_amount',
          optional: true,
        ),
        SchemaProperty('inactived', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
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
