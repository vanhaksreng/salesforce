import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_styles.dart';
import 'package:salesforce/core/presentation/widgets/btn_wiget.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/helpers.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class AlertDialogBuilderWidget extends StatelessWidget {
  const AlertDialogBuilderWidget({
    super.key,
    this.confirm,
    this.cancel,
    this.cancelText = "cancel",
    this.confirmText = "yes, i'm sure",
    this.labelAction = "Unknow",
    this.subTitle = "",
    this.child,
    this.canCancel = true,
  });

  final String confirmText;
  final String cancelText;
  final Function()? confirm;
  final Function()? cancel;
  final String labelAction;
  final String subTitle;
  final Widget? child;
  final bool canCancel;

  @override
  Widget build(BuildContext context) {
    return _buildAlertDialog(context);
  }

  Widget _buildAlertDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.scale),
      ),
      title: TextWidget(
        textAlign: TextAlign.center,
        text: Helpers.capitalizeWords(labelAction),
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      insetPadding: EdgeInsets.all(scaleFontSize(appSpace)),
      contentPadding: EdgeInsets.fromLTRB(
        16.scale,
        16.scale,
        16.scale,
        24.scale,
      ),
      content: SingleChildScrollView(
        child:
            child ??
            TextWidget(
              textAlign: TextAlign.center,
              text: subTitle,
              fontSize: 14,
            ),
      ),
      actionsOverflowButtonSpacing: scaleFontSize(appSpace),
      actions: [
        if (confirm != null)
          BtnWidget(
            size: BtnSize.medium,
            gradient: linearGradient,
            onPressed: confirm,
            title: Helpers.capitalizeWords(confirmText),
          ),
        if (canCancel)
          BtnWidget(
            size: BtnSize.medium,
            variant: BtnVariant.outline,
            bgColor: white,
            borderColor: error.withAlpha(50),
            textColor: error,
            onPressed: () {
              if (cancel != null) {
                cancel!.call();
              } else {
                Navigator.of(context).pop();
              }
            },
            title: Helpers.capitalizeWords(cancelText),
          ),
      ],
    );
  }
}
