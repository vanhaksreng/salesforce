import 'package:salesforce/infrastructure/network/network_info.dart';
import 'package:salesforce/infrastructure/storage/i_local_storage.dart';
import 'package:salesforce/features/tasks/data/datasources/api/api_task_data_source.dart';
import 'package:salesforce/features/tasks/data/datasources/api/api_task_data_source_impl.dart';
import 'package:salesforce/features/tasks/data/datasources/realm/realm_task_data_source.dart';
import 'package:salesforce/features/tasks/data/datasources/realm/realm_task_data_source_impl.dart';
import 'package:salesforce/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:salesforce/features/tasks/domain/repositories/task_repository.dart';
import 'package:salesforce/injection_container.dart';

Future<void> initTasksInjection() async {
  final networkInfo = getIt<NetworkInfo>();

  // Datasources
  getIt.registerLazySingleton<ApiTaskDataSource>(() => ApiTaskDataSourceImpl(network: networkInfo));

  getIt.registerLazySingleton<RealmTaskDataSource>(() => RealmTaskDataSourceImpl(ils: getIt<ILocalStorage>()));

  // Repository
  getIt.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(
      remote: getIt<ApiTaskDataSource>(),
      local: getIt<RealmTaskDataSource>(),
      networkInfo: networkInfo,
    ),
  );
}
