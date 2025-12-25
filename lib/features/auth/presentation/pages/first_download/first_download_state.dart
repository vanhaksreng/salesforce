import 'package:salesforce/realm/scheme/schemas.dart';

class FirstDownloadState {
  final bool isLoading;
  final List<AppSyncLog> tableLogs;
  final String? textLoading;
  final double progressValue;
  final int totalValue;
  final List<String> errors;

  const FirstDownloadState({
    this.isLoading = false,
    this.tableLogs = const [],
    this.textLoading,
    this.progressValue = 1,
    this.totalValue = 0,
    this.errors = const [],
  });

  FirstDownloadState copyWith({
    bool? isLoading,
    List<AppSyncLog>? tableLogs,
    String? textLoading,
    double? progressValue,
    int? totalValue,
    List<String>? errors,
  }) {
    return FirstDownloadState(
      isLoading: isLoading ?? this.isLoading,
      tableLogs: tableLogs ?? this.tableLogs,
      textLoading: textLoading ?? this.textLoading,
      progressValue: progressValue ?? this.progressValue,
      totalValue: totalValue ?? this.totalValue,
      errors: errors ?? this.errors,
    );
  }
}
