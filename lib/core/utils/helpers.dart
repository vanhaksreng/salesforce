import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as https;
import 'package:http/io_client.dart';
import 'package:image/image.dart' as img;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/custom_alert_dialog_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/fllutter_html_to_pdf.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/injection_container.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/realm/scheme/general_schemas.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:salesforce/core/constants/app_styles.dart';

class Helpers {
  static final Map<double, Widget> _heightCache = {};
  static final Map<double, Widget> _widthCache = {};

  static String? _lastMessage;

  // Khmer Unicode range
  static final khmerRegex = RegExp(r'[\u1780-\u17FF]+');

  static bool isKhmer(String text) {
    final khmerRegex = RegExp(r'[\u1780-\u17FF]');
    return khmerRegex.hasMatch(text);
  }

  static String? getFontFamily(String text) {
    if (isKhmer(text)) {
      return 'Siemreap';
    } else {
      return 'DMSans';
    }
  }

  static exception(T) => throw Exception(T.message);
  static BoxDecoration dropDownDecoration = BoxDecoration(
    border: Border.all(color: Colors.grey, width: 1),
    borderRadius: const BorderRadius.all(Radius.circular(appSpace - 3)),
  );

  static Widget gapH(double h) {
    return _heightCache.putIfAbsent(
      h,
      () => SizedBox(height: scaleFontSize(h)),
    );
  }

  static Widget gapW(double w) {
    return _widthCache.putIfAbsent(w, () => SizedBox(width: scaleFontSize(w)));
  }

  // static double toDouble(value) {
  //   if (value == null || value == "" || value == "-") {
  //     return 0;
  //   }

  //   String v = value.toString().replaceAll("\$", "");
  //   v = v.replaceAll("%", "");
  //   v = v.replaceAll(",", "");
  //   v = v.replaceAll(",", "");
  //   // v = v.replaceAll("-", "");
  //   return double.parse(v);
  // }

  static double toDouble(dynamic value) {
    if (value == null) return 0;

    String v = value.toString().trim();

    if (v.isEmpty || v == "-") return 0;

    // Remove unwanted characters like $ % , spaces, letters except dot and minus sign
    v = v.replaceAll(RegExp(r'[^0-9\.\-]'), '');

    // Handle cases where string is empty after removal
    if (v.isEmpty || v == "-" || v == "." || v == "-.") {
      return 0;
    }

    try {
      return double.parse(v);
    } catch (e) {
      return 0;
    }
  }

  static String toStrings(dynamic value) {
    if (value == null) {
      return "";
    }

    try {
      if (value is bool) {
        return value ? "true" : "false";
      }

      if (value is DateTime) {
        return value.toDateString();
      }

      if (value is List) {
        return value.join(", ");
      }

      if (value is Map) {
        return value.toString();
      }

      return value.toString().trim();
    } catch (e) {
      debugPrint('Error in toStrings: $e');
      return "";
    }
  }

  static int toInt(value) {
    if (value == null || value == "") {
      return 0;
    }

    String v = value.toString().replaceAll("\$", "");
    v = v.replaceAll("%", "");
    return int.parse(v);
  }

