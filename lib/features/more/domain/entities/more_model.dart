import 'package:flutter/material.dart';
import 'package:salesforce/features/tasks/domain/entities/tasks_arg.dart';

class MoreModel {
  final String title;
  final String subTitle;
  final IconData icon;
  final String routeName;
  final Args arg;
  final bool isShow;
  int countRemainUpload;
  final DefaultProcessArgs? processArg;

  MoreModel({
    this.title = "",
    this.subTitle = "",
    required this.icon,
    required this.routeName,
    required this.arg,
    this.isShow = true,
    this.processArg,
    this.countRemainUpload = 0,
  });
}

class Args {
  final String titelArg;
  final String parentTitle;

  Args({this.titelArg = "", this.parentTitle = ""});
}
