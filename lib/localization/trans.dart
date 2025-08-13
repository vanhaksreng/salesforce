import 'package:flutter/material.dart';
import 'package:salesforce/localization/locals.dart';

class Trans {
  static Locals? locals;
  void init(BuildContext context) {
    locals = Locals.of(context);
  }
}

String greeting(String key, {Map<String, String>? params}) {
  String result = Trans.locals!.greeting(key);

  if (params != null) {
    params.forEach((k, v) {
      result = result.replaceAll(':$k', v);
    });
  }

  return result;
}
