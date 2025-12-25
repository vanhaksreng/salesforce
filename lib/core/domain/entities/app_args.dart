import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class BuildUomArg {
  final String? inputLabel;
  final String? modalTitle;
  final String itemNo;
  final String uomCode;
  final Function(String uomCode)? onChanged;
  final VoidCallback? onClose;

  BuildUomArg({
    required this.inputLabel,
    required this.modalTitle,
    required this.itemNo,
    required this.uomCode,
    required this.onChanged,
    this.onClose,
  });
}

class UploadFileArg {
  final List<XFile>? files;
  final Map<String, dynamic>? data;

  UploadFileArg({
    required this.files,
    required this.data,
  });
}
