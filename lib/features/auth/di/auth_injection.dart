import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/features/auth/data/datasources/api/api_auth_data_source.dart';
import 'package:salesforce/features/auth/data/datasources/api/api_auth_data_source_impl.dart';
import 'package:salesforce/features/auth/data/datasources/realm/realm_auth_data_source.dart';
import 'package:salesforce/features/auth/data/datasources/realm/realm_auth_data_source_impl.dart';
import 'package:salesforce/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:salesforce/features/auth/domain/repositories/auth_repository.dart';
import 'package:salesforce/injection_container.dart';

Future<void> initAuthInjection() async {
  final networkInfo = getIt<NetworkInfo>();

  getIt.registerLazySingleton<ApiAuthDataSource>(() => ApiAuthDataSourceImpl(network: networkInfo));

  getIt.registerLazySingleton<RealmAuthDataSource>(() => RealmAuthDataSourceImpl(ils: getIt<ILocalStorage>()));

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: getIt<ApiAuthDataSource>(),
      local: getIt<RealmAuthDataSource>(),
      networkInfo: networkInfo,
    ),
  );
}
