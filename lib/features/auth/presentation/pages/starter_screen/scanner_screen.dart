import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:image_picker/image_picker.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/mixins/message_mixin.dart';
import 'package:salesforce/core/presentation/widgets/app_bar_widget.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/loading_page_widget.dart';
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
  CameraController? cameraController;

  final BarcodeScanner barcodeScanner = BarcodeScanner();
  final ImagePicker imagePicker = ImagePicker();
  bool isScanning = false;
  bool isUploading = false;
  late List<CameraDescription> _cameras;
  bool _isProcessing = false;
  bool isDetected = false;

  final Map<DeviceOrientation, int> _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        return;
      }

      final camera = _cameras.first;

      cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.yuv420,
      );
      await cameraController!.initialize();

      // Add delay before starting image stream on iOS
      if (Platform.isIOS) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      await cameraController!.startImageStream(_processCameraImage);

      if (mounted) setState(() {});
    } catch (e) {
      Logger.log(e.toString());
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    if (_isProcessing || !mounted) return;
    _isProcessing = true;

    try {
      final inputImage = _convertToInputImage(image);
      if (inputImage == null) {
        _isProcessing = false;
        return;
      }

      final barcodes = await barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty && mounted) {
        final code = barcodes.first.rawValue ?? '';

        if (isURL(code) && !isDetected) {
          setState(() {
            isDetected = true; // Trigger highlight animation
          });

          // Stop image stream immediately
          await cameraController?.stopImageStream();

          // Wait for animation to play
          await Future.delayed(const Duration(milliseconds: 800));

          if (!mounted) return;
          Navigator.of(context).pop(code);
        }
      }
    } catch (e) {
      debugPrint('Error processing image: $e');
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _convertToInputImage(CameraImage image) {
    final camera = cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;

    final deviceOrientation = cameraController!.value.deviceOrientation;
    final rotationCompensation = _orientations[deviceOrientation] ?? 0;

    InputImageRotation rotation;
    if (Platform.isIOS) {
      rotation =
          InputImageRotationValue.fromRawValue(sensorOrientation) ??
          InputImageRotation.rotation0deg;
    } else {
      int adjustedRotation;
      if (camera.lensDirection == CameraLensDirection.front) {
        adjustedRotation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        adjustedRotation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation =
          InputImageRotationValue.fromRawValue(adjustedRotation) ??
          InputImageRotation.rotation0deg;
    }

    try {
      if (Platform.isIOS) {
        // Fixed iOS implementation
        return _createInputImageForIOS(image, rotation);
      } else {
        // Android implementation
        final bytes = convertYUV420ToNV21(image);
        final metadata = InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: rotation,
          format: InputImageFormat.nv21,
          bytesPerRow: image.planes[0].bytesPerRow,
        );

        return InputImage.fromBytes(bytes: bytes, metadata: metadata);
      }
    } catch (e) {
      Logger.log(e.toString());
      return null;
    }
  }

  InputImage? _createInputImageForIOS(
    CameraImage image,
    InputImageRotation rotation,
  ) {
    try {
      if (image.planes.isEmpty) {
        return null;
      }

      final plane = image.planes.first;

      // Create metadata with correct format
      final metadata = InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.yuv420,
        bytesPerRow: plane.bytesPerRow,
      );

      return InputImage.fromBytes(bytes: plane.bytes, metadata: metadata);
    } catch (e) {
      return null;
    }
  }

  Uint8List convertYUV420ToNV21(CameraImage image) {
    final int width = image.width;
    final int height = image.height;

    // This is primarily for Android
    if (image.planes.length < 3) {
      throw Exception(
        'Invalid YUV image format: expected 3 planes, got ${image.planes.length}',
      );
    }

    final int uvRowStride = image.planes[1].bytesPerRow;
    final int uvPixelStride = image.planes[1].bytesPerPixel!;

    final ySize = width * height;
    final uvSize = width * height ~/ 2;

    final nv21 = Uint8List(ySize + uvSize);

    // Copy Y plane
    final yPlane = image.planes[0].bytes;
    nv21.setRange(0, ySize, yPlane);

    // Copy UV planes interleaved as VU for Android
    int uvIndex = ySize;
    final uPlane = image.planes[1].bytes;
    final vPlane = image.planes[2].bytes;

    for (int i = 0; i < height ~/ 2; i++) {
      for (int j = 0; j < width ~/ 2; j++) {
        final uPos = i * uvRowStride + j * uvPixelStride;
        final vPos = i * uvRowStride + j * uvPixelStride;
        nv21[uvIndex++] = vPlane[vPos];
        nv21[uvIndex++] = uPlane[uPos];
      }
    }

    return nv21;
  }

  bool isURL(String result) {
    final uri = Uri.tryParse(result);
    return uri != null &&
        (uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https'));
  }

  Future<String?> processImage(String imagePath) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodes = await barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        final code = barcodes.first.rawValue ?? '';

        if (isURL(code) && !isDetected) {
          setState(() {
            isDetected = true;
          });

          await Future.delayed(const Duration(milliseconds: 800));

          return code;
        }
      }

      return null;
    } catch (e) {
      Logger.log("Image processing error: $e");
      return null;
    }
  }

  Future<void> uploadFromGallery() async {
    setState(() {
      isUploading = true;
    });

    try {
      final XFile? pickedFile = await imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
      );

      if (pickedFile != null) {
        final result = await processImage(pickedFile.path);
        if (result != null && mounted) {
          Navigator.pop(context, result);
          return;
        } else {
          showErrorMessage("Invalid QR code");
        }
      }
    } catch (e) {
      Logger.log("Gallery upload error: $e");
      showErrorMessage("Invalid QR code");
    }

    setState(() {
      isUploading = false;
    });
  }

  @override
  void dispose() {
    _isProcessing = true; // Prevent further processing
    barcodeScanner.close();
    if (cameraController?.value.isStreamingImages ?? false) {
      cameraController?.stopImageStream();
    }
    cameraController?.dispose();
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
              onPressed: isUploading ? null : () => uploadFromGallery(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        if (cameraController == null || !cameraController!.value.isInitialized)
          const LoadingPageWidget()
        else
          Positioned.fill(child: CameraPreview(cameraController!)),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutBack,
                width: scaleFontSize(250),
                height: scaleFontSize(250),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  border: Border.all(
                    color: isDetected ? success : white,
                    width: isDetected ? 4 : 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isDetected
                      ? [
                          BoxShadow(
                            color: success.withAlpha((0.6 * 255).toInt()),
                            blurRadius: 20,
                            spreadRadius: 4,
                          ),
                        ]
                      : [],
                ),
              ),
              AnimatedScale(
                scale: isDetected ? 1.3 : 0.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInCirc,
                child: Icon(
                  Icons.qr_code_2,
                  size: scaleFontSize(200),
                  color: white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
