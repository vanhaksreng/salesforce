import 'package:flutter/material.dart';

class TabBarItemEntity {
  final String title;
  final bool isActive;
  final VoidCallback? onTap;

  const TabBarItemEntity({
    required this.title,
    this.isActive = false,
    this.onTap,
  });
}
