import 'package:salesforce/core/enums/enums.dart';
import 'package:salesforce/core/utils/helpers.dart';

class DailySaleSumaryReportModel {
  final String code;
  final String name;
  final int noOfOrder;
  final String orderAmount;
  final int noOfInvoices;
  final String invoiceAmount;
  final int noOfCreditMemo;
  final String creditMemoAmount;
  final String salesAmount;
  final String collectionAmount;
  final String target;

  DailySaleSumaryReportModel({
    required this.code,
    required this.name,
    required this.noOfOrder,
    required this.orderAmount,
    required this.noOfInvoices,
    required this.invoiceAmount,
    required this.noOfCreditMemo,
    required this.creditMemoAmount,
    required this.salesAmount,
    required this.collectionAmount,
    required this.target,
  });

  factory DailySaleSumaryReportModel.fromJson(Map<String, dynamic> json) => DailySaleSumaryReportModel(
    code: json["code"],
    name: Helpers.toStrings(json["name"] ?? ""),
    noOfOrder: Helpers.toInt(json["order_counted"] ?? ""),
    orderAmount: Helpers.formatNumberLink(json["order_amount"], option: FormatType.amount),
    noOfInvoices: Helpers.toInt(json["invoice_counted"] ?? ""),
    invoiceAmount: Helpers.formatNumberLink(json["invoice_amount"], option: FormatType.amount),
    noOfCreditMemo: Helpers.toInt(json["credit_memo_counted"] ?? ""),
    creditMemoAmount: Helpers.formatNumberLink(json["credit_memo_amount"], option: FormatType.amount),
    salesAmount: Helpers.formatNumberLink(json["total_sale"], option: FormatType.amount),
    collectionAmount: Helpers.formatNumberLink(json["collection_amount"], option: FormatType.amount),
    target: Helpers.formatNumberLink(json["target"], option: FormatType.amount),
  );

  // Map<String, dynamic> toJson() => {
  //       "code": code,
  //       "name": name,
  //       "no_of_invoices": noOfInvoices,
  //       "no_of_credit_memo": noOfCreditMemo,
  //       "sales_amount": salesAmount,
  //       "sales_credit_memo_amount": salesCreditMemoAmount,
  //       "collection": collection,
  //       "balance": balance,
  //       "sales_cash_on_hand": salesCashOnHand,
  //       "receive_amount": receiveAmount,
  //     };
}
