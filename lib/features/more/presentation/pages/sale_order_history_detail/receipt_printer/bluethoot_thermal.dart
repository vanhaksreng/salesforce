import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SimpleBluetoothPrinter extends StatefulWidget {
  const SimpleBluetoothPrinter({super.key});

  @override
  State<SimpleBluetoothPrinter> createState() => _SimpleBluetoothPrinterState();
}

class _SimpleBluetoothPrinterState extends State<SimpleBluetoothPrinter> {
  List<BluetoothInfo> devices = [];
  bool connected = false;
  bool isConnecting = false;
  String statusMessage = "";
  String? connectedMac;

  @override
  void initState() {
    super.initState();
    _initializePrinter();
  }

  // MARK: - Initialization
  Future<void> _initializePrinter() async {
    try {
      debugPrint("🚀 Initializing printer...");

      // First check if already connected
      await checkExistingConnection();

      // Scan for devices
      await scanDevices();

      // If not connected, try to auto-connect
      if (!connected && devices.isNotEmpty) {
        // Check if we have a stored preference for which device to use
        final storedMac = await _getStoredConnectedMac();

        if (storedMac != null && devices.any((d) => d.macAdress == storedMac)) {
          debugPrint(
            "📌 Found stored MAC, attempting to reconnect: $storedMac",
          );
          await connect(storedMac);
        } else {
          debugPrint("📌 No stored MAC, connecting to first device");
          await connect(devices[0].macAdress);
        }
      }
    } catch (e) {
      debugPrint("❌ Initialization error: $e");
      setState(() {
        statusMessage = "Failed to initialize: $e";
      });
    }
  }

  // MARK: - Connection Check
  Future<void> checkExistingConnection() async {
    try {
      debugPrint("🔍 Checking for existing connection...");

      // Check if already connected
      final bool isConnected = await PrintBluetoothThermal.connectionStatus;

      debugPrint("📊 Connection status: $isConnected");

      if (isConnected) {
        // Try to get stored MAC
        final storedMac = await _getStoredConnectedMac();

        if (storedMac != null) {
          setState(() {
            connected = true;
            connectedMac = storedMac;
            statusMessage = "Already connected to printer ✅";
          });

          debugPrint("✅ Already connected to: $storedMac");
          return;
        } else {
          debugPrint("⚠️ Connected but no stored MAC, will reconnect");
          // Disconnect and reconnect properly
          await PrintBluetoothThermal.disconnect;
          await Future.delayed(const Duration(milliseconds: 500));
        }
      } else {
        debugPrint("❌ No existing connection");
      }
    } catch (e) {
      debugPrint("❌ Error checking connection: $e");
    }
  }

  // MARK: - Scan Devices
  Future<void> scanDevices() async {
    try {
      debugPrint("🔍 Scanning for paired devices...");

      final result = await PrintBluetoothThermal.pairedBluetooths;

      setState(() => devices = result);

      debugPrint("📋 Found ${devices.length} paired devices:");
      for (var device in devices) {
        debugPrint("  - ${device.name} (${device.macAdress})");
      }

      if (devices.isEmpty) {
        setState(() {
          statusMessage =
              "No paired devices found. Please pair your printer first.";
        });
      }
    } catch (e) {
      debugPrint("❌ Scan error: $e");
      setState(() {
        statusMessage = "Failed to scan devices: $e";
      });
    }
  }

  // MARK: - Connect
  Future<void> connect(String mac) async {
    if (isConnecting) {
      debugPrint("⚠️ Already attempting to connect");
      return;
    }

    // Check if already connected to this device
    if (connected && connectedMac == mac) {
      final bool isStillConnected =
          await PrintBluetoothThermal.connectionStatus;
      if (isStillConnected) {
        debugPrint("✅ Already connected to this device");
        setState(() {
          statusMessage = "Already connected ✅";
        });
        return;
      } else {
        // Was connected but lost connection
        setState(() {
          connected = false;
          connectedMac = null;
        });
      }
    }

    setState(() {
      isConnecting = true;
      statusMessage = "Connecting...";
    });

    try {
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");
      debugPrint("🔵 Attempting to connect to: $mac");
      debugPrint("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━");

      // Disconnect any existing connection first
      if (connected) {
        debugPrint("🔌 Disconnecting previous connection...");
        await PrintBluetoothThermal.disconnect;
        await Future.delayed(const Duration(milliseconds: 800));
      }

      final bool result =
          await PrintBluetoothThermal.connect(macPrinterAddress: mac).timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint("⏱️ Connection timeout");
              return false;
            },
          );

      debugPrint("📊 Connection result: $result");

