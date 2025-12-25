class ItemRedemptionBySalespersonReportState {
  final bool isLoading;
  final String? error;
  final DateTime? startDate;
  final DateTime? toDate;
  final bool? isFilter;

  ItemRedemptionBySalespersonReportState({
    this.isLoading = false,
    this.error,
    this.startDate,
    this.toDate,
    this.isFilter,
  });

  ItemRedemptionBySalespersonReportState copyWith({
    bool? isLoading,
    String? error,
    DateTime? startDate,
    DateTime? toDate,
    bool? isFilter,
  }) {
    return ItemRedemptionBySalespersonReportState(
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      startDate: startDate ?? this.startDate,
      toDate: toDate ?? this.toDate,
      isFilter: isFilter ?? this.isFilter,
    );
  }
}
