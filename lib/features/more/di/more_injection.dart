import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/features/more/data/datasources/api/api_more_data_source.dart';
import 'package:salesforce/features/more/data/datasources/api/api_more_data_source_impl.dart';
import 'package:salesforce/features/more/data/datasources/realm/realm_more_data_source.dart';
import 'package:salesforce/features/more/data/datasources/realm/realm_more_data_source_impl.dart';
import 'package:salesforce/features/more/data/repositories/more_repository_impl.dart';
import 'package:salesforce/features/more/domain/repositories/more_repository.dart';
import 'package:salesforce/injection_container.dart';

Future<void> initMoreInjection() async {
  final networkInfo = getIt<NetworkInfo>();

  // Datasources
  getIt.registerLazySingleton<ApiMoreDataSource>(
    () => ApiMoreDataSourceImpl(network: networkInfo),
  );

  getIt.registerLazySingleton<RealmMoreDataSource>(
    () => RealmMoreDataSourceImpl(ils: getIt<ILocalStorage>()),
  );
  // Repository
  getIt.registerLazySingleton<MoreRepository>(
    () => MoreRepositoryImpl(
      remote: getIt<ApiMoreDataSource>(),
      local: getIt<RealmMoreDataSource>(),
      networkInfo: networkInfo,
    ),
  );
}
