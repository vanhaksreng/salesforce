import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';
import 'package:salesforce/core/constants/app_assets.dart';

class ImageNetWorkWidget extends StatelessWidget {
  const ImageNetWorkWidget({
    super.key,
    required this.imageUrl,
    this.width = double.infinity,
    this.height,
    this.fit = BoxFit.cover,
    this.round,
    this.topRight = 8,
    this.topLeft = 8,
    this.bottomLeft = 8,
    this.bottomRight = 8,
    this.isShadows = false,
    this.isSide = false,
    this.sideColor = white,
    this.sideWidth = 3,
  });

  final String imageUrl;
  final double width;
  final double? height;
  final BoxFit? fit;
  final double topRight;
  final double topLeft;
  final double bottomLeft;
  final double bottomRight;
  final bool isShadows;
  final bool isSide;
  final double? round;
  final double sideWidth;
  final Color sideColor;

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _buildContainer(_errorImg());
    if (!imageUrl.startsWith('http')) return _buildContainer(_localImg());

    late String img = imageUrl;
    if (img.startsWith('https')) {
      img = imageUrl.replaceAll("https", "http");
    }

    return CachedNetworkImage(
      imageUrl: img,
      imageBuilder: (context, imageProvider) => _buildContainer(_buildImageDecoration(imageProvider)),
      placeholder: (context, url) => _buildContainer(_placeHolderImg()),
      errorWidget: (context, url, error) => _buildContainer(_errorImg()),
    );
  }

  Widget _buildContainer(Widget child) {
    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          side: isSide ? BorderSide(width: sideWidth, color: sideColor) : BorderSide.none,
          borderRadius: _borderRadius(),
        ),
        shadows: isShadows ? [const BoxShadow(color: grey, blurRadius: 90, offset: Offset(0, 4))] : [],
      ),
      child: child,
    );
  }

  Widget _buildImageDecoration(ImageProvider imageProvider) {
    return Image(image: imageProvider, fit: fit, width: width, height: height);
  }

  Widget _placeHolderImg() {
    return Container(
      alignment: Alignment.center,
      child: SizedBox(
        width: scaleFontSize(20),
        height: scaleFontSize(20),
        child: const CircularProgressIndicator(strokeWidth: 1),
      ),
    );
  }

  Widget _errorImg() {
    return Image.asset(kAppEmptyImage, fit: fit, width: width, height: height);
  }

  Widget _localImg() {
    return Image.file(File(imageUrl), fit: fit, width: width, height: height);
  }

  BorderRadius _borderRadius() {
    return round != null
        ? BorderRadius.circular(round!)
        : BorderRadius.only(
            topRight: Radius.circular(topRight),
            topLeft: Radius.circular(topLeft),
            bottomLeft: Radius.circular(bottomLeft),
            bottomRight: Radius.circular(bottomRight),
          );
  }
}
