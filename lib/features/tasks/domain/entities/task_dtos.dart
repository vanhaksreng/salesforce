import 'package:flutter/material.dart';

class ScheduleOptionData {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final Widget? trailing;

  const ScheduleOptionData({
    required this.label,
    required this.icon,
    required this.onTap,
    this.trailing,
  });
}
