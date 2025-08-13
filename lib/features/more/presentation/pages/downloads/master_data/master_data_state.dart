import 'package:salesforce/realm/scheme/schemas.dart';

class MasterDataState {
  final bool isLoading;
  final List<AppSyncLog>? records;

  const MasterDataState({this.isLoading = false, this.records});

  MasterDataState copyWith({bool? isLoading, List<AppSyncLog>? records}) {
    return MasterDataState(isLoading: isLoading ?? this.isLoading, records: records ?? this.records);
  }
}
