import 'package:salesforce/realm/scheme/tasks_schemas.dart';
import 'package:salesforce/realm/scheme/transaction_schemas.dart';

class CheckStockSubmitPreviewCompetitorItemState {
  final bool isLoading;
  final List<CompetitorItemLedgerEntry> records;
  final SalespersonSchedule? schedule;

  const CheckStockSubmitPreviewCompetitorItemState({this.isLoading = false, this.records = const [], this.schedule});

  CheckStockSubmitPreviewCompetitorItemState copyWith({
    bool? isLoading,
    List<CompetitorItemLedgerEntry>? records,
    SalespersonSchedule? schedule,
  }) {
    return CheckStockSubmitPreviewCompetitorItemState(
      isLoading: isLoading ?? this.isLoading,
      records: records ?? this.records,
      schedule: schedule ?? this.schedule,
    );
  }
}
