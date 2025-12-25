import 'package:salesforce/features/tasks/domain/entities/sale_form_input.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class ItemSaleArg {
  final bool isRefreshing;
  final Customer customer;
  final Item? item;
  final String documentType;

  ItemSaleArg({
    required this.documentType,
    required this.isRefreshing,
    required this.customer,
    this.item,
  });
}

class SaleItemArg {
  final Item item;
  final Customer customer;
  final List<SaleFormInput> inputs;
  final double? discountAmount;
  final double? discountPercentage;
  final double? manualPrice;
  final String remark;
  final String documentType;
  final double itemUnitPrice;

  const SaleItemArg({
    required this.item,
    required this.inputs,
    required this.customer,
    required this.documentType,
    this.discountAmount,
    this.discountPercentage,
    this.manualPrice,
    this.remark = '',
    this.itemUnitPrice = 0,
  });
}
