import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/presentation/widgets/text_widget.dart';
import 'package:salesforce/core/utils/get_message_config.dart';
import 'package:salesforce/core/utils/size_config.dart';
import 'package:salesforce/theme/app_colors.dart';

class MessageHelper {
  static MessageConfig getMessageConfig(MessageStatus status) {
    switch (status) {
      case MessageStatus.success:
        return MessageConfig(
          color: success,
          icon: Icons.check_circle_outline,
          duration: Duration(seconds: 4),
        );
      case MessageStatus.warning:
        return MessageConfig(
          color: warning,
          icon: Icons.warning_amber_rounded,
          duration: Duration(seconds: 5),
        );
      case MessageStatus.errors:
        return MessageConfig(
          color: error,
          icon: Icons.error_outline,
          duration: Duration(seconds: 6),
        );
    }
  }

  static SnackBar buildBeautifulSnackBar({
    required String msg,
    required Color color,
    required IconData icon,
    SnackBarAction? action,
    bool closeIcon = true,
    required Duration duration,
  }) {
    return SnackBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      duration: duration,
      margin: EdgeInsets.symmetric(
        horizontal: scaleFontSize(16),
        vertical: scaleFontSize(20),
      ),
      content: Container(
        padding: EdgeInsets.symmetric(
          horizontal: scaleFontSize(16),
          vertical: scaleFontSize(14),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: .85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(scaleFontSize(16)),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: .3),
              blurRadius: 20,
              offset: Offset(0, 8),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: .1),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              padding: EdgeInsets.all(scaleFontSize(8)),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .2),
                borderRadius: BorderRadius.circular(scaleFontSize(8)),
              ),
              child: Icon(icon, color: white, size: scaleFontSize(20)),
            ),
            SizedBox(width: scaleFontSize(12)),

            // Message text
            Expanded(
              child: TextWidget(
                text: msg,
                color: white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            // Action button
            if (action != null) ...[
              SizedBox(width: scaleFontSize(8)),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(scaleFontSize(20)),
                ),
                child: action,
              ),
            ],

            // Close button
            if (closeIcon) ...[
              SizedBox(width: scaleFontSize(8)),
              InkWell(
                onTap: () {
                  final scaffold = kAppScaffoldMsgKey.currentState;
                  scaffold?.hideCurrentSnackBar();
                },
                borderRadius: BorderRadius.circular(scaleFontSize(16)),
                child: Container(
                  padding: EdgeInsets.all(scaleFontSize(6)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(scaleFontSize(12)),
                  ),
                  child: Icon(
                    Icons.close,
                    color: white,
                    size: scaleFontSize(16),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
