import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:salesforce/theme/app_colors.dart';

class DottedBorderPainter extends CustomPainter {
  final double radius;

  DottedBorderPainter({this.radius = 8});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = grey
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 5;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, size.width, size.height), Radius.circular(radius)));

    PathMetrics pathMetrics = path.computeMetrics();
    for (PathMetric pathMetric in pathMetrics) {
      double distance = 0;
      while (distance < pathMetric.length) {
        final Path extractPath = pathMetric.extractPath(distance, distance + dashWidth);
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
