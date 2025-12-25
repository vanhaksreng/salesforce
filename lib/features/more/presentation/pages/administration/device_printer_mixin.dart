import 'dart:convert';

import 'package:salesforce/core/data/models/extension/device_printer_extention.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:shared_preferences/shared_preferences.dart';

mixin DevicePrinterMixin {
  Future<DevicePrinter?> loadSelectedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceJson = prefs.getString('selected_printer');

      if (deviceJson != null && deviceJson.isNotEmpty) {
        final Map<String, dynamic> json = jsonDecode(deviceJson);
        return DevicePrinterExtension.fromMap(json);
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  Future<void> clearSelectedPrinter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('selected_printer');
    } catch (error) {
      rethrow;
    }
  }
}
