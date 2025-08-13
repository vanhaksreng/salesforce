import 'package:salesforce/features/report/domain/entities/item_inventory_report_model.dart';

class ItemInventoryReportState {
  final bool isLoading;
  final String? error;
  final DateTime? fromDate;
  final DateTime? endDate;
  final String? salePersonCode;
  final List<ItemInventoryReportModel> records;
  final String filterNote;
  final bool? isFilter;

  const ItemInventoryReportState({
    this.isLoading = false,
    this.error,
    this.fromDate,
    this.endDate,
    this.salePersonCode,
    this.records = const [],
    this.filterNote = '',
    this.isFilter,
  });

  ItemInventoryReportState copyWith({
    bool? isLoading,
    String? error,
    DateTime? fromDate,
    DateTime? endDate,
    String? salePersonCode,
    String? filterNote,
    List<ItemInventoryReportModel>? records,
    bool? isFilter,
  }) {
    return ItemInventoryReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      salePersonCode: salePersonCode ?? this.salePersonCode,
      fromDate: fromDate ?? this.fromDate,
      endDate: endDate ?? this.endDate,
      filterNote: filterNote ?? this.filterNote,
      records: records ?? this.records,
      isFilter: isFilter ?? this.isFilter,
    );
  }
}
