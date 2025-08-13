import 'package:salesforce/features/report/domain/entities/customer_balance_report.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class CustomerBalanceReportState {
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? toDate;
  final bool? isFilter;
  final bool? isClick;
  final String? isSelectedSalesperson;
  final Salesperson? salesperson;
  final List<Salesperson>? recordSalespersons;
  final List<CustomerBalanceReport>? records;

  const CustomerBalanceReportState({
    this.isLoading = false,
    this.error,
    this.startDate,
    this.toDate,
    this.isFilter,
    this.isClick,
    this.isSelectedSalesperson,
    this.salesperson,
    this.recordSalespersons,
    this.records,
  });

  CustomerBalanceReportState copyWith({
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? toDate,
    bool? isFilter,
    bool? isClick,
    String? isSelectedSalesperson,
    Salesperson? salesperson,
    List<Salesperson>? recordSalespersons,
    List<CustomerBalanceReport>? records,
  }) {
    return CustomerBalanceReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      startDate: startDate ?? this.startDate,
      toDate: toDate ?? this.toDate,
      isFilter: isFilter ?? this.isFilter,
      isClick: isClick ?? this.isClick,
      isSelectedSalesperson: isSelectedSalesperson ?? this.isSelectedSalesperson,
      salesperson: salesperson ?? this.salesperson,
      recordSalespersons: recordSalespersons ?? this.recordSalespersons,
      records: records ?? this.records,
    );
  }
}
