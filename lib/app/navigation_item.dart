import 'package:flutter/widgets.dart';

class NavigationItem {
  final IconData icon;
  final String label;
  final Widget screen;

  const NavigationItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
