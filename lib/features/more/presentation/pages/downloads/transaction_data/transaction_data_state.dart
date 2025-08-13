import 'package:salesforce/features/more/domain/entities/customer_balance.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class TransactionDataState {
  final bool isLoading;
  final List<AppSyncLog>? records;
  final CustomerBalance? cusBalance;

  const TransactionDataState({this.isLoading = false, this.records, this.cusBalance});

  TransactionDataState copyWith({bool? isLoading, List<AppSyncLog>? records, CustomerBalance? cusBalance}) {
    return TransactionDataState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      cusBalance: cusBalance ?? this.cusBalance,
    );
  }
}
