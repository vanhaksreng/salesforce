import 'package:salesforce/realm/scheme/item_schemas.dart';
import 'package:salesforce/realm/scheme/schemas.dart';
import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CheckStockSubmitPreviewState {
  final bool isLoading;
  final List<CustomerItemLedgerEntry> records;
  final List<Item> items;
  final SalespersonSchedule? schedule;
  final Customer? customer;

  const CheckStockSubmitPreviewState({
    this.isLoading = false,
    this.schedule,
    this.records = const [],
    this.items = const [],
    this.customer,
  });

  CheckStockSubmitPreviewState copyWith({
    bool? isLoading,
    SalespersonSchedule? schedule,
    List<CustomerItemLedgerEntry>? records,
    List<Item>? items,
    Customer? customer,
  }) {
    return CheckStockSubmitPreviewState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      schedule: schedule ?? this.schedule,
      items: items ?? this.items,
      customer: customer ?? this.customer,
    );
  }
}
