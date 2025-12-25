import 'package:salesforce/core/data/datasources/handlers/base_table_handler.dart';
import 'package:salesforce/core/data/models/extension/location_extension.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class LocationHandler extends BaseTableHandler<Location> {
  @override
  String get tableName => "location";

  @override
  Location fromMap(Map<String, dynamic> map) => LocationExtension.fromMap(map);

  @override
  String extractKey(Location record) => record.code;

  @override
  Type get type => Location;
}
