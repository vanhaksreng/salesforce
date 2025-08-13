import 'package:salesforce/core/utils/helpers.dart';

class CustomerBalanceReport {
  final String? no;
  final String? name;
  final String? noOfInvoices;
  final String? noOfCreditMemo;
  final String? salesAmount;
  final String? salesCreditMemoAmount;
  final String? collection;
  final String? balance;

  CustomerBalanceReport({
    this.no,
    this.name,
    this.noOfInvoices,
    this.noOfCreditMemo,
    this.salesAmount,
    this.salesCreditMemoAmount,
    this.collection,
    this.balance,
  });

  factory CustomerBalanceReport.fromJson(Map<String, dynamic> json) {
    return CustomerBalanceReport(
      no: json['no'] ?? '',
      name: json['name'] ?? '',
      noOfInvoices: json['no_of_invoices'] ?? '',
      noOfCreditMemo: json['no_of_credit_memo'] ?? '',
      salesAmount: json['sales_amount'] ?? '',
      salesCreditMemoAmount: json['sales_credit_memo_amount'] ?? '',
      collection: json['collection'] ?? '',
      balance: Helpers.toStrings(json['balance'] ?? ""),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no': no,
      'name': name,
      'no_of_invoices': noOfInvoices,
      'no_of_credit_memo': noOfCreditMemo,
      'sales_amount': salesAmount,
      'collection': collection,
      'sales_credit_memo_amount': salesCreditMemoAmount,
      'balance': balance,
    };
  }
}
