import 'package:salesforce/core/utils/helpers.dart';

class SalePersonGpsModel {
  final String code;
  final String name;
  final String phoneNo;
  final String avatar;
  final String latitude;
  final String longitude;
  final String trackingDate;

  SalePersonGpsModel({
    required this.code,
    required this.name,
    required this.phoneNo,
    required this.avatar,
    required this.latitude,
    required this.longitude,
    required this.trackingDate,
  });

  factory SalePersonGpsModel.fromJson(Map<String, dynamic> json) =>
      SalePersonGpsModel(
        code: Helpers.toStrings(json["code"]),
        name: Helpers.toStrings(json["name"]),
        phoneNo: Helpers.toStrings(json["phone_no"]),
        avatar: Helpers.toStrings(json["avatar"]),
        latitude: Helpers.toStrings(json["latitude"]),
        longitude: Helpers.toStrings(json["longitude"]),
        trackingDate: Helpers.toStrings(json["tracking_date"]),
      );

  Map<String, dynamic> toJson() => {
    "code": code,
    "name": name,
    "phone_no": phoneNo,
    "avatar": avatar,
    "latitude": latitude,
    "longitude": longitude,
    "tracking_date": trackingDate,
  };
}
