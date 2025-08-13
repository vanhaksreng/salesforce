import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/features/report/data/datasources/api/api_report_data_source.dart';
import 'package:salesforce/features/report/data/datasources/api/api_report_data_source_impl.dart';
import 'package:salesforce/features/report/data/datasources/realm/realm_report_data_source.dart';
import 'package:salesforce/features/report/data/datasources/realm/realm_report_data_source_impl.dart';
import 'package:salesforce/features/report/data/repositories/report_repository_impl.dart';
import 'package:salesforce/features/report/domain/repositories/report_repository.dart';
import 'package:salesforce/injection_container.dart';

Future<void> initReportInjection() async {
  final networkInfo = getIt<NetworkInfo>();

  // Datasources
  getIt.registerLazySingleton<ApiReportDataSource>(() => ApiReportDataSourceImpl(network: networkInfo));

  getIt.registerLazySingleton<RealmReportDataSource>(() => RealmReportDataSourceImpl(ils: getIt<ILocalStorage>()));
  // Repository
  getIt.registerLazySingleton<ReportRepository>(
    () => ReportRepositoryImpl(
      remote: getIt<ApiReportDataSource>(),
      local: getIt<RealmReportDataSource>(),
      networkInfo: networkInfo,
    ),
  );
}
