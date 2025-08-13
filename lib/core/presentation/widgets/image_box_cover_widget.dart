import 'package:flutter/material.dart';
import 'package:salesforce/core/presentation/widgets/image_network_widget.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class ImageBoxCoverWidget extends StatelessWidget {
  const ImageBoxCoverWidget({super.key, required this.image});

  final ImageNetWorkWidget image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      key: super.key,
      borderRadius: BorderRadius.circular(15),
      child: Container(key: super.key, color: grey.withAlpha(40), padding: EdgeInsets.all(8.scale), child: image),
    );
  }
}
