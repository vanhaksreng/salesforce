import 'package:salesforce/realm/scheme/tasks_schemas.dart';

extension GpsTrackingEntryExtension on GpsTrackingEntry {
  Map<String, dynamic> toJson() => {
    'entry_no': entryNo,
    'app_id': appId,
    'username': username,
    'full_name': fullName,
    'salesperson_code': salespersonCode,
    'salesperson_name': salespersonName,
    'salesperson_name_2': salespersonName2,
    'tracking_date': trackingDate,
    'tracking_datetime': trackingDatetime,
    'type': type,
    'document_type': documentType,
    'document_no': documentNo,
    'customer_no': customerNo,
    'customer_name': customerName,
    'customer_name_2': customerNname2,
    'gps_google_address': gpsGoogleAddress,
    'source_type': sourceType,
    'source_no': sourceNo,
    'latitude': latitude,
    'longitude': longitude,
    'c_latitude': cLatitude,
    'c_longitude': cLongitude,
    'is_sync': isSync,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}
