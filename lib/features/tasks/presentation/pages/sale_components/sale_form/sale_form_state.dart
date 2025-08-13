part of 'sale_form_cubit.dart';

class SaleFormState {
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
  final bool isExistedStd;
  final Item? item;
  final Customer? customer;
  final SalespersonSchedule? schedule;
  final String documentType;

  const SaleFormState({
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
    this.schedule,
    this.item,
    this.documentType = kSaleOrder,
    this.saleLines = const [],
  });

  SaleFormState copyWith({
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
    SalespersonSchedule? schedule,
    Item? item,
    String? documentType,
    List<PosSalesLine>? saleLines,
  }) {
    return SaleFormState(
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
      schedule: schedule ?? this.schedule,
      item: item ?? this.item,
      itemUnitPrice: itemUnitPrice ?? this.itemUnitPrice,
      documentType: documentType ?? this.documentType,
      saleLines: saleLines ?? this.saleLines,
    );
  }
}
