part of 'more_cubit.dart';

class MoreState {
  final bool isLoading;
  final bool isSelectAll;
  final bool refresh;
  final List<AppSyncLog>? records;

  MoreState({
    this.isLoading = false,
    this.isSelectAll = false,
    this.refresh = true,
    this.records,
  });

  MoreState copyWith({
    bool? isLoading,
    bool? isSelectAll,
    bool? refresh,
    List<AppSyncLog>? records,
  }) {
    return MoreState(
      isLoading: isLoading ?? this.isLoading,
      isSelectAll: isSelectAll ?? this.isSelectAll,
      refresh: refresh ?? this.refresh,
      records: records ?? this.records,
    );
  }
}
