import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/features/auth/domain/entities/user.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';

abstract class IGpsService {
  Future<void> execute({required LatLng latlng});
  Future<void> storeGps({required List<GpsRouteTracking> records});
  Future<void> syncToBackend({required User auth});
}
