import 'dart:ui';

import 'package:salesforce/theme/app_colors.dart';

Color getStatusColor(String? status) {
  if (status == "Posted") {
    return success;
  } else if (status == "Approved") {
    return warning;
  } else {
    return primary;
  }
}
