import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:salesforce/features/auth/domain/entities/user.dart';

abstract class IGpsService {
  Future<void> execute({required User auth, required LatLng latlng});

  Future<void> syncToBackend({required User auth});
}
