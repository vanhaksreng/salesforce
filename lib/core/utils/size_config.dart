import 'package:flutter/material.dart';

class SizeConfig {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static Orientation? orientation;

  static double shortDimension = 0;
  static double longDimension = 0;

  // Use consistent design guidelines
  static const designWidth = 375; // iPhone design width
  static const designHeight = 812; // iPhone design height

  static bool _isInitialized = false;

  void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);

    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    orientation = _mediaQueryData.orientation;

    shortDimension = screenWidth < screenHeight ? screenWidth : screenHeight;
    longDimension = screenWidth < screenHeight ? screenHeight : screenWidth;

    _isInitialized = true;
  }

  static bool get isInitialized => _isInitialized;
}

// Get proportionate height based on design height
double getScreenHeight(double inputHeight) {
  if (!SizeConfig.isInitialized) return inputHeight;
  return (inputHeight / SizeConfig.designHeight) * SizeConfig.screenHeight;
}

// Get proportionate width based on design width
double getScreenWidth(double inputWidth) {
  if (!SizeConfig.isInitialized) return inputWidth;
  return (inputWidth / SizeConfig.designWidth) * SizeConfig.screenWidth;
}

Size getPreferredSize({double height = 85}) {
  return Size.fromHeight(getScreenHeight(height));
}

// Scale based on screen density (good for fonts/icons)
double scale(double size) {
  if (!SizeConfig.isInitialized) return size;
  return SizeConfig.shortDimension / SizeConfig.designWidth * size;
}

// Font scaling with factor control
double scaleFontSize(double size, [double factor = 0.5]) {
  if (!SizeConfig.isInitialized) return size;
  return size + (scale(size) - size) * factor;
}

extension ScaleInt on int {
  double get scale {
    return scaleFontSize(toDouble());
  }
}

// Helper extensions for easier usage
extension ResponsiveInt on int {
  double get w => getScreenWidth(toDouble());
  double get h => getScreenHeight(toDouble());
  double get sp => scaleFontSize(toDouble());
}

extension ResponsiveDouble on double {
  double get w => getScreenWidth(this);
  double get h => getScreenHeight(this);
  double get sp => scaleFontSize(this);
}
