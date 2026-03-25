import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/localization/trans.dart';
import 'package:salesforce/theme/app_colors.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});
  static const String routeName = "scanner";

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with MessageMixin {
  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    returnImage: false,
  );

  final ImagePicker _imagePicker = ImagePicker();

  bool _isDetected = false;
  bool _isUploading = false;

  bool _isURL(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasScheme &&
        (uri.scheme == 'http' || uri.scheme == 'https');
  }

  Future<void> _handleBarcode(BarcodeCapture capture) async {
    if (_isDetected || !mounted) return;

    final barcode = capture.barcodes.firstOrNull;
    final code = barcode?.rawValue ?? '';

    if (_isURL(code)) {
      setState(() => _isDetected = true);

      // Brief pause so the success animation is visible
      await Future.delayed(const Duration(milliseconds: 600));

      await _scannerController.stop();

      if (!mounted) return;
      Navigator.of(context).pop(code);
    }
  }

  Future<void> _uploadFromGallery() async {
    setState(() => _isUploading = true);

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile == null) {
        setState(() => _isUploading = false);
        return;
      }

      // Analyse the chosen image with MobileScanner
      final result = await _scannerController.analyzeImage(pickedFile.path);

      if (!mounted) return;

      if (result != null) {
        final code = result.barcodes.firstOrNull?.rawValue ?? '';

        if (_isURL(code)) {
          setState(() => _isDetected = true);
          await Future.delayed(const Duration(milliseconds: 600));
          if (!mounted) return;
          Navigator.of(context).pop(code);
          return;
        }
      }

      showErrorMessage("Invalid QR code");
    } catch (e) {
      Logger.log("Gallery upload error: $e");
      showErrorMessage("Invalid QR code");
    }

    if (mounted) setState(() => _isUploading = false);
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWidget(title: greeting("Scanner")),
      body: _buildScanner(),
      persistentFooterButtons: [
        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: scaleFontSize(appSpace)),
            child: BtnWidget(
              bgColor: Colors.black54,
              textColor: white,
              icon: Icon(Icons.upload, size: scaleFontSize(26)),
              title: greeting("Upload Organization QR Code"),
              onPressed: _isUploading ? null : _uploadFromGallery,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        
        MobileScanner(
          controller: _scannerController,
          onDetect: _handleBarcode,
        ),

        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            width: scaleFontSize(250),
            height: scaleFontSize(250),
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                color: _isDetected ? success : white,
                width: _isDetected ? 4 : 2,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: _isDetected
                  ? [
                      BoxShadow(
                        color: success.withAlpha((0.6 * 255).toInt()),
                        blurRadius: 20,
                        spreadRadius: 4,
                      ),
                    ]
                  : [],
            ),
            child: AnimatedScale(
              scale: _isDetected ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInCirc,
              child: Icon(
                Icons.qr_code_2,
                size: scaleFontSize(180),
                color: white,
              ),
            ),
          ),
        ),

        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 100,
            color: const Color.fromRGBO(0, 0, 0, 0.4),
            alignment: Alignment.center,
            child: Text(
              _isDetected
                  ? greeting("QR Code detected!")
                  : greeting("Point your camera at a QR code"),
              overflow: TextOverflow.fade,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
}