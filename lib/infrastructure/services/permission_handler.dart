import 'package:permission_handler/permission_handler.dart';

Future<bool> requestLocationPermissions() async {
  var status = await Permission.location.status;

  if (status.isGranted) return true;

  if (status.isDenied) {
    var result = await Permission.location.request();
    return result.isGranted;
  }

  if (status.isPermanentlyDenied) {
    await openAppSettings();
    return false;
  }

  return false;
}
