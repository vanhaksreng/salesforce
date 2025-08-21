// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tasks_schemas.dart';

// **************************************************************************
// RealmObjectGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
class SalespersonSchedule extends _SalespersonSchedule
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  SalespersonSchedule(
    String id, {
    String? customerNo,
    String? description,
    String? salespersonCode,
    String? salespersonUplineCode,
    String? scheduleDate,
    String? scheduleDateMoveFrom,
    String? scheduleStartingTime,
    String? scheduleEndingTime,
    String? startingTime,
    String? endingTime,
    String? name,
    String? name2,
    String? shipToCode,
    String? address,
    String? address2,
    String? village,
    String? commune,
    String? district,
    String? province,
    String? phoneNo,
    String? phoneNo2,
    String? contactName,
    String? territoryCode,
    String? remark,
    String? planned,
    String? status = "Scheduled",
    double? latitude,
    double? longitude,
    double? actualLatitude,
    double? actualLongitude,
    double? actualDistance,
    double? actualDistanceHuman,
    double? timeOfVisited,
    String? timeOfVisitedHuman,
    String? timeOfVisitedFlag,
    String? timeOfVisitedData,
    String? positioningFlag,
    String? positioningData,
    String? externalDocumentType,
    String? externalDocumentNo,
    String? checkinDescription,
    String? checkInImage,
    String? checkInRemark,
    String? checkOutRemark,
    String? shopIsClosed = "Yes",
    String? isSync = "Yes",
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<SalespersonSchedule>({
        'status': "Scheduled",
        'shop_is_closed': "Yes",
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'salesperson_upline_code', salespersonUplineCode);
    RealmObjectBase.set(this, 'schedule_date', scheduleDate);
    RealmObjectBase.set(this, 'schedule_date_move_from', scheduleDateMoveFrom);
    RealmObjectBase.set(this, 'schedule_starting_time', scheduleStartingTime);
    RealmObjectBase.set(this, 'schedule_ending_time', scheduleEndingTime);
    RealmObjectBase.set(this, 'starting_time', startingTime);
    RealmObjectBase.set(this, 'ending_time', endingTime);
    RealmObjectBase.set(this, 'name', name);
    RealmObjectBase.set(this, 'name_2', name2);
    RealmObjectBase.set(this, 'ship_to_code', shipToCode);
    RealmObjectBase.set(this, 'address', address);
    RealmObjectBase.set(this, 'address_2', address2);
    RealmObjectBase.set(this, 'village', village);
    RealmObjectBase.set(this, 'commune', commune);
    RealmObjectBase.set(this, 'district', district);
    RealmObjectBase.set(this, 'province', province);
    RealmObjectBase.set(this, 'phone_no', phoneNo);
    RealmObjectBase.set(this, 'phone_no_2', phoneNo2);
    RealmObjectBase.set(this, 'contact_name', contactName);
    RealmObjectBase.set(this, 'territory_code', territoryCode);
    RealmObjectBase.set(this, 'remark', remark);
    RealmObjectBase.set(this, 'planned', planned);
    RealmObjectBase.set(this, 'status', status);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'actual_latitude', actualLatitude);
    RealmObjectBase.set(this, 'actual_longitude', actualLongitude);
    RealmObjectBase.set(this, 'actual_distance', actualDistance);
    RealmObjectBase.set(this, 'actual_distance_human', actualDistanceHuman);
    RealmObjectBase.set(this, 'time_of_visited', timeOfVisited);
    RealmObjectBase.set(this, 'time_of_visited_human', timeOfVisitedHuman);
    RealmObjectBase.set(this, 'time_of_visited_flag', timeOfVisitedFlag);
    RealmObjectBase.set(this, 'time_of_visited_data', timeOfVisitedData);
    RealmObjectBase.set(this, 'positioning_flag', positioningFlag);
    RealmObjectBase.set(this, 'positioning_data', positioningData);
    RealmObjectBase.set(this, 'external_document_type', externalDocumentType);
    RealmObjectBase.set(this, 'external_document_no', externalDocumentNo);
    RealmObjectBase.set(this, 'checkin_description', checkinDescription);
    RealmObjectBase.set(this, 'checkin_image', checkInImage);
    RealmObjectBase.set(this, 'checkin_remark', checkInRemark);
    RealmObjectBase.set(this, 'checkout_remark', checkOutRemark);
    RealmObjectBase.set(this, 'shop_is_closed', shopIsClosed);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  SalespersonSchedule._();

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
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get salespersonCode =>
      RealmObjectBase.get<String>(this, 'salesperson_code') as String?;
  @override
  set salespersonCode(String? value) =>
      RealmObjectBase.set(this, 'salesperson_code', value);

  @override
  String? get salespersonUplineCode =>
      RealmObjectBase.get<String>(this, 'salesperson_upline_code') as String?;
  @override
  set salespersonUplineCode(String? value) =>
      RealmObjectBase.set(this, 'salesperson_upline_code', value);

  @override
  String? get scheduleDate =>
      RealmObjectBase.get<String>(this, 'schedule_date') as String?;
  @override
  set scheduleDate(String? value) =>
      RealmObjectBase.set(this, 'schedule_date', value);

  @override
  String? get scheduleDateMoveFrom =>
      RealmObjectBase.get<String>(this, 'schedule_date_move_from') as String?;
  @override
  set scheduleDateMoveFrom(String? value) =>
      RealmObjectBase.set(this, 'schedule_date_move_from', value);

  @override
  String? get scheduleStartingTime =>
      RealmObjectBase.get<String>(this, 'schedule_starting_time') as String?;
  @override
  set scheduleStartingTime(String? value) =>
      RealmObjectBase.set(this, 'schedule_starting_time', value);

  @override
  String? get scheduleEndingTime =>
      RealmObjectBase.get<String>(this, 'schedule_ending_time') as String?;
  @override
  set scheduleEndingTime(String? value) =>
      RealmObjectBase.set(this, 'schedule_ending_time', value);

  @override
  String? get startingTime =>
      RealmObjectBase.get<String>(this, 'starting_time') as String?;
  @override
  set startingTime(String? value) =>
      RealmObjectBase.set(this, 'starting_time', value);

  @override
  String? get endingTime =>
      RealmObjectBase.get<String>(this, 'ending_time') as String?;
  @override
  set endingTime(String? value) =>
      RealmObjectBase.set(this, 'ending_time', value);

  @override
  String? get name => RealmObjectBase.get<String>(this, 'name') as String?;
  @override
  set name(String? value) => RealmObjectBase.set(this, 'name', value);

  @override
  String? get name2 => RealmObjectBase.get<String>(this, 'name_2') as String?;
  @override
  set name2(String? value) => RealmObjectBase.set(this, 'name_2', value);

  @override
  String? get shipToCode =>
      RealmObjectBase.get<String>(this, 'ship_to_code') as String?;
  @override
  set shipToCode(String? value) =>
      RealmObjectBase.set(this, 'ship_to_code', value);

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
  String? get contactName =>
      RealmObjectBase.get<String>(this, 'contact_name') as String?;
  @override
  set contactName(String? value) =>
      RealmObjectBase.set(this, 'contact_name', value);

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
  String? get planned =>
      RealmObjectBase.get<String>(this, 'planned') as String?;
  @override
  set planned(String? value) => RealmObjectBase.set(this, 'planned', value);

  @override
  String? get status => RealmObjectBase.get<String>(this, 'status') as String?;
  @override
  set status(String? value) => RealmObjectBase.set(this, 'status', value);

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
  double? get actualLatitude =>
      RealmObjectBase.get<double>(this, 'actual_latitude') as double?;
  @override
  set actualLatitude(double? value) =>
      RealmObjectBase.set(this, 'actual_latitude', value);

  @override
  double? get actualLongitude =>
      RealmObjectBase.get<double>(this, 'actual_longitude') as double?;
  @override
  set actualLongitude(double? value) =>
      RealmObjectBase.set(this, 'actual_longitude', value);

  @override
  double? get actualDistance =>
      RealmObjectBase.get<double>(this, 'actual_distance') as double?;
  @override
  set actualDistance(double? value) =>
      RealmObjectBase.set(this, 'actual_distance', value);

  @override
  double? get actualDistanceHuman =>
      RealmObjectBase.get<double>(this, 'actual_distance_human') as double?;
  @override
  set actualDistanceHuman(double? value) =>
      RealmObjectBase.set(this, 'actual_distance_human', value);

  @override
  double? get timeOfVisited =>
      RealmObjectBase.get<double>(this, 'time_of_visited') as double?;
  @override
  set timeOfVisited(double? value) =>
      RealmObjectBase.set(this, 'time_of_visited', value);

  @override
  String? get timeOfVisitedHuman =>
      RealmObjectBase.get<String>(this, 'time_of_visited_human') as String?;
  @override
  set timeOfVisitedHuman(String? value) =>
      RealmObjectBase.set(this, 'time_of_visited_human', value);

  @override
  String? get timeOfVisitedFlag =>
      RealmObjectBase.get<String>(this, 'time_of_visited_flag') as String?;
  @override
  set timeOfVisitedFlag(String? value) =>
      RealmObjectBase.set(this, 'time_of_visited_flag', value);

  @override
  String? get timeOfVisitedData =>
      RealmObjectBase.get<String>(this, 'time_of_visited_data') as String?;
  @override
  set timeOfVisitedData(String? value) =>
      RealmObjectBase.set(this, 'time_of_visited_data', value);

  @override
  String? get positioningFlag =>
      RealmObjectBase.get<String>(this, 'positioning_flag') as String?;
  @override
  set positioningFlag(String? value) =>
      RealmObjectBase.set(this, 'positioning_flag', value);

  @override
  String? get positioningData =>
      RealmObjectBase.get<String>(this, 'positioning_data') as String?;
  @override
  set positioningData(String? value) =>
      RealmObjectBase.set(this, 'positioning_data', value);

  @override
  String? get externalDocumentType =>
      RealmObjectBase.get<String>(this, 'external_document_type') as String?;
  @override
  set externalDocumentType(String? value) =>
      RealmObjectBase.set(this, 'external_document_type', value);

  @override
  String? get externalDocumentNo =>
      RealmObjectBase.get<String>(this, 'external_document_no') as String?;
  @override
  set externalDocumentNo(String? value) =>
      RealmObjectBase.set(this, 'external_document_no', value);

  @override
  String? get checkinDescription =>
      RealmObjectBase.get<String>(this, 'checkin_description') as String?;
  @override
  set checkinDescription(String? value) =>
      RealmObjectBase.set(this, 'checkin_description', value);

  @override
  String? get checkInImage =>
      RealmObjectBase.get<String>(this, 'checkin_image') as String?;
  @override
  set checkInImage(String? value) =>
      RealmObjectBase.set(this, 'checkin_image', value);

  @override
  String? get checkInRemark =>
      RealmObjectBase.get<String>(this, 'checkin_remark') as String?;
  @override
  set checkInRemark(String? value) =>
      RealmObjectBase.set(this, 'checkin_remark', value);

  @override
  String? get checkOutRemark =>
      RealmObjectBase.get<String>(this, 'checkout_remark') as String?;
  @override
  set checkOutRemark(String? value) =>
      RealmObjectBase.set(this, 'checkout_remark', value);

  @override
  String? get shopIsClosed =>
      RealmObjectBase.get<String>(this, 'shop_is_closed') as String?;
  @override
  set shopIsClosed(String? value) =>
      RealmObjectBase.set(this, 'shop_is_closed', value);

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
  Stream<RealmObjectChanges<SalespersonSchedule>> get changes =>
      RealmObjectBase.getChanges<SalespersonSchedule>(this);

  @override
  Stream<RealmObjectChanges<SalespersonSchedule>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<SalespersonSchedule>(this, keyPaths);

  @override
  SalespersonSchedule freeze() =>
      RealmObjectBase.freezeObject<SalespersonSchedule>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'customer_no': customerNo.toEJson(),
      'description': description.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'salesperson_upline_code': salespersonUplineCode.toEJson(),
      'schedule_date': scheduleDate.toEJson(),
      'schedule_date_move_from': scheduleDateMoveFrom.toEJson(),
      'schedule_starting_time': scheduleStartingTime.toEJson(),
      'schedule_ending_time': scheduleEndingTime.toEJson(),
      'starting_time': startingTime.toEJson(),
      'ending_time': endingTime.toEJson(),
      'name': name.toEJson(),
      'name_2': name2.toEJson(),
      'ship_to_code': shipToCode.toEJson(),
      'address': address.toEJson(),
      'address_2': address2.toEJson(),
      'village': village.toEJson(),
      'commune': commune.toEJson(),
      'district': district.toEJson(),
      'province': province.toEJson(),
      'phone_no': phoneNo.toEJson(),
      'phone_no_2': phoneNo2.toEJson(),
      'contact_name': contactName.toEJson(),
      'territory_code': territoryCode.toEJson(),
      'remark': remark.toEJson(),
      'planned': planned.toEJson(),
      'status': status.toEJson(),
      'latitude': latitude.toEJson(),
      'longitude': longitude.toEJson(),
      'actual_latitude': actualLatitude.toEJson(),
      'actual_longitude': actualLongitude.toEJson(),
      'actual_distance': actualDistance.toEJson(),
      'actual_distance_human': actualDistanceHuman.toEJson(),
      'time_of_visited': timeOfVisited.toEJson(),
      'time_of_visited_human': timeOfVisitedHuman.toEJson(),
      'time_of_visited_flag': timeOfVisitedFlag.toEJson(),
      'time_of_visited_data': timeOfVisitedData.toEJson(),
      'positioning_flag': positioningFlag.toEJson(),
      'positioning_data': positioningData.toEJson(),
      'external_document_type': externalDocumentType.toEJson(),
      'external_document_no': externalDocumentNo.toEJson(),
      'checkin_description': checkinDescription.toEJson(),
      'checkin_image': checkInImage.toEJson(),
      'checkin_remark': checkInRemark.toEJson(),
      'checkout_remark': checkOutRemark.toEJson(),
      'shop_is_closed': shopIsClosed.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(SalespersonSchedule value) => value.toEJson();
  static SalespersonSchedule _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => SalespersonSchedule(
        fromEJson(id),
        customerNo: fromEJson(ejson['customer_no']),
        description: fromEJson(ejson['description']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        salespersonUplineCode: fromEJson(ejson['salesperson_upline_code']),
        scheduleDate: fromEJson(ejson['schedule_date']),
        scheduleDateMoveFrom: fromEJson(ejson['schedule_date_move_from']),
        scheduleStartingTime: fromEJson(ejson['schedule_starting_time']),
        scheduleEndingTime: fromEJson(ejson['schedule_ending_time']),
        startingTime: fromEJson(ejson['starting_time']),
        endingTime: fromEJson(ejson['ending_time']),
        name: fromEJson(ejson['name']),
        name2: fromEJson(ejson['name_2']),
        shipToCode: fromEJson(ejson['ship_to_code']),
        address: fromEJson(ejson['address']),
        address2: fromEJson(ejson['address_2']),
        village: fromEJson(ejson['village']),
        commune: fromEJson(ejson['commune']),
        district: fromEJson(ejson['district']),
        province: fromEJson(ejson['province']),
        phoneNo: fromEJson(ejson['phone_no']),
        phoneNo2: fromEJson(ejson['phone_no_2']),
        contactName: fromEJson(ejson['contact_name']),
        territoryCode: fromEJson(ejson['territory_code']),
        remark: fromEJson(ejson['remark']),
        planned: fromEJson(ejson['planned']),
        status: fromEJson(ejson['status'], defaultValue: "Scheduled"),
        latitude: fromEJson(ejson['latitude']),
        longitude: fromEJson(ejson['longitude']),
        actualLatitude: fromEJson(ejson['actual_latitude']),
        actualLongitude: fromEJson(ejson['actual_longitude']),
        actualDistance: fromEJson(ejson['actual_distance']),
        actualDistanceHuman: fromEJson(ejson['actual_distance_human']),
        timeOfVisited: fromEJson(ejson['time_of_visited']),
        timeOfVisitedHuman: fromEJson(ejson['time_of_visited_human']),
        timeOfVisitedFlag: fromEJson(ejson['time_of_visited_flag']),
        timeOfVisitedData: fromEJson(ejson['time_of_visited_data']),
        positioningFlag: fromEJson(ejson['positioning_flag']),
        positioningData: fromEJson(ejson['positioning_data']),
        externalDocumentType: fromEJson(ejson['external_document_type']),
        externalDocumentNo: fromEJson(ejson['external_document_no']),
        checkinDescription: fromEJson(ejson['checkin_description']),
        checkInImage: fromEJson(ejson['checkin_image']),
        checkInRemark: fromEJson(ejson['checkin_remark']),
        checkOutRemark: fromEJson(ejson['checkout_remark']),
        shopIsClosed: fromEJson(ejson['shop_is_closed'], defaultValue: "Yes"),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SalespersonSchedule._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      SalespersonSchedule,
      'SALESPERSON_SCHEDULE',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty(
          'customerNo',
          RealmPropertyType.string,
          mapTo: 'customer_no',
          optional: true,
        ),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'salespersonCode',
          RealmPropertyType.string,
          mapTo: 'salesperson_code',
          optional: true,
        ),
        SchemaProperty(
          'salespersonUplineCode',
          RealmPropertyType.string,
          mapTo: 'salesperson_upline_code',
          optional: true,
        ),
        SchemaProperty(
          'scheduleDate',
          RealmPropertyType.string,
          mapTo: 'schedule_date',
          optional: true,
        ),
        SchemaProperty(
          'scheduleDateMoveFrom',
          RealmPropertyType.string,
          mapTo: 'schedule_date_move_from',
          optional: true,
        ),
        SchemaProperty(
          'scheduleStartingTime',
          RealmPropertyType.string,
          mapTo: 'schedule_starting_time',
          optional: true,
        ),
        SchemaProperty(
          'scheduleEndingTime',
          RealmPropertyType.string,
          mapTo: 'schedule_ending_time',
          optional: true,
        ),
        SchemaProperty(
          'startingTime',
          RealmPropertyType.string,
          mapTo: 'starting_time',
          optional: true,
        ),
        SchemaProperty(
          'endingTime',
          RealmPropertyType.string,
          mapTo: 'ending_time',
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
          'shipToCode',
          RealmPropertyType.string,
          mapTo: 'ship_to_code',
          optional: true,
        ),
        SchemaProperty('address', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'address2',
          RealmPropertyType.string,
          mapTo: 'address_2',
          optional: true,
        ),
        SchemaProperty('village', RealmPropertyType.string, optional: true),
        SchemaProperty('commune', RealmPropertyType.string, optional: true),
        SchemaProperty('district', RealmPropertyType.string, optional: true),
        SchemaProperty('province', RealmPropertyType.string, optional: true),
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
          'contactName',
          RealmPropertyType.string,
          mapTo: 'contact_name',
          optional: true,
        ),
        SchemaProperty(
          'territoryCode',
          RealmPropertyType.string,
          mapTo: 'territory_code',
          optional: true,
        ),
        SchemaProperty('remark', RealmPropertyType.string, optional: true),
        SchemaProperty('planned', RealmPropertyType.string, optional: true),
        SchemaProperty('status', RealmPropertyType.string, optional: true),
        SchemaProperty('latitude', RealmPropertyType.double, optional: true),
        SchemaProperty('longitude', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'actualLatitude',
          RealmPropertyType.double,
          mapTo: 'actual_latitude',
          optional: true,
        ),
        SchemaProperty(
          'actualLongitude',
          RealmPropertyType.double,
          mapTo: 'actual_longitude',
          optional: true,
        ),
        SchemaProperty(
          'actualDistance',
          RealmPropertyType.double,
          mapTo: 'actual_distance',
          optional: true,
        ),
        SchemaProperty(
          'actualDistanceHuman',
          RealmPropertyType.double,
          mapTo: 'actual_distance_human',
          optional: true,
        ),
        SchemaProperty(
          'timeOfVisited',
          RealmPropertyType.double,
          mapTo: 'time_of_visited',
          optional: true,
        ),
        SchemaProperty(
          'timeOfVisitedHuman',
          RealmPropertyType.string,
          mapTo: 'time_of_visited_human',
          optional: true,
        ),
        SchemaProperty(
          'timeOfVisitedFlag',
          RealmPropertyType.string,
          mapTo: 'time_of_visited_flag',
          optional: true,
        ),
        SchemaProperty(
          'timeOfVisitedData',
          RealmPropertyType.string,
          mapTo: 'time_of_visited_data',
          optional: true,
        ),
        SchemaProperty(
          'positioningFlag',
          RealmPropertyType.string,
          mapTo: 'positioning_flag',
          optional: true,
        ),
        SchemaProperty(
          'positioningData',
          RealmPropertyType.string,
          mapTo: 'positioning_data',
          optional: true,
        ),
        SchemaProperty(
          'externalDocumentType',
          RealmPropertyType.string,
          mapTo: 'external_document_type',
          optional: true,
        ),
        SchemaProperty(
          'externalDocumentNo',
          RealmPropertyType.string,
          mapTo: 'external_document_no',
          optional: true,
        ),
        SchemaProperty(
          'checkinDescription',
          RealmPropertyType.string,
          mapTo: 'checkin_description',
          optional: true,
        ),
        SchemaProperty(
          'checkInImage',
          RealmPropertyType.string,
          mapTo: 'checkin_image',
          optional: true,
        ),
        SchemaProperty(
          'checkInRemark',
          RealmPropertyType.string,
          mapTo: 'checkin_remark',
          optional: true,
        ),
        SchemaProperty(
          'checkOutRemark',
          RealmPropertyType.string,
          mapTo: 'checkout_remark',
          optional: true,
        ),
        SchemaProperty(
          'shopIsClosed',
          RealmPropertyType.string,
          mapTo: 'shop_is_closed',
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

class GpsTrackingEntry extends _GpsTrackingEntry
    with RealmEntity, RealmObjectBase, RealmObject {
  static var _defaultsSet = false;

  GpsTrackingEntry(
    int entryNo, {
    String? appId,
    String? username,
    String? fullName,
    String? salespersonCode,
    String? salespersonName,
    String? salespersonName2,
    String? trackingDate,
    String? trackingDatetime,
    String? type,
    String? documentType,
    String? documentNo,
    String? customerNo,
    String? customerName,
    String? customerNname2,
    String? gpsGoogleAddress,
    String? sourceType,
    String? sourceNo,
    double? latitude,
    double? longitude,
    double? cLatitude,
    double? cLongitude,
    String? isSync = "Yes",
    String? createdAt,
    String? updatedAt,
  }) {
    if (!_defaultsSet) {
      _defaultsSet = RealmObjectBase.setDefaults<GpsTrackingEntry>({
        'is_sync': "Yes",
      });
    }
    RealmObjectBase.set(this, 'entry_no', entryNo);
    RealmObjectBase.set(this, 'app_id', appId);
    RealmObjectBase.set(this, 'username', username);
    RealmObjectBase.set(this, 'full_name', fullName);
    RealmObjectBase.set(this, 'salesperson_code', salespersonCode);
    RealmObjectBase.set(this, 'salesperson_name', salespersonName);
    RealmObjectBase.set(this, 'salesperson_name_2', salespersonName2);
    RealmObjectBase.set(this, 'tracking_date', trackingDate);
    RealmObjectBase.set(this, 'tracking_datetime', trackingDatetime);
    RealmObjectBase.set(this, 'type', type);
    RealmObjectBase.set(this, 'document_type', documentType);
    RealmObjectBase.set(this, 'document_no', documentNo);
    RealmObjectBase.set(this, 'customer_no', customerNo);
    RealmObjectBase.set(this, 'customer_name', customerName);
    RealmObjectBase.set(this, 'customer_name_2', customerNname2);
    RealmObjectBase.set(this, 'gps_google_address', gpsGoogleAddress);
    RealmObjectBase.set(this, 'source_type', sourceType);
    RealmObjectBase.set(this, 'source_no', sourceNo);
    RealmObjectBase.set(this, 'latitude', latitude);
    RealmObjectBase.set(this, 'longitude', longitude);
    RealmObjectBase.set(this, 'c_latitude', cLatitude);
    RealmObjectBase.set(this, 'c_longitude', cLongitude);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createdAt);
    RealmObjectBase.set(this, 'updated_at', updatedAt);
  }

  GpsTrackingEntry._();

  @override
  int get entryNo => RealmObjectBase.get<int>(this, 'entry_no') as int;
  @override
  set entryNo(int value) => RealmObjectBase.set(this, 'entry_no', value);

  @override
  String? get appId => RealmObjectBase.get<String>(this, 'app_id') as String?;
  @override
  set appId(String? value) => RealmObjectBase.set(this, 'app_id', value);

  @override
  String? get username =>
      RealmObjectBase.get<String>(this, 'username') as String?;
  @override
  set username(String? value) => RealmObjectBase.set(this, 'username', value);

  @override
  String? get fullName =>
      RealmObjectBase.get<String>(this, 'full_name') as String?;
  @override
  set fullName(String? value) => RealmObjectBase.set(this, 'full_name', value);

  @override
  String? get salespersonCode =>
      RealmObjectBase.get<String>(this, 'salesperson_code') as String?;
  @override
  set salespersonCode(String? value) =>
      RealmObjectBase.set(this, 'salesperson_code', value);

  @override
  String? get salespersonName =>
      RealmObjectBase.get<String>(this, 'salesperson_name') as String?;
  @override
  set salespersonName(String? value) =>
      RealmObjectBase.set(this, 'salesperson_name', value);

  @override
  String? get salespersonName2 =>
      RealmObjectBase.get<String>(this, 'salesperson_name_2') as String?;
  @override
  set salespersonName2(String? value) =>
      RealmObjectBase.set(this, 'salesperson_name_2', value);

  @override
  String? get trackingDate =>
      RealmObjectBase.get<String>(this, 'tracking_date') as String?;
  @override
  set trackingDate(String? value) =>
      RealmObjectBase.set(this, 'tracking_date', value);

  @override
  String? get trackingDatetime =>
      RealmObjectBase.get<String>(this, 'tracking_datetime') as String?;
  @override
  set trackingDatetime(String? value) =>
      RealmObjectBase.set(this, 'tracking_datetime', value);

  @override
  String? get type => RealmObjectBase.get<String>(this, 'type') as String?;
  @override
  set type(String? value) => RealmObjectBase.set(this, 'type', value);

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
  String? get customerName =>
      RealmObjectBase.get<String>(this, 'customer_name') as String?;
  @override
  set customerName(String? value) =>
      RealmObjectBase.set(this, 'customer_name', value);

  @override
  String? get customerNname2 =>
      RealmObjectBase.get<String>(this, 'customer_name_2') as String?;
  @override
  set customerNname2(String? value) =>
      RealmObjectBase.set(this, 'customer_name_2', value);

  @override
  String? get gpsGoogleAddress =>
      RealmObjectBase.get<String>(this, 'gps_google_address') as String?;
  @override
  set gpsGoogleAddress(String? value) =>
      RealmObjectBase.set(this, 'gps_google_address', value);

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
  double? get cLatitude =>
      RealmObjectBase.get<double>(this, 'c_latitude') as double?;
  @override
  set cLatitude(double? value) =>
      RealmObjectBase.set(this, 'c_latitude', value);

  @override
  double? get cLongitude =>
      RealmObjectBase.get<double>(this, 'c_longitude') as double?;
  @override
  set cLongitude(double? value) =>
      RealmObjectBase.set(this, 'c_longitude', value);

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
  Stream<RealmObjectChanges<GpsTrackingEntry>> get changes =>
      RealmObjectBase.getChanges<GpsTrackingEntry>(this);

  @override
  Stream<RealmObjectChanges<GpsTrackingEntry>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<GpsTrackingEntry>(this, keyPaths);

  @override
  GpsTrackingEntry freeze() =>
      RealmObjectBase.freezeObject<GpsTrackingEntry>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'entry_no': entryNo.toEJson(),
      'app_id': appId.toEJson(),
      'username': username.toEJson(),
      'full_name': fullName.toEJson(),
      'salesperson_code': salespersonCode.toEJson(),
      'salesperson_name': salespersonName.toEJson(),
      'salesperson_name_2': salespersonName2.toEJson(),
      'tracking_date': trackingDate.toEJson(),
      'tracking_datetime': trackingDatetime.toEJson(),
      'type': type.toEJson(),
      'document_type': documentType.toEJson(),
      'document_no': documentNo.toEJson(),
      'customer_no': customerNo.toEJson(),
      'customer_name': customerName.toEJson(),
      'customer_name_2': customerNname2.toEJson(),
      'gps_google_address': gpsGoogleAddress.toEJson(),
      'source_type': sourceType.toEJson(),
      'source_no': sourceNo.toEJson(),
      'latitude': latitude.toEJson(),
      'longitude': longitude.toEJson(),
      'c_latitude': cLatitude.toEJson(),
      'c_longitude': cLongitude.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createdAt.toEJson(),
      'updated_at': updatedAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(GpsTrackingEntry value) => value.toEJson();
  static GpsTrackingEntry _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'entry_no': EJsonValue entryNo} => GpsTrackingEntry(
        fromEJson(entryNo),
        appId: fromEJson(ejson['app_id']),
        username: fromEJson(ejson['username']),
        fullName: fromEJson(ejson['full_name']),
        salespersonCode: fromEJson(ejson['salesperson_code']),
        salespersonName: fromEJson(ejson['salesperson_name']),
        salespersonName2: fromEJson(ejson['salesperson_name_2']),
        trackingDate: fromEJson(ejson['tracking_date']),
        trackingDatetime: fromEJson(ejson['tracking_datetime']),
        type: fromEJson(ejson['type']),
        documentType: fromEJson(ejson['document_type']),
        documentNo: fromEJson(ejson['document_no']),
        customerNo: fromEJson(ejson['customer_no']),
        customerName: fromEJson(ejson['customer_name']),
        customerNname2: fromEJson(ejson['customer_name_2']),
        gpsGoogleAddress: fromEJson(ejson['gps_google_address']),
        sourceType: fromEJson(ejson['source_type']),
        sourceNo: fromEJson(ejson['source_no']),
        latitude: fromEJson(ejson['latitude']),
        longitude: fromEJson(ejson['longitude']),
        cLatitude: fromEJson(ejson['c_latitude']),
        cLongitude: fromEJson(ejson['c_longitude']),
        isSync: fromEJson(ejson['is_sync'], defaultValue: "Yes"),
        createdAt: fromEJson(ejson['created_at']),
        updatedAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(GpsTrackingEntry._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      GpsTrackingEntry,
      'GPS_TRACKING_ENTRY',
      [
        SchemaProperty(
          'entryNo',
          RealmPropertyType.int,
          mapTo: 'entry_no',
          primaryKey: true,
        ),
        SchemaProperty(
          'appId',
          RealmPropertyType.string,
          mapTo: 'app_id',
          optional: true,
        ),
        SchemaProperty('username', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'fullName',
          RealmPropertyType.string,
          mapTo: 'full_name',
          optional: true,
        ),
        SchemaProperty(
          'salespersonCode',
          RealmPropertyType.string,
          mapTo: 'salesperson_code',
          optional: true,
        ),
        SchemaProperty(
          'salespersonName',
          RealmPropertyType.string,
          mapTo: 'salesperson_name',
          optional: true,
        ),
        SchemaProperty(
          'salespersonName2',
          RealmPropertyType.string,
          mapTo: 'salesperson_name_2',
          optional: true,
        ),
        SchemaProperty(
          'trackingDate',
          RealmPropertyType.string,
          mapTo: 'tracking_date',
          optional: true,
        ),
        SchemaProperty(
          'trackingDatetime',
          RealmPropertyType.string,
          mapTo: 'tracking_datetime',
          optional: true,
        ),
        SchemaProperty('type', RealmPropertyType.string, optional: true),
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
        SchemaProperty(
          'customerName',
          RealmPropertyType.string,
          mapTo: 'customer_name',
          optional: true,
        ),
        SchemaProperty(
          'customerNname2',
          RealmPropertyType.string,
          mapTo: 'customer_name_2',
          optional: true,
        ),
        SchemaProperty(
          'gpsGoogleAddress',
          RealmPropertyType.string,
          mapTo: 'gps_google_address',
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
        SchemaProperty('latitude', RealmPropertyType.double, optional: true),
        SchemaProperty('longitude', RealmPropertyType.double, optional: true),
        SchemaProperty(
          'cLatitude',
          RealmPropertyType.double,
          mapTo: 'c_latitude',
          optional: true,
        ),
        SchemaProperty(
          'cLongitude',
          RealmPropertyType.double,
          mapTo: 'c_longitude',
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

class SalesPersonScheduleLog extends _SalesPersonScheduleLog
    with RealmEntity, RealmObjectBase, RealmObject {
  SalesPersonScheduleLog(
    String id, {
    String? visitNo,
    String? logType,
    String? logDate,
    String? shopIsClosed,
    String? description,
    String? userId,
    String? isSync,
    String? createAt,
    String? updateAt,
  }) {
    RealmObjectBase.set(this, 'id', id);
    RealmObjectBase.set(this, 'visit_no', visitNo);
    RealmObjectBase.set(this, 'log_type', logType);
    RealmObjectBase.set(this, 'log_date', logDate);
    RealmObjectBase.set(this, 'shop_is_closed', shopIsClosed);
    RealmObjectBase.set(this, 'description', description);
    RealmObjectBase.set(this, 'user_id', userId);
    RealmObjectBase.set(this, 'is_sync', isSync);
    RealmObjectBase.set(this, 'created_at', createAt);
    RealmObjectBase.set(this, 'updated_at', updateAt);
  }

  SalesPersonScheduleLog._();

  @override
  String get id => RealmObjectBase.get<String>(this, 'id') as String;
  @override
  set id(String value) => RealmObjectBase.set(this, 'id', value);

  @override
  String? get visitNo =>
      RealmObjectBase.get<String>(this, 'visit_no') as String?;
  @override
  set visitNo(String? value) => RealmObjectBase.set(this, 'visit_no', value);

  @override
  String? get logType =>
      RealmObjectBase.get<String>(this, 'log_type') as String?;
  @override
  set logType(String? value) => RealmObjectBase.set(this, 'log_type', value);

  @override
  String? get logDate =>
      RealmObjectBase.get<String>(this, 'log_date') as String?;
  @override
  set logDate(String? value) => RealmObjectBase.set(this, 'log_date', value);

  @override
  String? get shopIsClosed =>
      RealmObjectBase.get<String>(this, 'shop_is_closed') as String?;
  @override
  set shopIsClosed(String? value) =>
      RealmObjectBase.set(this, 'shop_is_closed', value);

  @override
  String? get description =>
      RealmObjectBase.get<String>(this, 'description') as String?;
  @override
  set description(String? value) =>
      RealmObjectBase.set(this, 'description', value);

  @override
  String? get userId => RealmObjectBase.get<String>(this, 'user_id') as String?;
  @override
  set userId(String? value) => RealmObjectBase.set(this, 'user_id', value);

  @override
  String? get isSync => RealmObjectBase.get<String>(this, 'is_sync') as String?;
  @override
  set isSync(String? value) => RealmObjectBase.set(this, 'is_sync', value);

  @override
  String? get createAt =>
      RealmObjectBase.get<String>(this, 'created_at') as String?;
  @override
  set createAt(String? value) => RealmObjectBase.set(this, 'created_at', value);

  @override
  String? get updateAt =>
      RealmObjectBase.get<String>(this, 'updated_at') as String?;
  @override
  set updateAt(String? value) => RealmObjectBase.set(this, 'updated_at', value);

  @override
  Stream<RealmObjectChanges<SalesPersonScheduleLog>> get changes =>
      RealmObjectBase.getChanges<SalesPersonScheduleLog>(this);

  @override
  Stream<RealmObjectChanges<SalesPersonScheduleLog>> changesFor([
    List<String>? keyPaths,
  ]) => RealmObjectBase.getChangesFor<SalesPersonScheduleLog>(this, keyPaths);

  @override
  SalesPersonScheduleLog freeze() =>
      RealmObjectBase.freezeObject<SalesPersonScheduleLog>(this);

  EJsonValue toEJson() {
    return <String, dynamic>{
      'id': id.toEJson(),
      'visit_no': visitNo.toEJson(),
      'log_type': logType.toEJson(),
      'log_date': logDate.toEJson(),
      'shop_is_closed': shopIsClosed.toEJson(),
      'description': description.toEJson(),
      'user_id': userId.toEJson(),
      'is_sync': isSync.toEJson(),
      'created_at': createAt.toEJson(),
      'updated_at': updateAt.toEJson(),
    };
  }

  static EJsonValue _toEJson(SalesPersonScheduleLog value) => value.toEJson();
  static SalesPersonScheduleLog _fromEJson(EJsonValue ejson) {
    if (ejson is! Map<String, dynamic>) return raiseInvalidEJson(ejson);
    return switch (ejson) {
      {'id': EJsonValue id} => SalesPersonScheduleLog(
        fromEJson(id),
        visitNo: fromEJson(ejson['visit_no']),
        logType: fromEJson(ejson['log_type']),
        logDate: fromEJson(ejson['log_date']),
        shopIsClosed: fromEJson(ejson['shop_is_closed']),
        description: fromEJson(ejson['description']),
        userId: fromEJson(ejson['user_id']),
        isSync: fromEJson(ejson['is_sync']),
        createAt: fromEJson(ejson['created_at']),
        updateAt: fromEJson(ejson['updated_at']),
      ),
      _ => raiseInvalidEJson(ejson),
    };
  }

  static final schema = () {
    RealmObjectBase.registerFactory(SalesPersonScheduleLog._);
    register(_toEJson, _fromEJson);
    return const SchemaObject(
      ObjectType.realmObject,
      SalesPersonScheduleLog,
      'SALES_PERSON_SCHEDULE_LOG',
      [
        SchemaProperty('id', RealmPropertyType.string, primaryKey: true),
        SchemaProperty(
          'visitNo',
          RealmPropertyType.string,
          mapTo: 'visit_no',
          optional: true,
        ),
        SchemaProperty(
          'logType',
          RealmPropertyType.string,
          mapTo: 'log_type',
          optional: true,
        ),
        SchemaProperty(
          'logDate',
          RealmPropertyType.string,
          mapTo: 'log_date',
          optional: true,
        ),
        SchemaProperty(
          'shopIsClosed',
          RealmPropertyType.string,
          mapTo: 'shop_is_closed',
          optional: true,
        ),
        SchemaProperty('description', RealmPropertyType.string, optional: true),
        SchemaProperty(
          'userId',
          RealmPropertyType.string,
          mapTo: 'user_id',
          optional: true,
        ),
        SchemaProperty(
          'isSync',
          RealmPropertyType.string,
          mapTo: 'is_sync',
          optional: true,
        ),
        SchemaProperty(
          'createAt',
          RealmPropertyType.string,
          mapTo: 'created_at',
          optional: true,
        ),
        SchemaProperty(
          'updateAt',
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
