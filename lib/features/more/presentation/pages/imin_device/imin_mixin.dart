import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'imin_printer_service.dart';

mixin IminPrinterMixin on MessageMixin {
  bool _isPrinterInitialized = false;

  bool get isPrinterInitialized => _isPrinterInitialized;

  Future<bool> checkIminDevice() async {
    if (!Platform.isAndroid) return false;
    final deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    final model = (androidInfo.model).toLowerCase();
    final manufacturer = (androidInfo.manufacturer).toLowerCase();

    final isImin =
        manufacturer.contains("imin") ||
        model.contains("imin") ||
        model.startsWith("m2") || // Catches m2, m2-202, m2-203, m2 pro, etc.
        model.contains("m2-") ||
        model.contains("m2 pro") ||
        model.contains("d1") || // iMin D1 series
        model.contains("d2") || // iMin D2 series
        model.contains("d3") || // iMin D3 series
        model.contains("d4"); // iMin D4 series
    return isImin;
  }

  Future<bool> initializeIminPrinter() async {
    try {
      await IminPrinterService.initialize();
      _isPrinterInitialized = true;
      showSuccessMessage("iMin printer initialized successfully");
      return true;
    } catch (e) {
      _isPrinterInitialized = false;
      showErrorMessage("Failed to initialize printer: ${e.toString()}");
      return false;
    }
  }

  /// Check printer status and show message
  Future<Map<String, dynamic>?> checkIminPrinterStatus({
    bool showMessage = false,
  }) async {
    try {
      final status = await IminPrinterService.getStatus();

      if (showMessage) {
        final statusCode = status['status'] as int;
        final message = status['message'] as String;

        if (statusCode == 0 || statusCode == -1) {
          showSuccessMessage(message);
        } else {
          showErrorMessage(message);
        }
      }

      return status;
    } catch (e) {
      if (showMessage) {
        showErrorMessage("Failed to check printer status");
      }
      return null;
    }
  }

  /// Print text with iMin printer
  Future<bool> printWithImin(String text) async {
    try {
      if (!_isPrinterInitialized) {
        showErrorMessage("Printer not initialized");
        return false;
      }

      // Check status first
      final status = await IminPrinterService.getStatus();
      final statusCode = status['status'] as int;

      // Only block on critical errors (2-5), allow -1, 0, and 1
      if (statusCode >= 2 && statusCode <= 5) {
        final message = status['message'] as String;
        showErrorMessage(message);
        return false;
      }

      if (statusCode == -1) {
        showErrorMessage(
          "Printer status is -1, but attempting to print anyway",
        );
      }

      await IminPrinterService.printText(text);
      showSuccessMessage("Print successful");
      return true;
    } catch (e) {
      showErrorMessage("Print failed: ${e.toString()}");
      return false;
    }
  }

  Future<bool> printIminTestReceipt() async {
    try {
      if (!_isPrinterInitialized) {
        await initializeIminPrinter();
      }

      await IminPrinterService.testPrint();
      showSuccessMessage("Test print completed");
      return true;
    } catch (e) {
      showErrorMessage("Test print failed: ${e.toString()}");
      return false;
    }
  }

  /// Reset iMin printer
  Future<bool> resetIminPrinter() async {
    try {
      await IminPrinterService.reset();
      showSuccessMessage("Printer reset successfully");
      return true;
    } catch (e) {
      showErrorMessage("Failed to reset printer: ${e.toString()}");
      return false;
    }
  }

  /// Get device information
  Future<Map<String, dynamic>?> getIminDeviceInfo() async {
    try {
      final info = await IminPrinterService.getDeviceInfo();
      return info;
    } catch (e) {
      showErrorMessage("Failed to get device info: ${e.toString()}");
      return null;
    }
  }

  /// Get serial number
  Future<String?> getIminSerialNumber() async {
    try {
      final sn = await IminPrinterService.getSerialNumber();
      return sn;
    } catch (e) {
      showErrorMessage("Failed to get serial number: ${e.toString()}");
      return null;
    }
  }

  /// Open cash box
  Future<bool> openIminCashBox() async {
    try {
      await IminPrinterService.openCashBox();
      showSuccessMessage("Cash box opened");
      return true;
    } catch (e) {
      showErrorMessage("Failed to open cash box: ${e.toString()}");
      return false;
    }
  }

  Future<bool> printIminReceipt(String receiptContent) async {
    try {
      if (!_isPrinterInitialized) {
        final initialized = await initializeIminPrinter();
        if (!initialized) return false;
      }

      final status = await IminPrinterService.getStatus();
      final statusCode = status['status'] as int;

      if (statusCode >= 2 && statusCode <= 5) {
        final message = status['message'] as String;
        showErrorMessage("Printer not ready: $message");
        return false;
      }

      await IminPrinterService.printText(receiptContent);
      showSuccessMessage("Receipt printed successfully");
      return true;
    } catch (e) {
      showErrorMessage("Failed to print receipt: ${e.toString()}");
      return false;
    }
  }
}
