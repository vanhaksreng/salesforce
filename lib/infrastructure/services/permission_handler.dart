import 'package:geolocator/geolocator.dart';
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

// Future<bool> requestLocationPermissions() async {
//   bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     await Geolocator.openLocationSettings();

//     serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) return false;
//   }

//   var status = await Permission.location.status;

//   if (status.isGranted) {
//     return true;
//   }

//   if (status.isDenied) {
//     // Request permission
//     var result = await Permission.location.request();
//     return result.isGranted;
//   }

//   if (status.isPermanentlyDenied) {
//     // Open app settings to allow manual enabling
//     await openAppSettings();
//     return false;
//   }

//   return false;
// }
