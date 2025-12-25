import 'package:salesforce/core/constants/constants.dart';
import 'package:salesforce/features/tasks/domain/entities/sale_form_input.dart';
import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';

class SaleFormItemState {
  final bool isLoading;
  final bool canDiscount;
  final bool canModifyPrice;
  final double saleQuantity;
  final String saleUomCode;
  final double freeOfChage;
  final String freeOfChageUomCode;
  final double discountAmt;
  final double discountPercentage;
  final double manualPrice;
  final double itemUnitPrice;
  final List<SaleFormInput> saleForm;
  final List<PosSalesLine> saleLines;
  final SalespersonSchedule? schedule;
  final bool isExistedStd;
  final Item? item;
  final Customer? customer;
  final String documentType;

  const SaleFormItemState({
    this.isLoading = false,
    this.canDiscount = false,
    this.canModifyPrice = false,
    this.saleQuantity = 0,
    this.saleUomCode = "",
    this.freeOfChage = 0,
    this.freeOfChageUomCode = "",
    this.discountAmt = 0,
    this.discountPercentage = 0,
    this.manualPrice = 0,
    this.itemUnitPrice = 0,
    this.saleForm = const [],
    this.isExistedStd = false,
    this.customer,
    this.item,
    this.schedule,
    this.saleLines = const [],
    this.documentType = kSaleOrder,
  });

  SaleFormItemState copyWith({
    bool? isLoading,
    bool? canDiscount,
    bool? canModifyPrice,
    double? saleQuantity,
    String? saleUomCode,
    double? freeOfChage,
    String? freeOfChageUomCode,
    double? discountAmt,
    double? discountPercentage,
    double? manualPrice,
    double? itemUnitPrice,
    List<SaleFormInput>? saleForm,
    bool? isExistedStd,
    Customer? customer,
    Item? item,
    SalespersonSchedule? schedule,
    List<PosSalesLine>? saleLines,
    String? documentType,
  }) {
    return SaleFormItemState(
      isLoading: isLoading ?? this.isLoading,
      canDiscount: canDiscount ?? this.canDiscount,
      canModifyPrice: canModifyPrice ?? this.canModifyPrice,
      saleQuantity: saleQuantity ?? this.saleQuantity,
      saleUomCode: saleUomCode ?? this.saleUomCode,
      freeOfChage: freeOfChage ?? this.freeOfChage,
      freeOfChageUomCode: freeOfChageUomCode ?? this.freeOfChageUomCode,
      discountAmt: discountAmt ?? this.discountAmt,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      manualPrice: manualPrice ?? this.manualPrice,
      saleForm: saleForm ?? this.saleForm,
      isExistedStd: isExistedStd ?? this.isExistedStd,
      customer: customer ?? this.customer,
      item: item ?? this.item,
      itemUnitPrice: itemUnitPrice ?? this.itemUnitPrice,
      saleLines: saleLines ?? this.saleLines,
      documentType: documentType ?? this.documentType,
      schedule: schedule ?? this.schedule,
    );
  }
}
