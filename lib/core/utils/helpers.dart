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
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:salesforce/core/constants/app_assets.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/custom_alert_dialog_widget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/date_extensions.dart';
import 'package:salesforce/core/utils/fllutter_html_to_pdf.dart';
import 'package:salesforce/core/utils/logger.dart';
import 'package:salesforce/core/utils/message_helper.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/features/more/presentation/pages/sale_order_history_detail/receipt_printer/thermal_printer.dart';
import 'package:salesforce/infrastructure/external_services/location/geolocator_location_service.dart';
import 'package:salesforce/injection_container.dart';
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

  // static int toInt(value) {
  //   if (value == null || value == "") {
  //     return 0;
  //   }

  //   String v = value.toString().replaceAll("\$", "");
  //   v = v.replaceAll("%", "");
  //   return int.parse(v);
  // }

  static int toInt(dynamic value) {
    if (value == null || value.toString().trim().isEmpty) {
      return 0;
    }

    try {
      String v = value.toString().trim();

      v = v.replaceAll(RegExp(r'[^0-9\.\-]'), '');

      if (v.isEmpty || v == "-" || v == "." || v == "-.") {
        return 0;
      }

      double d = double.parse(v);
      return d.toInt();
    } catch (e) {
      return 0;
    }
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
  // static void showMessage({
  //   required String msg,
  //   MessageStatus status = MessageStatus.success,
  //   SnackBarAction? action,
  //   bool closeIcon = true,
  // }) {
  //   final scaffold = kAppScaffoldMsgKey.currentState;
  //   if (scaffold == null) return;

  //   // Prevent showing same message repeatedly
  //   if (_lastMessage == msg) return;
  //   _lastMessage = msg;

  //   Color color = success;
  //   if (status == MessageStatus.warning) {
  //     color = warning;
  //   } else if (status == MessageStatus.errors) {
  //     color = error;
  //   }
  //   scaffold.clearSnackBars(); // Hide previous snackbars
  //   scaffold.showSnackBar(
  //     SnackBar(
  //       backgroundColor: color,
  //       content: TextWidget(text: msg, color: white),
  //       showCloseIcon: closeIcon,
  //       closeIconColor: white,
  //       behavior: SnackBarBehavior.floating,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(scaleFontSize(8)),
  //       ),
  //       action: action,
  //     ),
  //   );

  //   // Reset last message after duration
  //   Future.delayed(const Duration(seconds: 3), () {
  //     _lastMessage = null;
  //   });
  // }

  static void showMessage({
    required String msg,
    MessageStatus status = MessageStatus.success,
    SnackBarAction? action,
    bool closeIcon = true,
    Duration? duration,
  }) {
    final scaffold = kAppScaffoldMsgKey.currentState;
    if (scaffold == null) return;

    if (_lastMessage == msg) return;
    _lastMessage = msg;

    final messageConfig = MessageHelper.getMessageConfig(status);

    scaffold.clearSnackBars();
    scaffold.showSnackBar(
      MessageHelper.buildBeautifulSnackBar(
        msg: msg,
        color: messageConfig.color,
        icon: messageConfig.icon,
        action: action,
        closeIcon: closeIcon,
        duration: duration ?? messageConfig.duration,
      ),
    );

    // Reset last message after duration
    Future.delayed(duration ?? messageConfig.duration, () {
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

  static void showNoInternetDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                kConnectInternetLottie,
                width: 200,
                height: 200,
                fit: BoxFit.cover,
                repeat: true,
              ),
              const SizedBox(height: 16),
              TextWidget(
                text: 'No Internet Connection',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                textAlign: TextAlign.center,
              ),
              Helpers.gapH(scaleFontSize(12)),

              TextWidget(
                text: 'Please check your internet connection and try again.',
                fontSize: 14,
                color: Colors.grey[600],
                textAlign: TextAlign.center,
              ),
              Helpers.gapH(scaleFontSize(24)),
              BtnWidget(
                onPressed: () => Navigator.pop(context),
                title: "Okay",
                bgColor: mainColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<BitmapDescriptor> createPinMarkerWithImageAndTitle(
    String imageUrl, {
    required String title,
    int size = 140,
    Color pinColor = primary,
    Color borderColor = white,
    double borderWidth = 3.5,
    Color shadowColor = borderClr,
    double shadowBlurRadius = 8.0,
    Offset shadowOffset = const Offset(0, 3),
    double fontSize = 30,
    Color textColor = white,
    double maxTextWidth = 350,
    double finalMarkerHeight = 55,
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

    // Pre-calculate text dimensions
    final textStyle = ui.TextStyle(
      color: textColor,
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
    );

    final tempParagraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '...',
    );

    final tempParagraphBuilder = ui.ParagraphBuilder(tempParagraphStyle)
      ..pushStyle(textStyle)
      ..addText(title);
    final tempParagraph = tempParagraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: maxTextWidth));

    final double actualTextWidth = math.min(
      tempParagraph.maxIntrinsicWidth,
      maxTextWidth,
    );

    const double textPaddingH = 18.0;
    const double textPaddingV = 16.0;
    const double imageCircleSize = 70.0; // Size of the circular image at top
    const double pinTipHeight = 35.0; // Height of bottom pointed part

    final double labelWidth = math.max(
      actualTextWidth + textPaddingH * 2,
      imageCircleSize + 30,
    );
    final double labelHeight = tempParagraph.height + textPaddingV * 2;

    // Canvas dimensions
    final double canvasWidth = labelWidth;
    final double canvasHeight =
        imageCircleSize / 2 + labelHeight + pinTipHeight + 5;

    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Paint paint = Paint()
      ..isAntiAlias = true
      ..filterQuality = FilterQuality.high;

    // Create the full marker path: circle at top + rounded rectangle + triangle at bottom
    final Path fullMarkerPath = Path();

    final double centerX = canvasWidth / 2;
    final double circleRadius = imageCircleSize / 2;
    final double circleCenterY = circleRadius + 2;

    // Top circle
    fullMarkerPath.addOval(
      Rect.fromCircle(
        center: Offset(centerX, circleCenterY),
        radius: circleRadius,
      ),
    );

    // Rounded rectangle body
    final double rectTop = circleCenterY + circleRadius * 0.6;
    final double rectHeight = labelHeight;
    final RRect bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, rectTop, labelWidth, rectHeight),
      const Radius.circular(12),
    );
    fullMarkerPath.addRRect(bodyRect);

    // Bottom triangle pointer
    final double triangleTop = rectTop + rectHeight;
    final double triangleWidth = 28.0;

    fullMarkerPath.moveTo(centerX - triangleWidth / 2, triangleTop);
    fullMarkerPath.lineTo(centerX, triangleTop + pinTipHeight);
    fullMarkerPath.lineTo(centerX + triangleWidth / 2, triangleTop);
    fullMarkerPath.close();

    // Draw shadow
    final Paint shadowPaint = Paint()
      ..color = shadowColor
      ..isAntiAlias = true
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlurRadius);
    canvas.drawPath(fullMarkerPath.shift(shadowOffset), shadowPaint);

    // Draw main pin color
    paint.color = pinColor;
    paint.style = PaintingStyle.fill;
    canvas.drawPath(fullMarkerPath, paint);

    // Subtle gradient overlay for depth
    final Paint gradientOverlay = Paint()
      ..shader = ui.Gradient.linear(
        Offset(centerX, circleCenterY),
        Offset(centerX, triangleTop + pinTipHeight),
        [white.withValues(alpha: .15), Colors.transparent],
        [0.0, 0.6],
      )
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;
    canvas.drawPath(fullMarkerPath, gradientOverlay);

    // Draw user image or icon in the circle
    final double imageRadius = circleRadius - borderWidth;

    if (userImage != null) {
      // Clip and draw user image
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
        ..filterQuality = FilterQuality.high;

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

      // White border around image
      final Paint imageBorderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..isAntiAlias = true;
      canvas.drawCircle(
        Offset(centerX, circleCenterY),
        imageRadius,
        imageBorderPaint,
      );
    } else {
      // White circle background
      final Paint whiteBgPaint = Paint()
        ..color = white
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawCircle(
        Offset(centerX, circleCenterY),
        imageRadius,
        whiteBgPaint,
      );

      // Draw simple person icon
      final Paint iconPaint = Paint()
        ..color = pinColor.withValues(alpha: .8)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      final double iconScale = imageRadius * 0.65;
      final double headRadius = iconScale * 0.32;
      final double headCenterY = circleCenterY - iconScale * 0.25;

      // Head
      canvas.drawCircle(Offset(centerX, headCenterY), headRadius, iconPaint);

      // Body
      final Path bodyPath = Path();
      final double shoulderWidth = iconScale * 0.6;
      final double bodyHeight = iconScale * 0.55;
      final double bodyTop = headCenterY + headRadius + iconScale * 0.08;

      bodyPath.moveTo(centerX - shoulderWidth / 2, bodyTop);
      bodyPath.quadraticBezierTo(
        centerX - shoulderWidth / 2.5,
        bodyTop + bodyHeight * 0.5,
        centerX - shoulderWidth / 3.2,
        bodyTop + bodyHeight,
      );
      bodyPath.lineTo(centerX + shoulderWidth / 3.2, bodyTop + bodyHeight);
      bodyPath.quadraticBezierTo(
        centerX + shoulderWidth / 2.5,
        bodyTop + bodyHeight * 0.5,
        centerX + shoulderWidth / 2,
        bodyTop,
      );
      bodyPath.close();

      canvas.drawPath(bodyPath, iconPaint);

      // Border around white circle
      final Paint iconBorderPaint = Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth
        ..isAntiAlias = true;
      canvas.drawCircle(
        Offset(centerX, circleCenterY),
        imageRadius,
        iconBorderPaint,
      );
    }

    // Draw text in the middle section
    final paragraphStyle = ui.ParagraphStyle(
      textAlign: TextAlign.center,
      maxLines: 2,
      ellipsis: '...',
    );

    final paragraphBuilder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(textStyle)
      ..addText(title);

    final ui.Paragraph paragraph = paragraphBuilder.build()
      ..layout(ui.ParagraphConstraints(width: labelWidth - textPaddingH * 2));

    final double textOffsetX = textPaddingH;
    final double textOffsetY = rectTop + (rectHeight - paragraph.height) / 2;
    canvas.drawParagraph(paragraph, Offset(textOffsetX, textOffsetY));

    // Create final image
    final ui.Image markerAsImage = await pictureRecorder.endRecording().toImage(
      canvasWidth.toInt(),
      canvasHeight.toInt(),
    );
    final ByteData? byteData = await markerAsImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    final Uint8List bytes = byteData!.buffer.asUint8List();

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

    final startTime = format.parse(start.trim());
    final endTime = format.parse(end.trim());

    final diff = endTime.difference(startTime);

    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;
    final seconds = diff.inSeconds % 60;

    final parts = <String>[];

    if (hours > 0) {
      parts.add("${hours.toString().padLeft(2, '0')}h");
    }
    if (minutes > 0 || hours > 0) {
      parts.add("${minutes.toString().padLeft(2, '0')}m");
    }
    parts.add("${seconds.toString().padLeft(2, '0')}s");

    return parts.join(" ");
  }

  static ConnectionType stringToConnectionType(String type) {
    switch (type.toLowerCase()) {
      case 'bluetooth':
        return ConnectionType.bluetooth;
      case 'usb':
        return ConnectionType.usb;
      case 'network':
        return ConnectionType.network;
      default:
        return ConnectionType.ble;
    }
  }
}
