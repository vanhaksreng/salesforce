import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:http/http.dart' as http;

class InvoiceItem {
  final String name;
  final int qty;
  final double price;
  final double discount;
  final double amount;

  InvoiceItem({
    required this.name,
    required this.qty,
    required this.price,
    required this.discount,
    required this.amount,
  });

  Map<String, dynamic> toMap() => {'name': name, 'qty': qty, 'price': price};
}

class BluetoothPrinterService {
  static const MethodChannel _channel = MethodChannel(
    'com.clearviewerp.pos_printer/bluetooth',
  );

  /// Requests BLUETOOTH_SCAN and BLUETOOTH_CONNECT permissions (Android 12+)
  Future<bool> requestPermissions() async {
    try {
      final bool granted = await _channel.invokeMethod('requestPermissions');
      return granted;
    } on PlatformException catch (e) {
      debugPrint("Failed to request permissions: ${e.message}");
      return false;
    }
  }

  /// Scans for paired devices and returns a list of maps with 'name' and 'address'
  Future<List<Map<String, String>>> getPairedDevices() async {
    try {
      final List<dynamic> devices = await _channel.invokeMethod('scanDevices');
      return devices.map((d) => Map<String, String>.from(d)).toList();
    } on PlatformException catch (e) {
      debugPrint("getPairedDevices failed: ${e.message}");
      return [];
    }
  }

  /// Connects to a specific printer using its MAC address
  Future<bool> connect(String address) async {
    try {
      final bool result = await _channel.invokeMethod('connect', {
        'address': address,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint("connect failed: ${e.message}");
      return false;
    }
  }

  /// Disconnects from the current printer
  Future<void> disconnect() async {
    try {
      await _channel.invokeMethod('disconnect');
    } on PlatformException catch (e) {
      debugPrint("Disconnect failed: ${e.message}");
    }
  }

  String underLine(int length) {
    return "-" * length;
  }

  Future<String?> printReceipt({
    required CompanyInformation company,
    required String customer,
    required String invoiceNo,
    required String dateTime,
    required List<InvoiceItem> items,
    required double discountAmount,
    required double vatAmount,
    required double amountDue,
    required String paymentMethod,
    String? printerName,
  }) async {
    try {
      final int fullWidth = 75;
      final String logoPath = company.logo128 ?? "";
      Uint8List? logoBytes;

      // ប្រសិនបើមានបញ្ជូនផ្លូវរូបភាពឡូហ្គោមក ត្រូវអានវាទៅជា Bytes
      if (logoPath.isNotEmpty) {
        try {
          final response = await http.get(Uri.parse(logoPath));
          if (response.statusCode == 200) {
            logoBytes = response.bodyBytes;
          } else {
            debugPrint(
              "Logo Error: Unable to download image. Status code: ${response.statusCode}",
            );
          }
        } catch (e) {
          logoBytes = null;
          debugPrint("Logo : $e");
        }
      }

      final buffer = StringBuffer();

      // ១. ផ្នែកក្បាលវិក្កយបត្រ (Header)
      buffer.writeln("[C]<b>${company.name}</b>");
      buffer.writeln("[C]${company.address}");
      // buffer.writeln("[C]<b>បង្កាន់ដៃទទួលប្រាក់</b>");

      //42 for 80mm and 32 for 58mm
      buffer.writeln(underLine(fullWidth));

      // ២. ព័ត៌មានវិក្កយបត្រ
      buffer.writeln("វិក្កយបត្រ (Invoice No): $invoiceNo");
      buffer.writeln("អតិថិជន (Customer): $customer");
      buffer.writeln("កាលបរិច្ឆេទ (Date): $dateTime");
      buffer.writeln("ទូទាត់ដោយ (Payment): $paymentMethod");

      buffer.writeln(underLine(fullWidth));
      buffer.writeln(
        "[TABLE]<b>ល.រ, ឈ្មោះទំនិញ, ចំនួន, តម្លៃ, ចុះតម្លៃ, សរុប</b>",
      );
      buffer.writeln("[TABLE]<b>No, Item Name, Qty, Price, Dis, Total</b>");
      buffer.writeln(underLine(fullWidth));

      // ៣. រង្វិលជុំទាញយកមុខទំនិញនីមួយៗ (Items Loop)
      double subtotal = 0.0;
      for (int i = 0; i < items.length; i++) {
        final item = items[i];
        final index = i + 1;
        final itemTotal = item.qty * item.price;
        subtotal += itemTotal;

        // បញ្ជូនតាមលំដាប់៖ ល.រ, ឈ្មោះ, ចំនួន, តម្លៃ, ចុះតម្លៃ, សរុប
        buffer.writeln(
          "[TABLE]$index, ${item.name}, ${item.qty}, ${Helpers.formatNumber(item.price, option: FormatType.amount)}, ${Helpers.formatNumber(item.discount, option: FormatType.percentage)}, ${Helpers.formatNumber(itemTotal, option: FormatType.amount)}",
        );
      }

      // ៤. ផ្នែកសរុបប្រាក់ និងបាតវិក្កយបត្រ (Footer)
      buffer.writeln(underLine(fullWidth));
      buffer.writeln(
        "[R]សរុប (Subtotal): ${Helpers.formatNumber(subtotal, option: FormatType.amount)}",
      );
      buffer.writeln(
        "[R]ចុះតម្លៃ (Discount): ${Helpers.formatNumber(discountAmount, option: FormatType.amount, showZeroWhenEmpty: true)}",
      );
      buffer.writeln(
        "[R]អាករ (VAT): ${Helpers.formatNumber(vatAmount, option: FormatType.amount, showZeroWhenEmpty: true)}",
      );
      buffer.writeln(
        "[R]<b>សរុបរួម (Total): ${Helpers.formatNumber(amountDue, option: FormatType.amount, showZeroWhenEmpty: true)}</b>",
      );
      buffer.writeln("");
      buffer.writeln("[C]សូមអរគុណ! Thank You!");

      final String result = await _channel.invokeMethod('printReceipt', {
        'text': buffer.toString(),
        'printerName': printerName,
        'logoBytes': logoBytes,
      });

      return result;
    } on PlatformException catch (e) {
      debugPrint("Printing failed: ${e.message}");
      return e.message;
    }
  }
}
