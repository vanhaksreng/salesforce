import 'package:salesforce/features/report/domain/entities/menu_report.dart';
import 'package:salesforce/realm/scheme/schemas.dart';

class MainPageReportState {
  final bool isLoading;
  final Salesperson? salesperson;
  final List<MenuReport> reports;

  const MainPageReportState({this.isLoading = false, this.salesperson, this.reports = const []});

  MainPageReportState copyWith({bool? isLoading, Salesperson? salesperson, List<MenuReport>? reports}) {
    return MainPageReportState(
      isLoading: isLoading ?? this.isLoading,
      salesperson: salesperson ?? this.salesperson,
      reports: reports ?? this.reports,
    );
  }
}
