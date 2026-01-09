import 'package:flutter/material.dart';
import 'package:salesforce/core/constants/app_config.dart';
import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';

mixin MessageMixin {
  void showErrorMessage([String msg = errorMessage]) {
    Helpers.showMessage(msg: msg, status: MessageStatus.errors);
    // Logger.log(msg);
  }

  void showSuccessMessage(String msg, {SnackBarAction? action}) {
    Helpers.showMessage(msg: msg, action: action);
  }

  void showWarningMessage(String msg, {SnackBarAction? action}) {
    Helpers.showMessage(
      msg: msg,
      status: MessageStatus.warning,
      action: action,
    );
  }
}
