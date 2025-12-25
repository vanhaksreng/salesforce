import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

extension SalespersonScheduleExtension on SalespersonSchedule {
  static SalespersonSchedule fromMap(Map<String, dynamic> json) {
    return SalespersonSchedule(
      Helpers.toStrings(json['id']),
      customerNo: json['customer_no'],
      description: json['description'] ?? "",
      salespersonCode: json['salesperson_code'] ?? '',
      salespersonUplineCode: json['salesperson_upline_code'] ?? '',
      scheduleDate: DateTimeExt.parse(json['schedule_date']).toDateString(),
      scheduleDateMoveFrom: DateTimeExt.parse(
        json['schedule_date_move_from'],
      ).toDateString(),
      startingTime: json['starting_time'] ?? "",
      endingTime: json['ending_time'] ?? "",
      duration: json['duration'] ?? "",
      statusInternetCheckIn: json['status_internet_check_in'] ?? "",
      statusInternetCheckOut: json['status_internet_check_out'] ?? "",
      checkInPosition: json['check_in_position'] ?? "",
      checkOutPosition: json['check_out_position'] ?? "",
      name: json['name'] ?? '',
      name2: json['name_2'] ?? '',
      address: json['address'] ?? '',
      address2: json['address_2'] ?? '',
      phoneNo: json['phone_no'] ?? '',
      phoneNo2: json['phone_no_2'] ?? '',
      status: json['status'] ?? 'Scheduled',
      latitude: Helpers.toDouble(json['latitude'] ?? 0),
      longitude: Helpers.toDouble(json['longitude'] ?? 0),
      actualLatitude: Helpers.toDouble(json['actual_latitude'] ?? 0),
      actualLongitude: Helpers.toDouble(json['actual_longitude'] ?? 0),
      checkInRemark: json['checkin_remark'] ?? '',
      checkOutRemark: json['checkout_remark'] ?? '',
      checkInImage: json['checkin_image'] ?? '',
      checkOutImage: json['checkout_image'] ?? '',
      remark: json['remark'] ?? '',
      planned: json['planned'] ?? kStatusYes,
      shopIsClosed: json['shop_is_closed'] ?? kStatusNo,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_no': customerNo,
      'description': description,
      'salesperson_code': salespersonCode,
      'salesperson_upline_code': salespersonUplineCode,
      'schedule_date': scheduleDate,
      'starting_time': startingTime,
      'ending_time': endingTime,
      'name': name,
      'name_2': name2,
      'address': address,
      'address_2': address2,
      'phone_no': phoneNo,
      'phone_no_2': phoneNo2,
      'status': status,
      'latitude': latitude?.toDouble(),
      'longitude': longitude?.toDouble(),
      'actual_latitude': actualLatitude?.toDouble(),
      'actual_longitude': actualLongitude?.toDouble(),
      'checkin_remark': checkInRemark,
      'checkout_remark': checkOutRemark,
      'checkin_image': checkInImage,
      'checkout_image': checkOutImage,
      'remark': remark,
      'planned': planned,
      'shop_is_closed': shopIsClosed,
      'schedule_date_move_from': scheduleDateMoveFrom,
      'status_internet_check_in': statusInternetCheckIn,
      'status_internet_check_out': statusInternetCheckOut,
      'duration': duration,
    };
  }
}
