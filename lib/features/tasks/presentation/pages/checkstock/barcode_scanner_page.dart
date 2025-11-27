import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:salesforce/core/utils/size_config.dart';

class BarcodeScannerPage extends StatefulWidget {
  const BarcodeScannerPage({super.key});
  static const String routeName = "scan";
  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  final MobileScannerController controller = MobileScannerController();
  BarcodeCapture? lastCapture;

  Barcode? _barcode;

  Widget _barcodePreview(Barcode? value) {
    if (value == null) {
      return const Text(
        'Scan something!',
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      value.displayValue ?? 'No display value.',
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  bool isQRCode = true;
  bool _isProcessing = false;

  void _handleBarcode(BarcodeCapture barcodes) {
    if (_isProcessing) return;

    final first = barcodes.barcodes.firstOrNull;
    final box = first;

    if (first != null && box != null && mounted) {
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      final Size screenSize = renderBox?.size ?? Size.zero;

      final frameWidth = isQRCode ? 250.0 : 300.0;
      final frameHeight = isQRCode ? 250.0 : 100.0;

      final left = (screenSize.width - frameWidth) / 2;
      final top = (screenSize.height - frameHeight) / 2;
      final scanRect = Rect.fromLTWH(left, top, frameWidth, frameHeight);

      final isInside = box.corners.every((corner) => scanRect.contains(corner));

      if (!isInside) return;

      _isProcessing = true;

      setState(() {
        _barcode = first;
        isQRCode = first.format == BarcodeFormat.qrCode;
      });

      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.of(context).pop(first.displayValue);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Code')),
      body: Stack(
        children: [
          MobileScanner(controller: controller, onDetect: _handleBarcode),

          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final height = constraints.maxHeight;

                final frameWidth = isQRCode ? 250.0 : 350.0;
                final frameHeight = isQRCode ? 250.0 : 150.0;

                final horizontalPadding =
                    (width - frameWidth) / scaleFontSize(2.25);
                final verticalPadding =
                    (height - frameHeight) / scaleFontSize(2.15);

                return Stack(
                  children: [
                    // Top
                    Positioned(
                      top: 0.scale,
                      left: 0.scale,
                      right: 0.scale,
                      height: scaleFontSize(verticalPadding),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    // Bottom
                    Positioned(
                      bottom: 0.scale,
                      left: 0.scale,
                      right: 0.scale,
                      height: scaleFontSize(verticalPadding),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    // Left
                    Positioned(
                      top: scaleFontSize(verticalPadding),
                      bottom: scaleFontSize(verticalPadding),
                      left: 0.scale,
                      width: scaleFontSize(horizontalPadding),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                    // Right
                    Positioned(
                      top: scaleFontSize(verticalPadding),
                      bottom: scaleFontSize(verticalPadding),
                      right: 0.scale,
                      width: scaleFontSize(horizontalPadding),
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Bottom scanned result display
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              alignment: Alignment.bottomCenter,
              height: 100.scale,
              color: const Color.fromRGBO(0, 0, 0, 0.4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(child: Center(child: _barcodePreview(_barcode))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
