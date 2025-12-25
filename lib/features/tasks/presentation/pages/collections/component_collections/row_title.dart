import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';

Row rowCollectionTitle({
  required String key,
  required String value,
  required String key2,
  required String value2,
  Color? valueColor,
  Color? value2Color,
  double fontSize = 15,
}) {
  return Row(
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key,
              style: TextStyle(color: Colors.grey, fontSize: scaleFontSize(fontSize - 3)),
            ),
            Text(
              value,
              style: TextStyle(fontWeight: FontWeight.w700, color: valueColor, fontSize: scaleFontSize(fontSize)),
            ),
          ],
        ),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              key2,
              style: TextStyle(color: Colors.grey, fontSize: scaleFontSize(fontSize - 3)),
            ),
            Text(
              value2,
              style: TextStyle(fontWeight: FontWeight.w700, color: value2Color, fontSize: scaleFontSize(fontSize)),
            ),
          ],
        ),
      ),
    ],
  );
}
