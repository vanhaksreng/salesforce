// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:bluetooth_print_plus/bluetooth_print_plus.dart';
// import 'package:flutter/services.dart';
// import 'package:image/image.dart' as img;

// class BluetoothPrintTestPage extends StatefulWidget {
//   const BluetoothPrintTestPage({super.key});

//   @override
//   State<BluetoothPrintTestPage> createState() => _BluetoothPrintTestPageState();
// }

// class _BluetoothPrintTestPageState extends State<BluetoothPrintTestPage> {
//   final bluetooth = BluetoothPrintPlus.connectState;
//   List<BluetoothDevice> devices = [];
//   BluetoothDevice? selectedDevice;
//   bool isScanning = false;
//   bool isPrinting = false;

//   @override
//   void initState() {
//     super.initState();
//     _initPrinter();
//   }

//   Future<void> _initPrinter() async {
//     await bluetooth.startScan(timeout: const Duration(seconds: 4));
//     final list = await bluetooth.getBondedDevices();
//     setState(() {
//       devices = list;
//     });
//   }

//   Future<void> _connectAndPrint() async {
//     if (selectedDevice == null) return;
//     setState(() => isPrinting = true);

//     await bluetooth.connect(selectedDevice!);
//     await Future.delayed(const Duration(seconds: 1));

//     // Generate test image with Khmer text
//     final pngBytes = await _createKhmerTestImage();

//     await bluetooth.printImage(Uint8List.fromList(pngBytes));

//     await Future.delayed(const Duration(seconds: 1));
//     await bluetooth.disconnect();

//     setState(() => isPrinting = false);
//   }

//   Future<Uint8List> _createKhmerTestImage() async {
//     const text = 'សូមអរគុណសម្រាប់ការទិញទំនិញរបស់អ្នក!\nThank you!';
//     const width = 384;
//     const height = 200;

//     final recorder = ui.PictureRecorder();
//     final canvas = Canvas(recorder);
//     final paint = Paint()..color = Colors.white;
//     canvas.drawRect(
//       const Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
//       paint,
//     );

//     // Load Khmer font
//     final fontLoader = FontLoader('NotoSansKhmer');
//     final fontData = await rootBundle.load(
//       'assets/fonts/NotoSansKhmer-Regular.ttf',
//     );
//     fontLoader.addFont(Future.value(fontData));
//     await fontLoader.load();

//     final textStyle = const TextStyle(
//       fontSize: 28,
//       fontFamily: 'NotoSansKhmer',
//       color: Colors.black,
//     );

//     final tp = TextPainter(
//       text: const TextSpan(
//         text: text,
//         style: TextStyle(
//           fontSize: 28,
//           fontFamily: 'NotoSansKhmer',
//           color: Colors.black,
//         ),
//       ),
//       textAlign: TextAlign.center,
//       textDirection: TextDirection.ltr,
//     );
//     tp.layout(maxWidth: width.toDouble());
//     tp.paint(canvas, Offset((width - tp.width) / 2, 50));

//     final picture = recorder.endRecording();
//     final image = await picture.toImage(width, height);
//     final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//     return byteData!.buffer.asUint8List();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Bluetooth Print Test')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 setState(() => isScanning = true);
//                 await bluetooth.startScan(timeout: const Duration(seconds: 4));
//                 final list = await bluetooth.getBondedDevices();
//                 setState(() {
//                   devices = list;
//                   isScanning = false;
//                 });
//               },
//               child: isScanning
//                   ? const Text('Scanning...')
//                   : const Text('Scan Devices'),
//             ),
//             const SizedBox(height: 12),
//             DropdownButton<BluetoothDevice>(
//               value: selectedDevice,
//               isExpanded: true,
//               hint: const Text('Select Printer'),
//               items: devices.map((d) {
//                 return DropdownMenuItem(
//                   value: d,
//                   child: Text('${d.name ?? "Unknown"} (${d.address})'),
//                 );
//               }).toList(),
//               onChanged: (val) => setState(() => selectedDevice = val),
//             ),
//             const SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: isPrinting ? null : _connectAndPrint,
//               child: isPrinting
//                   ? const Text('Printing...')
//                   : const Text('Print Test'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
