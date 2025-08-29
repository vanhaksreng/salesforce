import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CartPreviewItemState {
  final bool isLoading;
  final List<PosSalesLine> saleLines;
  final PosSalesHeader? salesHeader;
  final Item? item;
  final List<Item> items;
  final SalespersonSchedule? schedule;
  final String scheduleId;
  final String documentType;
  final double subTotalAmt;
  final double totalAmt;
  final double totalDiscountAmt;
  final double totalTaxAmt;
  final Customer? customer;
  final List<CustomerLedgerEntry>? customerLedgerEntries;
  final String creditLimitText;

  const CartPreviewItemState({
    this.isLoading = false,
    this.saleLines = const [],
    this.items = const [],
    this.scheduleId = "",
    this.documentType = "",
    this.totalAmt = 0,
    this.totalDiscountAmt = 0,
    this.totalTaxAmt = 0,
    this.subTotalAmt = 0,
    this.item,
    this.schedule,
    this.salesHeader,
    this.customer,
    this.customerLedgerEntries = const [],
    this.creditLimitText = "",
  });

  CartPreviewItemState copyWith({
    bool? isLoading,
    List<PosSalesLine>? saleLines,
    PosSalesHeader? salesHeader,
    String? scheduleId,
    String? documentType,
    double? totalAmt,
    double? totalDiscountAmt,
    double? totalTaxAmt,
    double? subTotalAmt,
    Item? item,
    SalespersonSchedule? schedule,
    List<Item>? items,
    Customer? customer,
    List<CustomerLedgerEntry>? customerLedgerEntries,
    String? creditLimitText,
  }) {
    return CartPreviewItemState(
      isLoading: isLoading ?? this.isLoading,
      saleLines: saleLines ?? this.saleLines,
      scheduleId: scheduleId ?? this.scheduleId,
      documentType: documentType ?? this.documentType,
      item: item ?? this.item,
      schedule: schedule ?? this.schedule,
      totalAmt: totalAmt ?? this.totalAmt,
      totalDiscountAmt: totalDiscountAmt ?? this.totalDiscountAmt,
      totalTaxAmt: totalTaxAmt ?? this.totalTaxAmt,
      subTotalAmt: subTotalAmt ?? this.subTotalAmt,
      items: items ?? this.items,
      salesHeader: salesHeader ?? this.salesHeader,
      customer: customer ?? this.customer,
      customerLedgerEntries:
          customerLedgerEntries ?? this.customerLedgerEntries,
      creditLimitText: creditLimitText ?? this.creditLimitText,
    );
  }
}
