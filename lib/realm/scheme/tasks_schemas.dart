import 'package:realm/realm.dart';
part 'tasks_schemas.realm.dart';

@MapTo("SALESPERSON_SCHEDULE")
@RealmModel()
class _SalespersonSchedule {
  @MapTo("id")
  @PrimaryKey()
  late String id;
  @MapTo("customer_no")
  late String? customerNo;
  @MapTo("description")
  late String? description;
  @MapTo("salesperson_code")
  late String? salespersonCode;
  @MapTo("salesperson_upline_code")
  late String? salespersonUplineCode;
  @MapTo("schedule_date")
  late String? scheduleDate;
  @MapTo("schedule_date_move_from")
  late String? scheduleDateMoveFrom;
  @MapTo("schedule_starting_time")
  late String? scheduleStartingTime;
  @MapTo("schedule_ending_time")
  late String? scheduleEndingTime;
  @MapTo("starting_time")
  late String? startingTime;
  @MapTo("ending_time")
  late String? endingTime;
  @MapTo("name")
  late String? name;
  @MapTo("name_2")
  late String? name2;
  @MapTo("ship_to_code")
  late String? shipToCode;
  @MapTo("address")
  late String? address;
  @MapTo("address_2")
  late String? address2;
  @MapTo("village")
  late String? village;
  @MapTo("commune")
  late String? commune;
  @MapTo("district")
  late String? district;
  @MapTo("province")
  late String? province;
  @MapTo("phone_no")
  late String? phoneNo;
  @MapTo("phone_no_2")
  late String? phoneNo2;
  @MapTo("contact_name")
  late String? contactName;
  @MapTo("territory_code")
  late String? territoryCode;
  @MapTo("remark")
  late String? remark;
  @MapTo("planned")
  late String? planned;
  @MapTo("status")
  late String? status = "Scheduled";
  @MapTo("latitude")
  late double? latitude;
  @MapTo("longitude")
  late double? longitude;
  @MapTo("actual_latitude")
  late double? actualLatitude;
  @MapTo("actual_longitude")
  late double? actualLongitude;
  @MapTo("actual_distance")
  late double? actualDistance;
  @MapTo("actual_distance_human")
  late double? actualDistanceHuman;
  @MapTo("time_of_visited")
  late double? timeOfVisited;
  @MapTo("time_of_visited_human")
  late String? timeOfVisitedHuman;
  @MapTo("time_of_visited_flag")
  late String? timeOfVisitedFlag;
  @MapTo("time_of_visited_data")
  late String? timeOfVisitedData;
  @MapTo("positioning_flag")
  late String? positioningFlag;
  @MapTo("positioning_data")
  late String? positioningData;
  @MapTo("external_document_type")
  late String? externalDocumentType;
  @MapTo("external_document_no")
  late String? externalDocumentNo;
  @MapTo("checkin_description")
  late String? checkinDescription;
  @MapTo("checkin_image")
  late String? checkInImage;
  @MapTo("checkin_remark")
  late String? checkInRemark;
  @MapTo("checkout_remark")
  late String? checkOutRemark;
  @MapTo("shop_is_closed")
  late String? shopIsClosed = "Yes";
  @MapTo("is_sync")
  late String? isSync = "Yes";
  @MapTo("created_at")
  late String? createdAt;
  @MapTo("updated_at")
  late String? updatedAt;
}

@MapTo("GPS_TRACKING_ENTRY")
@RealmModel()
class _GpsTrackingEntry {
  @MapTo("entry_no")
  @PrimaryKey()
  late int entryNo;
  @MapTo("app_id")
  late String? appId;
  @MapTo("username")
  late String? username;
  @MapTo("full_name")
  late String? fullName;
  @MapTo("salesperson_code")
  late String? salespersonCode;
  @MapTo("salesperson_name")
  late String? salespersonName;
  @MapTo("salesperson_name_2")
  late String? salespersonName2;
  @MapTo("tracking_date")
  late String? trackingDate;
  @MapTo("tracking_datetime")
  late String? trackingDatetime;
  @MapTo("type")
  late String? type;
  @MapTo("document_type")
  late String? documentType;
  @MapTo("document_no")
  late String? documentNo;
  @MapTo("customer_no")
  late String? customerNo;
  @MapTo("customer_name")
  late String? customerName;
  @MapTo("customer_name_2")
  late String? customerNname2;
  @MapTo("gps_google_address")
  late String? gpsGoogleAddress;
  @MapTo("source_type")
  late String? sourceType;
  @MapTo("source_no")
  late String? sourceNo;
  @MapTo("latitude")
  late double? latitude;
  @MapTo("longitude")
  late double? longitude;
  @MapTo("c_latitude")
  late double? cLatitude;
  @MapTo("c_longitude")
  late double? cLongitude;
  @MapTo("is_sync")
  late String? isSync = "Yes";
  @MapTo("created_at")
  late String? createdAt;
  @MapTo("updated_at")
  late String? updatedAt;
}

@MapTo("SALES_PERSON_SCHEDULE_LOG")
@RealmModel()
class _SalesPersonScheduleLog {
  @MapTo("id")
  @PrimaryKey()
  late String id;
  @MapTo("visit_no")
  late String? visitNo;
  @MapTo("log_type")
  late String? logType;
  @MapTo("log_date")
  late String? logDate;
  @MapTo("shop_is_closed")
  late String? shopIsClosed;
  @MapTo("description")
  late String? description;
  @MapTo("user_id")
  late String? userId;
  @MapTo("is_sync")
  late String? isSync;
  @MapTo("created_at")
  late String? createAt;
  @MapTo("updated_at")
  late String? updateAt;
}
