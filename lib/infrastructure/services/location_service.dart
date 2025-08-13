import 'package:latlong2/latlong.dart';
import 'package:salesforce/core/domain/repositories/base_app_repository.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/infrastructure/gps/gps_service_impl.dart';
import 'package:salesforce/injection_container.dart';

class LocationService {
  final _location = GeolocatorLocationService();
  final appRepo = getIt<BaseAppRepository>();

  void startForegroundTracking() {
    final GpsServiceImpl gpsService = GpsServiceImpl(appRepo);
    final auth = getAuth();

    _location.startContinuousLocationTracking(
      onLocationUpdate: (position) {
        print('Foreground Location: ${position.latitude}, ${position.longitude} ${position.accuracy}');

        if (auth != null) {
          gpsService.execute(auth: auth, latlng: LatLng(position.latitude, position.longitude));
          gpsService.syncToBackend(auth: auth);
        }
      },
    );
  }

  void stopForegroundTracking() {
    _location.stopTracking();
  }
}
