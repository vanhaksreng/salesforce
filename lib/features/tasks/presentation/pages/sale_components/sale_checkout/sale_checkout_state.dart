import 'package:flutter/material.dart';
import 'package:salesforce/realm/scheme/sales_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class SaleCheckoutState {
  final bool isLoading;
  final CustomerAddress? shipmentAddress;
  final PosSalesHeader? saleHeaser;
  final PaymentMethod? paymentMethod;
  final PaymentTerm? paymentTerm;
  final DateTime? pickDate;
  final TextEditingController? distributCtr;
  final String codeDis;
  final Customer? customer;
  final List<CustomerLedgerEntry> customerLedgerEntries;

  const SaleCheckoutState({
    this.isLoading = false,
    this.shipmentAddress,
    this.saleHeaser,
    this.paymentMethod,
    this.paymentTerm,
    this.pickDate,
    this.distributCtr,
    this.codeDis = "",
    this.customer,
    this.customerLedgerEntries = const [],
  });

  SaleCheckoutState copyWith({
    bool? isLoading,
    CustomerAddress? shipmentAddress,
    PosSalesHeader? saleHeaser,
    PaymentMethod? paymentMethod,
    PaymentTerm? paymentTerm,
    DateTime? pickDate,
    TextEditingController? distributCtr,
    String? codeDis,
    Customer? customer,
    List<CustomerLedgerEntry>? customerLedgerEntries,
  }) {
    return SaleCheckoutState(
      isLoading: isLoading ?? this.isLoading,
      shipmentAddress: shipmentAddress ?? this.shipmentAddress,
      saleHeaser: saleHeaser ?? this.saleHeaser,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentTerm: paymentTerm ?? this.paymentTerm,
      pickDate: pickDate ?? this.pickDate,
      distributCtr: distributCtr ?? this.distributCtr,
      codeDis: codeDis ?? this.codeDis,
      customer: customer ?? this.customer,
      customerLedgerEntries: customerLedgerEntries ?? this.customerLedgerEntries,
    );
  }
}
