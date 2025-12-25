import 'package:salesforce/realm/scheme/general_schemas.dart';

extension DevicePrinterExtension on DevicePrinter {
  Map<String, dynamic> toMap() {
    return {
      'mac_address': macAddress,
      'device_name': deviceName,
      'origin_device_name': originDeviceName,
      'type_connection': typeConnection,
      'model': model,
      'paperSize': paperSize,
    };
  }

  static DevicePrinter fromMap(Map<String, dynamic> map) {
    return DevicePrinter(
      map['device_name'] ?? '',
      map['model'] ?? '',
      map['type_connection'] ?? 'bluetooth',
      map['origin_device_name'] ?? '',
      map['mac_address'] ?? '',
      (map['paperSize'] ?? 576.0) as num,
    );
  }
}