      if (result) {
        // Verify connection is stable
        await Future.delayed(const Duration(milliseconds: 1000));
        final bool isStillConnected =
            await PrintBluetoothThermal.connectionStatus;

        debugPrint("✅ Connection status verified: $isStillConnected");

        if (isStillConnected) {
          setState(() {
            connected = true;
            connectedMac = mac;
            isConnecting = false;
            statusMessage = "Connected ✅";
          });

          // Store the connected MAC for later retrieval
          await _saveConnectedMac(mac);

          debugPrint("✅ Successfully connected to: $mac");

          // Send a test command to verify printer is responsive
          try {
            final profile = await CapabilityProfile.load();
            final generator = Generator(PaperSize.mm80, profile);
            List<int> bytes = [];
            bytes += generator.reset();
            await PrintBluetoothThermal.writeBytes(bytes);
            debugPrint("✅ Printer is responsive");
          } catch (e) {
            debugPrint("⚠️ Test command failed: $e");
          }
        } else {
          throw Exception("Connection lost immediately");
        }
      } else {
        throw Exception("Connection failed");
      }
    } catch (e) {
      debugPrint("❌ Connection error: $e");
      setState(() {
        connected = false;
        connectedMac = null;
        isConnecting = false;
        statusMessage = "Connection failed ❌";
      });
    }
  }

  // MARK: - Disconnect
  Future<void> disconnect() async {
    try {
      debugPrint("🔌 Disconnecting...");
      await PrintBluetoothThermal.disconnect;

      setState(() {
        connected = false;
        connectedMac = null;
        statusMessage = "Disconnected";
      });

      await _clearConnectedMac();

      debugPrint("✅ Disconnected successfully");
    } catch (e) {
      debugPrint("❌ Disconnect error: $e");
      setState(() {
        connected = false;
        connectedMac = null;
      });
    }
  }

  // MARK: - Print Receipt
  Future<void> printReceipt() async {
    try {
      debugPrint("🖨️ Starting print job...");

      bool isConnected = await PrintBluetoothThermal.connectionStatus;

      if (!isConnected) {
        debugPrint("❌ Printer not connected");
        setState(() => statusMessage = "Printer not connected!");

        // Try to reconnect
        if (connectedMac != null) {
          debugPrint("🔄 Attempting to reconnect...");
          await connect(connectedMac!);
          isConnected = await PrintBluetoothThermal.connectionStatus;

          if (!isConnected) {
            return;
          }
        } else {
          return;
        }
      }

      setState(() => statusMessage = "Printing...");

      final profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm80, profile);
      List<int> bytes = [];
      bytes += generator.reset();

      debugPrint("🎨 Creating receipt image...");
      final img.Image receipt = await _createReceiptImage();

      debugPrint("📤 Converting to printer bytes...");
      bytes += generator.imageRaster(receipt);
      bytes += generator.feed(2);
      bytes += generator.cut();

      debugPrint("📤 Sending ${bytes.length} bytes to printer...");
      await PrintBluetoothThermal.writeBytes(bytes);

      setState(() => statusMessage = "Printed successfully 🖨️");
      debugPrint("✅ Print job completed");
    } catch (e) {
      debugPrint("❌ Print error: $e");
      setState(() => statusMessage = "Print failed: $e");
      Logger.log(e);
    }
  }

  // MARK: - Create Receipt Image
  Future<img.Image> _createReceiptImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = Size(576, 800); // 576px width for 80mm paper

    // White background
    final paint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Text styles with Khmer font support
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 24,
      fontFamily: 'NotoSansKhmer',
    );

    final boldStyle = textStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 28,
    );

    final headerStyle = textStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 32,
    );

    double yPosition = 20;

    // Company Header
    _drawText(canvas, "Your Company Name", 20, yPosition, headerStyle);
    yPosition += 40;

    _drawText(canvas, "Address Line Here", 20, yPosition, textStyle);
    yPosition += 35;

    _drawText(canvas, "Phone: +855 XX XXX XXX", 20, yPosition, textStyle);
    yPosition += 35;

    // Separator
    _drawText(canvas, "═" * 48, 20, yPosition, textStyle);
    yPosition += 35;

    // Customer & Invoice Info
    _drawText(canvas, "Customer: John Doe", 20, yPosition, boldStyle);
    yPosition += 35;

    _drawText(
      canvas,
      "Date: ${DateTime.now().toString().split(' ')[0]}",
      20,
      yPosition,
      boldStyle,
    );
    yPosition += 35;

    _drawText(canvas, "Invoice No: INV-001", 20, yPosition, boldStyle);
    yPosition += 40;

    // Items Header
    _drawText(canvas, "─" * 48, 20, yPosition, textStyle);
    yPosition += 30;

    _drawText(
      canvas,
      "#  Item         Qty  Price    Amount",
      20,
      yPosition,
      boldStyle,
    );
    yPosition += 30;

    _drawText(canvas, "─" * 48, 20, yPosition, textStyle);
    yPosition += 35;

    // Items
    _drawText(
      canvas,
      "1  Product A     2   \$10.00   \$20.00",
      20,
      yPosition,
      textStyle,
    );
    yPosition += 35;

    _drawText(
      canvas,
      "2  Product B     1   \$15.00   \$15.00",
      20,
      yPosition,
      textStyle,
    );
    yPosition += 35;

    _drawText(
      canvas,
      "3  សំលៀកបំពាក់    3   \$12.00   \$36.00",
      20,
      yPosition,
      textStyle,
    );
    yPosition += 40;

    // Totals
    _drawText(canvas, "═" * 48, 20, yPosition, textStyle);
    yPosition += 35;

    _drawText(
      canvas,
      "Subtotal:                    \$71.00",
      20,
      yPosition,
      boldStyle,
    );
    yPosition += 30;

    _drawText(
      canvas,
      "Discount (10%):              -\$7.10",
      20,
      yPosition,
      textStyle,
    );
    yPosition += 30;

    _drawText(
      canvas,
      "Tax (10%):                    \$6.39",
      20,
      yPosition,
      textStyle,
    );
    yPosition += 35;

    _drawText(canvas, "═" * 48, 20, yPosition, textStyle);
    yPosition += 35;

    final totalStyle = textStyle.copyWith(
      fontWeight: FontWeight.bold,
      fontSize: 30,
    );
    _drawText(
      canvas,
      "TOTAL:                       \$70.29",
      20,
      yPosition,
      totalStyle,
    );
    yPosition += 50;

    // Footer
    _drawText(
      canvas,
      "សូមអរគុណ! Thank you for shopping!",
      20,
      yPosition,
      boldStyle,
    );
    yPosition += 35;

    final footerStyle = textStyle.copyWith(fontSize: 20);
    _drawText(
      canvas,
      "We look forward to serving you again! ❤️",
      20,
      yPosition,
      footerStyle,
    );
    yPosition += 40;

    _drawText(
      canvas,
      "Powered by Blue Technology Co., Ltd.",
      20,
      yPosition,
      footerStyle,
    );

    // Convert canvas to image
    final picture = recorder.endRecording();
    final uiImage = await picture.toImage(
      size.width.toInt(),
      size.height.toInt(),
    );
    final byteData = await uiImage.toByteData(format: ui.ImageByteFormat.png);

    // Convert to img.Image format
    final pngBytes = byteData!.buffer.asUint8List();
    return img.decodeImage(pngBytes)!;
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    TextStyle style,
  ) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  // MARK: - SharedPreferences Methods
  Future<void> _saveConnectedMac(String mac) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('connected_printer_mac', mac);
      debugPrint("💾 Saved connected MAC: $mac");
    } catch (e) {
      debugPrint("❌ Failed to save MAC: $e");
    }
  }

  Future<String?> _getStoredConnectedMac() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final mac = prefs.getString('connected_printer_mac');
      debugPrint("📖 Retrieved stored MAC: $mac");
      return mac;
    } catch (e) {
      debugPrint("❌ Failed to retrieve MAC: $e");
      return null;
    }
  }

  Future<void> _clearConnectedMac() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('connected_printer_mac');
      debugPrint("🗑️ Cleared stored MAC");
    } catch (e) {
      debugPrint("❌ Failed to clear MAC: $e");
    }
  }

  // MARK: - UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bluetooth Printer Example"),
        actions: [
          if (connected)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: checkExistingConnection,
              tooltip: "Check Connection",
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Connection Status Card
            Card(
              color: connected ? Colors.green.shade50 : Colors.grey.shade100,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      connected ? Icons.check_circle : Icons.error_outline,
                      color: connected ? Colors.green : Colors.grey,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            connected ? "Connected" : "Not Connected",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: connected ? Colors.green : Colors.grey,
                            ),
                          ),
                          if (connectedMac != null)
                            Text(
                              "MAC: $connectedMac",
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                    if (connected)
                      IconButton(
                        icon: const Icon(Icons.bluetooth_disabled),
                        onPressed: disconnect,
                        tooltip: "Disconnect",
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Scan Button
            ElevatedButton.icon(
              onPressed: scanDevices,
              icon: const Icon(Icons.bluetooth_searching),
              label: const Text("Scan Paired Printers"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
            const SizedBox(height: 16),

            // Device List
            Expanded(
              child: devices.isEmpty
                  ? const Center(child: Text("No paired devices found"))
                  : ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final d = devices[index];
                        final isConnectedDevice = connectedMac == d.macAdress;

                        return Card(
                          color: isConnectedDevice
                              ? Colors.green.shade50
                              : Colors.white,
                          child: ListTile(
                            leading: Icon(
                              isConnectedDevice
                                  ? Icons.print
                                  : Icons.print_outlined,
                              color: isConnectedDevice
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            title: Text(
                              d.name,
                              style: TextStyle(
                                fontWeight: isConnectedDevice
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text(d.macAdress),
                            trailing: ElevatedButton(
                              onPressed: isConnecting
                                  ? null
                                  : () => connect(d.macAdress),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isConnectedDevice
                                    ? Colors.green
                                    : null,
                              ),
                              child: Text(
                                isConnectedDevice ? "Connected" : "Connect",
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            // Print Button
            ElevatedButton.icon(
              onPressed: connected ? printReceipt : null,
              icon: const Icon(Icons.print),
              label: const Text("Print Test Receipt"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: connected ? Colors.green : null,
              ),
            ),

            const SizedBox(height: 16),

            // Status Message
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  if (isConnecting)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (isConnecting) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      statusMessage,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
