import 'package:flutter/material.dart';

class StockRequestArg {
  final String documentNo;

  StockRequestArg({required this.documentNo});
}

class ActionConfig {
  final Color color;
  final String name;
  final VoidCallback? action;

  const ActionConfig({
    required this.color,
    required this.name,
    this.action,
  });
}
