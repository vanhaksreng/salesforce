import 'package:salesforce/core/data/datasources/realm/base_realm_data_source_impl.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/features/report/data/datasources/realm/realm_report_data_source.dart';

class RealmReportDataSourceImpl extends BaseRealmDataSourceImpl implements RealmReportDataSource {
  final ILocalStorage ils;
  RealmReportDataSourceImpl({required this.ils}) : super(ils: ils);

  /////
  ///
  ///
  ///
  ///TODO Code bellow
}
