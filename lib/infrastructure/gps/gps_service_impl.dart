import 'dart:async';

import 'package:latlong2/latlong.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/features/auth/domain/entities/user.dart';

import 'gps_service.dart';

class GpsServiceImpl implements IGpsService {
  final BaseAppRepository _appRepo;

  GpsServiceImpl(BaseAppRepository appRepo) : _appRepo = appRepo;

  @override
  Future<void> execute({required User auth, required LatLng latlng}) async {
    _appRepo.storeLocationOffline(latlng);
  }

  @override
  Future<void> syncToBackend({required User auth}) async {
    await _appRepo.syncOfflineLocationToBackend();
  }
}
