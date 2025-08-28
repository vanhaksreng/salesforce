import 'package:flutter/material.dart';

class CustomSliderThumb extends SliderComponentShape {
  final double thumbRadius;
  final double value;

  CustomSliderThumb({required this.thumbRadius, required this.value});

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(center + const Offset(0, 2), thumbRadius, shadowPaint);

    // Gradient background
    final gradientPaint = Paint()
      ..shader = LinearGradient(
        colors: [Colors.blue.shade400, Colors.blue.shade600],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromCircle(center: center, radius: thumbRadius));
    canvas.drawCircle(center, thumbRadius, gradientPaint);

    // White inner circle
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, thumbRadius * 0.6, innerPaint);

    // Border
    final borderPaint = Paint()
      ..color = Colors.blue.shade600
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, thumbRadius, borderPaint);
  }
}
