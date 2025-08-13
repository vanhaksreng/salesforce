import 'package:flutter/material.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';

class MoreModel {
  final String title;
  final String subTitle;
  final IconData icon;
  final String routeName;
  final Args arg;
  final bool isShow;
  final DefaultProcessArgs? processArg;

  MoreModel({
    this.title = "",
    this.subTitle = "",
    required this.icon,
    required this.routeName,
    required this.arg,
    this.isShow = true,
    this.processArg,
  });
}

class Args {
  final String titelArg;
  final String parentTitle;

  Args({this.titelArg = "", this.parentTitle = ""});
}
