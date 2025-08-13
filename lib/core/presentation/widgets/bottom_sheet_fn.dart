import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/theme/app_colors.dart';

void modalBottomSheet(
  BuildContext context, {
  required Widget child,
  bool isDismissible = true,
  bool enableDrag = true,
  bool useRoot = true,
  Color? backgroundColor = white,
}) {
  const Radius rounding = appRounding;

  showModalBottomSheet(
    context: context,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    useRootNavigator: useRoot,
    isScrollControlled: true,
    backgroundColor: backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(topLeft: rounding, topRight: rounding),
    ),
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width,
      minWidth: MediaQuery.of(context).size.width,
    ),
    builder: (context) {
      return _KeyboardSafeBottomSheet(child: child);
    },
  );
}

class _KeyboardSafeBottomSheet extends StatelessWidget {
  final Widget child;

  const _KeyboardSafeBottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: SingleChildScrollView(child: child),
      ),
    );
  }
}