  static String rmZeroFormat(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 1);
  }

  static String getEmojiFlag(String emojiString) {
    const flagOffset = 0x1F1E6;
    const asciiOffset = 0x41;

    final firstChar = emojiString.codeUnitAt(0) - asciiOffset + flagOffset;
    final secondChar = emojiString.codeUnitAt(1) - asciiOffset + flagOffset;

    return String.fromCharCode(firstChar) + String.fromCharCode(secondChar);
  }

  //show messgae
  static void showMessage({
    required String msg,
    MessageStatus status = MessageStatus.success,
    SnackBarAction? action,
    bool closeIcon = true,
  }) {
    final scaffold = kAppScaffoldMsgKey.currentState;
    if (scaffold == null) return;

    // Prevent showing same message repeatedly
    if (_lastMessage == msg) return;
    _lastMessage = msg;

    Color color = success;
    if (status == MessageStatus.warning) {
      color = warning;
    } else if (status == MessageStatus.errors) {
      color = error;
    }
    scaffold.clearSnackBars(); // Hide previous snackbars
    scaffold.showSnackBar(
      SnackBar(
        backgroundColor: color,
        content: TextWidget(text: msg, color: white),
        showCloseIcon: closeIcon,
        closeIconColor: primary,
        action: action,
      ),
    );

    // Reset last message after duration
    Future.delayed(const Duration(seconds: 3), () {
      _lastMessage = null;
    });
  }

  static bool isValidUuid(String uuidString) {
    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    return uuidPattern.hasMatch(uuidString);
  }

  static String generateDocumentNo(String userId) {
    final id = DateTime.now().millisecondsSinceEpoch;
    return "$userId-$id";
  }

  static int generateUniqueNumber({int digit = 3}) {
    final random = math.Random().nextInt(1000).toString().padLeft(digit, '0');

    final now = DateTime.now();
    return Helpers.toInt("${now.year}${now.month}${now.day}${random}1");
  }

  // static int generateSaleId(String scheduleId, {int digit = 5}) {
  //   final random = math.Random().nextInt(100).toString().padLeft(digit, '0');
  //   final now = DateTime.now();
  //   // return Helpers.toInt("${now.year}${now.month}${now.day}$scheduleId$random");
  // }

  static int generateSaleId(String scheduleId, {int digit = 5}) {
    final random = math.Random().nextInt(99999).toString().padLeft(digit, '0');
    final now = DateTime.now();
    final date =
        "${now.year % 100}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}";

    final hash = scheduleId.codeUnits.fold(0, (p, c) => (p + c) % 999999);

    return int.parse("$date$hash$random");
  }

  static String getSalePrefix(String documentType) {
    if (documentType == kSaleCreditMemo) {
      return "CR";
    } else if (documentType == kSaleOrder) {
      return "SO";
    }

    return "INV";
  }

  static SizedBox buildDivider() {
    return SizedBox(
      width: double.infinity,
      child: Divider(
        color: grey.withValues(alpha: 0.4),
        thickness: 1,
        height: 0,
      ),
    );
  }

  static showDialogAction(
    BuildContext context, {
    Function()? confirm,
    Function()? cancel,
    String labelAction = "confirmation",
    String subtitle = "Do you want me to go ahead with this?",
    String cancelText = "No, Not Yet",
    String confirmText = "Yes, I'm ready",
    bool canCancel = true,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AlertDialogBuilderWidget(
          subTitle: subtitle,
          labelAction: labelAction,
          confirm: confirm,
          cancelText: cancelText,
          confirmText: confirmText,
          canCancel: canCancel,
        ),
      ),
    );
  }

  static String formatSeparator(String value) {
    if (value.isEmpty) return '';

    try {
      final parts = value.trim().split('.');
      if (parts.isEmpty) return value;

      final intPart = parts[0].replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (match) => ',',
      );

      if (parts.length == 1) {
        return intPart;
      }

      final decimalPart = parts[1];
      return '$intPart.$decimalPart';
    } catch (e) {
      debugPrint('Error formatting number: $e');
      return value;
    }
  }

  static String formatNumberLink(
    dynamic value, {
    FormatType option = FormatType.amount,
  }) {
    final result = formatNumber(value, option: option);

    if (result.isEmpty || toDouble(result) == 0) {
      return "-";
    }

    return result;
  }

  static double formatNumberDb(
    dynamic value, {
    FormatType option = FormatType.amount,
  }) {
    final r = formatNumber(value, option: option, display: false);
    return toDouble(r);
  }

  static String formatNumber(
    dynamic value, {
    FormatType option = FormatType.quantity,
    bool display = true,
  }) {
    try {
      if (value == null || value.toString().isEmpty) {
        return "";
      }

      if (value == 0 || value == "-") return "";

      double number = Helpers.toDouble(value);
      int decimal = 0;

      ApplicationSetup? appSetup;
      try {
        appSetup = getIt<ApplicationSetup>();
      } catch (_) {
        appSetup = null;
      }

      if (appSetup == null) {
        return value.toString();
      }
      switch (option) {
        case FormatType.amount:
          decimal = appSetup.amountDecimal ?? 0;
          break;
        case FormatType.cost:
          decimal = appSetup.costDecimal ?? 0;
          break;
        case FormatType.price:
          decimal = appSetup.priceDecimal ?? 0;
          break;
        case FormatType.percentage:
          decimal = appSetup.percentageDecimal ?? 0;
          break;
        case FormatType.quantity:
          decimal = appSetup.quantityDecimal ?? 0;
          break;
        case FormatType.measurement:
          decimal = appSetup.measurementDecimal ?? 0;
        case FormatType.int:
          decimal = 0;
          break;
      }

      final formatted = number.toStringAsFixed(decimal);
      if (formatted == "0" && display) {
        return "";
      }

      if (!display) {
        return formatted;
      }

      if (option == FormatType.amount || option == FormatType.price) {
        if (number.isNegative) {
          return "-${currencySymble()}${formatSeparator(formatted).replaceAll("-", "")}";
        }

        return currencySymble() + formatSeparator(formatted);
      } else if (option == FormatType.quantity) {
        return formatSeparator(formatted).replaceAll(RegExp(r'([.]*0+)$'), '');
      } else if (option == FormatType.percentage) {
        return "${formatSeparator(formatted)}%";
      }

      return formatSeparator(formatted);
    } catch (e) {
      return "";
    }
  }

  static bool shouldReload(Object? value) {
    if (value == null) {
      return false;
    }

    // Check if value is of type ActionState
    if (value is! ActionState) {
      return false;
    }

    // Check specific action states
    if (value == ActionState.created || value == ActionState.updated) {
      return true;
    }
    return false;
  }

  static String getSaleDocumentNo({
    required String scheduleId,
    required String documentType,
  }) {
    final auth = getAuth();
    return "${Helpers.getSalePrefix(documentType)}${auth?.id}$scheduleId";
  }

  static String currencySymble() {
    return "\$";
  }

  static String capitalizeWords(String s) => s
      .split(' ')
      .map(
        (word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '',
      )
      .join(' ');

  static String calculateDistanceDisplay(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // print("lat1:$lat1, lon1:$lon1, lat2:$lat2, lon2:$lon2");

    final double distInMeters = Helpers.calculateDistanceInMeters(
      lat1,
      lon1,
      lat2,
      lon2,
    );

    final double distInKm = distInMeters / 1000;

    if (distInKm > 1) {
      return "${Helpers.formatNumberLink(distInKm, option: FormatType.quantity)}km";
    }

    return "${Helpers.formatNumberLink(distInMeters, option: FormatType.quantity)}m";
  }

  static double calculateDistanceInMeters(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return GeolocatorLocationService().getDistanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  // ======================== Image Download and Resize ========================
  static Future<Uint8List> downloadAndResizeImage(
    String imageUrl, {
    int width = 100,
  }) async {
    final ioClient = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    final client = IOClient(ioClient);

    final response = await client.get(Uri.parse(imageUrl));
    final Uint8List bytes = response.bodyBytes;

    final img.Image? baseSizeImage = img.decodeImage(bytes);
    final img.Image resized = img.copyResize(baseSizeImage!, width: width);

    return Uint8List.fromList(img.encodePng(resized));
  }

  static Future<Uint8List> downloadAndResizeImageForServer(
    String imageUrl, {
    int width = 100,
  }) async {
    try {
      final response = await https.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        throw Exception("Failed to load image from $imageUrl");
      }

      final Uint8List bytes = response.bodyBytes;
      final img.Image? baseSizeImage = img.decodeImage(bytes);
      if (baseSizeImage == null) throw Exception("Invalid image data");

      final img.Image resized = img.copyResize(baseSizeImage, width: width);
      return Uint8List.fromList(img.encodePng(resized));
    } catch (e) {
      debugPrint("Error downloading image: $e");
      rethrow;
    }
  }

  static Future<BitmapDescriptor> createPinMarkerWithImageAndTitle(
    String imageUrl, {
    required String title,
    int size = 150,
    Color pinColor = Colors.red,
    Color borderColor = Colors.white,
    double borderWidth = 4.0,
    Color shadowColor = Colors.black38,
    double shadowBlurRadius = 4.0,
    Offset shadowOffset = const Offset(1, 1),
    double fontSize = 46,
    Color textColor = Colors.red,
    double maxTextWidth = 400,
    double finalMarkerHeight = 42,
  }) async {
    Uint8List? resizedBytes;
    ui.Image? userImage;

    if (imageUrl.trim().isNotEmpty) {
      try {
        final int imageSize = (size ~/ 2) * 2;
        resizedBytes = await downloadAndResizeImage(imageUrl, width: imageSize);

        final codec = await ui.instantiateImageCodec(
          resizedBytes,
          targetWidth: imageSize,
          targetHeight: imageSize,
        );
        final frame = await codec.getNextFrame();
        userImage = frame.image;
      } catch (e) {
        Logger.log("createPinMarkerWithImageAndTitle Error: $e");
      }
    }

    // Pre-calculate text dimensions for auto-width
    final textStyle = ui.TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
    );

    final tempParagraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      maxLines: 1,
      ellipsis: '...',
    );

    final tempParagraphBuilder = ui.ParagraphBuilder(tempParagraphStyle)
      ..pushStyle(textStyle)
      ..addText(title);
    final tempParagraph = tempParagraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: maxTextWidth));

    // Calculate actual text width (auto-width)
    final double actualTextWidth = math.min(
      tempParagraph.maxIntrinsicWidth,
      maxTextWidth,
    );
    const double textPadding = 20.0;
    const double spacing = 10.0;

    // Calculate dynamic canvas dimensions based on text width
    final double markerWidth = size.toDouble();
    final double canvasWidth =
        markerWidth + spacing + actualTextWidth + textPadding;
    final double canvasHeight = math.max(
      size.toDouble(),
      tempParagraph.height + 40,
    );

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;

    final double circleRadius = markerWidth * 0.3;
    final double centerX = markerWidth / 2;
    final double circleCenterY = circleRadius + borderWidth;

    // Pin shape
    final Path pinPath = Path();
    pinPath.addOval(
      Rect.fromCircle(
        center: Offset(centerX, circleCenterY),
        radius: circleRadius,
      ),
    );
    pinPath.moveTo(centerX - circleRadius, circleCenterY);
    pinPath.lineTo(centerX, size.toDouble());
    pinPath.lineTo(centerX + circleRadius, circleCenterY);
    pinPath.close();

    // Shadow
    final Paint shadowPaint = Paint()
      ..color = shadowColor
      ..isAntiAlias = true
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlurRadius);
    canvas.drawPath(pinPath.shift(shadowOffset), shadowPaint);

    // Pin fill
    paint.color = pinColor;
    paint.style = PaintingStyle.fill;
    canvas.drawPath(pinPath, paint);

    // Border
    paint.color = borderColor;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = borderWidth;
    canvas.drawPath(pinPath, paint);

    // User image or person icon with proper background
    final double imageRadius = circleRadius - borderWidth;

    if (userImage != null) {
      // Draw user image
      canvas.save();
      final Path clipPath = Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(centerX, circleCenterY),
            radius: imageRadius,
          ),
        );

      canvas.clipPath(clipPath, doAntiAlias: true);

      final double imageDiameter = imageRadius * 2;
      final double scaleX = imageDiameter / userImage.width;
      final double scaleY = imageDiameter / userImage.height;
      final double scale = scaleX > scaleY ? scaleX : scaleY;

      final double imageWidth = userImage.width.toDouble();
      final double imageHeight = userImage.height.toDouble();

      final double imgOffsetX = centerX - (imageWidth * scale) / 2;
      final double imgOffsetY = circleCenterY - (imageHeight * scale) / 2;

      final Paint imagePaint = Paint()
        ..isAntiAlias = true
        ..filterQuality = FilterQuality.high
        ..blendMode = ui.BlendMode.srcOver;

      canvas.drawImageRect(
        userImage,
        Rect.fromLTWH(0, 0, imageWidth, imageHeight),
        Rect.fromLTWH(
          imgOffsetX,
          imgOffsetY,
          imageWidth * scale,
          imageHeight * scale,
        ),
        imagePaint,
      );

      canvas.restore();
    } else {
      // Draw background circle first for no-image case
      final Paint backgroundPaint = Paint()
        ..color =
            Colors.grey[200]! // Light grey background
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      canvas.drawCircle(
        Offset(centerX, circleCenterY),
        imageRadius,
        backgroundPaint,
      );

      // Draw person icon when no image is available
      final Paint iconPaint = Paint()
        ..color =
            Colors.grey[600]! // Darker grey for the icon
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      final double iconScale = imageRadius * 0.7; // Scale icon to fit nicely

      // Person head (circle)
      final double headRadius = iconScale * 0.25;
      final double headCenterY = circleCenterY - iconScale * 0.25;
      canvas.drawCircle(Offset(centerX, headCenterY), headRadius, iconPaint);

      // Person body/shoulders (more realistic shape)
      final Path bodyPath = Path();
      final double shoulderWidth = iconScale * 0.5;
      final double bodyHeight = iconScale * 0.45;
      final double bodyTop = headCenterY + headRadius + iconScale * 0.05;

      // Create a more person-like silhouette
      bodyPath.moveTo(centerX - shoulderWidth / 2, bodyTop); // Left shoulder
      bodyPath.lineTo(centerX + shoulderWidth / 2, bodyTop); // Right shoulder
      bodyPath.lineTo(
        centerX + shoulderWidth / 3,
        bodyTop + bodyHeight,
      ); // Right side
      bodyPath.lineTo(
        centerX - shoulderWidth / 3,
        bodyTop + bodyHeight,
      ); // Left side
      bodyPath.close();

      canvas.drawPath(bodyPath, iconPaint);
    }

    // Title text with auto-width (using actual text dimensions)
    final double textOffsetX = markerWidth + spacing;

    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.left,
      maxLines: 1,
      ellipsis: '...', // Handle text overflow
    );

    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(title);

    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: actualTextWidth + textPadding));

    final double textOffsetY = circleCenterY - (paragraph.height / 2);
    canvas.drawParagraph(paragraph, Offset(textOffsetX, textOffsetY));

    // Create image with dynamic dimensions
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final ByteData? byteData = await markerAsImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List bytes = byteData!.buffer.asUint8List();

    // Calculate proportional final width based on canvas width
    final double aspectRatio = canvasWidth / canvasHeight;
    final double finalMarkerWidth = finalMarkerHeight * aspectRatio;

    return BitmapDescriptor.bytes(
      bytes,
      width: finalMarkerWidth,
      height: finalMarkerHeight,
    );
  }

  // static Future<void> ensureLocationEnabled(BuildContext context) async {
  //   await Geolocator.requestPermission();
  //   bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();

  //   LocationPermission permission = await Geolocator.checkPermission();

  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //   }

  //   if ((permission == LocationPermission.denied ||
  //           permission == LocationPermission.deniedForever) &&
  //       context.mounted) {
  //     await showDialogAction(
  //       context,
  //       confirm: () async {
  //         await Geolocator.openAppSettings();
  //         if (!context.mounted) return;
  //         Navigator.of(context).pop(); // Close dialog
  //       },
  //       canCancel: false,
  //       confirmText: "Enable Now",
  //       labelAction: "Location Permission Disabled",
  //       subtitle: "Please enable location permission to continue.",
  //     );
  //     return;
  //   }

  //   if (!isServiceEnabled && context.mounted) {
  //     await showDialogAction(
  //       context,
  //       confirm: () async {
  //         await Geolocator.openLocationSettings();
  //         if (!context.mounted) return;
  //         Navigator.of(context).pop(); // Close dialog
  //       },
  //       canCancel: false,
  //       confirmText: "Enable Now",
  //       labelAction: "Location Service Disabled",
  //       subtitle: "Please enable location service to continue.",
  //     );

  //     return;
  //   }
  // }

  static Future<File?> generateToPdfDocument({
    required String htmlContent,
    required String documentNo,
  }) async {
    try {
      final directory = Platform.isIOS
          ? await getTemporaryDirectory()
          : await getApplicationDocumentsDirectory();

      final targetDirectory = directory.path;
      final targetName = "$documentNo-${DateTime.now().toDateTimeNameString()}";

      final resultFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent,
        targetDirectory,
        targetName,
      );
      return resultFile;
    } catch (e) {
      return null;
    }
  }

  static Future<File> createFileWithStringContent(
    String content,
    String path,
  ) async {
    return await File(path).writeAsString(content);
  }

  static File copyAndDeleteOriginalFile(
    String generatedFilePath,
    String targetDirectory,
    String targetName,
  ) {
    final fileOriginal = File(generatedFilePath);
    final fileCopy = File('$targetDirectory/$targetName.pdf');
    fileCopy.writeAsBytesSync(File.fromUri(fileOriginal.uri).readAsBytesSync());
    fileOriginal.delete();
    return fileCopy;
  }

  static String calculateDuration(String start, String end) {
    final format = DateFormat("HH:mm:ss");

    final startTime = format.parse(start);
    final endTime = format.parse(end);

    final diff = endTime.difference(startTime);

    // format as HH:mm:ss
    final hours = diff.inHours.toString().padLeft(2, '0');
    final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');

    return "$hours:$minutes:$seconds";
  }
}
