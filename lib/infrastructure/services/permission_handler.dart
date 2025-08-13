import 'package:permission_handler/permission_handler.dart';

Future<bool> requestLocationPermissions() async {
  // Check current status
  var status = await Permission.location.status;

  if (status.isGranted) {
    return true;
  } else if (status.isDenied) {
    // Request permission
    var result = await Permission.location.request();
    return result.isGranted;
  } else if (status.isPermanentlyDenied) {
    // Open app settings to let user enable permission manually
    await openAppSettings();
    return false;
  }

  return false;
}
