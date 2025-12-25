import 'package:salesforce/realm/scheme/schemas.dart';

class DistributorState {
  final bool isLoading;
  final List<Distributor> records;

  const DistributorState({this.isLoading = false, this.records = const []});

  DistributorState copyWith({bool? isLoading, List<Distributor>? records}) {
    return DistributorState(isLoading: isLoading ?? this.isLoading, records: records ?? this.records);
  }
}
