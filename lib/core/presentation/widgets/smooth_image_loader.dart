import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';

class SmoothImageLoader extends StatelessWidget {
  SmoothImageLoader({super.key, this.imageLocal = "", this.height = 150, this.width = 150})
    : _imageFuture = Future.delayed(const Duration(milliseconds: 500));

  final String imageLocal;
  final double height;
  final double width;
  final Future<void> _imageFuture;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _imageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator(strokeWidth: 1);
        } else if (snapshot.connectionState == ConnectionState.done) {
          return Image.asset(
            key: super.key,
            imageLocal,
            height: scaleFontSize(height),
            width: scaleFontSize(width),
            fit: BoxFit.fill,
          );
        } else {
          return Container();
        }
      },
    );
  }
}
