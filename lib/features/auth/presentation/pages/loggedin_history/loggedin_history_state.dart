import 'package:salesforce/realm/scheme/schemas.dart';

class LoggedinHistoryState {
  final bool isLoading;
  final CompanyInformation? company;

  const LoggedinHistoryState({this.isLoading = false, this.company});

  LoggedinHistoryState copyWith({bool? isLoading, CompanyInformation? company}) {
    return LoggedinHistoryState(isLoading: isLoading ?? this.isLoading, company: company ?? this.company);
  }
}
